import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'finance.dart';

const categories = ['Groceries','Vegetables','Fruits','Food','Restaurant','Canteen','Tea/Coffee','Shopping','Clothes','Mall','Household','Rent','Maintenance','Electricity','Water','Internet','Mobile Recharge','LPG for Home','Fuel/Petrol','Diesel','CNG for Car','FASTag','Parking','Vehicle Maintenance','Public Transport','Travel','Education','School/College Fees','Hospital','Doctor','Medicine','Insurance','Entertainment','Gifts','Personal Care','Family','Miscellaneous','Salary','Business','Interest','Refund','Gift','Other Income'];

class FinanceStore {
  final Database db;
  FinanceStore(this.db);
  static Future<FinanceStore> open() async => FinanceStore(await openDatabase(
    p.join(await getDatabasesPath(),'rkc_expence.db'),version:2,
    onConfigure:(db)=>db.execute('PRAGMA foreign_keys = ON'),
    onCreate:(db,version) async {await migrateV1(db,1);await migrate(db,1,version);},
    onUpgrade:migrate));

  static Future<void> migrate(Database db,int old,int next) async {
    if(old<2 && next>=2) {
      await db.execute('CREATE TABLE budgets(month TEXT NOT NULL, category_id TEXT NOT NULL DEFAULT \'\', amount INTEGER NOT NULL CHECK(amount > 0), PRIMARY KEY(month,category_id))');
    }
  }
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
  Future<List<Map<String,Object?>>> categoryList()=>db.query('categories',where:'archived = 0',orderBy:'name');
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
