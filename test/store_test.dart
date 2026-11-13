import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:expence/core/store.dart';
import 'package:expence/core/finance.dart';

void main() {
  sqfliteFfiInit();
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
