import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'models.dart';
import 'storage.dart';

String patientReportText(Patient p, {List<PackageRecord> packages=const [], List<ExaminationRecord> exams=const []}) {
  final b=StringBuffer();
  b.writeln('نظام وسيم الطبي PRO');
  b.writeln('كشف المريض');
  b.writeln('==============================');
  b.writeln('اسم المريض: ${p.name}');
  b.writeln('رقم الملف: ${p.fileNo}');
  b.writeln('الهاتف: ${p.phone}');
  b.writeln('الجنس: ${p.gender} | العمر: ${p.age}');
  b.writeln('القسم: ${p.department}');
  b.writeln('الخدمة/الشكوى: ${p.service}');
  b.writeln('الطبيب/الأخصائي: ${p.doctor}');
  b.writeln('العنوان: ${p.address}');
  b.writeln('تاريخ التسجيل: ${p.createdAt}');
  b.writeln('ملاحظات: ${p.notes}');
  b.writeln('');
  b.writeln('الباقات:');
  if(packages.where((x)=>x.patientId==p.id).isEmpty) b.writeln('لا توجد باقات.');
  for(final x in packages.where((x)=>x.patientId==p.id)) {
    b.writeln('- ${x.name} | الجلسات المتبقية ${x.remaining}/${x.sessions} | الممرض/الأخصائي: ${x.therapist} | المدفوع: ${x.paid}');
  }
  b.writeln('');
  b.writeln('سجل المعاينات:');
  final patientExams=exams.where((x)=>x.patientId==p.id).toList()..sort((a,b)=>b.date.compareTo(a.date));
  if(patientExams.isEmpty) b.writeln('لا توجد معاينات.');
  for(final e in patientExams) {
    b.writeln('التاريخ: ${e.date} | الفاحص: ${e.examiner}');
    b.writeln('الشكوى: ${e.complaint}');
    b.writeln('التاريخ المرضي: ${e.history}');
    b.writeln('التشخيص: ${e.diagnosis}');
    b.writeln('الخطة العلاجية: ${e.treatment}');
    b.writeln('الضغط: ${e.bloodPressure} | الحرارة: ${e.temperature} | الوزن: ${e.weight}');
    b.writeln('ملاحظات: ${e.notes}');
    b.writeln('------------------------------');
  }
  return b.toString();
}

Future<void> sharePatientReport(Patient p) async {
  final packages=await LocalStore.packages();
  final exams=await LocalStore.examinations();
  await Share.share(patientReportText(p,packages:packages,exams:exams),subject:'كشف المريض ${p.name}');
}

Future<void> printPatientReport(Patient p) async {
  final packages=await LocalStore.packages();
  final exams=await LocalStore.examinations();
  final lines=patientReportText(p,packages:packages,exams:exams).split('\n');
  final pdf=pw.Document();
  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    build:(context)=>[
      for(final line in lines)
        pw.Container(
          alignment:pw.Alignment.centerRight,
          padding:const pw.EdgeInsets.symmetric(vertical:3),
          child:pw.Text(line, textAlign:pw.TextAlign.right, style:pw.TextStyle(fontSize:10)),
        ),
    ],
  ));
  await Printing.layoutPdf(onLayout:(format)=>pdf.save(),name:'patient-${p.fileNo}.pdf');
}

class PatientReportsPage extends StatefulWidget {
  const PatientReportsPage({super.key});
  @override State<PatientReportsPage> createState()=>_PatientReportsPageState();
}
class _PatientReportsPageState extends State<PatientReportsPage> {
  String query='';
  bool busy=false;
  Future<void> _allPatients(List<Patient> patients) async {
    if(patients.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('لا توجد سجلات مرضى للطباعة.'))); return; }
    setState(()=>busy=true);
    try {
      final packages=await LocalStore.packages();
      final exams=await LocalStore.examinations();
      final text=patients.map((p)=>patientReportText(p,packages:packages,exams:exams)).join('\n\n================================\n\n');
      await Share.share(text,subject:'الكشف الكامل للمرضى - ${patients.length} ملف');
    } finally { if(mounted)setState(()=>busy=false); }
  }
  Future<void> _printAll(List<Patient> patients) async {
    if(patients.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('لا توجد سجلات مرضى للطباعة.'))); return; }
    setState(()=>busy=true);
    try {
      final pdf=pw.Document();
      pdf.addPage(pw.MultiPage(pageFormat:PdfPageFormat.a4,build:(context)=>[
        pw.Align(alignment:pw.Alignment.centerRight,child:pw.Text('نظام وسيم الطبي PRO - الكشف الكامل للمرضى',style:pw.TextStyle(fontSize:14,fontWeight:pw.FontWeight.bold))),
        pw.SizedBox(height:12),
        pw.TableHelper.fromTextArray(
          headers:['#','File No','Patient Name','Phone','Gender','Age','Department','Registered'],
          data:[for(var i=0;i<patients.length;i++) [('${i+1}'),patients[i].fileNo,patients[i].name,patients[i].phone,patients[i].gender,patients[i].age.toString(),patients[i].department,patients[i].createdAt]],
          headerStyle:pw.TextStyle(fontSize:8,fontWeight:pw.FontWeight.bold),
          cellStyle:const pw.TextStyle(fontSize:7),
          cellAlignment:pw.Alignment.centerRight,
        ),
      ]));
      await Printing.layoutPdf(onLayout:(format)=>pdf.save(),name:'waseem-patients-register.pdf');
    } finally { if(mounted)setState(()=>busy=false); }
  }
  @override Widget build(BuildContext context)=>FutureBuilder<List<Patient>>(
    future:LocalStore.patients(),
    builder:(context,s) {
      final all=s.data??[];
      final visible=all.where((p)=>query.isEmpty||p.name.contains(query)||p.fileNo.contains(query)||p.phone.contains(query)).toList();
      return ListView(padding:const EdgeInsets.all(16),children:[
        const Text('تقارير المرضى',style:TextStyle(fontSize:23,fontWeight:FontWeight.bold)),
        const SizedBox(height:6),
        const Text('اطبع كشفاً كاملاً مختصراً للمرضى، أو افتح ملف مريض لمشاركة كشفه الفردي.'),
        const SizedBox(height:14),
        TextField(onChanged:(v)=>setState(()=>query=v),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),labelText:'بحث بالاسم أو رقم الملف أو الهاتف')),
        const SizedBox(height:12),
        Card(child:ListTile(leading:const Icon(Icons.print_outlined),title:const Text('طباعة الكشف الكامل للمرضى'),subtitle:Text('${all.length} ملف'),trailing:const Icon(Icons.chevron_left),onTap:busy?null:()=>_printAll(all))),
        Card(child:ListTile(leading:const Icon(Icons.share_outlined),title:const Text('مشاركة الكشف الكامل كنص'),subtitle:const Text('يمكن إرساله عبر WhatsApp أو البريد أو حفظه'),trailing:const Icon(Icons.chevron_left),onTap:busy?null:()=>_allPatients(all))),
        if(busy) const Padding(padding:EdgeInsets.all(16),child:Center(child:CircularProgressIndicator())),
        const SizedBox(height:10),
        for(final p in visible) Card(margin:const EdgeInsets.only(bottom:8),child:ListTile(
          leading:const CircleAvatar(child:Icon(Icons.person_outline)),
          title:Text(p.name,style:const TextStyle(fontWeight:FontWeight.bold)),
          subtitle:Text('${p.fileNo} • ${p.phone}'),
          trailing:IconButton(tooltip:'مشاركة الكشف الفردي',icon:const Icon(Icons.share_outlined),onPressed:()=>sharePatientReport(p)),
          onTap:()=>printPatientReport(p),
        )),
      ]);
    },
  );
}
