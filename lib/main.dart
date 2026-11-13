import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';
import 'core/finance.dart';
import 'core/store.dart';
import 'management.dart';
import 'attachments.dart';

void main() { WidgetsFlutterBinding.ensureInitialized(); runApp(const ExpenceApp()); }
String money(int n)=>'${n<0?'-':''}₹${n.abs()~/100}.${(n.abs()%100).toString().padLeft(2,'0')}';
String dateLabel(DateTime d)=>'${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

class ExpenceApp extends StatelessWidget {
  final FinanceStore? store;
  const ExpenceApp({super.key,this.store});
  @override Widget build(BuildContext context)=>MaterialApp(title:'RKC Expence',debugShowCheckedModeBanner:false,
    theme:ThemeData(colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xff18365d)),useMaterial3:true),home:Home(store:store));
}
class Home extends StatefulWidget {
  final FinanceStore? store;
  const Home({super.key,this.store});
  @override State<Home> createState()=>_HomeState();
}
class _HomeState extends State<Home> {
  FinanceStore? store;
  Ledger? ledger;
  List<Map<String,Object?>> accounts=[],entries=[],cats=[];
  String? error;
  String search='';
  int budget=3000000;
  @override void initState() {super.initState();store=widget.store;refresh();}
  Future<void> refresh() async {
    try {
      store ??= await FinanceStore.open();
      final a=await store!.accounts(),e=await store!.entries(),c=await store!.categoryList(includeArchived:true);
      final l=await store!.ledger(store!.db);
      final b=await store!.budget(DateTime.now());
      if(mounted) setState(() {accounts=a;entries=e;cats=c;ledger=l;budget=b;error=null;});
    } catch(e) {if(mounted) setState(()=>error='$e');}
  }
  Future<void> edit([Map<String,Object?>? row]) async {
    final available=accounts.where((a)=>a['archived']==0 || a['id']==row?['account_id'] || a['id']==row?['destination_id']).toList();
    if(available.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Create or restore an account first.')));return;}
    await Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>EntryEditor(store:store!,accounts:available,categories:cats.where((c)=>c['archived']==0 || c['id']==row?['category_id']).toList(),row:row)));
    await refresh();
  }
  Future<void> manage(bool accounts) async {
    await Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>ManagementPage(store:store!,accounts:accounts)));
    await refresh();
  }
  Future<void> editBudget() async {
    final controller=TextEditingController(text:'${budget~/100}.${(budget%100).toString().padLeft(2,'0')}');
    final key=GlobalKey<FormState>();
    final value=await showDialog<int>(context:context,builder:(c)=>AlertDialog(
      title:const Text('This month’s budget'),
      content:Form(key:key,child:TextFormField(controller:controller,autofocus:true,
        keyboardType:const TextInputType.numberWithOptions(decimal:true),
        decoration:const InputDecoration(labelText:'Monthly limit (INR)'),
        validator:(v){try{parseMinorUnits(v?.trim()??'');return null;}catch(_){return 'Enter a positive amount with up to 2 decimal places.';}})),
      actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Cancel')),
        FilledButton(onPressed:(){if(key.currentState!.validate()) Navigator.pop(c,parseMinorUnits(controller.text.trim()));},child:const Text('Save'))]));
    // Dispose after the dialog route has completed its closing animation.
    await Future<void>.delayed(const Duration(milliseconds:300));controller.dispose();
    if(value==null) return;
    try{await store!.setBudget(DateTime.now(),value);await refresh();}
    catch(e){if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Could not save budget: $e')));}
  }
  Future<void> remove(Map<String,Object?> row) async {
    final yes=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Delete transaction?'),content:const Text('Your balances will be recalculated.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Delete'))]));
    if(yes!=true) return;
    try {await store!.delete(row['id'] as String);await refresh();}
    catch(e) {if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$e')));}
  }
  @override Widget build(BuildContext context) {
    final now=DateTime.now();
    final spending=ledger?.expenses(DateTime(now.year,now.month),DateTime(now.year,now.month+1))??0;
    final total=accounts.fold(0,(int n,a)=>n+(ledger?.balance(a['id'] as String)??0));
    return Scaffold(appBar:AppBar(title:const Text('RKC Expence'),actions:[IconButton(tooltip:'Refresh',onPressed:refresh,icon:const Icon(Icons.refresh))]),
      floatingActionButton:FloatingActionButton.extended(onPressed:accounts.isEmpty?null:()=>edit(),icon:const Icon(Icons.add),label:const Text('Transaction')),
      body:RefreshIndicator(onRefresh:refresh,child:ListView(padding:EdgeInsets.fromLTRB(MediaQuery.sizeOf(context).width>900?80:16,16,MediaQuery.sizeOf(context).width>900?80:16,100),children:[
        const Text('YOUR MONEY, CLEARLY',style:TextStyle(letterSpacing:2)),const SizedBox(height:12),
        Card(color:Theme.of(context).colorScheme.primaryContainer,child:Padding(padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Available balance'),Text(money(total),style:Theme.of(context).textTheme.headlineLarge),const SizedBox(height:12),const Text('On this device • Offline mode')]))),
        if(error!=null) Text('Unable to open local data: $error'),
        if(ledger==null && error==null) const LinearProgressIndicator(),
        Wrap(spacing:8,children:[OutlinedButton(onPressed:store==null?null:()=>manage(true),child:const Text('Manage accounts')),OutlinedButton(onPressed:store==null?null:()=>manage(false),child:const Text('Manage categories'))]),
        Wrap(spacing:8,runSpacing:8,children:accounts.map((a)=>Chip(label:Text('${a['name']}  ${money(ledger?.balance(a['id'] as String)??0)}'))).toList()),
        const SizedBox(height:20),Text('Monthly budget',style:Theme.of(context).textTheme.titleLarge),Text('${money(spending)} spent of ${money(budget)}'),
        Align(alignment:Alignment.centerLeft,child:TextButton.icon(onPressed:store==null?null:editBudget,icon:const Icon(Icons.edit_outlined),label:const Text('Edit monthly budget'))),
        const SizedBox(height:8),LinearProgressIndicator(value:(spending/budget).clamp(0,1)),Text('${money(budget-spending)} remaining'),
        const SizedBox(height:24),Text('Transactions',style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:12),
        TextField(decoration:const InputDecoration(prefixIcon:Icon(Icons.search),labelText:'Search notes or type',border:OutlineInputBorder()),onChanged:(v)=>setState(()=>search=v.toLowerCase())),
        if(entries.isEmpty) const Padding(padding:EdgeInsets.symmetric(vertical:40),child:Text('No transactions yet. Add your first income or expense.')),
        ...entries.where((e)=>'${e['notes']} ${e['kind']}'.toLowerCase().contains(search)).map((e)=>Card(child:ListTile(leading:Icon(e['kind']=='income'?Icons.south_west:e['kind']=='transfer'?Icons.swap_horiz:Icons.north_east),title:Text('${e['kind']} · ${money(e['amount'] as int)}'),subtitle:Text('${dateLabel(DateTime.parse(e['date'] as String))} · ${e['notes']}'),onTap:()=>edit(e),trailing:IconButton(tooltip:'Delete transaction',onPressed:()=>remove(e),icon:const Icon(Icons.delete_outline))))),
      ])));
  }
}
class EntryEditor extends StatefulWidget {
  final FinanceStore store;
  final List<Map<String,Object?>> accounts,categories;
  final Map<String,Object?>? row;
  const EntryEditor({super.key,required this.store,required this.accounts,required this.categories,this.row});
  @override State<EntryEditor> createState()=>_EntryEditorState();
}
class _EntryEditorState extends State<EntryEditor> {
  late final String entryId;
  final form=GlobalKey<FormState>();
  late final TextEditingController amount,notes;
  late String account;
  String? destination,category,error;
  late PostingKind kind;
  late DateTime date;
  bool saving=false;
  @override void initState() {
    super.initState();final r=widget.row;
    entryId=r?['id'] as String? ?? const Uuid().v4();
    amount=TextEditingController(text:r==null?'':'${(r['amount'] as int)~/100}.${((r['amount'] as int)%100).toString().padLeft(2,'0')}');
    notes=TextEditingController(text:r?['notes'] as String? ?? '');
    account=r?['account_id'] as String? ?? widget.accounts.first['id'] as String;
    destination=r?['destination_id'] as String?;category=r?['category_id'] as String?;
    kind=r==null?PostingKind.expense:PostingKind.values.byName(r['kind'] as String);
    date=r==null?DateTime.now():DateTime.parse(r['date'] as String);
  }
  @override void dispose() {amount.dispose();notes.dispose();super.dispose();}
  Future<void> save({bool attach=false}) async {
    if(!form.currentState!.validate()) return;
    setState(() {saving=true;error=null;});
    try {
      await widget.store.save(Posting(id:entryId,kind:kind,amount:parseMinorUnits(amount.text.trim()),accountId:account,date:date,destinationId:kind==PostingKind.transfer?destination:null),categoryId:category,notes:notes.text);
      if(attach && mounted) await Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>AttachmentsPage(store:widget.store,entryId:entryId)));
      if(mounted) Navigator.pop(context);
    } catch(e) {if(mounted) setState(()=>error='$e');}
    finally {if(mounted) setState(()=>saving=false);}
  }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(widget.row==null?'Add transaction':'Edit transaction')),body:Form(key:form,child:ListView(padding:const EdgeInsets.all(24),children:[
    DropdownButtonFormField<PostingKind>(initialValue:kind,decoration:const InputDecoration(labelText:'Type'),items:[PostingKind.expense,PostingKind.income,PostingKind.transfer].map((k)=>DropdownMenuItem(value:k,child:Text(k.name))).toList(),onChanged:saving?null:(v)=>setState(()=>kind=v!)),
    TextFormField(controller:amount,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Amount (INR)'),validator:(v){try {parseMinorUnits(v?.trim()??'');return null;}catch(e){return 'Enter a positive amount with up to 2 decimal places.';}}),
    DropdownButtonFormField<String>(initialValue:account,decoration:const InputDecoration(labelText:'Account'),items:widget.accounts.map((a)=>DropdownMenuItem(value:a['id'] as String,child:Text(a['name'] as String))).toList(),onChanged:(v)=>setState(()=>account=v!)),
    if(kind==PostingKind.transfer) DropdownButtonFormField<String>(initialValue:destination,decoration:const InputDecoration(labelText:'Destination account'),items:widget.accounts.map((a)=>DropdownMenuItem(value:a['id'] as String,child:Text(a['name'] as String))).toList(),onChanged:(v)=>setState(()=>destination=v),validator:(v)=>v==null||v==account?'Choose a different account':null),
    if(kind!=PostingKind.transfer) DropdownButtonFormField<String>(initialValue:category,decoration:const InputDecoration(labelText:'Category'),items:widget.categories.map((a)=>DropdownMenuItem(value:a['id'] as String,child:Text(a['name'] as String))).toList(),onChanged:(v)=>setState(()=>category=v)),
    const SizedBox(height:16),OutlinedButton.icon(icon:const Icon(Icons.calendar_month),label:Text(dateLabel(date)),onPressed:()async {final d=await showDatePicker(context:context,initialDate:date,firstDate:DateTime(1900),lastDate:DateTime(2200));if(d!=null&&mounted) setState(()=>date=DateTime(d.year,d.month,d.day,date.hour,date.minute));}),
    TextFormField(controller:notes,decoration:const InputDecoration(labelText:'Notes (optional)'),maxLength:2000,maxLines:3),
    if(error!=null) Text(error!,style:TextStyle(color:Theme.of(context).colorScheme.error)),const SizedBox(height:24),FilledButton(onPressed:saving?null:save,child:Text(saving?'Saving…':'Save transaction')),
    OutlinedButton.icon(onPressed:saving?null:()=>save(attach:true),icon:const Icon(Icons.attach_file),label:const Text('Save & manage bills')),
  ])));
}
