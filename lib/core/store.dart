import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'finance.dart';
import 'dart:typed_data';

const categories = ['Groceries','Vegetables','Fruits','Food','Restaurant','Canteen','Tea/Coffee','Shopping','Clothes','Mall','Household','Rent','Maintenance','Electricity','Water','Internet','Mobile Recharge','LPG for Home','Fuel/Petrol','Diesel','CNG for Car','FASTag','Parking','Vehicle Maintenance','Public Transport','Travel','Education','School/College Fees','Hospital','Doctor','Medicine','Insurance','Entertainment','Gifts','Personal Care','Family','Miscellaneous','Salary','Business','Interest','Refund','Gift','Other Income'];

class FinanceStore {
  final Database db;
  FinanceStore(this.db);
  static Future<FinanceStore> open() async => FinanceStore(await openDatabase(
    p.join(await getDatabasesPath(),'rkc_expence.db'),version:3,
    onConfigure:(db)=>db.execute('PRAGMA foreign_keys = ON'),
    onCreate:(db,version) async {await migrateV1(db,1);await migrate(db,1,version);},
    onUpgrade:migrate));

  static Future<void> migrate(Database db,int old,int next) async {
    if(next>3) throw StateError('Unsupported database version.');
    if(old<2 && next>=2) {
      await db.execute('CREATE TABLE budgets(month TEXT NOT NULL, category_id TEXT NOT NULL DEFAULT \'\', amount INTEGER NOT NULL CHECK(amount > 0), PRIMARY KEY(month,category_id))');
    }
    if(old<3 && next>=3) {
      await db.execute('CREATE TABLE attachments(id TEXT PRIMARY KEY, entry_id TEXT NOT NULL REFERENCES entries(id) ON DELETE CASCADE, name TEXT NOT NULL, mime TEXT NOT NULL, data BLOB NOT NULL, created_at TEXT NOT NULL)');
      await db.execute('CREATE INDEX attachments_entry ON attachments(entry_id)');
    }
  }
  Future<List<Map<String,Object?>>> attachments(String entryId)=>db.query('attachments',columns:['id','name','mime','created_at'],where:'entry_id = ?',whereArgs:[entryId],orderBy:'created_at');
  Future<Uint8List> attachmentData(String id) async {
    final rows=await db.query('attachments',columns:['data'],where:'id = ?',whereArgs:[id]);
    if(rows.isEmpty) throw StateError('Attachment no longer exists.');
    return rows.single['data'] as Uint8List;
  }
  Future<void> attach(String entryId,String name,String mime,Uint8List bytes,{String? replaceId}) async {
    if(bytes.isEmpty || bytes.length>20*1024*1024) throw ArgumentError('Choose a non-empty file up to 20 MB.');
    final pdf=bytes.length>=5 && String.fromCharCodes(bytes.take(5))=='%PDF-';
    final jpeg=bytes.length>=3 && bytes[0]==255 && bytes[1]==216 && bytes[2]==255;
    final png=bytes.length>=8 && bytes[0]==137 && bytes[1]==80 && bytes[2]==78 && bytes[3]==71;
    if(!(mime=='application/pdf'&&pdf || mime=='image/jpeg'&&jpeg || mime=='image/png'&&png)) throw ArgumentError('Use a valid JPEG, PNG or PDF file.');
    if(name.trim().isEmpty || name.length>255) throw ArgumentError('Invalid attachment name.');
    await db.transaction((txn) async {
      if((await txn.query('entries',columns:['id'],where:'id = ?',whereArgs:[entryId])).isEmpty) throw ArgumentError('Save the transaction first.');
      final row={'entry_id':entryId,'name':name,'mime':mime,'data':bytes,'created_at':DateTime.now().toUtc().toIso8601String()};
      if(replaceId==null) {await txn.insert('attachments',{'id':const Uuid().v4(),...row});}
      else if(await txn.update('attachments',row,where:'id = ? AND entry_id = ?',whereArgs:[replaceId,entryId])!=1) {throw StateError('Attachment no longer exists.');}
    });
  }
  Future<void> removeAttachment(String id) async {await db.delete('attachments',where:'id = ?',whereArgs:[id]);}
  static String monthKey(DateTime month)=>'${month.year}-${month.month.toString().padLeft(2,'0')}';
  Future<int> budget(DateTime month,{String categoryId=''}) async {
    final rows=await db.query('budgets',where:'month = ? AND category_id = ?',whereArgs:[monthKey(month),categoryId]);
    if(rows.isNotEmpty) return rows.first['amount'] as int;
    if(categoryId.isNotEmpty) return 0;
    final settings=await db.query('settings',where:'key = ?',whereArgs:['budget']);
    return settings.isEmpty?3000000:int.parse(settings.first['value'] as String);
  }
  Future<void> setBudget(DateTime month,int amount,{String categoryId=''}) async {
    if(amount<=0) throw ArgumentError('Budget must be positive.');
    if(categoryId.isNotEmpty && (await db.query('categories',where:'id = ?',whereArgs:[categoryId])).isEmpty) {
      throw ArgumentError('Unknown category.');
    }
    await db.insert('budgets',{'month':monthKey(month),'category_id':categoryId,'amount':amount},conflictAlgorithm:ConflictAlgorithm.replace);
  }

  static Future<void> migrateV1(Database db, int version) async {
    await db.execute('CREATE TABLE accounts(id TEXT PRIMARY KEY, name TEXT NOT NULL, kind TEXT NOT NULL, opening INTEGER NOT NULL DEFAULT 0, archived INTEGER NOT NULL DEFAULT 0)');
    await db.execute('CREATE TABLE categories(id TEXT PRIMARY KEY, name TEXT NOT NULL, archived INTEGER NOT NULL DEFAULT 0)');
    await db.execute('CREATE TABLE entries(id TEXT PRIMARY KEY, kind TEXT NOT NULL, amount INTEGER NOT NULL CHECK(amount > 0), account_id TEXT NOT NULL REFERENCES accounts(id), destination_id TEXT REFERENCES accounts(id), original_id TEXT REFERENCES entries(id), category_id TEXT REFERENCES categories(id), date TEXT NOT NULL, notes TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)');
    await db.execute('CREATE INDEX entries_date ON entries(date)');
    await db.execute('CREATE TABLE settings(key TEXT PRIMARY KEY, value TEXT NOT NULL)');
    await db.insert('settings',{'key':'budget','value':'3000000'});
    for(final kind in ['Cash','Bank','Wallet']) {
      await db.insert('accounts',{'id':const Uuid().v4(),'name':kind,'kind':kind,'opening':0});
    }
    for(final name in categories) {
      await db.insert('categories',{'id':const Uuid().v4(),'name':name});
    }
  }
  Future<List<Map<String,Object?>>> accounts()=>db.query('accounts',orderBy:'name');
  Future<List<Map<String,Object?>>> categoryList({bool includeArchived=false})=>db.query('categories',where:includeArchived?null:'archived = 0',orderBy:'name');
  Future<String> saveAccount({String? id,required String name,required String kind,required int opening}) async {
    if(name.trim().isEmpty || name.trim().length>100 || !['Cash','Bank','Wallet'].contains(kind) || opening.abs()>9007199254740991) throw ArgumentError('Enter a valid account name, type and opening balance.');
    final key=id??const Uuid().v4();
    final row={'name':name.trim(),'kind':kind,'opening':opening};
    if(id==null) {await db.insert('accounts',{'id':key,...row});}
    else if(await db.update('accounts',row,where:'id = ?',whereArgs:[id])!=1) {throw ArgumentError('Account not found.');}
    return key;
  }
  Future<String> saveCategory({String? id,required String name}) async {
    if(name.trim().isEmpty || name.trim().length>100) throw ArgumentError('Enter a category name of 1–100 characters.');
    final key=id??const Uuid().v4();
    if(id==null) {await db.insert('categories',{'id':key,'name':name.trim()});}
    else if(await db.update('categories',{'name':name.trim()},where:'id = ?',whereArgs:[id])!=1) {throw ArgumentError('Category not found.');}
    return key;
  }
  Future<void> archive({required bool account,required String id,required bool archived}) async {
    if(await db.update(account?'accounts':'categories',{'archived':archived?1:0},where:'id = ?',whereArgs:[id])!=1) throw ArgumentError('Record not found.');
  }
  Future<List<Map<String,Object?>>> entries()=>db.query('entries',orderBy:'date DESC, created_at DESC');
  static Posting posting(Map<String,Object?> r)=>Posting(id:r['id'] as String,
    kind:PostingKind.values.byName(r['kind'] as String),amount:r['amount'] as int,
    accountId:r['account_id'] as String,destinationId:r['destination_id'] as String?,
    originalId:r['original_id'] as String?,date:DateTime.parse(r['date'] as String));
  Future<Ledger> ledger(DatabaseExecutor executor) async {
    final accounts=await executor.query('accounts');
    final ledger=Ledger({for(final a in accounts) a['id'] as String:a['opening'] as int});
    final entries=await executor.query('entries');
    for(final e in entries.where((e)=>e['kind']!='refund')) {ledger.put(posting(e));}
    for(final e in entries.where((e)=>e['kind']=='refund')) {ledger.put(posting(e));}
    return ledger;
  }
  Future<void> save(Posting entry,{String? categoryId,String notes=''})=>db.transaction((txn) async {
    (await ledger(txn)).put(entry);
    final previous=await txn.query('entries',where:'id = ?',whereArgs:[entry.id]);
    final old=previous.isEmpty?<String,Object?>{}:previous.first;
    for(final pair in [('accounts',entry.accountId,old['account_id']),('accounts',entry.destinationId,old['destination_id']),('categories',categoryId,old['category_id'])]) {
      if(pair.$2==null) continue;
      final matches=await txn.query(pair.$1,where:'id = ?',whereArgs:[pair.$2]);
      if(matches.isEmpty || (matches.first['archived']==1 && pair.$2!=pair.$3)) throw ArgumentError('Choose an active account or category.');
    }
    final now=DateTime.now().toUtc().toIso8601String();
    final row={'id':entry.id,'kind':entry.kind.name,'amount':entry.amount,
      'account_id':entry.accountId,'destination_id':entry.destinationId,'original_id':entry.originalId,
      'category_id':categoryId,'date':entry.date.toIso8601String(),'notes':notes.trim(),
      'created_at':previous.isEmpty?now:previous.first['created_at'],'updated_at':now};
    if(previous.isEmpty) {await txn.insert('entries',row);}
    else {await txn.update('entries',row,where:'id = ?',whereArgs:[entry.id]);}
  });
  Future<void> delete(String id)=>db.transaction((txn) async {
    (await ledger(txn)).remove(id);
    await txn.delete('entries',where:'id = ?',whereArgs:[id]);
  });
}
