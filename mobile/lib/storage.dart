import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class LocalStore {
  static Future<List<T>> read<T>(String key,T Function(Map<String,dynamic>) fromJson) async {
    final p=await SharedPreferences.getInstance();
    return (p.getStringList(key)??[]).map((x)=>fromJson(jsonDecode(x) as Map<String,dynamic>)).toList();
  }
  static Future<void> write<T>(String key,List<T> items,Map<String,dynamic> Function(T) toJson) async {
    final p=await SharedPreferences.getInstance();
    await p.setStringList(key,items.map((x)=>jsonEncode(toJson(x))).toList());
  }
  static Future<List<Patient>> patients()=>read('patients',Patient.fromJson);
  static Future<void> savePatients(List<Patient> x)=>write('patients',x,(v)=>v.toJson());
  static Future<List<Appointment>> appointments()=>read('appointments',Appointment.fromJson);
  static Future<void> saveAppointments(List<Appointment> x)=>write('appointments',x,(v)=>v.toJson());
  static Future<List<PackageRecord>> packages()=>read('packages',PackageRecord.fromJson);
  static Future<void> savePackages(List<PackageRecord> x)=>write('packages',x,(v)=>v.toJson());
  static Future<List<Invoice>> invoices()=>read('invoices',Invoice.fromJson);
  static Future<void> saveInvoices(List<Invoice> x)=>write('invoices',x,(v)=>v.toJson());
  static Future<List<AppNotification>> notifications()=>read('notifications',AppNotification.fromJson);
  static Future<void> saveNotifications(List<AppNotification> x)=>write('notifications',x,(v)=>v.toJson());
  static Future<int> nextPatientNumber() async {
    final list=await patients(); var max=1000;
    for(final p in list){final n=int.tryParse(p.fileNo.replaceAll(RegExp(r'[^0-9]'),''))??0;if(n>max)max=n;}
    return max+1;
  }
}
