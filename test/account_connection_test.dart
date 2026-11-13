import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:expence/account_connection.dart';

class FakeConnection implements AccountConnection {
  bool fail=false;
  int signOuts=0;
  @override Future<String?> initialize() async=>null;
  @override Future<String?> connect() async {if(fail)throw StateError('offline');return 'tester@example.com';}
  @override Future<void> disconnect() async {signOuts++;}
}
void main(){
  testWidgets('Connect, confirm sign out and recover from failure',(tester)async {
    final connection=FakeConnection();
    await tester.pumpWidget(MaterialApp(home:AccountConnectionPage(connection:connection)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with Google'));await tester.pumpAndSettle();
    expect(find.text('tester@example.com'),findsOneWidget);
    await tester.tap(find.text('Sign out'));await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));await tester.pumpAndSettle();
    expect(connection.signOuts,0);
    await tester.tap(find.text('Sign out'));await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out').last);await tester.pumpAndSettle();
    expect(connection.signOuts,1);
    connection.fail=true;
    await tester.tap(find.text('Continue with Google'));await tester.pumpAndSettle();
    expect(find.textContaining('Local records are still available'),findsOneWidget);
    expect(find.text('Back to local records'),findsOneWidget);
  });
}
