import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'models.dart';
import 'storage.dart';

class PatientOperationsStatementPage extends StatefulWidget {
  final Patient patient;
  const PatientOperationsStatementPage({super.key, required this.patient});
  @override State<PatientOperationsStatementPage> createState()=>_PatientOperationsStatementPageState();
}
class _PatientOperationsStatementPageState extends State<PatientOperationsStatementPage> {
  bool busy=false;
  Future<Map<String,dynamic>> load() async {
    final r=await Future.wait<Object>([LocalStore.appointments(),LocalStore.packages(),LocalStore.sessions(),LocalStore.invoices(),LocalStore.payments(),LocalStore.examinations()]);
    return {'appointments':(r[0] as List<Appointment>).where((x)=>x.patientId==widget.patient.id).toList()..sort((a,b)=>b.date.compareTo(a.date)),
      'packages':(r[1] as List<PackageRecord>).where((x)=>x.patientId==widget.patient.id).toList(),
      'sessions':(r[2] as List<SessionRecord>).where((x)=>x.patientId==widget.patient.id).toList()..sort((a,b)=>b.date.compareTo(a.date)),
      'invoices':(r[3] as List<Invoice>).where((x)=>x.patientId==widget.patient.id).toList()..sort((a,b)=>b.date.compareTo(a.date)),
      'payments':(r[4] as List<PaymentRecord>).where((x)=>x.patientId==widget.patient.id).toList()..sort((a,b)=>b.date.compareTo(a.date)),
      'exams':(r[5] as List<ExaminationRecord>).where((x)=>x.patientId==widget.patient.id).toList()..sort((a,b)=>b.date.compareTo(a.date))};
  }
  String report(Map<String,dynamic> d) {
    final p=widget.patient; final b=StringBuffer();
    b.writeln('نظام وسيم الطبي PRO - كشف عمليات المريض');
    b.writeln('الاسم: ${p.name} | رقم الملف: ${p.fileNo} | الهاتف: ${p.phone}');
    b.writeln('القسم: ${p.department} | الطبيب: ${p.doctor} | الممرض: ${p.nurse}');
    b.writeln('--- المواعيد ---');
    for(final x in d['appointments'] as List<Appointment>) b.writeln('${x.date} ${x.time} • ${x.doctor} • ${x.status}');
    b.writeln('--- الباقات ---');
    for(final x in d['packages'] as List<PackageRecord>) b.writeln('${x.name}: ${x.remaining}/${x.sessions} جلسة متبقية • السعر ${x.price} • المدفوع ${x.paid}');
    b.writeln('--- الجلسات ---');
    for(final x in d['sessions'] as List<SessionRecord>) b.writeln('${x.date} ${x.time} • ${x.packageName} • ${x.therapist} • ${x.status}');
    b.writeln('--- الفواتير ---');
    for(final x in d['invoices'] as List<Invoice>) b.writeln('${x.date} • فاتورة ${x.number} • الإجمالي ${x.total} • المدفوع ${x.paid} • المتبقي ${x.remaining}');
    b.writeln('--- الدفعات ---');
    for(final x in d['payments'] as List<PaymentRecord>) b.writeln('${x.date} • ${x.amount} • ${x.method} • ${x.notes}');
    b.writeln('--- المعاينات ---');
    for(final x in d['exams'] as List<ExaminationRecord>) b.writeln('${x.date} • الشكوى: ${x.complaint} • التشخيص: ${x.diagnosis} • العلاج: ${x.treatment}');
    final invoices=d['invoices'] as List<Invoice>;
    b.writeln('الإجمالي المستحق: ${invoices.fold<double>(0,(s,x)=>s+x.remaining).toStringAsFixed(2)}');
    return b.toString();
  }
  Future<void> send(String channel,Map<String,dynamic> d) async {
    final p=widget.patient;
    if(p.phone.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('رقم هاتف المريض غير مسجل')));return;}
    final uri=channel=='WhatsApp'
      ? Uri.parse('https://wa.me/${p.phone.replaceAll(RegExp(r'[^0-9+]'),'').replaceAll('+','')}?text=${Uri.encodeComponent(report(d))}')
      : Uri(scheme:'sms',path:p.phone,queryParameters:{'body':report(d)});
    if(!await launchUrl(uri,mode:LaunchMode.externalApplication)&&mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تعذر فتح تطبيق الإرسال')));
  }
  Future<void> printReport(Map<String,dynamic> d) async {
    setState(()=>busy=true);
    try {
      final doc=pw.Document();
      final lines=report(d).split('\n');
      doc.addPage(pw.MultiPage(pageFormat:PdfPageFormat.a4,build:(_)=>[
        for(final line in lines) pw.Container(alignment:pw.Alignment.centerRight,padding:const pw.EdgeInsets.symmetric(vertical:3),child:pw.Text(line,textAlign:pw.TextAlign.right,style:const pw.TextStyle(fontSize:10)))
      ]));
      await Printing.layoutPdf(onLayout:(_)=>doc.save(),name:'patient-${widget.patient.fileNo}-operations.pdf');
    } finally {if(mounted)setState(()=>busy=false);}
  }
  @override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(
    appBar:AppBar(title:const Text('كشف جميع العمليات')),
    body:FutureBuilder<Map<String,dynamic>>(future:load(),builder:(context,s){
      if(!s.hasData)return const Center(child:CircularProgressIndicator());
      final d=s.data!; final p=widget.patient;
      final invoices=d['invoices'] as List<Invoice>; final packages=d['packages'] as List<PackageRecord>;
      final appointments=d['appointments'] as List<Appointment>; final sessions=d['sessions'] as List<SessionRecord>;
      final payments=d['payments'] as List<PaymentRecord>; final exams=d['exams'] as List<ExaminationRecord>;
      Widget section(String title,IconData icon,List<Widget> children)=>Card(margin:const EdgeInsets.only(bottom:10),child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Icon(icon,color:const Color(0xFF0869B9)),const SizedBox(width:8),Text(title,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:16))]),const Divider(),if(children.isEmpty)const Text('لا توجد سجلات'),...children])));
      Widget row(String title,String detail)=>ListTile(dense:true,title:Text(title),subtitle:Text(detail));
      return ListView(padding:const EdgeInsets.all(14),children:[
        Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.person)),title:Text(p.name,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('${p.fileNo} • ${p.phone} • ${p.department}'))),
        Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(children:[
          Row(children:[Expanded(child:Text('إجمالي الفواتير: ${invoices.fold<double>(0,(s,x)=>s+x.total).toStringAsFixed(2)}')),Expanded(child:Text('المدفوع: ${invoices.fold<double>(0,(s,x)=>s+x.paid).toStringAsFixed(2)}'))]),
          const SizedBox(height:6),Align(alignment:Alignment.centerRight,child:Text('المتبقي: ${invoices.fold<double>(0,(s,x)=>s+x.remaining).toStringAsFixed(2)}',style:const TextStyle(color:Colors.red,fontWeight:FontWeight.bold)))
        ]))),
        Wrap(spacing:8,runSpacing:8,children:[
          FilledButton.tonalIcon(onPressed:()=>send('WhatsApp',d),icon:const Icon(Icons.chat),label:const Text('WhatsApp')),
          FilledButton.tonalIcon(onPressed:()=>send('SMS',d),icon:const Icon(Icons.sms_outlined),label:const Text('رسالة SMS')),
          FilledButton.icon(onPressed:busy?null:()=>printReport(d),icon:const Icon(Icons.print),label:Text(busy?'جارٍ التجهيز':'طباعة A4')),
        ]),
        const SizedBox(height:10),
        section('المواعيد',Icons.calendar_month,appointments.map((x)=>row('${x.date} • ${x.time}','${x.doctor} • ${x.status}')).toList()),
        section('الباقات',Icons.layers,packages.map((x)=>row(x.name,'جلسات ${x.remaining}/${x.sessions} • السعر ${x.price} • المدفوع ${x.paid}')).toList()),
        section('الجلسات المنفذة',Icons.event_available,sessions.map((x)=>row('${x.date} • ${x.time}', '${x.packageName} • ${x.therapist} • ${x.status}')).toList()),
        section('الفواتير',Icons.receipt_long,invoices.map((x)=>row('فاتورة ${x.number} • ${x.date}','الإجمالي ${x.total} • المدفوع ${x.paid} • المتبقي ${x.remaining}')).toList()),
        section('الدفعات',Icons.payments,payments.map((x)=>row('${x.date} • ${x.amount} • ${x.method}',x.notes)).toList()),
        section('المعاينات الطبية',Icons.medical_information,exams.map((x)=>row('${x.date} • ${x.complaint}','التشخيص: ${x.diagnosis} • العلاج: ${x.treatment}')).toList()),
      ]);
    })
  ));
}
