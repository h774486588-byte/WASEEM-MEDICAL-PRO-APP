import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'storage.dart';

/// Local JSON backup with an explicit restore confirmation.
/// Sharing the JSON lets the operator save it to a file, email, or cloud drive manually.
class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});
  @override State<BackupRestorePage> createState()=>_BackupRestorePageState();
}
class _BackupRestorePageState extends State<BackupRestorePage> {
  final restoreText=TextEditingController();
  bool exporting=false,restoring=false;
  String? lastBackup;
  @override void dispose(){restoreText.dispose();super.dispose();}

  Future<String> _makeBackup() async {
    final data=await LocalStore.exportData();
    return const JsonEncoder.withIndent('  ').convert({
      'format':'WASEEM_MEDICAL_PRO_BACKUP',
      'version':1,
      'createdAt':DateTime.now().toIso8601String(),
      'data':data,
    });
  }
  Future<void> exportBackup() async {
    setState(()=>exporting=true);
    try {
      final json=await _makeBackup();
      lastBackup=json;
      await Clipboard.setData(ClipboardData(text:json));
      if(!mounted)return;
      await Share.share(json,subject:'نسخة احتياطية - نظام وسيم الطبي PRO');
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم تجهيز النسخة الاحتياطية ونسخها. اختر حفظها في الملفات أو Google Drive من قائمة المشاركة.')));
    } catch(e) {
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('تعذر تجهيز النسخة: $e')));
    } finally {if(mounted)setState(()=>exporting=false);}
  }
  Future<void> restoreBackup() async {
    if(restoring)return;
    Map<String,dynamic> root;
    try {
      final decoded=jsonDecode(restoreText.text.trim());
      if(decoded is! Map)throw const FormatException('يجب أن يكون المحتوى كائن JSON.');
      root=Map<String,dynamic>.from(decoded);
      if(root['format']!=null&&root['format']!='WASEEM_MEDICAL_PRO_BACKUP')throw const FormatException('ملف النسخة لا يخص نظام وسيم الطبي PRO.');
      final data=root['data'] is Map?Map<String,dynamic>.from(root['data']):root;
      const known=['patients','appointments','packages','sessions','examinations','invoices','payments','inventory','staff','expenses'];
      if(!known.any(data.containsKey))throw const FormatException('لم يتم العثور على بيانات النظام داخل النسخة.');
      final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
        title:const Text('تأكيد استعادة النسخة'),
        content:const Text('ستُستبدل البيانات الموجودة في الأقسام المتوفرة داخل النسخة ببيانات النسخة الاحتياطية. يُنصح بتصدير نسخة من الوضع الحالي أولاً. هل تريد المتابعة؟'),
        actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('استعادة البيانات'))],
      ));
      if(ok!=true||!mounted)return;
      setState(()=>restoring=true);
      await LocalStore.importData(data);
      if(!mounted)return;
      restoreText.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('اكتملت استعادة البيانات. أعد فتح الصفحات لتحديث عرضها.')));
    } catch(e) {
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('تعذر استعادة النسخة: $e')));
    } finally {if(mounted)setState(()=>restoring=false);}
  }
  @override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(
    body:ListView(padding:const EdgeInsets.all(16),children:[
      Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:const Color(0xFF0869B9),borderRadius:BorderRadius.circular(20)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Icon(Icons.cloud_sync_outlined,color:Colors.white,size:36),SizedBox(height:10),
        Text('النسخ الاحتياطي والاستعادة',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.bold)),
        SizedBox(height:6),Text('احفظ بيانات المركز في نسخة JSON ثم استعدها عند الحاجة.',style:TextStyle(color:Colors.white70)),
      ])),
      const SizedBox(height:14),
      Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('1. إنشاء نسخة احتياطية',style:TextStyle(fontSize:17,fontWeight:FontWeight.bold)),
        const SizedBox(height:8),const Text('تشمل النسخة المرضى والمواعيد والباقات والجلسات والفواتير والمدفوعات والمخزون والطاقم والمصروفات والحضور والرواتب والإعدادات. ستظهر قائمة المشاركة لحفظ النسخة في الملفات أو Google Drive.'),
        const SizedBox(height:12),SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:exporting?null:exportBackup,icon:exporting?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.backup_outlined),label:Text(exporting?'جارٍ تجهيز النسخة...':'إنشاء ومشاركة نسخة احتياطية'))),
      ]))),
      const SizedBox(height:12),
      Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('2. استعادة نسخة احتياطية',style:TextStyle(fontSize:17,fontWeight:FontWeight.bold)),
        const SizedBox(height:8),const Text('افتح ملف JSON المحفوظ، وانسخ محتواه كاملاً ثم الصقه هنا. الاستعادة تستبدل بيانات الأقسام الموجودة في النسخة؛ راجع النسخة الحالية أولاً.'),
        const SizedBox(height:10),TextField(controller:restoreText,minLines:5,maxLines:10,decoration:const InputDecoration(border:OutlineInputBorder(),hintText:'الصق محتوى ملف النسخة الاحتياطية هنا')),
        const SizedBox(height:12),SizedBox(width:double.infinity,child:FilledButton.tonalIcon(onPressed:restoring?null:restoreBackup,icon:restoring?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.restore),label:Text(restoring?'جارٍ الاستعادة...':'التحقق واستعادة البيانات'))),
      ]))),
      const SizedBox(height:12),
      const Card(child:Padding(padding:EdgeInsets.all(14),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Icon(Icons.info_outline,color:Color(0xFF0869B9)),SizedBox(width:10),Expanded(child:Text('مهم: الحفظ إلى Google Drive هنا يتم عبر قائمة المشاركة يدويًا؛ لا توجد مزامنة تلقائية أو جدولة سحابية مفعّلة بعد. احتفظ بنسخة خارج الهاتف بانتظام.')),
      ]))),
    ]),
  ));
}
