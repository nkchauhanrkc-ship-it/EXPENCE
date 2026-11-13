import 'package:material_ui/material_ui.dart';
import 'core/store.dart';
import 'core/finance.dart';

class ManagementPage extends StatefulWidget {
  final FinanceStore store;
  final bool accounts;
  const ManagementPage({super.key,required this.store,required this.accounts});
  @override State<ManagementPage> createState()=>_ManagementPageState();
}
class _ManagementPageState extends State<ManagementPage> {
  List<Map<String,Object?>> rows=[];
  String? error;
  String query='';
  @override void initState(){super.initState();reload();}
  Future<void> reload() async {
    try{final result=widget.accounts?await widget.store.accounts():await widget.store.categoryList(includeArchived:true);if(mounted)setState((){rows=result;error=null;});}
    catch(e){if(mounted)setState(()=>error='$e');}
  }
  Future<void> edit([Map<String,Object?>? row]) async {
    await Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>_RecordEditor(store:widget.store,account:widget.accounts,row:row)));
    await reload();
  }
  Future<void> archive(Map<String,Object?> row) async {
    final archived=row['archived']==1;
    final yes=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:Text('${archived?'Restore':'Archive'} ${row['name']}?'),content:const Text('Existing transactions and balances are preserved. Archived items cannot be selected for new transactions.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Confirm'))]));
    if(yes!=true)return;
    try{await widget.store.archive(account:widget.accounts,id:row['id'] as String,archived:!archived);await reload();}
    catch(e){if(mounted)setState(()=>error='$e');}
  }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(widget.accounts?'Accounts':'Categories')),
    floatingActionButton:FloatingActionButton.extended(onPressed:()=>edit(),icon:const Icon(Icons.add),label:Text(widget.accounts?'Add account':'Add category')),
    body:ListView(padding:const EdgeInsets.fromLTRB(16,16,16,100),children:[
      TextField(decoration:const InputDecoration(labelText:'Search',prefixIcon:Icon(Icons.search)),onChanged:(v)=>setState(()=>query=v.toLowerCase())),
      if(error!=null)Text(error!),
      ...rows.where((r)=>(r['name'] as String).toLowerCase().contains(query)).map((r)=>ListTile(title:Text(r['name'] as String),subtitle:Text('${widget.accounts?r['kind']: 'Category'}${r['archived']==1?' · Archived':''}'),onTap:()=>edit(r),trailing:IconButton(tooltip:r['archived']==1?'Restore':'Archive',icon:Icon(r['archived']==1?Icons.unarchive_outlined:Icons.archive_outlined),onPressed:()=>archive(r))))
    ]));
}

class _RecordEditor extends StatefulWidget {
  final FinanceStore store;
  final bool account;
  final Map<String,Object?>? row;
  const _RecordEditor({required this.store,required this.account,this.row});
  @override State<_RecordEditor> createState()=>_RecordEditorState();
}
class _RecordEditorState extends State<_RecordEditor> {
  final form=GlobalKey<FormState>();
  late final TextEditingController name,opening;
  late String kind;
  bool saving=false;
  String? error;
  @override void initState(){super.initState();name=TextEditingController(text:widget.row?['name'] as String? ?? '');final n=widget.row?['opening'] as int? ?? 0;opening=TextEditingController(text:'${n<0?'-':''}${n.abs()~/100}.${(n.abs()%100).toString().padLeft(2,'0')}');kind=widget.row?['kind'] as String? ?? 'Cash';}
  @override void dispose(){name.dispose();opening.dispose();super.dispose();}
  int openingValue(){final s=opening.text.trim();if(RegExp(r'^-?0+(\.0{1,2})?$').hasMatch(s))return 0;return s.startsWith('-')?-parseMinorUnits(s.substring(1)):parseMinorUnits(s);}
  Future<void> save() async {
    if(!form.currentState!.validate())return;
    setState(()=>saving=true);
    try{if(widget.account){await widget.store.saveAccount(id:widget.row?['id'] as String?,name:name.text,kind:kind,opening:openingValue());}else{await widget.store.saveCategory(id:widget.row?['id'] as String?,name:name.text);}if(mounted)Navigator.pop(context);}
    catch(e){if(mounted)setState(()=>error='$e');}
    finally{if(mounted)setState(()=>saving=false);}
  }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text('${widget.row==null?'Add':'Edit'} ${widget.account?'account':'category'}')),body:Form(key:form,child:ListView(padding:const EdgeInsets.all(24),children:[
    TextFormField(controller:name,decoration:const InputDecoration(labelText:'Name'),maxLength:100,validator:(v)=>(v??'').trim().isEmpty?'Enter a name':null),
    if(widget.account)...[
      DropdownButtonFormField<String>(initialValue:kind,decoration:const InputDecoration(labelText:'Account type'),items:['Cash','Bank','Wallet'].map((k)=>DropdownMenuItem(value:k,child:Text(k))).toList(),onChanged:(v)=>setState(()=>kind=v!)),
      TextFormField(controller:opening,decoration:const InputDecoration(labelText:'Opening balance (INR)',helperText:'Changing this recalculates your balance; it is not income.'),keyboardType:const TextInputType.numberWithOptions(decimal:true,signed:true),validator:(v){try{openingValue();return null;}catch(_){return 'Enter a valid amount with up to 2 decimal places.';}}),
    ],
    if(error!=null)Text(error!),const SizedBox(height:24),FilledButton(onPressed:saving?null:save,child:Text(saving?'Saving…':'Save'))
  ])));
}
