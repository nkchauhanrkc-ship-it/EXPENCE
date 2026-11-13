import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:expence/core/store.dart';
import 'package:expence/core/finance.dart';

void main() {
  sqfliteFfiInit();
  test('Account/category management preserves history and rejects new archived use',() async {
    final db=await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,options:OpenDatabaseOptions(version:1,onCreate:FinanceStore.migrateV1));
    addTearDown(db.close);final store=FinanceStore(db);
    final account=await store.saveAccount(name:'Savings bank',kind:'Bank',opening:100000);
    final category=await store.saveCategory(name:'Books');
    Posting entry(String id)=>Posting(id:id,kind:PostingKind.expense,amount:2500,accountId:account,date:DateTime(2026,11,13));
    await store.save(entry('old'),categoryId:category);
    await store.saveAccount(id:account,name:'Renamed bank',kind:'Bank',opening:200000);
    await store.saveCategory(id:category,name:'Reading');
    expect((await store.ledger(db)).balance(account),197500);
    await store.archive(account:true,id:account,archived:true);
    await store.archive(account:false,id:category,archived:true);
    expect((await store.entries()).single['category_id'],category);
    expect((await store.categoryList()).any((c)=>c['id']==category),false);
    await expectLater(store.save(entry('new'),categoryId:category),throwsArgumentError);
    await store.save(entry('old'),categoryId:category,notes:'History remains editable');
    expect((await store.ledger(db)).balance(account),197500);
    await store.archive(account:true,id:account,archived:false);
    await store.archive(account:false,id:category,archived:false);
    await store.save(entry('new'),categoryId:category);
    expect((await store.ledger(db)).balance(account),195000);
    await expectLater(store.saveAccount(name:'',kind:'Bank',opening:0),throwsArgumentError);
  });
  test('Budget migration preserves records and isolates months and categories',() async {
    final db=await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
      options:OpenDatabaseOptions(version:1,onCreate:FinanceStore.migrateV1));
    addTearDown(db.close);
    final store=FinanceStore(db);
    final account=(await store.accounts()).first['id'] as String;
    await store.save(Posting(id:'before-upgrade',kind:PostingKind.income,amount:12345,accountId:account,date:DateTime(2026,11,13)));
    await FinanceStore.migrate(db,1,2);
    expect((await store.ledger(db)).balance(account),12345);
    expect(await store.budget(DateTime(2026,11)),3000000);
    await store.setBudget(DateTime(2026,11),4500000);
    expect(await store.budget(DateTime(2026,11,30)),4500000);
    expect(await store.budget(DateTime(2026,12)),3000000);
    final category=(await store.categoryList()).first['id'] as String;
    await store.setBudget(DateTime(2026,11),200000,categoryId:category);
    expect(await store.budget(DateTime(2026,11),categoryId:category),200000);
    expect(await store.budget(DateTime(2026,11)),4500000);
    await expectLater(store.setBudget(DateTime(2026,11),0),throwsArgumentError);
    await expectLater(store.setBudget(DateTime(2026,11),100,categoryId:'missing'),throwsArgumentError);
  });
  test('SQLite writes, updates, deletes and rejects invalid transfers atomically',() async {
    final db=await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
      options:OpenDatabaseOptions(version:1,onCreate:FinanceStore.migrateV1,
        onConfigure:(db)=>db.execute('PRAGMA foreign_keys = ON')));
    final store=FinanceStore(db);
    try {
      final accounts=await store.accounts();
      final source=accounts.first['id'] as String,target=accounts.last['id'] as String;
      Posting p(int amount,{String? to})=>Posting(id:'fixed',kind:to==null?PostingKind.income:PostingKind.transfer,amount:amount,accountId:source,destinationId:to,date:DateTime(2026,11,12));
      await store.save(p(10000));await store.save(p(25000));
      expect((await store.entries()).length,1);
      expect((await store.ledger(db)).balance(source),25000);
      await expectLater(store.save(p(300,to:'missing')),throwsArgumentError);
      expect((await store.ledger(db)).balance(source),25000);
      await store.save(p(300,to:target));
      final ledger=await store.ledger(db);
      expect(ledger.balance(source),-300);expect(ledger.balance(target),300);
      await store.delete('fixed');expect(await store.entries(),isEmpty);
      expect((await store.categoryList()).length,categories.length);
    } finally {await db.close();}
  });
}
