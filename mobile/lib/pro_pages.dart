import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'storage.dart';
import 'models.dart';
class ReportsPage extends StatelessWidget {
 const ReportsPage({super.key});

 Future<Map<String, num>> data() async {
  final patients = await LocalStore.patients();
  final appointments = await LocalStore.appointments();
  final packages = await LocalStore.packages();
  final invoices = await LocalStore.invoices();
  final expenses = await LocalStore.expenses();
  final payroll = await LocalStore.payrollEntries();
  final sales = await LocalStore.sales();
  final invoiceRevenue = invoices.fold<double>(0, (sum, item) => sum + item.paid);
  final stockRevenue = sales.fold<double>(0, (sum, item) => sum + item.total);
  final stockProfit = sales.fold<double>(0, (sum, item) => sum + item.profit);
  final expenseTotal = expenses.fold<double>(0, (sum, item) => sum + item.amount);
  final payrollPaid = payroll.where((item) => item.type == 'صرف راتب').fold<double>(0, (sum, item) => sum + item.amount);
  return {
   'patients': patients.length,
   'appointments': appointments.length,
   'packages': packages.length,
   'sessions': packages.fold<int>(0, (sum, item) => sum + item.sessions - item.remaining),
   'revenue': invoiceRevenue,
   'outstanding': invoices.fold<double>(0, (sum, item) => sum + item.remaining),
   'stockRevenue': stockRevenue,
   'stockProfit': stockProfit,
   'expenses': expenseTotal,
   'payrollPaid': payrollPaid,
   'netEstimate': invoiceRevenue + stockRevenue - expenseTotal - payrollPaid,
  };
 }

 @override
 Widget build(BuildContext context) => FutureBuilder<Map<String, num>>(
  future: data(),
  builder: (context, snapshot) {
   final d = snapshot.data ?? <String, num>{};
   String money(String key) => (d[key] ?? 0).toStringAsFixed(2);
   return ListView(
    padding: const EdgeInsets.all(16),
    children: [
     const Text('التقارير', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
     const SizedBox(height: 14),
     if (snapshot.connectionState == ConnectionState.waiting)
      const LinearProgressIndicator(),
     _R('إجمالي المرضى', (d['patients'] ?? 0).toString(), Icons.people),
     _R('إجمالي المواعيد', (d['appointments'] ?? 0).toString(), Icons.event),
     _R('الباقات المسجلة', (d['packages'] ?? 0).toString(), Icons.inventory_2),
     _R('الجلسات المنفذة', (d['sessions'] ?? 0).toString(), Icons.medical_services),
     _R('المدفوع من فواتير المرضى', money('revenue'), Icons.payments),
     _R('المتبقي على فواتير المرضى', money('outstanding'), Icons.account_balance_wallet),
     _R('إيرادات مبيعات المخزون', money('stockRevenue'), Icons.point_of_sale),
     _R('الربح التقديري للمخزون', money('stockProfit'), Icons.trending_up),
     _R('المصروفات التشغيلية المسجلة', money('expenses'), Icons.money_off_csred_outlined),
     _R('إجمالي الرواتب المصروفة', money('payrollPaid'), Icons.badge_outlined),
     _R('صافي التدفق النقدي التقديري', money('netEstimate'), Icons.account_balance_outlined),
     const Padding(
      padding: EdgeInsets.only(top: 8),
      child: Text(
       'ملخص تقديري يعتمد على الحركات المسجلة محلياً. راجع القيود والدفعات قبل استخدامه كتقرير محاسبي نهائي.',
       style: TextStyle(color: Colors.black54, fontSize: 12),
      ),
     ),
    ],
   );
  },
 );
}
class _R extends StatelessWidget{final String t,v;final IconData i;const _R(this.t,this.v,this.i);@override Widget build(BuildContext c)=>Card(child:ListTile(leading:Icon(i,color:Theme.of(c).colorScheme.primary),title:Text(t),trailing:Text(v,style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold))));}
class SettingsPage extends StatefulWidget{const SettingsPage({super.key});@override State<SettingsPage> createState()=>_SettingsPageState();}
class _SettingsPageState extends State<SettingsPage>{final name=TextEditingController(),phone=TextEditingController(),address=TextEditingController();bool whatsapp=true,sms=true;
 @override void initState(){super.initState();_load();}
 Future<void> _load()async{final s=await LocalStore.settings();name.text=s['name']??'نظام وسيم الطبي PRO';phone.text=s['phone']??'';address.text=s['address']??'';if(mounted)setState((){whatsapp=s['whatsapp']!='false';sms=s['sms']!='false';});}
 Future<void> _save()async{await LocalStore.saveSettings({'name':name.text.trim(),'phone':phone.text.trim(),'address':address.text.trim(),'whatsapp':'$whatsapp','sms':'$sms'});if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم حفظ إعدادات المركز')));}
 Future<void> _contactSupport(bool whatsapp) async {
   final uri=whatsapp
     ? Uri.parse('https://wa.me/967774486588?text=${Uri.encodeComponent('مرحباً وسيم الفرح، أحتاج إلى دعم فني لنظام وسيم الطبي PRO.')}') 
     : Uri(scheme:'tel',path:'774486588');
   if(!await launchUrl(uri,mode:LaunchMode.externalApplication) && mounted){
     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تعذر فتح تطبيق التواصل على هذا الجهاز.')));
   }
 }
 Future<void> _forgetTrustedDevice() async {
   final prefs=await SharedPreferences.getInstance();
   await prefs.remove('waseem_trusted_device');
   if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم إلغاء تذكر هذا الجهاز. سيُطلب تسجيل الدخول عند فتح التطبيق لاحقاً.')));
 }
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
 @override Widget build(BuildContext c)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:const Text('إعدادات المركز')),body:ListView(padding:const EdgeInsets.all(16),children:[TextField(controller:name,decoration:const InputDecoration(labelText:'اسم المركز',prefixIcon:Icon(Icons.business))),const SizedBox(height:12),TextField(controller:phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'رقم التواصل',prefixIcon:Icon(Icons.phone))),const SizedBox(height:12),TextField(controller:address,decoration:const InputDecoration(labelText:'العنوان',prefixIcon:Icon(Icons.location_on))),const SizedBox(height:8),SwitchListTile(title:const Text('تفعيل قناة WhatsApp'),value:whatsapp,onChanged:(v)=>setState(()=>whatsapp=v)),SwitchListTile(title:const Text('تفعيل قناة SMS'),value:sms,onChanged:(v)=>setState(()=>sms=v)),const SizedBox(height:12),FilledButton.icon(onPressed:_save,icon:const Icon(Icons.save),label:const Text('حفظ الإعدادات')),const SizedBox(height:10),OutlinedButton.icon(onPressed:_exportBackup,icon:const Icon(Icons.backup_outlined),label:const Text('تصدير نسخة احتياطية')),const SizedBox(height:8),OutlinedButton.icon(onPressed:_importBackup,icon:const Icon(Icons.restore_rounded),label:const Text('استعادة نسخة احتياطية')),const SizedBox(height:20),const Card(child:Padding(padding:EdgeInsets.all(14),child:Text('تفعيل القناة يجهز النظام للتكامل، أما الإرسال الآلي الحقيقي فيحتاج بيانات مزود WhatsApp Business أو SMS Gateway.'))),const SizedBox(height:10),const Text('الدعم الفني — وسيم الفرح',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:8),OutlinedButton.icon(onPressed:()=>_contactSupport(true),icon:const Icon(Icons.chat,color:Colors.green),label:const Text('التواصل عبر واتساب: 774486588')),OutlinedButton.icon(onPressed:()=>_contactSupport(false),icon:const Icon(Icons.phone),label:const Text('الاتصال بالمطور: 774486588')),const SizedBox(height:10),OutlinedButton.icon(onPressed:_forgetTrustedDevice,icon:const Icon(Icons.phonelink_lock_outlined),label:const Text('إلغاء تذكر هذا الجهاز'))])));
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
class StaffPage extends StatefulWidget {
 const StaffPage({super.key});
 @override State<StaffPage> createState()=>_StaffPageState();
}
class _StaffPageState extends State<StaffPage> {
 Future<void> _add() async {
  final name=TextEditingController(),role=TextEditingController(),phone=TextEditingController(),salary=TextEditingController(text:'0');
  final ok=await showDialog<bool>(
   context:context,
   builder:(ctx)=>Directionality(
    textDirection:TextDirection.rtl,
    child:AlertDialog(
     title:const Text('إضافة عضو للطاقم'),
     content:SizedBox(
      width:420,
      child:SingleChildScrollView(
       child:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:name,decoration:const InputDecoration(labelText:'الاسم *')),
        const SizedBox(height:8),
        TextField(controller:role,decoration:const InputDecoration(labelText:'التخصص / الوظيفة')),
        const SizedBox(height:8),
        TextField(controller:phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'رقم الهاتف')),
        const SizedBox(height:8),
        TextField(controller:salary,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'الراتب الشهري الأساسي')),
       ]),
      ),
     ),
     actions:[
      TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('إلغاء')),
      FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('حفظ')),
     ],
    ),
   ),
  );
  if(ok==true&&name.text.trim().isNotEmpty){
   final monthlySalary=salary.text.trim().isEmpty?0.0:(double.tryParse(salary.text.trim())??-1.0);
   if(monthlySalary<0||!monthlySalary.isFinite){
    if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أدخل راتباً شهرياً صحيحاً غير سالب.')));
   }else{
    final list=await LocalStore.staff();
    list.add(StaffMember(id:DateTime.now().microsecondsSinceEpoch.toString(),name:name.text.trim(),role:role.text.trim(),phone:phone.text.trim(),monthlySalary:monthlySalary));
    await LocalStore.saveStaff(list);
    if(mounted)setState((){});
   }
  }
  name.dispose();role.dispose();phone.dispose();salary.dispose();
 }
 Future<void> _edit(StaffMember person) async {
  final name=TextEditingController(text:person.name);
  final role=TextEditingController(text:person.role);
  final phone=TextEditingController(text:person.phone);
  final salary=TextEditingController(text:person.monthlySalary.toStringAsFixed(2));
  final ok=await showDialog<bool>(
   context:context,
   builder:(ctx)=>Directionality(
    textDirection:TextDirection.rtl,
    child:AlertDialog(
     title:Text('تعديل بيانات • ${person.name}'),
     content:SizedBox(width:420,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      TextField(controller:name,decoration:const InputDecoration(labelText:'الاسم *')),
      const SizedBox(height:8),
      TextField(controller:role,decoration:const InputDecoration(labelText:'التخصص / الوظيفة')),
      const SizedBox(height:8),
      TextField(controller:phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'رقم الهاتف')),
      const SizedBox(height:8),
      TextField(controller:salary,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'الراتب الشهري الأساسي')),
     ]))),
     actions:[
      TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('إلغاء')),
      FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('حفظ التعديلات')),
     ],
    ),
   ),
  );
  if(ok==true){
   final value=salary.text.trim().isEmpty?0.0:(double.tryParse(salary.text.trim())??-1.0);
   if(name.text.trim().isEmpty||value<0||!value.isFinite){
    if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تحقق من الاسم والراتب.')));
   }else{
    final list=await LocalStore.staff();
    final index=list.indexWhere((x)=>x.id==person.id);
    if(index>=0){
     list[index]=StaffMember(id:person.id,name:name.text.trim(),role:role.text.trim(),phone:phone.text.trim(),monthlySalary:value);
     await LocalStore.saveStaff(list);
     if(mounted){setState((){});ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم تحديث بيانات الموظف.')));}
    }
   }
  }
  name.dispose();role.dispose();phone.dispose();salary.dispose();
 }
 Future<void> _delete(StaffMember person)async{
  final confirm=await showDialog<bool>(context:context,builder:(ctx)=>Directionality(textDirection:TextDirection.rtl,child:AlertDialog(
   title:const Text('حذف عضو الطاقم؟'),
   content:Text('سيتم حذف ${person.name} من قائمة الطاقم. ستظل سجلات الحضور والرواتب السابقة محفوظة.'),
   actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('حذف'))],
  )));
  if(confirm!=true)return;
  final list=await LocalStore.staff();list.removeWhere((x)=>x.id==person.id);await LocalStore.saveStaff(list);
  if(mounted)setState((){});
 }
 @override Widget build(BuildContext context)=>FutureBuilder<List<StaffMember>>(future:LocalStore.staff(),builder:(context,s){
  final list=s.data??[];
  return ListView(padding:const EdgeInsets.all(16),children:[
   Row(children:[const Expanded(child:Text('الطاقم الطبي',style:TextStyle(fontSize:23,fontWeight:FontWeight.bold))),IconButton.filled(onPressed:_add,icon:const Icon(Icons.person_add_alt_1))]),
   const SizedBox(height:12),
   if(list.isEmpty)const Padding(padding:EdgeInsets.all(24),child:Center(child:Text('لا يوجد أعضاء مسجلون. اضغط + لإضافة الطبيب أو الأخصائي أو الموظف.'))),
   for(final person in list)Card(margin:const EdgeInsets.only(bottom:8),child:ListTile(
    leading:const CircleAvatar(child:Icon(Icons.medical_services_outlined)),
    title:Text(person.name,style:const TextStyle(fontWeight:FontWeight.bold)),
    subtitle:Text('${person.role.isEmpty?'بدون تخصص محدد':person.role}${person.phone.isEmpty?'':' • '+person.phone}\nالراتب الشهري: ${person.monthlySalary.toStringAsFixed(2)}'),
    isThreeLine:true,
    trailing:Row(mainAxisSize:MainAxisSize.min,children:[
     IconButton(tooltip:'تعديل بيانات الموظف',onPressed:()=>_edit(person),icon:const Icon(Icons.edit_outlined)),
     IconButton(tooltip:'حذف الموظف',onPressed:()=>_delete(person),icon:const Icon(Icons.delete_outline,color:Colors.red)),
    ]),
   )),
  ]);
 });
}

String _financeDate(DateTime d)=>'${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
String _financeMonth(DateTime d)=>'${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}';
String _financeTime(DateTime d)=>'${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';

class FinancePage extends StatefulWidget {
 const FinancePage({super.key});
 @override State<FinancePage> createState()=>_FinancePageState();
}
class _FinancePageState extends State<FinancePage> {
 Future<Map<String,dynamic>> _load() async {
  final expenses=await LocalStore.expenses();
  final staff=await LocalStore.staff();
  final attendance=await LocalStore.attendance();
  final payroll=await LocalStore.payrollEntries();
  return {'expenses':expenses,'staff':staff,'attendance':attendance,'payroll':payroll};
 }
 Future<void> _addExpense() async {
  final title=TextEditingController(),amount=TextEditingController(),payee=TextEditingController(),notes=TextEditingController();
  String category='تشغيل وصيانة',method='نقدي';
  final ok=await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,setDialog)=>Directionality(
   textDirection:TextDirection.rtl,
   child:AlertDialog(
    title:const Text('تسجيل مصروف'),
    content:SizedBox(width:440,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
     TextField(controller:title,decoration:const InputDecoration(labelText:'بيان المصروف *')),
     const SizedBox(height:8),
     TextField(controller:amount,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'المبلغ *')),
     const SizedBox(height:8),
     DropdownButtonFormField<String>(initialValue:category,decoration:const InputDecoration(labelText:'التصنيف'),items:const[
      DropdownMenuItem(value:'تشغيل وصيانة',child:Text('تشغيل وصيانة')),
      DropdownMenuItem(value:'مستلزمات طبية',child:Text('مستلزمات طبية')),
      DropdownMenuItem(value:'إيجار وفواتير',child:Text('إيجار وفواتير')),
      DropdownMenuItem(value:'نقل ومواصلات',child:Text('نقل ومواصلات')),
      DropdownMenuItem(value:'أخرى',child:Text('أخرى')),
     ],onChanged:(v)=>setDialog(()=>category=v??'أخرى')),
     const SizedBox(height:8),
     TextField(controller:payee,decoration:const InputDecoration(labelText:'الجهة المستفيدة (اختياري)')),
     const SizedBox(height:8),
     DropdownButtonFormField<String>(initialValue:method,decoration:const InputDecoration(labelText:'طريقة الدفع'),items:const[
      DropdownMenuItem(value:'نقدي',child:Text('نقدي')),
      DropdownMenuItem(value:'تحويل بنكي',child:Text('تحويل بنكي')),
      DropdownMenuItem(value:'محفظة إلكترونية',child:Text('محفظة إلكترونية')),
     ],onChanged:(v)=>setDialog(()=>method=v??'نقدي')),
     const SizedBox(height:8),
     TextField(controller:notes,maxLines:2,decoration:const InputDecoration(labelText:'ملاحظات')),
    ]))),
    actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('حفظ المصروف'))],
   ),
  )));
  if(ok==true){
   final value=double.tryParse(amount.text.trim())??-1;
   if(title.text.trim().isEmpty||value<=0||!value.isFinite){
    if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أدخل بياناً ومبلغاً صحيحاً للمصروف.')));
   }else{
    final all=await LocalStore.expenses();
    all.add(ExpenseRecord(id:DateTime.now().microsecondsSinceEpoch.toString(),title:title.text.trim(),category:category,payee:payee.text.trim(),date:_financeDate(DateTime.now()),method:method,amount:value,notes:notes.text.trim()));
    await LocalStore.saveExpenses(all);
    if(mounted){setState((){});ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم حفظ المصروف.')));}
   }
  }
  title.dispose();amount.dispose();payee.dispose();notes.dispose();
 }
 AttendanceRecord? _attendanceFor(List<AttendanceRecord> all,String staffId,String date){
  for(final item in all){if(item.staffId==staffId&&item.date==date)return item;}
  return null;
 }
 Future<void> _recordAttendance(StaffMember person,String status) async {
  final today=_financeDate(DateTime.now());
  final now=DateTime.now();
  final all=await LocalStore.attendance();
  final index=all.indexWhere((x)=>x.staffId==person.id&&x.date==today);
  final record=AttendanceRecord(id:index>=0?all[index].id:DateTime.now().microsecondsSinceEpoch.toString(),staffId:person.id,staffName:person.name,date:today,status:status,checkIn:(status=='حاضر'||status=='متأخر')?_financeTime(now):'',notes:index>=0?all[index].notes:'');
  if(index>=0)all[index]=record;else all.add(record);
  await LocalStore.saveAttendance(all);
  if(mounted){setState((){});ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('تم تحديث حضور ${person.name}: $status')));}
 }
 double _usedPayroll(List<PayrollEntry> entries,String staffId,String month){
  return entries.where((x)=>x.staffId==staffId&&x.month==month&&(x.type=='صرف راتب'||x.type=='خصم')).fold<double>(0,(sum,x)=>sum+x.amount);
 }
 Future<void> _recordPayroll(StaffMember person) async {
  if(person.monthlySalary<=0){
   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('حدّد الراتب الشهري للموظف من شاشة الطاقم الطبي أولاً.')));
   return;
  }
  final month=_financeMonth(DateTime.now());
  final before=await LocalStore.payrollEntries();
  final dueBefore=(person.monthlySalary-_usedPayroll(before,person.id,month)).clamp(0.0,person.monthlySalary).toDouble();
  if(dueBefore<=0){
   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم تسوية راتب هذا الشهر بالكامل.')));
   return;
  }
  final amount=TextEditingController(),notes=TextEditingController();
  String type='صرف راتب',method='نقدي';
  final ok=await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,setDialog)=>Directionality(
   textDirection:TextDirection.rtl,
   child:AlertDialog(
    title:Text('حركة راتب • ${person.name}'),
    content:SizedBox(width:420,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
     Text('المتبقي من راتب الشهر: ${dueBefore.toStringAsFixed(2)}'),
     const SizedBox(height:8),
     DropdownButtonFormField<String>(initialValue:type,decoration:const InputDecoration(labelText:'نوع الحركة'),items:const[
      DropdownMenuItem(value:'صرف راتب',child:Text('صرف راتب')),
      DropdownMenuItem(value:'خصم',child:Text('خصم من الراتب')),
     ],onChanged:(v)=>setDialog(()=>type=v??'صرف راتب')),
     const SizedBox(height:8),
     TextField(controller:amount,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'المبلغ *')),
     const SizedBox(height:8),
     DropdownButtonFormField<String>(initialValue:method,decoration:const InputDecoration(labelText:'طريقة الدفع'),items:const[
      DropdownMenuItem(value:'نقدي',child:Text('نقدي')),
      DropdownMenuItem(value:'تحويل بنكي',child:Text('تحويل بنكي')),
      DropdownMenuItem(value:'محفظة إلكترونية',child:Text('محفظة إلكترونية')),
     ],onChanged:(v)=>setDialog(()=>method=v??'نقدي')),
     const SizedBox(height:8),
     TextField(controller:notes,maxLines:2,decoration:const InputDecoration(labelText:'ملاحظات')),
    ]))),
    actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('حفظ الحركة'))],
   ),
  )));
  if(ok==true){
   final value=double.tryParse(amount.text.trim())??-1;
   final latest=await LocalStore.payrollEntries();
   final due=(person.monthlySalary-_usedPayroll(latest,person.id,month)).clamp(0.0,person.monthlySalary).toDouble();
   if(value<=0||!value.isFinite||value>due){
    if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تحقق من المبلغ؛ لا يمكن أن يتجاوز المتبقي من الراتب.')));
   }else{
    latest.add(PayrollEntry(id:DateTime.now().microsecondsSinceEpoch.toString(),staffId:person.id,staffName:person.name,type:type,month:month,date:_financeDate(DateTime.now()),method:method,amount:value,notes:notes.text.trim()));
    await LocalStore.savePayrollEntries(latest);
    if(mounted){setState((){});ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم حفظ حركة الراتب.')));}
   }
  }
  amount.dispose();notes.dispose();
 }
 Future<void> _showPayrollHistory(StaffMember person) async {
  final all=await LocalStore.payrollEntries();
  final history=all.where((x)=>x.staffId==person.id).toList()..sort((a,b)=>b.date.compareTo(a.date));
  if(!mounted)return;
  await showDialog<void>(context:context,builder:(ctx)=>Directionality(textDirection:TextDirection.rtl,child:AlertDialog(
   title:Text('سجل الرواتب • ${person.name}'),
   content:SizedBox(width:440,child:history.isEmpty?const Text('لا توجد حركات رواتب مسجلة.'):ConstrainedBox(
    constraints:const BoxConstraints(maxHeight:420),
    child:ListView(shrinkWrap:true,children:[
     for(final item in history)ListTile(
      leading:Icon(item.type=='خصم'?Icons.remove_circle_outline:Icons.payments_outlined,color:item.type=='خصم'?Colors.red:Colors.green),
      title:Text('${item.type}: ${item.amount.toStringAsFixed(2)}'),
      subtitle:Text('${item.month} • ${item.date} • ${item.method}${item.notes.isEmpty?'':'\n'+item.notes}'),
     ),
    ]),
   )),
   actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('إغلاق'))],
  )));
 }
 @override Widget build(BuildContext context)=>FutureBuilder<Map<String,dynamic>>(future:_load(),builder:(context,s){
  if(!s.hasData)return const Center(child:CircularProgressIndicator());
  final expenses=s.data!['expenses'] as List<ExpenseRecord>;
  final staff=s.data!['staff'] as List<StaffMember>;
  final attendance=s.data!['attendance'] as List<AttendanceRecord>;
  final payroll=s.data!['payroll'] as List<PayrollEntry>;
  final today=_financeDate(DateTime.now()),month=_financeMonth(DateTime.now());
  final expenseTotal=expenses.fold<double>(0,(sum,x)=>sum+x.amount);
  final monthPayroll=payroll.where((x)=>x.month==month).toList();
  final monthPaid=monthPayroll.where((x)=>x.type=='صرف راتب').fold<double>(0,(sum,x)=>sum+x.amount);
  final monthDeductions=monthPayroll.where((x)=>x.type=='خصم').fold<double>(0,(sum,x)=>sum+x.amount);
  return DefaultTabController(length:3,child:Column(children:[
   const Material(color:Color(0xFF0869B9),child:TabBar(isScrollable:true,labelColor:Colors.white,unselectedLabelColor:Colors.white70,indicatorColor:Colors.white,tabs:[
    Tab(icon:Icon(Icons.money_off_csred_outlined),text:'المصروفات'),
    Tab(icon:Icon(Icons.fact_check_outlined),text:'الحضور'),
    Tab(icon:Icon(Icons.payments_outlined),text:'الرواتب والخصومات'),
   ])),
   Expanded(child:TabBarView(children:[
    ListView(padding:const EdgeInsets.all(16),children:[
     Row(children:[const Expanded(child:Text('سجل المصروفات',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold))),IconButton.filled(onPressed:_addExpense,icon:const Icon(Icons.add))]),
     Card(child:ListTile(leading:const Icon(Icons.account_balance_wallet_outlined),title:const Text('إجمالي المصروفات المسجلة'),subtitle:Text('${expenses.length} حركة'),trailing:Text(expenseTotal.toStringAsFixed(2),style:const TextStyle(fontWeight:FontWeight.bold,fontSize:18)))),
     const SizedBox(height:10),
     if(expenses.isEmpty)const Padding(padding:EdgeInsets.all(24),child:Center(child:Text('لا توجد مصروفات مسجلة.'))),
     for(final item in expenses.reversed)Card(margin:const EdgeInsets.only(bottom:8),child:ListTile(
      leading:const CircleAvatar(child:Icon(Icons.receipt_long_outlined)),
      title:Text(item.title,style:const TextStyle(fontWeight:FontWeight.bold)),
      subtitle:Text('${item.category} • ${item.date} • ${item.method}${item.payee.isEmpty?'':'\nالمستفيد: '+item.payee}${item.notes.isEmpty?'':'\n'+item.notes}'),
      isThreeLine:true,
      trailing:Text(item.amount.toStringAsFixed(2),style:const TextStyle(fontWeight:FontWeight.bold,color:Colors.red)),
     )),
    ]),
    ListView(padding:const EdgeInsets.all(16),children:[
     Row(children:[const Expanded(child:Text('حضور الطاقم',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold))),Text(today,style:const TextStyle(color:Colors.black54))]),
     const SizedBox(height:10),
     if(staff.isEmpty)const Padding(padding:EdgeInsets.all(24),child:Center(child:Text('أضف أعضاء الطاقم أولاً لتسجيل الحضور.'))),
     for(final person in staff)
      Builder(builder:(ctx){
       final record=_attendanceFor(attendance,person.id,today);
       return Card(margin:const EdgeInsets.only(bottom:8),child:ListTile(
        leading:CircleAvatar(child:Icon(record?.status=='غائب'?Icons.person_off_outlined:Icons.person_outline)),
        title:Text(person.name,style:const TextStyle(fontWeight:FontWeight.bold)),
        subtitle:Text('${person.role.isEmpty?'بدون تخصص':person.role} • ${record?.status??'لم يسجل بعد'}${record==null||record.checkIn.isEmpty?'':' • '+record.checkIn}'),
        trailing:PopupMenuButton<String>(
         tooltip:'تسجيل الحالة',
         onSelected:(v)=>_recordAttendance(person,v),
         itemBuilder:(_)=>const[
          PopupMenuItem(value:'حاضر',child:Text('حاضر')),
          PopupMenuItem(value:'متأخر',child:Text('متأخر')),
          PopupMenuItem(value:'غائب',child:Text('غائب')),
          PopupMenuItem(value:'إجازة',child:Text('إجازة')),
         ],
         icon:const Icon(Icons.edit_calendar_outlined),
        ),
       ));
      }),
    ]),
    ListView(padding:const EdgeInsets.all(16),children:[
     Row(children:[const Expanded(child:Text('الرواتب والخصومات',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold))),Text(month,style:const TextStyle(color:Colors.black54))]),
     Card(child:ListTile(leading:const Icon(Icons.payments_outlined),title:const Text('ملخص الحركات لهذا الشهر'),subtitle:Text('صرف: ${monthPaid.toStringAsFixed(2)} • خصومات: ${monthDeductions.toStringAsFixed(2)}'),trailing:Text((monthPaid+monthDeductions).toStringAsFixed(2),style:const TextStyle(fontWeight:FontWeight.bold)))),
     const SizedBox(height:10),
     if(staff.isEmpty)const Padding(padding:EdgeInsets.all(24),child:Center(child:Text('أضف أعضاء الطاقم وحدّد رواتبهم الشهرية أولاً.'))),
     for(final person in staff)
      Builder(builder:(ctx){
       final entries=payroll.where((x)=>x.staffId==person.id&&x.month==month).toList();
       final paid=entries.where((x)=>x.type=='صرف راتب').fold<double>(0,(sum,x)=>sum+x.amount);
       final deductions=entries.where((x)=>x.type=='خصم').fold<double>(0,(sum,x)=>sum+x.amount);
       final due=(person.monthlySalary-paid-deductions).clamp(0.0,person.monthlySalary).toDouble();
       return Card(margin:const EdgeInsets.only(bottom:10),child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(person.name,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:17)),
        Text(person.role.isEmpty?'موظف':'${person.role}',style:const TextStyle(color:Colors.black54)),
        const SizedBox(height:8),
        Wrap(spacing:14,runSpacing:6,children:[
         Text('الراتب: ${person.monthlySalary.toStringAsFixed(2)}'),
         Text('المصروف: ${paid.toStringAsFixed(2)}'),
         Text('الخصم: ${deductions.toStringAsFixed(2)}'),
         Text('المتبقي: ${due.toStringAsFixed(2)}',style:TextStyle(fontWeight:FontWeight.bold,color:due<=0?Colors.green:Colors.orange)),
        ]),
        const SizedBox(height:8),
        Row(mainAxisAlignment:MainAxisAlignment.end,children:[
         TextButton.icon(onPressed:()=>_showPayrollHistory(person),icon:const Icon(Icons.history),label:const Text('السجل')),
         const SizedBox(width:8),
         FilledButton.tonalIcon(onPressed:person.monthlySalary>0&&due>0?()=>_recordPayroll(person):null,icon:const Icon(Icons.add_card),label:const Text('صرف / خصم')),
        ]),
       ])));
      }),
    ]),
   ])),
  ]));
 });
}
