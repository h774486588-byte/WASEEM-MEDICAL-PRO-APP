import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'storage.dart';
import 'models.dart';
class ReportsPage extends StatelessWidget{
 const ReportsPage({super.key});
 Future<Map<String,num>> data()async{final p=await LocalStore.patients(),a=await LocalStore.appointments(),g=await LocalStore.packages(),i=await LocalStore.invoices();return {'patients':p.length,'appointments':a.length,'packages':g.length,'sessions':g.fold<num>(0,(s,x)=>s+x.sessions-x.remaining),'revenue':i.fold<num>(0,(s,x)=>s+x.paid),'outstanding':i.fold<num>(0,(s,x)=>s+x.remaining)};}
 @override Widget build(BuildContext c)=>FutureBuilder<Map<String,num>>(future:data(),builder:(c,s){final d=s.data??{};return ListView(padding:const EdgeInsets.all(16),children:[const Text('التقارير',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),const SizedBox(height:14),_R('إجمالي المرضى',(d['patients']??0).toString(),Icons.people),_R('إجمالي المواعيد',(d['appointments']??0).toString(),Icons.event),_R('الباقات',(d['packages']??0).toString(),Icons.inventory_2),_R('الجلسات المنفذة',(d['sessions']??0).toString(),Icons.medical_services),_R('إجمالي المدفوع',(d['revenue']??0).toStringAsFixed(0),Icons.payments),_R('إجمالي المتبقي',(d['outstanding']??0).toStringAsFixed(0),Icons.account_balance_wallet)]);});
}
class _R extends StatelessWidget{final String t,v;final IconData i;const _R(this.t,this.v,this.i);@override Widget build(BuildContext c)=>Card(child:ListTile(leading:Icon(i,color:Theme.of(c).colorScheme.primary),title:Text(t),trailing:Text(v,style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold))));}
class SettingsPage extends StatefulWidget{const SettingsPage({super.key});@override State<SettingsPage> createState()=>_SettingsPageState();}
class _SettingsPageState extends State<SettingsPage>{final name=TextEditingController(),phone=TextEditingController(),address=TextEditingController();bool whatsapp=false,sms=false;
 @override void initState(){super.initState();_load();}
 Future<void> _load()async{final s=await LocalStore.settings();name.text=s['name']??'نظام وسيم الطبي PRO';phone.text=s['phone']??'';address.text=s['address']??'';if(mounted)setState((){whatsapp=s['whatsapp']=='true';sms=s['sms']=='true';});}
 Future<void> _save()async{await LocalStore.saveSettings({'name':name.text.trim(),'phone':phone.text.trim(),'address':address.text.trim(),'whatsapp':'$whatsapp','sms':'$sms'});if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم حفظ إعدادات المركز')));}
 Future<void> _exportBackup() async {
   try {
     final data=await LocalStore.exportData();
     final json=const JsonEncoder.withIndent('  ').convert({'app':'WASEEM MEDICAL PRO','schemaVersion':1,'exportedAt':DateTime.now().toIso8601String(),'data':data});
     await Clipboard.setData(ClipboardData(text:json));
     if(!mounted)return;
     await showDialog<void>(context:context,builder:(ctx)=>AlertDialog(title:const Text('تم تجهيز النسخة الاحتياطية'),content:const Text('تم نسخ بيانات التطبيق بصيغة JSON إلى الحافظة. احفظها في ملف نصي آمن. تحتوي النسخة على بيانات المرضى، لذا لا تشاركها مع الآخرين.'),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('حسنًا'))]));
   } catch(e) { if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('تعذر إنشاء النسخة الاحتياطية: $e'))); }
 }
 Future<void> _importBackup() async {
   final controller=TextEditingController();
   final raw=await showDialog<String>(context:context,builder:(ctx)=>Directionality(textDirection:TextDirection.rtl,child:AlertDialog(title:const Text('استعادة نسخة احتياطية'),content:SizedBox(width:480,child:TextField(controller:controller,maxLines:9,decoration:const InputDecoration(hintText:'الصق محتوى ملف JSON هنا',border:OutlineInputBorder()))),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(ctx,controller.text),child:const Text('استعادة البيانات'))])));
   if(raw==null||raw.trim().isEmpty)return;
   try {
     final decoded=jsonDecode(raw);
     if(decoded is! Map<String,dynamic> || decoded['app']!='WASEEM MEDICAL PRO' || decoded['data'] is! Map) throw const FormatException('ملف النسخة الاحتياطية غير صالح أو غير معروف.');
     final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('تأكيد الاستعادة'),content:const Text('ستُستبدل البيانات المحلية الموجودة بالبيانات الموجودة في النسخة الاحتياطية. هل تريد المتابعة؟'),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('متابعة'))]));
     if(ok!=true)return;
     await LocalStore.importData(Map<String,dynamic>.from(decoded['data'] as Map));
     if(!mounted)return;
     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تمت استعادة النسخة الاحتياطية. أعد فتح الأقسام لتحديث البيانات.')));
   } catch(e) { if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('فشلت الاستعادة: $e'))); }
   finally { controller.dispose(); }
 }
 @override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:const Text('إعدادات المركز')),body:ListView(padding:const EdgeInsets.all(16),children:[TextField(controller:name,decoration:const InputDecoration(labelText:'اسم المركز',prefixIcon:Icon(Icons.business))),const SizedBox(height:12),TextField(controller:phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'رقم التواصل',prefixIcon:Icon(Icons.phone))),const SizedBox(height:12),TextField(controller:address,decoration:const InputDecoration(labelText:'العنوان',prefixIcon:Icon(Icons.location_on))),const SizedBox(height:8),SwitchListTile(title:const Text('تفعيل قناة WhatsApp'),value:whatsapp,onChanged:(v)=>setState(()=>whatsapp=v)),SwitchListTile(title:const Text('تفعيل قناة SMS'),value:sms,onChanged:(v)=>setState(()=>sms=v)),const SizedBox(height:12),FilledButton.icon(onPressed:_save,icon:const Icon(Icons.save),label:const Text('حفظ الإعدادات')),const SizedBox(height:10),OutlinedButton.icon(onPressed:_exportBackup,icon:const Icon(Icons.backup_outlined),label:const Text('تصدير نسخة احتياطية')),const SizedBox(height:8),OutlinedButton.icon(onPressed:_importBackup,icon:const Icon(Icons.restore_rounded),label:const Text('استعادة نسخة احتياطية')),const SizedBox(height:20),const Card(child:Padding(padding:EdgeInsets.all(14),child:Text('تفعيل القناة يجهز النظام للتكامل، أما الإرسال الآلي الحقيقي فيحتاج بيانات مزود WhatsApp Business أو SMS Gateway.')))])));
}


class InventoryPage extends StatefulWidget {
 const InventoryPage({super.key});
 @override State<InventoryPage> createState()=>_InventoryPageState();
}
class _InventoryPageState extends State<InventoryPage> {
 Future<void> _addItem() async {
  final suppliers=await LocalStore.suppliers();
  final name=TextEditingController(),code=TextEditingController(),unit=TextEditingController(text:'قطعة'),qty=TextEditingController(text:'0'),cost=TextEditingController(text:'0'),sell=TextEditingController(text:'0');
  String supplierId='';
  final ok=await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,setDialog)=>Directionality(textDirection:TextDirection.rtl,child:AlertDialog(title:const Text('إضافة صنف للمخزون'),content:SizedBox(width:440,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
   TextField(controller:name,decoration:const InputDecoration(labelText:'اسم الصنف *')),const SizedBox(height:8),
   TextField(controller:code,decoration:const InputDecoration(labelText:'الباركود / رمز الصنف')),const SizedBox(height:8),
   TextField(controller:unit,decoration:const InputDecoration(labelText:'وحدة القياس')),const SizedBox(height:8),
   TextField(controller:qty,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'الكمية الافتتاحية')),const SizedBox(height:8),
   TextField(controller:cost,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'تكلفة الوحدة')),const SizedBox(height:8),
   TextField(controller:sell,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'سعر البيع للوحدة')),
   const SizedBox(height:8),DropdownButtonFormField<String>(value:supplierId,decoration:const InputDecoration(labelText:'المورد (اختياري)'),items:[const DropdownMenuItem(value:'',child:Text('بدون مورد')),...suppliers.map((x)=>DropdownMenuItem(value:x.id,child:Text(x.name)))],onChanged:(v)=>setDialog(()=>supplierId=v??''))
  ]))),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('حفظ الصنف'))]))));
  if(ok==true&&name.text.trim().isNotEmpty){
   final q=double.tryParse(qty.text)??-1,co=double.tryParse(cost.text)??-1,sp=double.tryParse(sell.text)??-1;
   if(q<0||co<0||sp<0){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أدخل كميات وأسعار صحيحة غير سالبة')));}
   else {final list=await LocalStore.inventory();list.add(InventoryItem(id:DateTime.now().microsecondsSinceEpoch.toString(),name:name.text.trim(),code:code.text.trim(),unit:unit.text.trim().isEmpty?'قطعة':unit.text.trim(),quantity:q,cost:co,sellPrice:sp,supplierId:supplierId));await LocalStore.saveInventory(list);if(mounted)setState((){});}
  }
  name.dispose();code.dispose();unit.dispose();qty.dispose();cost.dispose();sell.dispose();
 }
 Future<void> _addSupplier() async {
  final name=TextEditingController(),phone=TextEditingController(),address=TextEditingController(),notes=TextEditingController();
  final ok=await showDialog<bool>(context:context,builder:(ctx)=>Directionality(textDirection:TextDirection.rtl,child:AlertDialog(title:const Text('إضافة مورد'),content:SizedBox(width:420,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
   TextField(controller:name,decoration:const InputDecoration(labelText:'اسم المورد *')),const SizedBox(height:8),
   TextField(controller:phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'رقم الهاتف')),const SizedBox(height:8),
   TextField(controller:address,decoration:const InputDecoration(labelText:'العنوان')),const SizedBox(height:8),
   TextField(controller:notes,decoration:const InputDecoration(labelText:'ملاحظات'))
  ]))),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('حفظ المورد'))])));
  if(ok==true&&name.text.trim().isNotEmpty){final list=await LocalStore.suppliers();list.add(Supplier(id:DateTime.now().microsecondsSinceEpoch.toString(),name:name.text.trim(),phone:phone.text.trim(),address:address.text.trim(),notes:notes.text.trim()));await LocalStore.saveSuppliers(list);if(mounted)setState((){});}
  name.dispose();phone.dispose();address.dispose();notes.dispose();
 }
 Future<void> _sell(InventoryItem item) async {
  final quantity=TextEditingController(text:'1'),price=TextEditingController(text:item.sellPrice.toStringAsFixed(2));
  final ok=await showDialog<bool>(context:context,builder:(ctx)=>Directionality(textDirection:TextDirection.rtl,child:AlertDialog(title:Text('بيع: ${item.name}'),content:Column(mainAxisSize:MainAxisSize.min,children:[
   Text('المتوفر: ${item.quantity} ${item.unit}'),const SizedBox(height:8),
   TextField(controller:quantity,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'الكمية المباعة')),
   const SizedBox(height:8),TextField(controller:price,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'سعر بيع الوحدة'))
  ]),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('تأكيد البيع'))])));
  if(ok==true){
   final q=double.tryParse(quantity.text)??0,p=double.tryParse(price.text)??-1;
   if(q<=0||q>item.quantity||p<0){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تحقق من الكمية المتاحة وسعر البيع')));}
   else{
    final items=await LocalStore.inventory();final index=items.indexWhere((x)=>x.id==item.id);
    if(index>=0){items[index]=InventoryItem(id:item.id,name:item.name,unit:item.unit,code:item.code,quantity:item.quantity-q,cost:item.cost,sellPrice:item.sellPrice,supplierId:item.supplierId);await LocalStore.saveInventory(items);}
    final all=await LocalStore.sales();all.add(InventorySale(id:DateTime.now().microsecondsSinceEpoch.toString(),itemId:item.id,itemName:item.name,date:DateTime.now().toIso8601String().substring(0,10),quantity:q,unitPrice:p,total:q*p,costTotal:q*item.cost));await LocalStore.saveSales(all);
    if(mounted){setState((){});ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('تم تسجيل البيع: ${(q*p).toStringAsFixed(2)}')));}
   }
  }
  quantity.dispose();price.dispose();
 }
 String _supplierName(String id,List<Supplier> suppliers){for(final s in suppliers){if(s.id==id)return s.name;}return 'بدون مورد';}
 @override Widget build(BuildContext context)=>FutureBuilder(future:Future.wait([LocalStore.inventory(),LocalStore.sales(),LocalStore.suppliers()]),builder:(context,s){
  if(!s.hasData)return const Center(child:CircularProgressIndicator());
  final items=s.data![0] as List<InventoryItem>,sales=s.data![1] as List<InventorySale>,suppliers=s.data![2] as List<Supplier>;
  final stockValue=items.fold<double>(0,(v,x)=>v+x.quantity*x.cost);
  final revenue=sales.fold<double>(0,(v,x)=>v+x.total),profit=sales.fold<double>(0,(v,x)=>v+x.profit);
  return DefaultTabController(length:3,child:Column(children:[
   const Material(color:Color(0xFF0869B9),child:TabBar(isScrollable:true,labelColor:Colors.white,unselectedLabelColor:Colors.white70,indicatorColor:Colors.white,tabs:[Tab(icon:Icon(Icons.inventory_2_outlined),text:'المخزون'),Tab(icon:Icon(Icons.point_of_sale),text:'المبيعات'),Tab(icon:Icon(Icons.local_shipping_outlined),text:'الموردون')])),
   Expanded(child:TabBarView(children:[
    ListView(padding:const EdgeInsets.all(16),children:[
     Row(children:[const Expanded(child:Text('الأصناف والمخزون',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold))),IconButton.filled(onPressed:_addItem,icon:const Icon(Icons.add))]),
     Card(child:ListTile(leading:const Icon(Icons.account_balance_wallet_outlined),title:const Text('قيمة المخزون بالتكلفة'),trailing:Text(stockValue.toStringAsFixed(2),style:const TextStyle(fontWeight:FontWeight.bold,fontSize:18)))),
     const SizedBox(height:10),if(items.isEmpty)const Padding(padding:EdgeInsets.all(24),child:Center(child:Text('لا توجد أصناف. أضف صنفًا للبدء.'))),
     for(final item in items)Card(margin:const EdgeInsets.only(bottom:8),child:ListTile(
      leading:const CircleAvatar(child:Icon(Icons.inventory_2)),title:Text(item.name,style:const TextStyle(fontWeight:FontWeight.bold)),
      subtitle:Text('${item.code.isEmpty?'بدون باركود':item.code} • المتوفر ${item.quantity} ${item.unit}\nالتكلفة ${item.cost.toStringAsFixed(2)} • البيع ${item.sellPrice.toStringAsFixed(2)}\nالمورد: ${_supplierName(item.supplierId,suppliers)}'),
      isThreeLine:true,trailing:PopupMenuButton<String>(onSelected:(v){if(v=='sell')_sell(item);},itemBuilder:(_)=>[const PopupMenuItem(value:'sell',child:Text('بيع هذا الصنف'))],icon:const Icon(Icons.more_vert))))
    ]),
    ListView(padding:const EdgeInsets.all(16),children:[
     const Text('ملخص المبيعات',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),const SizedBox(height:10),
     Row(children:[Expanded(child:Card(child:ListTile(title:const Text('إجمالي المبيع'),subtitle:Text(revenue.toStringAsFixed(2),style:const TextStyle(fontSize:19,fontWeight:FontWeight.bold))))),const SizedBox(width:8),Expanded(child:Card(child:ListTile(title:const Text('الربح التقديري'),subtitle:Text(profit.toStringAsFixed(2),style:const TextStyle(fontSize:19,fontWeight:FontWeight.bold,color:Colors.green))))) ]),
     const SizedBox(height:12),if(sales.isEmpty)const Padding(padding:EdgeInsets.all(24),child:Center(child:Text('لا توجد مبيعات مسجلة بعد.'))),
     for(final sale in sales.reversed)Card(margin:const EdgeInsets.only(bottom:8),child:ListTile(leading:const Icon(Icons.receipt_long),title:Text(sale.itemName),subtitle:Text('${sale.date} • الكمية ${sale.quantity} • سعر الوحدة ${sale.unitPrice.toStringAsFixed(2)}'),isThreeLine:true,trailing:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.end,children:[Text(sale.total.toStringAsFixed(2),style:const TextStyle(fontWeight:FontWeight.bold)),Text('ربح ${sale.profit.toStringAsFixed(2)}',style:const TextStyle(fontSize:11,color:Colors.green))])))
    ]),
    ListView(padding:const EdgeInsets.all(16),children:[
     Row(children:[const Expanded(child:Text('الموردون',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold))),IconButton.filled(onPressed:_addSupplier,icon:const Icon(Icons.person_add_alt_1))]),
     const SizedBox(height:10),if(suppliers.isEmpty)const Padding(padding:EdgeInsets.all(24),child:Center(child:Text('أضف الموردين لربطهم بالأصناف.'))),
     for(final supplier in suppliers)Card(margin:const EdgeInsets.only(bottom:8),child:ListTile(leading:const CircleAvatar(child:Icon(Icons.local_shipping_outlined)),title:Text(supplier.name,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('${supplier.phone}\n${supplier.address}'),isThreeLine:true))
    ])
   ]))
  ]));
 });
}
class StaffPage extends StatefulWidget { const StaffPage({super.key}); @override State<StaffPage> createState()=>_StaffPageState(); }
class _StaffPageState extends State<StaffPage> {
 Future<void> _add() async {
  final name=TextEditingController(),role=TextEditingController(),phone=TextEditingController();
  final ok=await showDialog<bool>(context:context,builder:(ctx)=>Directionality(textDirection:TextDirection.rtl,child:AlertDialog(title:const Text('إضافة عضو للطاقم'),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:name,decoration:const InputDecoration(labelText:'الاسم *')),const SizedBox(height:8),TextField(controller:role,decoration:const InputDecoration(labelText:'التخصص / الوظيفة')),const SizedBox(height:8),TextField(controller:phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'رقم الهاتف'))]),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('حفظ'))])));
  if(ok==true&&name.text.trim().isNotEmpty){final list=await LocalStore.staff();list.add(StaffMember(id:DateTime.now().microsecondsSinceEpoch.toString(),name:name.text.trim(),role:role.text.trim(),phone:phone.text.trim()));await LocalStore.saveStaff(list);if(mounted)setState((){});}
  name.dispose();role.dispose();phone.dispose();
 }
 Future<void> _delete(StaffMember person)async{final list=await LocalStore.staff();list.removeWhere((x)=>x.id==person.id);await LocalStore.saveStaff(list);if(mounted)setState((){});}
 @override Widget build(BuildContext context)=>FutureBuilder<List<StaffMember>>(future:LocalStore.staff(),builder:(context,s){final list=s.data??[];return ListView(padding:const EdgeInsets.all(16),children:[
  Row(children:[const Expanded(child:Text('الطاقم الطبي',style:TextStyle(fontSize:23,fontWeight:FontWeight.bold))),IconButton.filled(onPressed:_add,icon:const Icon(Icons.person_add_alt_1))]),
  const SizedBox(height:12),if(list.isEmpty)const Padding(padding:EdgeInsets.all(24),child:Center(child:Text('لا يوجد أعضاء مسجلون. اضغط + لإضافة الطبيب أو الأخصائي أو الموظف.'))),
  for(final person in list)Card(margin:const EdgeInsets.only(bottom:8),child:ListTile(leading:const CircleAvatar(child:Icon(Icons.medical_services_outlined)),title:Text(person.name,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('${person.role.isEmpty?'بدون تخصص محدد':person.role}${person.phone.isEmpty?'':' • '+person.phone}'),trailing:IconButton(onPressed:()=>_delete(person),icon:const Icon(Icons.delete_outline,color:Colors.red))))
 ]);});
}
