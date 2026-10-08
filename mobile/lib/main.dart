import 'package:flutter/material.dart';
import 'models.dart';
import 'storage.dart';
import 'pro_pages.dart';

void main()=>runApp(const WaseemMedicalPro());

String dateOnly(DateTime d)=>d.year.toString().padLeft(4,'0')+'-'+d.month.toString().padLeft(2,'0')+'-'+d.day.toString().padLeft(2,'0');
String idNow()=>DateTime.now().microsecondsSinceEpoch.toString();

class WaseemMedicalPro extends StatelessWidget{
  const WaseemMedicalPro({super.key});
  @override Widget build(BuildContext context)=>MaterialApp(
    debugShowCheckedModeBanner:false,
    title:'نظام وسيم الطبي PRO',
    theme:ThemeData(
      useMaterial3:true,
      colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xFF0876D1),brightness:Brightness.light),
      scaffoldBackgroundColor:const Color(0xFFF5F8FC),
      appBarTheme:const AppBarTheme(backgroundColor:Color(0xFF0869B9),foregroundColor:Colors.white,elevation:0,centerTitle:false),
      cardTheme:CardThemeData(elevation:0,margin:EdgeInsets.zero,shape:RoundedRectangleBorder(borderRadius:BorderRadius.all(Radius.circular(18)))),
      inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(14)),borderSide:BorderSide.none),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(14)),borderSide:BorderSide(color:Color(0xFFE2EAF2)),),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(14)),borderSide:BorderSide(color:Color(0xFF0876D1),width:1.5))),
    ),
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
    SizedBox(height:20),SizedBox(width:double.infinity,height:52,child:FilledButton(onPressed:(){if(user.text.trim()!='admin'||pass.text!='1234'){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('بيانات الدخول غير صحيحة')));return;}Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const Dashboard()));},child:Text('دخول')))
  ]))))));
}

class Dashboard extends StatefulWidget{const Dashboard({super.key});@override State<Dashboard> createState()=>_DashboardState();}
class _DashboardState extends State<Dashboard>{
  int index=0,version=0;
  final names=['الرئيسية','المرضى','المواعيد','الباقات','الفواتير','الإشعارات','التقارير','الإعدادات'];
  void refresh()=>setState(()=>version++);
  void go(int i)=>setState(()=>index=i);
  @override Widget build(BuildContext context){
    final pages=[
      HomePage(key:ValueKey('h'+version.toString()),open:go),
      PatientsPage(key:ValueKey('p'+version.toString()),changed:refresh),
      AppointmentsPage(key:ValueKey('a'+version.toString()),changed:refresh),
      PackagesPage(key:ValueKey('g'+version.toString()),changed:refresh),
      InvoicesPage(key:ValueKey('i'+version.toString()),changed:refresh),
      NotificationsPage(key:ValueKey('n'+version.toString())),
      ReportsPage(key:ValueKey('r'+version.toString())),
      SettingsPage(key:ValueKey('s'+version.toString()))
    ];
    return Directionality(textDirection:TextDirection.rtl,child:Scaffold(
      backgroundColor:const Color(0xFFF5F8FC),
      appBar: index==0 ? null : AppBar(
        backgroundColor:const Color(0xFF0869B9),foregroundColor:Colors.white,
        title:Text(names[index],style:const TextStyle(fontWeight:FontWeight.bold)),
        actions:[IconButton(onPressed:refresh,icon:const Icon(Icons.refresh_rounded))]
      ),
      drawer:Drawer(child:ListView(padding:EdgeInsets.zero,children:[
        Container(height:190,padding:const EdgeInsets.fromLTRB(20,35,20,20),decoration:const BoxDecoration(color:Color(0xFF0869B9)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.end,children:[
          Row(children:[Container(width:54,height:54,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16)),child:const Icon(Icons.favorite_border_rounded,size:34,color:Color(0xFF0869B9))),const SizedBox(width:12),const Expanded(child:Text('مركز وسيم الطبي\nWASEEM MEDICAL CENTER',style:TextStyle(color:Colors.white,fontSize:17,fontWeight:FontWeight.bold)))]),
          const SizedBox(height:8),const Text('نظام إدارة المركز الطبي PRO',style:TextStyle(color:Colors.white70))
        ])),
        for(int i=0;i<names.length;i++)ListTile(selected:index==i,selectedColor:const Color(0xFF0869B9),leading:Icon([Icons.home_rounded,Icons.people_alt_rounded,Icons.calendar_month_rounded,Icons.layers_rounded,Icons.receipt_long_rounded,Icons.notifications_rounded,Icons.bar_chart_rounded,Icons.settings_rounded][i]),title:Text(names[i],style:const TextStyle(fontWeight:FontWeight.w600)),onTap:(){go(i);Navigator.pop(context);}})
      ])),
      body:pages[index],
      bottomNavigationBar: index<6 ? NavigationBar(
        selectedIndex:index>4?4:index,
        onDestinationSelected:(i){if(i<5)go(i);},
        backgroundColor:Colors.white,
        destinations:const[
          NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home),label:'الرئيسية'),
          NavigationDestination(icon:Icon(Icons.people_outline),selectedIcon:Icon(Icons.people),label:'المرضى'),
          NavigationDestination(icon:Icon(Icons.calendar_month_outlined),selectedIcon:Icon(Icons.calendar_month),label:'المواعيد'),
          NavigationDestination(icon:Icon(Icons.medical_services_outlined),selectedIcon:Icon(Icons.medical_services),label:'الباقات'),
          NavigationDestination(icon:Icon(Icons.more_horiz),selectedIcon:Icon(Icons.more_horiz),label:'المزيد')
        ]):null
    ));
  }
}

class HomePage extends StatelessWidget{
  final void Function(int) open; const HomePage({super.key,required this.open});
  Future<Map<String,dynamic>> data()async{
    final p=await LocalStore.patients(),a=await LocalStore.appointments(),g=await LocalStore.packages(),i=await LocalStore.invoices();
    final today=dateOnly(DateTime.now());
    return {'patients':p.length,'appointments':a.where((x)=>x.date==today).length,'sessions':g.fold<int>(0,(s,x)=>s+x.remaining),'revenue':i.fold<double>(0,(s,x)=>s+x.paid),'invoices':i.where((x)=>x.remaining>0).length,'todayApps':a.where((x)=>x.date==today).toList(),'patientsList':p};
  }
  @override Widget build(BuildContext context)=>FutureBuilder<Map<String,dynamic>>(future:data(),builder:(c,s){
    final d=s.data??{}; final patients=(d['patientsList'] as List<Patient>?)??[]; final apps=(d['todayApps'] as List<Appointment>?)??[];
    String pname(String id){for(final p in patients){if(p.id==id)return p.name;}return 'مريض';}
    return CustomScrollView(slivers:[
      SliverToBoxAdapter(child:Container(
        padding:const EdgeInsets.fromLTRB(18,18,18,24),
        decoration:const BoxDecoration(color:Color(0xFF0869B9),borderRadius:BorderRadius.only(bottomLeft:Radius.circular(28),bottomRight:Radius.circular(28))),
        child:SafeArea(bottom:false,child:Column(children:[
          Row(children:[
            Builder(builder:(ctx)=>IconButton(onPressed:()=>Scaffold.of(ctx).openDrawer(),color:Colors.white,icon:const Icon(Icons.menu_rounded,size:30))),
            const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('مركز وسيم الطبي',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.bold)),Text('WASEEM MEDICAL CENTER',style:TextStyle(color:Colors.white70,fontSize:11,letterSpacing:1.1))])),
            Stack(children:[IconButton(onPressed:()=>open(5),color:Colors.white,icon:const Icon(Icons.notifications_none_rounded,size:28)),Positioned(right:4,top:4,child:Container(padding:const EdgeInsets.all(4),decoration:const BoxDecoration(color:Color(0xFFFF4D5E),shape:BoxShape.circle),child:const Text('5',style:TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.bold))))])
          ]),
          const SizedBox(height:12),
          Container(width:double.infinity,padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20)),child:const Row(children:[
            CircleAvatar(radius:28,backgroundColor:Color(0xFFE8F3FF),child:Icon(Icons.favorite_rounded,color:Color(0xFF0869B9),size:32)),
            SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('مرحباً بك في مركز وسيم الطبي',style:TextStyle(color:Color(0xFF12395C),fontSize:18,fontWeight:FontWeight.bold)),SizedBox(height:5),Text('إدارة متكاملة لمرضاك ومواعيدك وفواتيرك',style:TextStyle(color:Colors.black54))]))
          ]))
        ]))
      )),
      SliverPadding(padding:const EdgeInsets.fromLTRB(14,16,14,0),sliver:SliverGrid(delegate:SliverChildListDelegate([
        _DashStat('إجمالي المرضى',(d['patients']??0).toString(),Icons.people_alt_rounded,const Color(0xFFEAF4FF),const Color(0xFF0876D1)),
        _DashStat('مواعيد اليوم',(d['appointments']??0).toString(),Icons.calendar_month_rounded,const Color(0xFFEAFBF1),const Color(0xFF16A05D)),
        _DashStat('الجلسات المتبقية',(d['sessions']??0).toString(),Icons.layers_rounded,const Color(0xFFFFF2F5),const Color(0xFFE7385B)),
        _DashStat('إجمالي الإيرادات',(d['revenue']??0).toStringAsFixed(0),Icons.payments_rounded,const Color(0xFFFFF5E9),const Color(0xFFE58B00))
      ]),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:1.75))),
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(16,22,16,10),child:const Text('الوصول السريع',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:Color(0xFF12395C))))),
      SliverPadding(padding:const EdgeInsets.symmetric(horizontal:16),sliver:SliverGrid(delegate:SliverChildListDelegate([
        _QuickTile('المرضى','إدارة ملفات المرضى',Icons.people_alt_rounded,const Color(0xFF0876D1),()=>open(1)),
        _QuickTile('المواعيد','حجز وإدارة المواعيد',Icons.calendar_month_rounded,const Color(0xFFFF4B57),()=>open(2)),
        _QuickTile('الجلسات والباقات','متابعة الجلسات',Icons.layers_rounded,const Color(0xFF7B3FE4),()=>open(3)),
        _QuickTile('الفواتير','إصدار وإدارة الفواتير',Icons.receipt_long_rounded,const Color(0xFF0A9A88),()=>open(4)),
        _QuickTile('المخزون','إدارة الأصناف',Icons.inventory_2_rounded,const Color(0xFFF08A00),()=>open(3)),
        _QuickTile('الطاقم الطبي','إدارة الموظفين',Icons.groups_rounded,const Color(0xFF149B92),()=>open(7)),
        _QuickTile('التقارير','إحصائيات وتقارير',Icons.bar_chart_rounded,const Color(0xFF7040D8),()=>open(6)),
        _QuickTile('الإعدادات','إعدادات المركز',Icons.settings_rounded,const Color(0xFF1677D2),()=>open(7))
      ]),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:1.25))),
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(16,24,16,10),child:Row(children:[const Expanded(child:Text('مواعيد اليوم',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:Color(0xFF12395C)))),TextButton(onPressed:()=>open(2),child:const Text('عرض الكل'))]))),
      SliverPadding(padding:const EdgeInsets.fromLTRB(16,0,16,24),sliver:SliverList(delegate:SliverChildListDelegate([
        if(apps.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(24),child:Center(child:Text('لا توجد مواعيد اليوم')))),
        ...apps.take(5).map((x)=>Card(margin:const EdgeInsets.only(bottom:8),child:ListTile(leading:CircleAvatar(backgroundColor:const Color(0xFFE8F3FF),child:const Icon(Icons.person,color:Color(0xFF0876D1))),title:Text(pname(x.patientId),style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text(x.time+' • '+x.doctor),trailing:Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),decoration:BoxDecoration(color:x.status=='مؤكد'?const Color(0xFFE8F8EF):const Color(0xFFFFF3DF),borderRadius:BorderRadius.circular(10)),child:Text(x.status.isEmpty?'مؤكد':x.status)))
      ])))
    ]);
  });
}
class _DashStat extends StatelessWidget{final String title,value;final IconData icon;final Color bg,fg;const _DashStat(this.title,this.value,this.icon,this.bg,this.fg);@override Widget build(BuildContext c)=>Card(elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),child:Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:bg,borderRadius:BorderRadius.circular(18)),child:Row(children:[Icon(icon,color:fg,size:30),const SizedBox(width:9),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[Text(value,style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:fg),maxLines:1),Text(title,style:const TextStyle(fontSize:11,color:Color(0xFF456174)),maxLines:2)])])));}
class _QuickTile extends StatelessWidget{final String title,sub;final IconData icon;final Color color;final VoidCallback tap;const _QuickTile(this.title,this.sub,this.icon,this.color,this.tap);@override Widget build(BuildContext c)=>Card(elevation:0,child:InkWell(borderRadius:BorderRadius.circular(18),onTap:tap,child:Padding(padding:const EdgeInsets.all(13),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[Container(width:44,height:44,decoration:BoxDecoration(color:color.withOpacity(.12),borderRadius:BorderRadius.circular(13)),child:Icon(icon,color:color)),const SizedBox(height:9),Text(title,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:15)),const SizedBox(height:2),Text(sub,style:const TextStyle(fontSize:11,color:Colors.black54))])));}
class PatientsPage extends StatefulWidget{final VoidCallback changed;const PatientsPage({super.key,required this.changed});@override State<PatientsPage> createState()=>_PatientsPageState();}
class _PatientsPageState extends State<PatientsPage>{
  String q='';
  Future<void> add()async{
    final r=await Navigator.push<Patient>(context,MaterialPageRoute(builder:(_)=>const PatientForm()));
    if(r==null)return;final list=await LocalStore.patients();list.add(r);await LocalStore.savePatients(list);
    final ns=await LocalStore.notifications();ns.insert(0,AppNotification(id:idNow(),title:'تسجيل مريض جديد',body:'تم تسجيل '+r.name+' برقم الملف '+r.fileNo,channel:'النظام',status:'جاهز',date:dateOnly(DateTime.now())));await LocalStore.saveNotifications(ns);
    setState((){});widget.changed();
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
  ])));
}
class PatientDetails extends StatelessWidget{
  final Patient patient;
  const PatientDetails({super.key,required this.patient});
  @override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(
    appBar:AppBar(title:Text(patient.fileNo)),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.person)),title:Text(patient.name,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text(patient.phone))),
      Info('الجنس',patient.gender),Info('الخدمة',patient.service),Info('الطبيب',patient.doctor),Info('العنوان',patient.address),Info('ملاحظات',patient.notes)
    ])
  ));
}
class Info extends StatelessWidget{final String a,b;const Info(this.a,this.b,{super.key});@override Widget build(BuildContext c)=>Card(child:ListTile(title:Text(a),subtitle:Text(b.isEmpty?'—':b)));}

class AppointmentsPage extends StatefulWidget{final VoidCallback changed;const AppointmentsPage({super.key,required this.changed});@override State<AppointmentsPage> createState()=>_AppointmentsPageState();}
class _AppointmentsPageState extends State<AppointmentsPage>{
  Future<void> add()async{final ps=await LocalStore.patients();if(ps.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف مريضاً أولاً')));return;}final r=await Navigator.push<Appointment>(context,MaterialPageRoute(builder:(_)=>AppointmentForm(patients:ps)));if(r==null)return;final l=await LocalStore.appointments();l.add(r);await LocalStore.saveAppointments(l);setState((){});widget.changed();}
  @override Widget build(BuildContext c)=>FutureBuilder(future:Future.wait([LocalStore.appointments(),LocalStore.patients()]),builder:(c,s){
    if(!s.hasData)return const Center(child:CircularProgressIndicator());final a=s.data![0] as List<Appointment>,ps=s.data![1] as List<Patient>;final today=dateOnly(DateTime.now());final list=a.where((x)=>x.date==today).toList();
    String pname(String id){for(final p in ps){if(p.id==id)return p.name;}return 'غير معروف';}
    return ListView(padding:const EdgeInsets.all(16),children:[Row(children:[const Expanded(child:Text('مواعيد اليوم',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold))),FilledButton.icon(onPressed:add,icon:const Icon(Icons.add),label:const Text('موعد جديد'))]),const SizedBox(height:12),if(list.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(28),child:Center(child:Text('لا توجد مواعيد اليوم')))),...list.map((x)=>Card(child:ListTile(leading:const Icon(Icons.event_available),title:Text(pname(x.patientId)),subtitle:Text(x.time+' • '+x.doctor),trailing:Text(x.status))))]);
  });
}
class AppointmentForm extends StatefulWidget{
  final List<Patient> patients;
  const AppointmentForm({super.key,required this.patients});
  @override State<AppointmentForm> createState()=>_AppointmentFormState();
}
class _AppointmentFormState extends State<AppointmentForm>{
  late String pid;
  final time=TextEditingController(text:'09:00'),doctor=TextEditingController();
  @override void initState(){super.initState();pid=widget.patients.first.id;}
  @override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(
    appBar:AppBar(title:const Text('موعد جديد')),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      DropdownButtonFormField(value:pid,decoration:const InputDecoration(labelText:'المريض'),items:widget.patients.map((p)=>DropdownMenuItem(value:p.id,child:Text(p.fileNo+' - '+p.name))).toList(),onChanged:(v)=>setState(()=>pid=v!)),
      const SizedBox(height:12),TextField(controller:time,decoration:const InputDecoration(labelText:'الوقت')),
      const SizedBox(height:12),TextField(controller:doctor,decoration:const InputDecoration(labelText:'الطبيب / الأخصائي')),
      const SizedBox(height:20),FilledButton(onPressed:()=>Navigator.pop(c,Appointment(id:idNow(),patientId:pid,date:dateOnly(DateTime.now()),time:time.text,doctor:doctor.text)),child:const Text('حفظ الموعد'))
    ])
  ));
}
class PackagesPage extends StatefulWidget{final VoidCallback changed;const PackagesPage({super.key,required this.changed});@override State<PackagesPage> createState()=>_PackagesPageState();}
class _PackagesPageState extends State<PackagesPage>{
  Future<void> add()async{
    final ps=await LocalStore.patients();
    if(ps.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف مريضاً أولاً')));return;}
    final r=await Navigator.push<PackageRecord>(context,MaterialPageRoute(builder:(_)=>PackageForm(patients:ps)));
    if(r==null)return;
    final l=await LocalStore.packages();l.add(r);await LocalStore.savePackages(l);setState((){});widget.changed();
  }

  Future<void> registerSession(PackageRecord item)async{
    if(item.remaining<=0){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('لا توجد جلسات متبقية في هذه الباقة')));
      return;
    }
    final list=await LocalStore.packages();
    final index=list.indexWhere((x)=>x.id==item.id);
    if(index<0)return;
    final left=item.remaining-1;
    list[index]=PackageRecord(
      id:item.id,patientId:item.patientId,name:item.name,price:item.price,paid:item.paid,
      sessions:item.sessions,remaining:left,startDate:item.startDate,endDate:item.endDate);
    await LocalStore.savePackages(list);

    final notes=await LocalStore.notifications();
    if(left<=2){
      notes.insert(0,AppNotification(
        id:idNow(),
        title:left==0?'انتهاء الباقة':'تنبيه قرب انتهاء الباقة',
        body:left==0?'انتهت جميع جلسات باقة '+item.name:'تبقى '+left.toString()+' جلسة من باقة '+item.name,
        channel:'النظام',status:'جاهز',date:dateOnly(DateTime.now())));
      await LocalStore.saveNotifications(notes);
    }
    setState((){});widget.changed();
    if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('تم تسجيل الجلسة. المتبقي: '+left.toString())));
  }

  @override Widget build(BuildContext c)=>FutureBuilder(
    future:Future.wait([LocalStore.packages(),LocalStore.patients()]),
    builder:(c,s){
      if(!s.hasData)return const Center(child:CircularProgressIndicator());
      final g=s.data![0] as List<PackageRecord>,ps=s.data![1] as List<Patient>;
      String pname(String id){for(final p in ps){if(p.id==id)return p.name;}return 'غير معروف';}
      return ListView(padding:const EdgeInsets.all(16),children:[
        Row(children:[
          const Expanded(child:Text('الباقات والجلسات',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold))),
          FilledButton.icon(onPressed:add,icon:const Icon(Icons.add),label:const Text('باقة جديدة'))
        ]),
        const SizedBox(height:12),
        if(g.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(28),child:Center(child:Text('لا توجد باقات')))),
        ...g.map((x)=>Card(child:ListTile(
          title:Text(x.name),
          subtitle:Text(pname(x.patientId)+' • '+x.remaining.toString()+' جلسة متبقية'),
          trailing:FilledButton.tonalIcon(
            onPressed:()=>registerSession(x),
            icon:const Icon(Icons.medical_services_outlined),
            label:const Text('تسجيل جلسة'),
          ),
        )))
      ]);
    });
}
class PackageForm extends StatefulWidget{
  final List<Patient> patients;
  const PackageForm({super.key,required this.patients});
  @override State<PackageForm> createState()=>_PackageFormState();
}
class _PackageFormState extends State<PackageForm>{
  late String pid;
  final name=TextEditingController(),price=TextEditingController(),paid=TextEditingController(),sessions=TextEditingController();
  @override void initState(){super.initState();pid=widget.patients.first.id;}
  @override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(
    appBar:AppBar(title:const Text('باقة جديدة')),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      DropdownButtonFormField(value:pid,decoration:const InputDecoration(labelText:'المريض'),items:widget.patients.map((p)=>DropdownMenuItem(value:p.id,child:Text(p.name))).toList(),onChanged:(v)=>setState(()=>pid=v!)),
      const SizedBox(height:10),TextField(controller:name,decoration:const InputDecoration(labelText:'اسم الباقة')),
      const SizedBox(height:10),TextField(controller:price,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'السعر')),
      const SizedBox(height:10),TextField(controller:paid,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'المدفوع')),
      const SizedBox(height:10),TextField(controller:sessions,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'عدد الجلسات')),
      const SizedBox(height:20),FilledButton(onPressed:(){final s=int.tryParse(sessions.text)??0;Navigator.pop(c,PackageRecord(id:idNow(),patientId:pid,name:name.text,price:double.tryParse(price.text)??0,paid:double.tryParse(paid.text)??0,sessions:s,remaining:s,startDate:dateOnly(DateTime.now()),endDate:dateOnly(DateTime.now().add(const Duration(days:30)))));},child:const Text('حفظ الباقة'))
    ])
  ));
}
class InvoicesPage extends StatefulWidget{final VoidCallback changed;const InvoicesPage({super.key,required this.changed});@override State<InvoicesPage> createState()=>_InvoicesPageState();}
class _InvoicesPageState extends State<InvoicesPage>{
 Future<void> add()async{final ps=await LocalStore.patients();if(ps.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف مريضاً أولاً')));return;}final r=await Navigator.push<Invoice>(context,MaterialPageRoute(builder:(_)=>InvoiceForm(patients:ps)));if(r==null)return;final l=await LocalStore.invoices();l.add(r);await LocalStore.saveInvoices(l);setState((){});widget.changed();}
 @override Widget build(BuildContext c)=>FutureBuilder(future:Future.wait([LocalStore.invoices(),LocalStore.patients()]),builder:(c,s){if(!s.hasData)return const Center(child:CircularProgressIndicator());final inv=s.data![0] as List<Invoice>,ps=s.data![1] as List<Patient>;String pname(String id){for(final p in ps){if(p.id==id)return p.name;}return 'غير معروف';}return ListView(padding:const EdgeInsets.all(16),children:[Row(children:[const Expanded(child:Text('الفواتير والمدفوعات',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold))),FilledButton.icon(onPressed:add,icon:const Icon(Icons.add),label:const Text('فاتورة جديدة'))]),const SizedBox(height:12),if(inv.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(28),child:Center(child:Text('لا توجد فواتير')))),...inv.map((x)=>Card(child:ListTile(title:Text(x.number+' • '+pname(x.patientId)),subtitle:Text('الإجمالي: '+x.total.toStringAsFixed(0)+' | المدفوع: '+x.paid.toStringAsFixed(0)),trailing:Text('متبقي '+x.remaining.toStringAsFixed(0)))))]);});
}
class InvoiceForm extends StatefulWidget{
  final List<Patient> patients;
  const InvoiceForm({super.key,required this.patients});
  @override State<InvoiceForm> createState()=>_InvoiceFormState();
}
class _InvoiceFormState extends State<InvoiceForm>{
  late String pid;
  final total=TextEditingController(),paid=TextEditingController();
  @override void initState(){super.initState();pid=widget.patients.first.id;}
  @override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(
    appBar:AppBar(title:const Text('فاتورة جديدة')),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      DropdownButtonFormField(value:pid,decoration:const InputDecoration(labelText:'المريض'),items:widget.patients.map((p)=>DropdownMenuItem(value:p.id,child:Text(p.name))).toList(),onChanged:(v)=>setState(()=>pid=v!)),
      const SizedBox(height:10),TextField(controller:total,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'الإجمالي')),
      const SizedBox(height:10),TextField(controller:paid,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'المدفوع')),
      const SizedBox(height:20),FilledButton(onPressed:(){final t=double.tryParse(total.text)??0,p=double.tryParse(paid.text)??0;Navigator.pop(c,Invoice(id:idNow(),patientId:pid,number:'INV-'+DateTime.now().millisecondsSinceEpoch.toString(),total:t,paid:p,date:dateOnly(DateTime.now()),status:p>=t?'مدفوعة':'جزئية'));},child:const Text('حفظ الفاتورة'))
    ])
  ));
}
class NotificationsPage extends StatelessWidget{const NotificationsPage({super.key});@override Widget build(BuildContext c)=>FutureBuilder<List<AppNotification>>(future:LocalStore.notifications(),builder:(c,s){final n=s.data??[];return ListView(padding:const EdgeInsets.all(16),children:[const Text('مركز الإشعارات',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),const SizedBox(height:12),if(n.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(30),child:Center(child:Text('لا توجد إشعارات')))),...n.map((x)=>Card(child:ListTile(leading:Icon(x.channel=='WhatsApp'?Icons.chat:Icons.notifications),title:Text(x.title),subtitle:Text(x.body+'\n'+x.date),isThreeLine:true,trailing:Text(x.status))))]);});}
