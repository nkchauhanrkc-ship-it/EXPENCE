import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:file_selector/file_selector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'core/store.dart';

class AttachmentsPage extends StatefulWidget {
  final FinanceStore store;
  final String entryId;
  const AttachmentsPage({super.key,required this.store,required this.entryId});
  @override State<AttachmentsPage> createState()=>_AttachmentsPageState();
}
class _AttachmentsPageState extends State<AttachmentsPage> {
  List<Map<String,Object?>> rows=[];
  String? error;
  bool busy=false;
  @override void initState(){super.initState();reload();}
  Future<void> reload() async {try{final r=await widget.store.attachments(widget.entryId);if(mounted)setState(()=>rows=r);}catch(e){if(mounted)setState(()=>error='$e');}}
  Future<void> pick(String source,{String? replaceId}) async {
    setState((){busy=true;error=null;});
    try{
      List<XFile> files=[];
      if(source=='camera'){final f=await ImagePicker().pickImage(source:ImageSource.camera);if(f!=null)files=[f];}
      else if(source=='gallery'){files=replaceId==null?await ImagePicker().pickMultiImage():[?await ImagePicker().pickImage(source:ImageSource.gallery)];}
      else {files=await openFiles(acceptedTypeGroups:[const XTypeGroup(label:'Bills',extensions:['pdf','jpg','jpeg','png'],mimeTypes:['application/pdf','image/jpeg','image/png'])]);}
      if(replaceId!=null && files.length>1)throw ArgumentError('Choose one file to replace this attachment.');
      for(final file in files){
        if(await file.length()>20*1024*1024)throw ArgumentError('Each bill must be at most 20 MB.');
        final bytes=await file.readAsBytes();
        final mime=bytes.length>=5 && String.fromCharCodes(bytes.take(5))=='%PDF-'?'application/pdf':bytes.isNotEmpty&&bytes[0]==137?'image/png':'image/jpeg';
        await widget.store.attach(widget.entryId,p.basename(file.name),mime,bytes,replaceId:replaceId);
      }
    }catch(e){if(mounted)setState(()=>error='Could not attach bill: $e');}
    finally{await reload();if(mounted)setState(()=>busy=false);}
  }
  Future<void> view(Map<String,Object?> row) async {
    try{
      final bytes=await widget.store.attachmentData(row['id'] as String);
      if(!mounted)return;
      if(row['mime']!='application/pdf'){
        await Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>Scaffold(appBar:AppBar(title:Text(row['name'] as String)),body:Center(child:InteractiveViewer(child:Image.memory(bytes,errorBuilder:(_,e,stack)=>const Text('Unable to display this image.')))))));
      }else{
        final dir=await getTemporaryDirectory();
        final file=File(p.join(dir.path,'${row['id']}.pdf'));await file.writeAsBytes(bytes,flush:true);
        final result=await OpenFilex.open(file.path,type:'application/pdf');
        if(result.type!=ResultType.done)throw StateError(result.message);
      }
    }catch(e){if(mounted)setState(()=>error='Could not open bill: $e');}
  }
  Future<void> remove(String id) async {
    final yes=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Remove this bill?'),content:const Text('The transaction will remain unchanged.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Remove'))]));
    if(yes!=true)return;
    try{await widget.store.removeAttachment(id);await reload();}catch(e){if(mounted)setState(()=>error='$e');}
  }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Bills & receipts')),body:ListView(padding:const EdgeInsets.all(16),children:[
    const Text('Saved privately on this device. JPEG, PNG or PDF; up to 20 MB per file.'),const SizedBox(height:16),
    Wrap(spacing:8,children:[FilledButton.icon(onPressed:busy?null:()=>pick('camera'),icon:const Icon(Icons.camera_alt_outlined),label:const Text('Take photo')),OutlinedButton(onPressed:busy?null:()=>pick('gallery'),child:const Text('Photos')),OutlinedButton(onPressed:busy?null:()=>pick('file'),child:const Text('PDF / file'))]),
    if(busy)const LinearProgressIndicator(),if(error!=null)Text(error!),
    if(rows.isEmpty&&!busy)const Padding(padding:EdgeInsets.all(24),child:Text('No bills attached yet.')),
    ...rows.map((r)=>ListTile(leading:Icon(r['mime']=='application/pdf'?Icons.picture_as_pdf:Icons.receipt_long),title:Text(r['name'] as String),onTap:()=>view(r),trailing:PopupMenuButton<String>(enabled:!busy,onSelected:(v)=>v=='remove'?remove(r['id'] as String):pick('file',replaceId:r['id'] as String),itemBuilder:(_)=>[const PopupMenuItem(value:'replace',child:Text('Replace')),const PopupMenuItem(value:'remove',child:Text('Remove'))])))
  ]));
}
