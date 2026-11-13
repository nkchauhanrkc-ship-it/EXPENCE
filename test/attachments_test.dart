import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:expence/core/store.dart';
import 'package:expence/core/finance.dart';

void main(){
  sqfliteFfiInit();
  test('Attachment migration, replacement and deletion preserve financial totals',() async {
    final db=await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,options:OpenDatabaseOptions(version:1,onCreate:FinanceStore.migrateV1,onConfigure:(db)=>db.execute('PRAGMA foreign_keys = ON')));
    addTearDown(db.close);final store=FinanceStore(db);
    final account=(await store.accounts()).first['id'] as String;
    await store.save(Posting(id:'bill',kind:PostingKind.expense,amount:12345,accountId:account,date:DateTime(2026,11,13)));
    await FinanceStore.migrate(db,1,3);
    final bytes=Uint8List.fromList('%PDF-1.7\nfixture'.codeUnits);
    await store.attach('bill','receipt.pdf','application/pdf',bytes);
    await store.attach('bill','second.pdf','application/pdf',bytes);
    var rows=await store.attachments('bill');expect(rows.length,2);
    final id=rows.first['id'] as String;
    expect(await store.attachmentData(id),bytes);
    await store.attach('bill','replacement.pdf','application/pdf',bytes,replaceId:id);
    expect((await store.attachments('bill')).length,2);
    await expectLater(store.attach('bill','bad.pdf','application/pdf',Uint8List.fromList([1,2,3])),throwsArgumentError);
    await expectLater(store.attach('missing','bill.pdf','application/pdf',bytes),throwsArgumentError);
    expect((await store.ledger(db)).balance(account),-12345);
    await store.removeAttachment(id);expect((await store.attachments('bill')).length,1);
    await store.delete('bill');expect(await store.attachments('bill'),isEmpty);
    expect((await store.ledger(db)).balance(account),0);
  });
}
