import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:expence/core/store.dart';
import 'package:expence/main.dart';

void main() {
  sqfliteFfiInit();
  testWidgets('Enter income and edit it with persistent balances', (tester) async {
    final db=await databaseFactoryFfiNoIsolate.openDatabase(inMemoryDatabasePath,
      options:OpenDatabaseOptions(version:1,onCreate:FinanceStore.migrateV1));
    addTearDown(db.close);
    await tester.pumpWidget(ExpenceApp(store:FinanceStore(db)));
    await tester.pumpAndSettle();
    expect(find.text('RKC Expence'),findsOneWidget);
    expect(find.text('No transactions yet. Add your first income or expense.'),findsOneWidget);
    await tester.tap(find.text('Transaction'));await tester.pumpAndSettle();
    await tester.tap(find.text('expense'));await tester.pumpAndSettle();
    await tester.tap(find.text('income').last);await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first,'2500.50');
    await tester.ensureVisible(find.text('Save transaction'));
    await tester.tap(find.text('Save transaction'));await tester.pumpAndSettle();
    expect(find.text('₹2500.50'),findsOneWidget);
    expect((await db.query('entries')).single['amount'],250050);
    await tester.tap(find.text('income · ₹2500.50'));await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first,'100');
    await tester.ensureVisible(find.text('Save transaction'));
    await tester.tap(find.text('Save transaction'));await tester.pumpAndSettle();
    expect(find.text('₹100.00'),findsOneWidget);
    expect((await db.query('entries')).length,1);
    expect(tester.takeException(),isNull);
  });
}
