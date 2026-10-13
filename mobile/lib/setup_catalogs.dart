import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// إعدادات التعريف الأساسية: الأقسام والخدمات والباقات القابلة لإعادة الاستخدام.
class ServiceDirectoryPage extends StatefulWidget {
  const ServiceDirectoryPage({super.key});
  @override State<ServiceDirectoryPage> createState()=>_ServiceDirectoryPageState();
}
class _ServiceDirectoryPageState extends State<ServiceDirectoryPage> {
  List<Map<String,dynamic>> items=[];
  bool loading=true;
  @override void initState(){super.initState();load();}
  Future<void> load() async {
    final p=await SharedPreferences.getInstance();
    final raw=p.getStringList('service_directory_v1')??[];
    if(!mounted)return;
    setState(()=>items=raw.map((e)=>Map<String,dynamic>.from(jsonDecode(e) as Map)).toList()..sort((a,b)=>(a['name']??'').toString().compareTo((b['name']??'').toString())));
    setState(()=>loading=false);
  }
  Future<void> save() async {
    final p=await SharedPreferences.getInstance();
    await p.setStringList('service_directory_v1',items.map(jsonEncode).toList());
  }
  Future<void> edit([Map<String,dynamic>? old]) async {
    final name=TextEditingController(text:(old?['name']??'').toString());
    final dept=TextEditingController(text:(old?['department']??'').toString());
    final price=TextEditingController(text:(old?['price']??'').toString());
    final duration=TextEditingController(text:(old?['duration']??'').toString());
    final desc=TextEditingController(text:(old?['description']??'').toString());
    final result=await showDialog<Map<String,dynamic>>(context:context,builder:(ctx)=>AlertDialog(
      title:Text(old==null?'إضافة خدمة':'تعديل الخدمة'),
      content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:name,decoration:const InputDecoration(labelText:'اسم الخدمة *')),
        TextField(controller:dept,decoration:const InputDecoration(labelText:'القسم *')),
        TextField(controller:price,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'السعر الأساسي')),
        TextField(controller:duration,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'المدة بالدقائق')),
        TextField(controller:desc,decoration:const InputDecoration(labelText:'الوصف')),
      ])),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('إلغاء')),FilledButton(onPressed:(){
        final n=name.text.trim(),d=dept.text.trim(),p=double.tryParse(price.text.trim())??0;
        if(n.isEmpty||d.isEmpty||p<0){ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content:Text('أدخل اسم الخدمة والقسم وسعرًا صحيحًا')));return;}
        Navigator.pop(ctx,{'id':old?['id']??DateTime.now().microsecondsSinceEpoch.toString(),'name':n,'department':d,'price':p,'duration':int.tryParse(duration.text)??0,'description':desc.text.trim(),'active':old?['active']??true});
      },child:const Text('حفظ'))]
    ));
    if(result==null)return;
    setState((){final i=items.indexWhere((x)=>x['id']==result['id']);if(i<0){items.add(result);}else{items[i]=result;}});
    await save();
  }
  Future<void> toggle(Map<String,dynamic> item) async {setState(()=>item['active']=!(item['active'] as bool? ?? true));await save();}
  @override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(
    floatingActionButton:FloatingActionButton.extended(onPressed:()=>edit(),icon:const Icon(Icons.add),label:const Text('إضافة خدمة')),
    body:loading?const Center(child:CircularProgressIndicator()):Column(children:[
      Container(width:double.infinity,padding:const EdgeInsets.all(18),color:const Color(0xFF0869B9),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('دليل الخدمات والأقسام',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.bold)),
        SizedBox(height:6),Text('عرّف الخدمات وأسعارها ومددها مرة واحدة لاستخدامها في التشغيل اليومي.',style:TextStyle(color:Colors.white70))
      ])),
      Expanded(child:items.isEmpty?const Center(child:Text('لا توجد خدمات بعد. اضغط «إضافة خدمة» للبدء.')):ListView.builder(padding:const EdgeInsets.all(12),itemCount:items.length,itemBuilder:(c,i){
        final x=items[i];final active=x['active'] as bool? ?? true;
        return Card(child:ListTile(
          leading:CircleAvatar(backgroundColor:active?const Color(0xFFE8F3FF):Colors.grey.shade200,child:Icon(Icons.medical_services_outlined,color:active?const Color(0xFF0869B9):Colors.grey)),
          title:Text((x['name']??'').toString(),style:const TextStyle(fontWeight:FontWeight.bold)),
          subtitle:Text('القسم: ${x['department']} • السعر: ${x['price']} • المدة: ${x['duration']} دقيقة\n${x['description']??''}'),
          isThreeLine:true,
          trailing:PopupMenuButton<String>(onSelected:(v){if(v=='edit')edit(x);if(v=='toggle')toggle(x);},itemBuilder:(_)=>[const PopupMenuItem(value:'edit',child:Text('تعديل')),PopupMenuItem(value:'toggle',child:Text(active?'تعطيل':'تفعيل'))]),
        ));
      }))
    ])
  ));
}

class PackageDirectoryPage extends StatefulWidget {
  const PackageDirectoryPage({super.key});
  @override State<PackageDirectoryPage> createState()=>_PackageDirectoryPageState();
}
class _PackageDirectoryPageState extends State<PackageDirectoryPage> {
  List<Map<String,dynamic>> items=[]; bool loading=true;
  @override void initState(){super.initState();load();}
  Future<void> load()async{final p=await SharedPreferences.getInstance();final raw=p.getStringList('package_catalog_v1')??[];if(!mounted)return;setState(()=>items=raw.map((e)=>Map<String,dynamic>.from(jsonDecode(e) as Map)).toList());setState(()=>loading=false);}
  Future<void> save()async{final p=await SharedPreferences.getInstance();await p.setStringList('package_catalog_v1',items.map(jsonEncode).toList());}
  Future<void> edit([Map<String,dynamic>? old])async{
    final name=TextEditingController(text:(old?['name']??'').toString()),sessions=TextEditingController(text:(old?['sessions']??'').toString()),price=TextEditingController(text:(old?['price']??'').toString()),days=TextEditingController(text:(old?['validDays']??'').toString()),details=TextEditingController(text:(old?['details']??'').toString());
    final result=await showDialog<Map<String,dynamic>>(context:context,builder:(ctx)=>AlertDialog(title:Text(old==null?'تعريف باقة جديدة':'تعديل تعريف الباقة'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      TextField(controller:name,decoration:const InputDecoration(labelText:'اسم الباقة *')),
      TextField(controller:sessions,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'عدد الجلسات *')),
      TextField(controller:price,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'السعر الإجمالي *')),
      TextField(controller:days,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'مدة الصلاحية بالأيام')),
      TextField(controller:details,decoration:const InputDecoration(labelText:'الخدمات أو الشروط')),
    ])),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('إلغاء')),FilledButton(onPressed:(){
      final n=name.text.trim(),s=int.tryParse(sessions.text)??0,p=double.tryParse(price.text)??-1;
      if(n.isEmpty||s<1||p<0){ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content:Text('تحقق من الاسم وعدد الجلسات والسعر')));return;}
      Navigator.pop(ctx,{'id':old?['id']??DateTime.now().microsecondsSinceEpoch.toString(),'name':n,'sessions':s,'price':p,'validDays':int.tryParse(days.text)??0,'details':details.text.trim(),'active':old?['active']??true});
    },child:const Text('حفظ'))]));
    if(result==null)return;setState((){final i=items.indexWhere((x)=>x['id']==result['id']);if(i<0)items.add(result);else items[i]=result;});await save();
  }
  Future<void> toggle(Map<String,dynamic> item)async{setState(()=>item['active']=!(item['active'] as bool? ?? true));await save();}
  @override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(
    floatingActionButton:FloatingActionButton.extended(onPressed:()=>edit(),icon:const Icon(Icons.add),label:const Text('تعريف باقة')),
    body:loading?const Center(child:CircularProgressIndicator()):Column(children:[
      Container(width:double.infinity,padding:const EdgeInsets.all(18),color:const Color(0xFF0869B9),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('دليل الباقات والجلسات',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.bold)),
        SizedBox(height:6),Text('عرّف اسم الباقة وسعرها وعدد الجلسات قبل تسجيلها للمرضى.',style:TextStyle(color:Colors.white70))
      ])),
      Expanded(child:items.isEmpty?const Center(child:Text('لم تتم إضافة باقات إلى الدليل بعد.')):ListView.builder(padding:const EdgeInsets.all(12),itemCount:items.length,itemBuilder:(c,i){
        final x=items[i];final active=x['active'] as bool? ?? true;
        return Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.layers_outlined)),title:Text((x['name']??'').toString(),style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('${x['sessions']} جلسة • السعر ${x['price']} • الصلاحية ${x['validDays']} يوم\n${x['details']??''}'),isThreeLine:true,trailing:PopupMenuButton<String>(onSelected:(v){if(v=='edit')edit(x);if(v=='toggle')toggle(x);},itemBuilder:(_)=>[const PopupMenuItem(value:'edit',child:Text('تعديل')),PopupMenuItem(value:'toggle',child:Text(active?'تعطيل':'تفعيل'))])));
      }))
    ])
  ));
}
