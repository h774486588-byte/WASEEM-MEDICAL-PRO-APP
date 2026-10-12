import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'models.dart';
import 'storage.dart';

String _examDate(DateTime d)=>'${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
class ExaminationPage extends StatefulWidget {
 final Patient patient;
 const ExaminationPage({super.key,required this.patient});
 @override State<ExaminationPage> createState()=>_ExaminationPageState();
}
class _ExaminationPageState extends State<ExaminationPage> {
 final complaint=TextEditingController(),history=TextEditingController(),diagnosis=TextEditingController(),treatment=TextEditingController(),notes=TextEditingController(),examiner=TextEditingController(),pressure=TextEditingController(),temperature=TextEditingController(),weight=TextEditingController();
 bool saving=false;
 @override void dispose(){complaint.dispose();history.dispose();diagnosis.dispose();treatment.dispose();notes.dispose();examiner.dispose();pressure.dispose();temperature.dispose();weight.dispose();super.dispose();}
 Future<void> save() async {
  if(complaint.text.trim().isEmpty&&diagnosis.text.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أدخل الشكوى أو التشخيص على الأقل.')));return;}
  setState(()=>saving=true);
  final e=ExaminationRecord(id:DateTime.now().microsecondsSinceEpoch.toString(),patientId:widget.patient.id,date:_examDate(DateTime.now()),complaint:complaint.text.trim(),history:history.text.trim(),diagnosis:diagnosis.text.trim(),treatment:treatment.text.trim(),notes:notes.text.trim(),examiner:examiner.text.trim(),bloodPressure:pressure.text.trim(),temperature:temperature.text.trim(),weight:weight.text.trim());
  final all=await LocalStore.examinations();all.add(e);await LocalStore.saveExaminations(all);
  if(mounted){setState(()=>saving=false);ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم حفظ ورقة المعاينة في ملف المريض.')));Navigator.pop(context,true);}
 }
 @override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(
  appBar:AppBar(title:const Text('ورقة معاينة طبية')),
  body:ListView(padding:const EdgeInsets.all(16),children:[
   Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.person)),title:Text(widget.patient.name,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('${widget.patient.fileNo} • ${widget.patient.phone}'))),
   const SizedBox(height:12),
   Text('بيانات المعاينة • ${_examDate(DateTime.now())}',style:const TextStyle(fontWeight:FontWeight.bold,fontSize:17)),
   const SizedBox(height:10),
   TextField(controller:examiner,decoration:const InputDecoration(labelText:'اسم الطبيب / الممرض الفاحص')),
   const SizedBox(height:9),TextField(controller:complaint,maxLines:2,decoration:const InputDecoration(labelText:'الشكوى الرئيسية *')),
   const SizedBox(height:9),TextField(controller:history,maxLines:3,decoration:const InputDecoration(labelText:'التاريخ المرضي')),
   const SizedBox(height:9),TextField(controller:diagnosis,maxLines:2,decoration:const InputDecoration(labelText:'التشخيص')),
   const SizedBox(height:9),TextField(controller:treatment,maxLines:3,decoration:const InputDecoration(labelText:'الخطة العلاجية / الإجراء')),
   const SizedBox(height:9),Row(children:[Expanded(child:TextField(controller:pressure,decoration:const InputDecoration(labelText:'ضغط الدم'))),const SizedBox(width:8),Expanded(child:TextField(controller:temperature,decoration:const InputDecoration(labelText:'الحرارة')))]),
   const SizedBox(height:9),TextField(controller:weight,decoration:const InputDecoration(labelText:'الوزن')),
   const SizedBox(height:9),TextField(controller:notes,maxLines:3,decoration:const InputDecoration(labelText:'ملاحظات إضافية')),
   const SizedBox(height:18),SizedBox(height:50,child:FilledButton.icon(onPressed:saving?null:save,icon:const Icon(Icons.save_outlined),label:Text(saving?'جارٍ الحفظ...':'حفظ المعاينة'))),
  ]),
 ));
}
