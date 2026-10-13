import 'package:flutter/material.dart';
import 'models.dart';
import 'storage.dart';

class StaffDirectoryPage extends StatefulWidget {
  const StaffDirectoryPage({super.key});
  @override State<StaffDirectoryPage> createState()=>_StaffDirectoryPageState();
}
class _StaffDirectoryPageState extends State<StaffDirectoryPage>{
  List<StaffMember> staff=[];bool loading=true;
  @override void initState(){super.initState();load();}
  Future<void> load()async{final x=await LocalStore.staff();if(!mounted)return;setState(()=>staff=x..sort((a,b)=>a.name.compareTo(b.name)));setState(()=>loading=false);}
  Future<void> edit([StaffMember? old])async{
    final name=TextEditingController(text:old?.name??''),role=TextEditingController(text:old?.role??''),phone=TextEditingController(text:old?.phone??''),salary=TextEditingController(text:old==null?'':old.monthlySalary.toString()),commission=TextEditingController(text:old==null?'':old.commissionPercent.toString()),sessionFee=TextEditingController(text:old==null?'':old.sessionFee.toString());
    final result=await showDialog<StaffMember>(context:context,builder:(ctx)=>AlertDialog(
      title:Text(old==null?'إضافة موظف إلى الدليل':'تعديل بيانات الموظف'),
      content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:name,decoration:const InputDecoration(labelText:'اسم الموظف *')),
        TextField(controller:role,decoration:const InputDecoration(labelText:'المسمى الوظيفي *')),
        TextField(controller:phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'رقم الهاتف')),
        TextField(controller:salary,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'الراتب الشهري الأساسي')),
        TextField(controller:commission,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'نسبة العمولة من الخدمة (%)')),
        TextField(controller:sessionFee,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'أجر الجلسة الثابت (اختياري)'),),
      ])),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('إلغاء')),FilledButton(onPressed:(){
        final n=name.text.trim(),r=role.text.trim(),s=double.tryParse(salary.text.trim())??-1;
        if(n.isEmpty||r.isEmpty||s<0){ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content:Text('أدخل الاسم والمسمى وراتبًا صحيحًا')));return;}
        Navigator.pop(ctx,StaffMember(id:old?.id??DateTime.now().microsecondsSinceEpoch.toString(),name:n,role:r,phone:phone.text.trim(),monthlySalary:s,commissionPercent:cp,sessionFee:sf));
      },child:const Text('حفظ'))]
    ));
    if(result==null)return;
    final list=await LocalStore.staff();final i=list.indexWhere((x)=>x.id==result.id);if(i<0)list.add(result);else list[i]=result;
    await LocalStore.saveStaff(list);if(mounted)setState(()=>staff=list..sort((a,b)=>a.name.compareTo(b.name)));
  }
  Future<void> remove(StaffMember s)async{
    final yes=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('حذف الموظف'),content:Text('هل تريد حذف سجل ${s.name}؟ راجع سجلات الدوام والرواتب المرتبطة به قبل الحذف.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('حذف'))]));
    if(yes!=true)return;final list=await LocalStore.staff();list.removeWhere((x)=>x.id==s.id);await LocalStore.saveStaff(list);if(mounted)setState(()=>staff=list);
  }
  @override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(
    floatingActionButton:FloatingActionButton.extended(onPressed:()=>edit(),icon:const Icon(Icons.person_add_alt_1),label:const Text('إضافة موظف')),
    body:loading?const Center(child:CircularProgressIndicator()):Column(children:[
      Container(width:double.infinity,padding:const EdgeInsets.all(18),color:const Color(0xFF0869B9),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('دليل الكادر الوظيفي',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.bold)),
        SizedBox(height:6),Text('تعريف بيانات الموظفين والوظائف والراتب الأساسي.',style:TextStyle(color:Colors.white70))
      ])),
      Padding(padding:const EdgeInsets.all(12),child:Row(children:[Expanded(child:Text('عدد الموظفين: ${staff.length}',style:const TextStyle(fontWeight:FontWeight.bold))),Text('مجموع الرواتب الأساسية: ${staff.fold<double>(0,(sum,x)=>sum+x.monthlySalary).toStringAsFixed(2)}',style:const TextStyle(color:Color(0xFF0869B9),fontWeight:FontWeight.bold))])),
      Expanded(child:staff.isEmpty?const Center(child:Text('لا توجد سجلات في الدليل بعد.')):ListView.builder(padding:const EdgeInsets.fromLTRB(12,0,12,80),itemCount:staff.length,itemBuilder:(c,i){final x=staff[i];return Card(child:ListTile(
        leading:const CircleAvatar(child:Icon(Icons.badge_outlined)),
        title:Text(x.name,style:const TextStyle(fontWeight:FontWeight.bold)),
        subtitle:Text('${x.role} • ${x.phone.isEmpty?'لا يوجد هاتف':x.phone}\nالراتب الأساسي: ${x.monthlySalary.toStringAsFixed(2)} • العمولة: ${x.commissionPercent}% • أجر الجلسة: ${x.sessionFee.toStringAsFixed(2)}'),
        isThreeLine:true,
        trailing:PopupMenuButton<String>(onSelected:(v){if(v=='edit')edit(x);if(v=='delete')remove(x);},itemBuilder:(_)=>[const PopupMenuItem(value:'edit',child:Text('تعديل البيانات')),const PopupMenuItem(value:'delete',child:Text('حذف السجل'))]),
      ));}))
    ])
  ));
}
