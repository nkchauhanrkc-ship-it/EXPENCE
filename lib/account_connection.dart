import 'package:material_ui/material_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AccountConnection {
  Future<String?> initialize();
  Future<String?> connect();
  Future<void> disconnect();
}

class GoogleAccountConnection implements AccountConnection {
  static Future<void>? _googleInitialization;
  Future<void> _ready() async {
    if(Firebase.apps.isEmpty) await Firebase.initializeApp();
    if(Firebase.app().options.projectId!='expense-8468') throw StateError('This build has the wrong Firebase project configuration.');
  }
  @override Future<String?> initialize() async {await _ready();return FirebaseAuth.instance.currentUser?.email;}
  @override Future<String?> connect() async {
    await _ready();
    try {
      await (_googleInitialization??=GoogleSignIn.instance.initialize());
    } catch (_) {_googleInitialization=null;rethrow;}
    final account=await GoogleSignIn.instance.authenticate();
    final token=account.authentication.idToken;
    if(token==null) throw StateError('Google did not return a sign-in token. Please try again.');
    final result=await FirebaseAuth.instance.signInWithCredential(GoogleAuthProvider.credential(idToken:token));
    return result.user?.email;
  }
  @override Future<void> disconnect() async {
    await FirebaseAuth.instance.signOut();
    if(_googleInitialization!=null) await GoogleSignIn.instance.signOut();
  }
}

class AccountConnectionPage extends StatefulWidget {
  final AccountConnection? connection;
  const AccountConnectionPage({super.key,this.connection});
  @override State<AccountConnectionPage> createState()=>_AccountConnectionPageState();
}
class _AccountConnectionPageState extends State<AccountConnectionPage> {
  late final AccountConnection connection=widget.connection??GoogleAccountConnection();
  String? email,error;
  bool busy=true;
  @override void initState(){super.initState();run(connection.initialize);}
  Future<void> run(Future<String?> Function() action) async {
    setState((){busy=true;error=null;});
    try{final result=await action();if(mounted)setState(()=>email=result);}
    on GoogleSignInException catch(e){if(mounted && e.code!=GoogleSignInExceptionCode.canceled)setState(()=>error='Google sign-in could not finish. Check your connection and try again. (${e.code.name})');}
    on FirebaseAuthException catch(e){if(mounted)setState(()=>error=e.code=='network-request-failed'?'No connection. You can continue using local records offline.':'Sign-in failed (${e.code}). Please try again.');}
    catch(_){if(mounted)setState(()=>error='Account connection is unavailable. Check your internet connection and Firebase configuration. Local records are still available.');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  Future<void> disconnect() async {
    final yes=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Sign out?'),content:const Text('Records stay on this device. Anyone using this app on this phone can still access them.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Sign out'))]));
    if(yes==true)await run(() async {await connection.disconnect();return null;});
  }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Account connection')),body:ListView(padding:const EdgeInsets.all(24),children:[
    const Icon(Icons.account_circle_outlined,size:64),const SizedBox(height:16),
    Text(email??'Use RKC Expence offline',style:Theme.of(context).textTheme.titleLarge),
    const SizedBox(height:12),const Text('Google sign-in connects your identity. Synchronization and family sharing are not available in this build. Your financial records and bills remain on this device.'),
    const SizedBox(height:12),const Text('Only basic Google sign-in is requested. No Drive, Gmail or contacts access.'),
    if(error!=null)Padding(padding:const EdgeInsets.symmetric(vertical:16),child:Text(error!)),
    if(busy)const LinearProgressIndicator(),const SizedBox(height:24),
    if(email==null)FilledButton(onPressed:busy?null:()=>run(connection.connect),child:const Text('Continue with Google'))
    else OutlinedButton(onPressed:busy?null:disconnect,child:const Text('Sign out')),
    TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Back to local records')),
  ]));
}
