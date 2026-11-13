import 'package:flutter_test/flutter_test.dart';
import 'package:expence/core/finance.dart';

void main() {
  final date=DateTime(2026,11,12);
  Posting entry(String id,PostingKind kind,int amount,{String? to,String? original})=>Posting(id:id,kind:kind,amount:amount,accountId:'cash',destinationId:to,originalId:original,date:date);
  test('Amount parsing uses integer paise and rejects invalid precision',() {
    expect(parseMinorUnits('123.45'),12345);
    expect(parseMinorUnits('0.01'),1);
    for(final s in ['0','-1','1.001','NaN','1e4','']) {expect(()=>parseMinorUnits(s),throwsFormatException);}
  });
  test('Transfers conserve total balance and never count as expenses',() {
    final l=Ledger({'cash':10000,'bank':20000});
    l.put(entry('t',PostingKind.transfer,2500,to:'bank'));
    expect(l.balance('cash'),7500);expect(l.balance('bank'),22500);
    expect(l.expenses(DateTime(2026),DateTime(2027)),0);
  });
  test('Updates and deletes recalculate without duplicate postings',() {
    final l=Ledger({'cash':10000});
    l.put(entry('a',PostingKind.expense,100));l.put(entry('a',PostingKind.expense,250));
    expect(l.balance('cash'),9750);l.remove('a');expect(l.balance('cash'),10000);
  });
  test('Partial refunds reduce spending and cannot exceed original',() {
    final l=Ledger({'cash':10000});l.put(entry('a',PostingKind.expense,1000));
    l.put(entry('r',PostingKind.refund,400,original:'a'));
    expect(l.balance('cash'),9400);expect(l.expenses(DateTime(2026),DateTime(2027)),600);
    expect(()=>l.put(entry('r2',PostingKind.refund,601,original:'a')),throwsArgumentError);
    expect(()=>l.remove('a'),throwsStateError);
    expect(()=>l.put(entry('a',PostingKind.expense,399)),throwsArgumentError);
  });
  test('Goal allocations and debt principal never inflate ordinary spending',() {
    final l=Ledger({'cash':10000});l.put(entry('g',PostingKind.goalAllocation,300));
    l.put(entry('d',PostingKind.debtPrincipal,1000));
    expect(l.balance('cash'),9000);expect(l.expenses(DateTime(2026),DateTime(2027)),0);
  });
  test('All half-month periods cover each day across leap and common years',() {
    for(final year in [2024,2025,2026,2028]) {
      for(var month=1;month<=12;month++) {
        final last=DateTime(year,month+1,0).day;
        for(var day=1;day<=last;day++) {
          final date=DateTime(year,month,day);
          final (start,end)=fortnight(date);
          expect(!date.isBefore(start)&&date.isBefore(end),isTrue);
          expect(start.day,day<=15?1:16);
          expect(end,day<=15?DateTime(year,month,16):DateTime(year,month+1));
        }
      }
    }
  });
}
