import 'package:flutter/material.dart';
import 'models.dart';
import 'storage.dart';

void main()=>runApp(const WaseemMedicalPro());

String dateOnly(DateTime d)=>d.year.toString().padLeft(4,'0')+'-'+d.month.toString().padLeft(2,'0')+'-'+d.day.toString().padLeft(2,'0');
String idNow()=>DateTime.now().microsecondsSinceEpoch.toString();

class WaseemMedicalPro extends StatelessWidget{
  const WaseemMedicalPro({super.key});
  @override Widget build(BuildContext context)=>MaterialApp(
    debugShowCheckedModeBanner:false,
    title:'نظام وسيم الطبي PRO',
    theme:ThemeData(useMaterial3:true,colorSchemeSeed:const Color(0xFF1565C0),scaffoldBackgroundColor:const Color(0xFFF7F9FC)),
    home:const LoginPage());
}

class LoginPage extends StatefulWidget{const LoginPage({super.key});@override State<LoginPage> createState()=>_LoginPageState();}
class _LoginPageState extends State<LoginPage>{
  final user=TextEditingController(),pass=TextEditingController();
  @override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(body:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:430),child:Column(children:[
    Icon(Icons.local_hospital,size:78,color:Color(0xFF1565C0)),
    SizedBox(height:12),Text('نظام وسيم الطبي PRO',style:TextStyle(fontSize:27,fontWeight:FontWeight.bold)),SizedBox(height:6),
    Text('إدارة مركزك الطبي باحترافية'),SizedBox(height:28),
    TextField(controller:user,decoration:InputDecoration(labelText:'اسم المستخدم',prefixIcon:Icon(Icons.person_outline))),
    SizedBox(height:12),TextField(controller:pass,obscureText:true,decoration:InputDecoration(labelText:'كلمة المرور',prefixIcon:Icon(Icons.lock_outline))),
    SizedBox(height:20),SizedBox(width:double.infinity,height:52,child:FilledButton(onPressed:()=>Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const Dashboard())),child:Text('دخول')))
  ]))))));
}

class Dashboard extends StatefulWidget{const Dashboard({super.key});@override State<Dashboard> createState()=>_DashboardState();}
class _DashboardState extends State<Dashboard>{
  int index=0,version=0;
  final names=['الرئيسية','المرضى','المواعيد','الباقات','الفواتير','الإشعارات'];
  void refresh()=>setState(()=>version++);
  @override Widget build(BuildContext context){
    final pages=[
      HomePage(key:ValueKey('h'+version.toString()),open:(i)=>setState(()=>index=i)),
      PatientsPage(key:ValueKey('p'+version.toString()),changed:refresh),
      AppointmentsPage(key:ValueKey('a'+version.toString()),changed:refresh),
      PackagesPage(key:ValueKey('g'+version.toString()),changed:refresh),
      InvoicesPage(key:ValueKey('i'+version.toString()),changed:refresh),
      NotificationsPage(key:ValueKey('n'+version.toString()))
    ];
    return Directionality(textDirection:TextDirection.rtl,child:Scaffold(
      appBar:AppBar(title:Text(names[index]),actions:[IconButton(onPressed:refresh,icon:const Icon(Icons.refresh))]),
      drawer:Drawer(child:ListView(children:[
        const DrawerHeader(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.end,children:[Icon(Icons.local_hospital,size:42,color:Color(0xFF1565C0)),SizedBox(height:8),Text('نظام وسيم الطبي PRO',style:TextStyle(fontWeight:FontWeight.bold,fontSize:18))])),
        for(int i=0;i<names.length;i++)ListTile(selected:index==i,leading:Icon([Icons.dashboard,Icons.people,Icons.calendar_month,Icons.inventory_2,Icons.receipt_long,Icons.notifications_none][i]),title:Text(names[i]),onTap:(){setState(()=>index=i);Navigator.pop(context);}),
        const Divider(),const ListTile(leading:Icon(Icons.settings_outlined),title:Text('الإعدادات'))
      ])),
      body:pages[index]));
  }
}

class HomePage extends StatelessWidget{
  final void Function(int) open; const HomePage({super.key,required this.open});
  Future<List<int>> stats()async{
    final p=await LocalStore.patients(),a=await LocalStore.appointments(),g=await LocalStore.packages(),i=await LocalStore.invoices();
    final today=dateOnly(DateTime.now());
    return [p.length,a.where((x)=>x.date==today).length,g.fold(0,(s,x)=>s+x.remaining),i.where((x)=>x.remaining>0).length];
  }
  @override Widget build(BuildContext context)=>FutureBuilder<List<int>>(future:stats(),builder:(c,s){
    final v=s.data??[0,0,0,0];
    return ListView(padding:const EdgeInsets.all(16),children:[
      const Text('مرحباً بك 👋',style:TextStyle(fontSize:26,fontWeight:FontWeight.bold)),const SizedBox(height:4),const Text('لوحة التحكم والمتابعة اليومية'),const SizedBox(height:18),
      GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:1.45,children:[StatCard('المرضى',v[0].toString(),Icons.people),StatCard('مواعيد اليوم',v[1].toString(),Icons.event),StatCard('الجلسات المتبقية',v[2].toString(),Icons.medical_services),StatCard('فواتير عليها رصيد',v[3].toString(),Icons.account_balance_wallet)]),
      const SizedBox(height:22),const Text('الوصول السريع',style:TextStyle(fontSize:19,fontWeight:FontWeight.bold)),const SizedBox(height:10),
      Wrap(spacing:8,runSpacing:8,children:[Quick('مريض جديد',Icons.person_add,()=>open(1)),Quick('موعد جديد',Icons.add_alarm,()=>open(2)),Quick('باقة جديدة',Icons.inventory_2,()=>open(3)),Quick('فاتورة جديدة',Icons.receipt_long,()=>open(4))])
    ]);
  });
}
class StatCard extends StatelessWidget{final String title,value;final IconData icon;const StatCard(this.title,this.value,this.icon,{super.key});@override Widget build(BuildContext c)=>Card(child:Padding(padding:const EdgeInsets.all(15),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(icon,color:Theme.of(c).colorScheme.primary),const Spacer(),Text(value,style:const TextStyle(fontSize:25,fontWeight:FontWeight.bold)),Text(title)])));}
class Quick extends StatelessWidget{final String title;final IconData icon;final VoidCallback tap;const Quick(this.title,this.icon,this.tap,{super.key});@override Widget build(BuildContext c)=>FilledButton.tonalIcon(onPressed:tap,icon:Icon(icon),label:Text(title));}

class PatientsPage extends StatefulWidget{final VoidCallback changed;const PatientsPage({super.key,required this.changed});@override State<PatientsPage> createState()=>_PatientsPageState();}
class _PatientsPageState extends State<PatientsPage>{
  String q='';
  Future<void> add()async{
    final r=await Navigator.push<Patient>(context,MaterialPageRoute(builder:(_)=>const PatientForm()));
    if(r==null)return;final list=await LocalStore.patients();list.add(r);await LocalStore.savePatients(list);
    final ns=await LocalStore.notifications();ns.insert(0,AppNotification(id:idNow(),title:'تسجيل مريض جديد',body:'تم تسجيل '+r.name+' برقم الملف '+r.fileNo,channel:'النظام',status:'جاهز',date:dateOnly(DateTime.now())));await LocalStore.saveNotifications(ns);
    setState((){});changed();
  }
  @override Widget build(BuildContext c)=>FutureBuilder<List<Patient>>(future:LocalStore.patients(),builder:(c,s){
    final all=s.data??[];final list=all.where((p)=>p.name.contains(q)||p.fileNo.contains(q)||p.phone.contains(q)).toList();
    return ListView(padding:const EdgeInsets.all(16),children:[
      Row(children:[const Expanded(child:Text('المرضى',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold))),FilledButton.icon(onPressed:add,icon:const Icon(Icons.add),label:const Text('مريض جديد'))]),
      const SizedBox(height:12),TextField(onChanged:(x)=>setState(()=>q=x),decoration:const InputDecoration(hintText:'بحث بالاسم أو رقم الملف أو الهاتف',prefixIcon:Icon(Icons.search))),
      const SizedBox(height:10),if(list.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(30),child:Center(child:Text('لا توجد سجلات')))),
      ...list.map((p)=>Card(child:ListTile(leading:CircleAvatar(child:Text(p.fileNo.replaceAll('P-',''))),title:Text(p.name),subtitle:Text(p.fileNo+' • '+p.phone),trailing:const Icon(Icons.chevron_left),onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>PatientDetails(patient:p))))))
    ]);
  });
}

class PatientForm extends StatefulWidget{const PatientForm({super.key});@override State<PatientForm> createState()=>_PatientFormState();}
class _PatientFormState extends State<PatientForm>{
  final name=TextEditingController(),phone=TextEditingController(),national=TextEditingController(),service=TextEditingController(),doctor=TextEditingController(),address=TextEditingController(),notes=TextEditingController();
  String gender='ذكر',department='العلاج الطبيعي';
  Future<void> save()async{
    if(name.text.trim().isEmpty||phone.text.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أدخل اسم المريض ورقم الهاتف')));return;}
    final n=await LocalStore.nextPatientNumber();
    Navigator.pop(context,Patient(id:idNow(),fileNo:'P-'+n.toString(),name:name.text.trim(),phone:phone.text.trim(),nationalId:national.text.trim(),gender:gender,department:department,service:service.text.trim(),doctor:doctor.text.trim(),address:address.text.trim(),notes:notes.text.trim(),createdAt:dateOnly(DateTime.now())));
  }
  @override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:const Text('تسجيل مريض جديد')),body:ListView(padding:const EdgeInsets.all(16),children:[
    TextField(controller:name,decoration:const InputDecoration(labelText:'اسم المريض *')),const SizedBox(height:10),
    TextField(controller:phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'رقم الهاتف *')),const SizedBox(height:10),
    TextField(controller:national,decoration:const InputDecoration(labelText:'الهوية / الرقم الوطني')),const SizedBox(height:10),
    DropdownButtonFormField(value:gender,decoration:const InputDecoration(labelText:'الجنس'),items:['ذكر','أنثى'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setState(()=>gender=v!)),const SizedBox(height:10),
    TextField(controller:service,decoration:const InputDecoration(labelText:'الخدمة / الشكوى')),const SizedBox(height:10),
    TextField(controller:doctor,decoration:const InputDecoration(labelText:'الطبيب / الأخصائي')),const SizedBox(height:10),
    TextField(controller:address,decoration:const InputDecoration(labelText:'العنوان')),const SizedBox(height:10),
    TextField(controller:notes,maxLines:3,decoration:const InputDecoration(labelText:'ملاحظات')),const SizedBox(height:20),
    SizedBox(height:50,child:FilledButton.icon(onPressed:save,icon:const Icon(Icons.save),label:const Text('حفظ الملف')))
  ]));
}
class PatientDetails extends StatelessWidget{final Patient patient;const PatientDetails({super.key,required this.patient});@override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:Text(patient.fileNo)),body:ListView(padding:const EdgeInsets.all(16),children:[
  Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.person)),title:Text(patient.name,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text(patient.phone))),Info('الجنس',patient.gender),Info('الخدمة',patient.service),Info('الطبيب',patient.doctor),Info('العنوان',patient.address),Info('ملاحظات',patient.notes)
]));}
class Info extends StatelessWidget{final String a,b;const Info(this.a,this.b,{super.key});@override Widget build(BuildContext c)=>Card(child:ListTile(title:Text(a),subtitle:Text(b.isEmpty?'—':b)));}

class AppointmentsPage extends StatefulWidget{final VoidCallback changed;const AppointmentsPage({super.key,required this.changed});@override State<AppointmentsPage> createState()=>_AppointmentsPageState();}
class _AppointmentsPageState extends State<AppointmentsPage>{
  Future<void> add()async{final ps=await LocalStore.patients();if(ps.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف مريضاً أولاً')));return;}final r=await Navigator.push<Appointment>(context,MaterialPageRoute(builder:(_)=>AppointmentForm(patients:ps)));if(r==null)return;final l=await LocalStore.appointments();l.add(r);await LocalStore.saveAppointments(l);setState((){});changed();}
  @override Widget build(BuildContext c)=>FutureBuilder(future:Future.wait([LocalStore.appointments(),LocalStore.patients()]),builder:(c,s){
    if(!s.hasData)return const Center(child:CircularProgressIndicator());final a=s.data![0] as List<Appointment>,ps=s.data![1] as List<Patient>;final today=dateOnly(DateTime.now());final list=a.where((x)=>x.date==today).toList();
    String pname(String id){for(final p in ps){if(p.id==id)return p.name;}return 'غير معروف';}
    return ListView(padding:const EdgeInsets.all(16),children:[Row(children:[const Expanded(child:Text('مواعيد اليوم',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold))),FilledButton.icon(onPressed:add,icon:const Icon(Icons.add),label:const Text('موعد جديد'))]),const SizedBox(height:12),if(list.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(28),child:Center(child:Text('لا توجد مواعيد اليوم')))),...list.map((x)=>Card(child:ListTile(leading:const Icon(Icons.event_available),title:Text(pname(x.patientId)),subtitle:Text(x.time+' • '+x.doctor),trailing:Text(x.status))))]);
  });
}
class AppointmentForm extends StatefulWidget{final List<Patient> patients;const AppointmentForm({super.key,required this.patients});@override State<AppointmentForm> createState()=>_AppointmentFormState();}
class _AppointmentFormState extends State<AppointmentForm>{late String pid;final time=TextEditingController(text:'09:00'),doctor=TextEditingController();@override void initState(){super.initState();pid=widget.patients.first.id;}@override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:const Text('موعد جديد')),body:ListView(padding:const EdgeInsets.all(16),children:[
 DropdownButtonFormField(value:pid,decoration:const InputDecoration(labelText:'المريض'),items:widget.patients.map((p)=>DropdownMenuItem(value:p.id,child:Text(p.fileNo+' - '+p.name))).toList(),onChanged:(v)=>setState(()=>pid=v!)),const SizedBox(height:12),
 TextField(controller:time,decoration:const InputDecoration(labelText:'الوقت')),const SizedBox(height:12),TextField(controller:doctor,decoration:const InputDecoration(labelText:'الطبيب / الأخصائي')),const SizedBox(height:20),
 FilledButton(onPressed:()=>Navigator.pop(c,Appointment(id:idNow(),patientId:pid,date:dateOnly(DateTime.now()),time:time.text,doctor:doctor.text)),child:const Text('حفظ الموعد'))
 ]));}

class PackagesPage extends StatefulWidget{final VoidCallback changed;const PackagesPage({super.key,required this.changed});@override State<PackagesPage> createState()=>_PackagesPageState();}
class _PackagesPageState extends State<PackagesPage>{
  Future<void> add()async{final ps=await LocalStore.patients();if(ps.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف مريضاً أولاً')));return;}final r=await Navigator.push<PackageRecord>(context,MaterialPageRoute(builder:(_)=>PackageForm(patients:ps)));if(r==null)return;final l=await LocalStore.packages();l.add(r);await LocalStore.savePackages(l);setState((){});changed();}
  @override Widget build(BuildContext c)=>FutureBuilder(future:Future.wait([LocalStore.packages(),LocalStore.patients()]),builder:(c,s){if(!s.hasData)return const Center(child:CircularProgressIndicator());final g=s.data![0] as List<PackageRecord>,ps=s.data![1] as List<Patient>;String pname(String id){for(final p in ps){if(p.id==id)return p.name;}return 'غير معروف';}return ListView(padding:const EdgeInsets.all(16),children:[Row(children:[const Expanded(child:Text('الباقات والجلسات',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold))),FilledButton.icon(onPressed:add,icon:const Icon(Icons.add),label:const Text('باقة جديدة'))]),const SizedBox(height:12),if(g.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(28),child:Center(child:Text('لا توجد باقات')))),...g.map((x)=>Card(child:ListTile(title:Text(x.name),subtitle:Text(pname(x.patientId)+' • '+x.remaining.toString()+' جلسة متبقية'),trailing:Text(x.paid.toStringAsFixed(0)+' / '+x.price.toStringAsFixed(0)))))]);});
}
class PackageForm extends StatefulWidget{final List<Patient> patients;const PackageForm({super.key,required this.patients});@override State<PackageForm> createState()=>_PackageFormState();}
class _PackageFormState extends State<PackageForm>{late String pid;final name=TextEditingController(),price=TextEditingController(),paid=TextEditingController(),sessions=TextEditingController();@override void initState(){super.initState();pid=widget.patients.first.id;}@override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:const Text('باقة جديدة')),body:ListView(padding:const EdgeInsets.all(16),children:[
 DropdownButtonFormField(value:pid,decoration:const InputDecoration(labelText:'المريض'),items:widget.patients.map((p)=>DropdownMenuItem(value:p.id,child:Text(p.name))).toList(),onChanged:(v)=>setState(()=>pid=v!)),const SizedBox(height:10),
 TextField(controller:name,decoration:const InputDecoration(labelText:'اسم الباقة')),const SizedBox(height:10),TextField(controller:price,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'السعر')),const SizedBox(height:10),TextField(controller:paid,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'المدفوع')),const SizedBox(height:10),TextField(controller:sessions,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'عدد الجلسات')),const SizedBox(height:20),
 FilledButton(onPressed:(){final s=int.tryParse(sessions.text)??0;Navigator.pop(c,PackageRecord(id:idNow(),patientId:pid,name:name.text,price:double.tryParse(price.text)??0,paid:double.tryParse(paid.text)??0,sessions:s,remaining:s,startDate:dateOnly(DateTime.now()),endDate:dateOnly(DateTime.now().add(const Duration(days:30)))));},child:const Text('حفظ الباقة'))
 ]));}

class InvoicesPage extends StatefulWidget{final VoidCallback changed;const InvoicesPage({super.key,required this.changed});@override State<InvoicesPage> createState()=>_InvoicesPageState();}
class _InvoicesPageState extends State<InvoicesPage>{
 Future<void> add()async{final ps=await LocalStore.patients();if(ps.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف مريضاً أولاً')));return;}final r=await Navigator.push<Invoice>(context,MaterialPageRoute(builder:(_)=>InvoiceForm(patients:ps)));if(r==null)return;final l=await LocalStore.invoices();l.add(r);await LocalStore.saveInvoices(l);setState((){});changed();}
 @override Widget build(BuildContext c)=>FutureBuilder(future:Future.wait([LocalStore.invoices(),LocalStore.patients()]),builder:(c,s){if(!s.hasData)return const Center(child:CircularProgressIndicator());final inv=s.data![0] as List<Invoice>,ps=s.data![1] as List<Patient>;String pname(String id){for(final p in ps){if(p.id==id)return p.name;}return 'غير معروف';}return ListView(padding:const EdgeInsets.all(16),children:[Row(children:[const Expanded(child:Text('الفواتير والمدفوعات',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold))),FilledButton.icon(onPressed:add,icon:const Icon(Icons.add),label:const Text('فاتورة جديدة'))]),const SizedBox(height:12),if(inv.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(28),child:Center(child:Text('لا توجد فواتير')))),...inv.map((x)=>Card(child:ListTile(title:Text(x.number+' • '+pname(x.patientId)),subtitle:Text('الإجمالي: '+x.total.toStringAsFixed(0)+' | المدفوع: '+x.paid.toStringAsFixed(0)),trailing:Text('متبقي '+x.remaining.toStringAsFixed(0)))))]);});
}
class InvoiceForm extends StatefulWidget{final List<Patient> patients;const InvoiceForm({super.key,required this.patients});@override State<InvoiceForm> createState()=>_InvoiceFormState();}
class _InvoiceFormState extends State<InvoiceForm>{late String pid;final total=TextEditingController(),paid=TextEditingController();@override void initState(){super.initState();pid=widget.patients.first.id;}@override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:const Text('فاتورة جديدة')),body:ListView(padding:const EdgeInsets.all(16),children:[
 DropdownButtonFormField(value:pid,decoration:const InputDecoration(labelText:'المريض'),items:widget.patients.map((p)=>DropdownMenuItem(value:p.id,child:Text(p.name))).toList(),onChanged:(v)=>setState(()=>pid=v!)),const SizedBox(height:10),TextField(controller:total,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'الإجمالي')),const SizedBox(height:10),TextField(controller:paid,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'المدفوع')),const SizedBox(height:20),
 FilledButton(onPressed:(){final t=double.tryParse(total.text)??0,p=double.tryParse(paid.text)??0;Navigator.pop(c,Invoice(id:idNow(),patientId:pid,number:'INV-'+DateTime.now().millisecondsSinceEpoch.toString(),total:t,paid:p,date:dateOnly(DateTime.now()),status:p>=t?'مدفوعة':'جزئية'));},child:const Text('حفظ الفاتورة'))
 ]));}

class NotificationsPage extends StatelessWidget{const NotificationsPage({super.key});@override Widget build(BuildContext c)=>FutureBuilder<List<AppNotification>>(future:LocalStore.notifications(),builder:(c,s){final n=s.data??[];return ListView(padding:const EdgeInsets.all(16),children:[const Text('مركز الإشعارات',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),const SizedBox(height:12),if(n.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(30),child:Center(child:Text('لا توجد إشعارات')))),...n.map((x)=>Card(child:ListTile(leading:Icon(x.channel=='WhatsApp'?Icons.chat:Icons.notifications),title:Text(x.title),subtitle:Text(x.body+'\n'+x.date),isThreeLine:true,trailing:Text(x.status))))]);});}
