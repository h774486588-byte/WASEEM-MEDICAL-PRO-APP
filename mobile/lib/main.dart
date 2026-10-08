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
class PatientsPage extends StatefulWidget{
  final VoidCallback changed;
  const PatientsPage({super.key,required this.changed});
  @override State<PatientsPage> createState()=>_PatientsPageState();
}
class _PatientsPageState extends State<PatientsPage>{
  String q='';
  Future<void> add()async{
    final r=await Navigator.push<Patient>(context,MaterialPageRoute(builder:(_)=>const PatientForm()));
    if(r==null)return;
    final list=await LocalStore.patients();list.add(r);await LocalStore.savePatients(list);
    final ns=await LocalStore.notifications();
    ns.insert(0,AppNotification(id:idNow(),title:'تسجيل مريض جديد',body:'تم تسجيل '+r.name+' برقم الملف '+r.fileNo,channel:'النظام',status:'جاهز',date:dateOnly(DateTime.now())));
    await LocalStore.saveNotifications(ns);
    setState((){});widget.changed();
  }
  @override Widget build(BuildContext c)=>FutureBuilder<List<Patient>>(future:LocalStore.patients(),builder:(c,s){
    final all=s.data??[];
    final list=all.where((p)=>q.trim().isEmpty||p.name.contains(q)||p.fileNo.contains(q)||p.phone.contains(q)).toList();
    return CustomScrollView(slivers:[
      SliverToBoxAdapter(child:Container(
        padding:const EdgeInsets.fromLTRB(16,18,16,22),
        decoration:const BoxDecoration(color:Color(0xFF0869B9),borderRadius:BorderRadius.only(bottomLeft:Radius.circular(26),bottomRight:Radius.circular(26))),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('المرضى',style:TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.bold)),
          const SizedBox(height:4),Text(all.length.toString()+' ملف مسجل في النظام',style:const TextStyle(color:Colors.white70)),
          const SizedBox(height:15),
          Row(children:[
            Expanded(child:TextField(onChanged:(x)=>setState(()=>q=x),decoration:InputDecoration(hintText:'ابحث باسم المريض أو رقم الملف',prefixIcon:const Icon(Icons.search),filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide.none)))),
            const SizedBox(width:10),
            IconButton(onPressed:add,style:IconButton.styleFrom(backgroundColor:Colors.white,foregroundColor:const Color(0xFF0869B9),padding:const EdgeInsets.all(14)),icon:const Icon(Icons.person_add_alt_1_rounded))
          ])
        ])
      )),
      SliverPadding(padding:const EdgeInsets.fromLTRB(16,16,16,24),sliver:SliverList(delegate:SliverChildListDelegate([
        if(list.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(32),child:Center(child:Text('لا توجد سجلات مطابقة')))),
        ...list.map((p)=>Card(margin:const EdgeInsets.only(bottom:10),child:InkWell(
          borderRadius:BorderRadius.circular(18),
          onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>PatientDetails(patient:p))),
          child:Padding(padding:const EdgeInsets.all(12),child:Row(children:[
            CircleAvatar(radius:27,backgroundColor:const Color(0xFFE8F3FF),child:Text(p.fileNo.replaceAll('P-',''),style:const TextStyle(color:Color(0xFF0869B9),fontWeight:FontWeight.bold))),
            const SizedBox(width:12),
            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text(p.name,style:const TextStyle(fontSize:16,fontWeight:FontWeight.bold)),
              const SizedBox(height:4),
              Text(p.fileNo+' • '+p.phone,style:const TextStyle(color:Colors.black54,fontSize:12)),
              if(p.service.isNotEmpty)Text(p.service,style:const TextStyle(color:Color(0xFF0876D1),fontSize:12))
            ])),
            const Icon(Icons.chevron_left_rounded,color:Colors.black38)
          ]))
        )))
      ])))
    ]);
  });
}
class PatientForm extends StatefulWidget{const PatientForm({super.key});@override State<PatientForm> createState()=>_PatientFormState();}
class _PatientFormState extends State<PatientForm>{
  final name=TextEditingController(),phone=TextEditingController(),alternate=TextEditingController(),national=TextEditingController(),service=TextEditingController(),doctor=TextEditingController(),address=TextEditingController(),notes=TextEditingController();
  String gender='ذكر',department='العلاج الطبيعي',channel='النظام'; DateTime? birth;
  Future<void> pickBirth()async{final d=await showDatePicker(context:context,initialDate:DateTime(2000),firstDate:DateTime(1900),lastDate:DateTime.now());if(d!=null)setState(()=>birth=d);}
  int? age(){if(birth==null)return null;final now=DateTime.now();var a=now.year-birth!.year;if(now.month<birth!.month||(now.month==birth!.month&&now.day<birth!.day))a--;return a;}
  Future<void> save()async{if(name.text.trim().isEmpty||phone.text.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أدخل اسم المريض ورقم الهاتف')));return;}final n=await LocalStore.nextPatientNumber();final extra=alternate.text.trim().isEmpty?'':'هاتف بديل: '+alternate.text.trim();final note=notes.text.trim();final p=Patient(id:idNow(),fileNo:'P-'+n.toString(),name:name.text.trim(),phone:phone.text.trim(),nationalId:national.text.trim(),birthDate:birth==null?'':dateOnly(birth!),gender:gender,department:department,service:service.text.trim(),doctor:doctor.text.trim(),address:address.text.trim(),notes:extra+(extra.isNotEmpty&&note.isNotEmpty?'\n':'')+note,createdAt:dateOnly(DateTime.now()));Navigator.pop(context,p);}
  @override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:const Text('تسجيل مريض جديد')),body:ListView(padding:const EdgeInsets.all(16),children:[
    TextField(controller:name,decoration:const InputDecoration(labelText:'اسم المريض *',prefixIcon:Icon(Icons.person_outline))),const SizedBox(height:10),
    TextField(controller:phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'رقم الهاتف *',prefixIcon:Icon(Icons.phone))),const SizedBox(height:10),
    TextField(controller:alternate,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'رقم هاتف بديل',prefixIcon:Icon(Icons.phone_android))),const SizedBox(height:10),
    TextField(controller:national,decoration:const InputDecoration(labelText:'الهوية / الرقم الوطني',prefixIcon:Icon(Icons.badge_outlined))),const SizedBox(height:10),
    InkWell(onTap:pickBirth,child:InputDecorator(decoration:const InputDecoration(labelText:'تاريخ الميلاد',prefixIcon:Icon(Icons.cake_outlined)),child:Text(birth==null?'اختر التاريخ':dateOnly(birth!)))),const SizedBox(height:10),
    InputDecorator(decoration:const InputDecoration(labelText:'العمر'),child:Text(age()==null?'—':age().toString()+' سنة')),const SizedBox(height:10),
    DropdownButtonFormField(value:gender,decoration:const InputDecoration(labelText:'الجنس'),items:['ذكر','أنثى'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setState(()=>gender=v!)),const SizedBox(height:10),
    DropdownButtonFormField(value:department,decoration:const InputDecoration(labelText:'القسم'),items:['العلاج الطبيعي','العيادة','الأسنان','التمريض','أخرى'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setState(()=>department=v!)),const SizedBox(height:10),
    TextField(controller:service,decoration:const InputDecoration(labelText:'الخدمة / الشكوى',prefixIcon:Icon(Icons.medical_services_outlined))),const SizedBox(height:10),
    TextField(controller:doctor,decoration:const InputDecoration(labelText:'الطبيب / الأخصائي',prefixIcon:Icon(Icons.person_search_outlined))),const SizedBox(height:10),
    TextField(controller:address,decoration:const InputDecoration(labelText:'العنوان',prefixIcon:Icon(Icons.location_on_outlined))),const SizedBox(height:10),
    DropdownButtonFormField(value:channel,decoration:const InputDecoration(labelText:'قناة إشعار التسجيل'),items:['النظام','WhatsApp','SMS','بدون'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setState(()=>channel=v!)),const SizedBox(height:10),
    TextField(controller:notes,maxLines:3,decoration:const InputDecoration(labelText:'ملاحظات')),const SizedBox(height:20),
    SizedBox(height:50,child:FilledButton.icon(onPressed:save,icon:const Icon(Icons.save),label:const Text('حفظ الملف')))
  ]));
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

class AppointmentsPage extends StatefulWidget{
  final VoidCallback changed;
  const AppointmentsPage({super.key,required this.changed});
  @override State<AppointmentsPage> createState()=>_AppointmentsPageState();
}
class _AppointmentsPageState extends State<AppointmentsPage>{
  DateTime selected=DateTime.now();
  Future<void> add()async{
    final ps=await LocalStore.patients();
    if(ps.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف مريضاً أولاً')));return;}
    final r=await Navigator.push<Appointment>(context,MaterialPageRoute(builder:(_)=>AppointmentForm(patients:ps)));
    if(r==null)return;
    final l=await LocalStore.appointments();l.add(r);await LocalStore.saveAppointments(l);
    final ns=await LocalStore.notifications();
    ns.insert(0,AppNotification(id:idNow(),title:'موعد جديد',body:'تم حجز موعد للمريض في '+r.date+' الساعة '+r.time,channel:'النظام',status:'جاهز',date:dateOnly(DateTime.now())));
    await LocalStore.saveNotifications(ns);
    setState((){});widget.changed();
  }
  Future<void> pickDate()async{
    final d=await showDatePicker(context:context,initialDate:selected,firstDate:DateTime(2020),lastDate:DateTime(2100),locale:null);
    if(d!=null)setState(()=>selected=d);
  }
  @override Widget build(BuildContext c)=>FutureBuilder(future:Future.wait([LocalStore.appointments(),LocalStore.patients()]),builder:(c,s){
    if(!s.hasData)return const Center(child:CircularProgressIndicator());
    final a=s.data![0] as List<Appointment>,ps=s.data![1] as List<Patient>;
    final key=dateOnly(selected);
    final list=a.where((x)=>x.date==key).toList()..sort((x,y)=>x.time.compareTo(y.time));
    String pname(String id){for(final p in ps){if(p.id==id)return p.name;}return 'غير معروف';}
    return ListView(padding:EdgeInsets.zero,children:[
      Container(padding:const EdgeInsets.fromLTRB(16,18,16,20),decoration:const BoxDecoration(color:Color(0xFF0869B9),borderRadius:BorderRadius.only(bottomLeft:Radius.circular(26),bottomRight:Radius.circular(26))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[const Expanded(child:Text('المواعيد',style:TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.bold))),IconButton(onPressed:add,style:IconButton.styleFrom(backgroundColor:Colors.white,foregroundColor:Color(0xFF0869B9)),icon:const Icon(Icons.add_rounded))]),
        const SizedBox(height:4),Text(list.length.toString()+' موعد في اليوم المحدد',style:const TextStyle(color:Colors.white70)),
        const SizedBox(height:14),
        InkWell(onTap:pickDate,borderRadius:BorderRadius.circular(14),child:Container(padding:const EdgeInsets.symmetric(horizontal:14,vertical:12),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14)),child:Row(children:[const Icon(Icons.calendar_month_rounded,color:Color(0xFF0869B9)),const SizedBox(width:10),Expanded(child:Text(key,style:const TextStyle(fontWeight:FontWeight.bold,color:Color(0xFF12395C)))),const Icon(Icons.keyboard_arrow_down_rounded,color:Color(0xFF0869B9))])))
      ])),
      Padding(padding:const EdgeInsets.fromLTRB(16,18,16,8),child:Text(selected.year==DateTime.now().year&&selected.month==DateTime.now().month&&selected.day==DateTime.now().day?'مواعيد اليوم':'المواعيد المحددة',style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:Color(0xFF12395C)))),
      Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:Column(children:[
        if(list.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(28),child:Center(child:Text('لا توجد مواعيد في هذا اليوم')))),
        ...list.map((x)=>Card(margin:const EdgeInsets.only(bottom:10),child:Padding(padding:const EdgeInsets.all(13),child:Row(children:[
          Container(width:68,padding:const EdgeInsets.symmetric(vertical:10),decoration:BoxDecoration(color:const Color(0xFFEAF4FF),borderRadius:BorderRadius.circular(13)),child:Text(x.time,textAlign:TextAlign.center,style:const TextStyle(color:Color(0xFF0869B9),fontWeight:FontWeight.bold))),
          const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(pname(x.patientId),style:const TextStyle(fontWeight:FontWeight.bold,fontSize:16)),const SizedBox(height:4),Text(x.doctor.isEmpty?'بدون أخصائي محدد':x.doctor,style:const TextStyle(color:Colors.black54,fontSize:12)),if(x.notes.isNotEmpty)Text(x.notes,style:const TextStyle(color:Colors.black45,fontSize:11))])),
          Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:6),decoration:BoxDecoration(color:x.status=='مؤكد'?const Color(0xFFE8F8EF):const Color(0xFFFFF3DF),borderRadius:BorderRadius.circular(10)),child:Text(x.status))
        ])))
      ]))
    ]);
  });
}
class AppointmentForm extends StatefulWidget{
  final List<Patient> patients;
  const AppointmentForm({super.key,required this.patients});
  @override State<AppointmentForm> createState()=>_AppointmentFormState();
}
class _AppointmentFormState extends State<AppointmentForm>{
  late String pid,status='مؤكد';
  DateTime date=DateTime.now();
  final time=TextEditingController(text:'09:00'),doctor=TextEditingController(),notes=TextEditingController();
  @override void initState(){super.initState();pid=widget.patients.first.id;}
  Future<void> pick()async{final d=await showDatePicker(context:context,initialDate:date,firstDate:DateTime(2020),lastDate:DateTime(2100));if(d!=null)setState(()=>date=d);}
  @override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:const Text('موعد جديد')),body:ListView(padding:const EdgeInsets.all(16),children:[
    DropdownButtonFormField(value:pid,decoration:const InputDecoration(labelText:'المريض'),items:widget.patients.map((p)=>DropdownMenuItem(value:p.id,child:Text(p.fileNo+' - '+p.name))).toList(),onChanged:(v)=>setState(()=>pid=v!)),
    const SizedBox(height:12),InkWell(onTap:pick,child:InputDecorator(decoration:const InputDecoration(labelText:'تاريخ الموعد',prefixIcon:Icon(Icons.calendar_month)),child:Text(dateOnly(date)))),
    const SizedBox(height:12),TextField(controller:time,keyboardType:TextInputType.datetime,decoration:const InputDecoration(labelText:'الوقت',prefixIcon:Icon(Icons.access_time))),
    const SizedBox(height:12),TextField(controller:doctor,decoration:const InputDecoration(labelText:'الطبيب / الأخصائي',prefixIcon:Icon(Icons.medical_services_outlined))),
    const SizedBox(height:12),DropdownButtonFormField(value:status,decoration:const InputDecoration(labelText:'الحالة'),items:['مؤكد','انتظار','تم الحضور','ملغي'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setState(()=>status=v!)),
    const SizedBox(height:12),TextField(controller:notes,maxLines:3,decoration:const InputDecoration(labelText:'ملاحظات')),
    const SizedBox(height:20),SizedBox(height:50,child:FilledButton.icon(onPressed:()=>Navigator.pop(c,Appointment(id:idNow(),patientId:pid,date:dateOnly(date),time:time.text.trim(),doctor:doctor.text.trim(),status:status,notes:notes.text.trim())),icon:const Icon(Icons.save),label:const Text('حفظ الموعد')))
  ]));
}
class PackagesPage extends StatefulWidget{
  final VoidCallback changed;
  const PackagesPage({super.key,required this.changed});
  @override State<PackagesPage> createState()=>_PackagesPageState();
}
class _PackagesPageState extends State<PackagesPage>{
  Future<void> add()async{
    final ps=await LocalStore.patients();
    if(ps.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف مريضاً أولاً')));return;}
    final r=await Navigator.push<PackageRecord>(context,MaterialPageRoute(builder:(_)=>PackageForm(patients:ps)));
    if(r==null)return; final l=await LocalStore.packages(); l.add(r); await LocalStore.savePackages(l); setState((){}); widget.changed();
  }
  Future<void> registerSession(PackageRecord item)async{
    if(item.remaining<=0){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('انتهت جلسات هذه الباقة')));return;}
    final list=await LocalStore.packages(); final i=list.indexWhere((x)=>x.id==item.id); if(i<0)return;
    final left=item.remaining-1;
    list[i]=PackageRecord(id:item.id,patientId:item.patientId,name:item.name,price:item.price,paid:item.paid,sessions:item.sessions,remaining:left,startDate:item.startDate,endDate:item.endDate);
    await LocalStore.savePackages(list);
    final ns=await LocalStore.notifications();
    if(left<=2){ns.insert(0,AppNotification(id:idNow(),title:left==0?'انتهاء الباقة':'تنبيه قرب انتهاء الباقة',body:left==0?'انتهت جميع جلسات باقة '+item.name:'تبقى '+left.toString()+' جلسة من باقة '+item.name,channel:'النظام',status:'جاهز',date:dateOnly(DateTime.now())));await LocalStore.saveNotifications(ns);}
    setState((){}); widget.changed();
    if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('تم تسجيل الجلسة • المتبقي '+left.toString())));
  }
  @override Widget build(BuildContext c)=>FutureBuilder(future:Future.wait([LocalStore.packages(),LocalStore.patients()]),builder:(c,s){
    if(!s.hasData)return const Center(child:CircularProgressIndicator());
    final g=s.data![0] as List<PackageRecord>,ps=s.data![1] as List<Patient>;
    String pname(String id){for(final p in ps){if(p.id==id)return p.name;}return 'غير معروف';}
    return ListView(padding:EdgeInsets.zero,children:[
      Container(padding:const EdgeInsets.fromLTRB(16,18,16,20),decoration:const BoxDecoration(color:Color(0xFF0869B9),borderRadius:BorderRadius.only(bottomLeft:Radius.circular(26),bottomRight:Radius.circular(26))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[const Expanded(child:Text('الباقات والجلسات',style:TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.bold))),IconButton(onPressed:add,style:IconButton.styleFrom(backgroundColor:Colors.white,foregroundColor:Color(0xFF0869B9)),icon:const Icon(Icons.add_rounded))]),
        const SizedBox(height:4),Text(g.length.toString()+' باقة مسجلة',style:const TextStyle(color:Colors.white70))
      ])),
      Padding(padding:const EdgeInsets.fromLTRB(16,18,16,8),child:const Text('متابعة الجلسات',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:Color(0xFF12395C)))),
      Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:Column(children:[
        if(g.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(28),child:Center(child:Text('لا توجد باقات مسجلة')))),
        ...g.map((x)=>Card(margin:const EdgeInsets.only(bottom:10),child:Padding(padding:const EdgeInsets.all(14),child:Column(children:[
          Row(children:[Container(width:46,height:46,decoration:BoxDecoration(color:const Color(0xFFEAF4FF),borderRadius:BorderRadius.circular(13)),child:const Icon(Icons.layers_rounded,color:Color(0xFF0869B9))),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(x.name,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:16)),const SizedBox(height:3),Text(pname(x.patientId),style:const TextStyle(color:Colors.black54,fontSize:12))])),Text(x.remaining.toString(),style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold,color:Color(0xFF0869B9)))]),
          const SizedBox(height:12),
          ClipRRect(borderRadius:BorderRadius.circular(8),child:LinearProgressIndicator(value:x.sessions<=0?0:x.remaining/x.sessions,minHeight:8,backgroundColor:const Color(0xFFE8EEF5))),
          const SizedBox(height:8),
          Row(children:[Expanded(child:Text('المتبقي '+x.remaining.toString()+' من '+x.sessions.toString()+' جلسة',style:const TextStyle(fontSize:12,color:Colors.black54))),FilledButton.tonalIcon(onPressed:()=>registerSession(x),icon:const Icon(Icons.check_circle_outline),label:const Text('تسجيل جلسة'))])
        ])))
      ]))
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
  @override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:const Text('باقة جديدة')),body:ListView(padding:const EdgeInsets.all(16),children:[
    DropdownButtonFormField(value:pid,decoration:const InputDecoration(labelText:'المريض'),items:widget.patients.map((p)=>DropdownMenuItem(value:p.id,child:Text(p.name))).toList(),onChanged:(v)=>setState(()=>pid=v!)),
    const SizedBox(height:10),TextField(controller:name,decoration:const InputDecoration(labelText:'اسم الباقة')),
    const SizedBox(height:10),TextField(controller:price,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'السعر')),
    const SizedBox(height:10),TextField(controller:paid,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'المدفوع')),
    const SizedBox(height:10),TextField(controller:sessions,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'عدد الجلسات')),
    const SizedBox(height:20),SizedBox(height:50,child:FilledButton.icon(onPressed:(){final s=int.tryParse(sessions.text)??0;if(name.text.trim().isEmpty||s<=0){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أدخل اسم الباقة وعدد جلسات صحيح')));return;}final p=double.tryParse(price.text)??0,paidValue=double.tryParse(paid.text)??0;if(p<0||paidValue<0||paidValue>p){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تحقق من السعر والمدفوع')));return;}Navigator.pop(c,PackageRecord(id:idNow(),patientId:pid,name:name.text.trim(),price:p,paid:paidValue,sessions:s,remaining:s,startDate:dateOnly(DateTime.now()),endDate:dateOnly(DateTime.now().add(const Duration(days:30)))));},icon:const Icon(Icons.save),label:const Text('حفظ الباقة')))
  ]));
}
class InvoicesPage extends StatefulWidget{
  final VoidCallback changed;
  const InvoicesPage({super.key,required this.changed});
  @override State<InvoicesPage> createState()=>_InvoicesPageState();
}
class _InvoicesPageState extends State<InvoicesPage>{
  Future<void> add()async{
    final ps=await LocalStore.patients();
    if(ps.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف مريضاً أولاً')));return;}
    final r=await Navigator.push<Invoice>(context,MaterialPageRoute(builder:(_)=>InvoiceForm(patients:ps)));
    if(r==null)return; final l=await LocalStore.invoices();l.add(r);await LocalStore.saveInvoices(l);setState((){});widget.changed();
  }
  @override Widget build(BuildContext c)=>FutureBuilder(future:Future.wait([LocalStore.invoices(),LocalStore.patients()]),builder:(c,s){
    if(!s.hasData)return const Center(child:CircularProgressIndicator());
    final inv=s.data![0] as List<Invoice>,ps=s.data![1] as List<Patient>;
    String pname(String id){for(final p in ps){if(p.id==id)return p.name;}return 'غير معروف';}
    final total=inv.fold<double>(0,(x,e)=>x+e.total),paid=inv.fold<double>(0,(x,e)=>x+e.paid),remaining=inv.fold<double>(0,(x,e)=>x+e.remaining);
    return ListView(padding:EdgeInsets.zero,children:[
      Container(padding:const EdgeInsets.fromLTRB(16,18,16,20),decoration:const BoxDecoration(color:Color(0xFF0869B9),borderRadius:BorderRadius.only(bottomLeft:Radius.circular(26),bottomRight:Radius.circular(26))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[const Expanded(child:Text('الفواتير والمدفوعات',style:TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.bold))),IconButton(onPressed:add,style:IconButton.styleFrom(backgroundColor:Colors.white,foregroundColor:Color(0xFF0869B9)),icon:const Icon(Icons.add_rounded))]),
        const SizedBox(height:4),Text(inv.length.toString()+' فاتورة مسجلة',style:const TextStyle(color:Colors.white70))
      ])),
      Padding(padding:const EdgeInsets.fromLTRB(16,16,16,10),child:Row(children:[
        Expanded(child:_MoneyCard('الإجمالي',total,Icons.receipt_long_rounded,const Color(0xFFEAF4FF),const Color(0xFF0876D1))),
        const SizedBox(width:8),Expanded(child:_MoneyCard('المدفوع',paid,Icons.payments_rounded,const Color(0xFFEAFBF1),const Color(0xFF15945A))),
        const SizedBox(width:8),Expanded(child:_MoneyCard('المتبقي',remaining,Icons.account_balance_wallet_rounded,const Color(0xFFFFF3E2),const Color(0xFFE58B00)))
      ])),
      Padding(padding:const EdgeInsets.fromLTRB(16,10,16,8),child:const Text('سجل الفواتير',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:Color(0xFF12395C)))),
      Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:Column(children:[
        if(inv.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(28),child:Center(child:Text('لا توجد فواتير')))),
        ...inv.reversed.map((x)=>Card(margin:const EdgeInsets.only(bottom:10),child:ListTile(
          leading:CircleAvatar(backgroundColor:const Color(0xFFEAF4FF),child:const Icon(Icons.receipt_long,color:Color(0xFF0869B9))),
          title:Text(x.number,style:const TextStyle(fontWeight:FontWeight.bold)),
          subtitle:Text(pname(x.patientId)+' • '+x.date+'\\nالإجمالي '+x.total.toStringAsFixed(0)+' • المدفوع '+x.paid.toStringAsFixed(0)),
          isThreeLine:true,
          trailing:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.end,children:[Text(x.remaining.toStringAsFixed(0),style:TextStyle(fontWeight:FontWeight.bold,color:x.remaining<=0?const Color(0xFF15945A):const Color(0xFFE58B00))),Text(x.remaining<=0?'مدفوعة':'متبقي',style:const TextStyle(fontSize:11,color:Colors.black54))])
        )))
      ]))
    ]);
  });
}
class _MoneyCard extends StatelessWidget{
  final String title; final double value; final IconData icon; final Color bg,fg;
  const _MoneyCard(this.title,this.value,this.icon,this.bg,this.fg);
  @override Widget build(BuildContext c)=>Container(padding:const EdgeInsets.all(11),decoration:BoxDecoration(color:bg,borderRadius:BorderRadius.circular(16)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(icon,color:fg,size:23),const SizedBox(height:7),Text(value.toStringAsFixed(0),style:TextStyle(fontSize:17,fontWeight:FontWeight.bold,color:fg),maxLines:1),Text(title,style:const TextStyle(fontSize:11,color:Color(0xFF456174)))]);
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
  @override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:const Text('فاتورة جديدة')),body:ListView(padding:const EdgeInsets.all(16),children:[
    DropdownButtonFormField(value:pid,decoration:const InputDecoration(labelText:'المريض'),items:widget.patients.map((p)=>DropdownMenuItem(value:p.id,child:Text(p.name))).toList(),onChanged:(v)=>setState(()=>pid=v!)),
    const SizedBox(height:12),TextField(controller:total,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'الإجمالي',prefixIcon:Icon(Icons.payments_outlined))),
    const SizedBox(height:12),TextField(controller:paid,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'المدفوع',prefixIcon:Icon(Icons.account_balance_wallet_outlined))),
    const SizedBox(height:20),SizedBox(height:50,child:FilledButton.icon(onPressed:(){final t=double.tryParse(total.text.trim())??-1,p=double.tryParse(paid.text.trim())??-1;if(t<=0||p<0||p>t){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تحقق من الإجمالي والمدفوع')));return;}Navigator.pop(c,Invoice(id:idNow(),patientId:pid,number:'INV-'+DateTime.now().millisecondsSinceEpoch.toString(),total:t,paid:p,date:dateOnly(DateTime.now()),status:p>=t?'مدفوعة':'جزئية'));},icon:const Icon(Icons.save),label:const Text('حفظ الفاتورة')))
  ]));
}
class NotificationsPage extends StatefulWidget{
  const NotificationsPage({super.key});
  @override State<NotificationsPage> createState()=>_NotificationsPageState();
}
class _NotificationsPageState extends State<NotificationsPage>{
  Future<void> clear()async{await LocalStore.saveNotifications([]);setState((){});}
  @override Widget build(BuildContext c)=>FutureBuilder<List<AppNotification>>(future:LocalStore.notifications(),builder:(c,s){
    final n=s.data??[];
    return ListView(padding:EdgeInsets.zero,children:[
      Container(padding:const EdgeInsets.fromLTRB(16,18,16,20),decoration:const BoxDecoration(color:Color(0xFF0869B9),borderRadius:BorderRadius.only(bottomLeft:Radius.circular(26),bottomRight:Radius.circular(26))),child:Row(children:[
        const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('مركز الإشعارات',style:TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.bold)),SizedBox(height:4),Text('متابعة تنبيهات النظام والمرضى والجلسات',style:TextStyle(color:Colors.white70))])),
        if(n.isNotEmpty)IconButton(onPressed:clear,style:IconButton.styleFrom(backgroundColor:Colors.white,foregroundColor:Color(0xFF0869B9)),icon:const Icon(Icons.delete_sweep_outlined))
      ])),
      Padding(padding:const EdgeInsets.fromLTRB(16,18,16,8),child:Text(n.length.toString()+' إشعار',style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:Color(0xFF12395C)))),
      Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:Column(children:[
        if(n.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(32),child:Center(child:Text('لا توجد إشعارات حالياً')))),
        ...n.map((x)=>Card(margin:const EdgeInsets.only(bottom:10),child:ListTile(
          leading:CircleAvatar(backgroundColor:x.channel=='WhatsApp'?const Color(0xFFEAFBF1):const Color(0xFFEAF4FF),child:Icon(x.channel=='WhatsApp'?Icons.chat_bubble_outline:Icons.notifications_none_rounded,color:x.channel=='WhatsApp'?const Color(0xFF15945A):const Color(0xFF0869B9))),
          title:Text(x.title,style:const TextStyle(fontWeight:FontWeight.bold)),
          subtitle:Text(x.body+'\\n'+x.date, maxLines:3,overflow:TextOverflow.ellipsis),
          trailing:Text(x.status,style:const TextStyle(fontSize:11,color:Colors.black54))
        )))
      ]))
    ]);
  });
}
