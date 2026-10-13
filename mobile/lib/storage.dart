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
  static Future<List<SessionRecord>> sessions()=>read('sessions',SessionRecord.fromJson);
  static Future<List<ExaminationRecord>> examinations()=>read('examinations',ExaminationRecord.fromJson);
  static Future<void> saveExaminations(List<ExaminationRecord> x)=>write('examinations',x,(v)=>v.toJson());
  static Future<void> saveSessions(List<SessionRecord> x)=>write('sessions',x,(v)=>v.toJson());
  static Future<List<Invoice>> invoices()=>read('invoices',Invoice.fromJson);
  static Future<void> saveInvoices(List<Invoice> x)=>write('invoices',x,(v)=>v.toJson());
  static Future<List<PaymentRecord>> payments()=>read('payments',PaymentRecord.fromJson);
  static Future<void> savePayments(List<PaymentRecord> x)=>write('payments',x,(v)=>v.toJson());
  static Future<List<AppNotification>> notifications()=>read('notifications',AppNotification.fromJson);
  static Future<List<InventoryItem>> inventory()=>read('inventory',InventoryItem.fromJson);
  static Future<void> saveInventory(List<InventoryItem> x)=>write('inventory',x,(v)=>v.toJson());
  static Future<List<StaffMember>> staff()=>read('staff',StaffMember.fromJson);
  static Future<List<ExpenseRecord>> expenses()=>read('expenses',ExpenseRecord.fromJson);
  static Future<void> saveExpenses(List<ExpenseRecord> x)=>write('expenses',x,(v)=>v.toJson());
  static Future<List<AttendanceRecord>> attendance()=>read('attendance',AttendanceRecord.fromJson);
  static Future<void> saveAttendance(List<AttendanceRecord> x)=>write('attendance',x,(v)=>v.toJson());
  static Future<List<PayrollEntry>> payrollEntries()=>read('payroll_entries',PayrollEntry.fromJson);
  static Future<void> savePayrollEntries(List<PayrollEntry> x)=>write('payroll_entries',x,(v)=>v.toJson());
  static Future<List<Supplier>> suppliers()=>read('suppliers',Supplier.fromJson);
  static Future<void> saveSuppliers(List<Supplier> x)=>write('suppliers',x,(v)=>v.toJson());
  static Future<List<InventorySale>> sales()=>read('inventory_sales',InventorySale.fromJson);
  static Future<void> saveSales(List<InventorySale> x)=>write('inventory_sales',x,(v)=>v.toJson());
  static Future<void> saveStaff(List<StaffMember> x)=>write('staff',x,(v)=>v.toJson());
  static Future<void> saveNotifications(List<AppNotification> x)=>write('notifications',x,(v)=>v.toJson());
  static Future<int> nextPatientNumber() async {
    final list=await patients(); var max=1000;
    for(final p in list){final n=int.tryParse(p.fileNo.replaceAll(RegExp(r'[^0-9]'),''))??0;if(n>max)max=n;}
    return max+1;
  }
  static Future<Map<String,dynamic>> exportData() async {
    return {
      'patients':(await patients()).map((e)=>e.toJson()).toList(),
      'appointments':(await appointments()).map((e)=>e.toJson()).toList(),
      'packages':(await packages()).map((e)=>e.toJson()).toList(),
      'sessions':(await sessions()).map((e)=>e.toJson()).toList(),
      'examinations':(await examinations()).map((e)=>e.toJson()).toList(),
      'invoices':(await invoices()).map((e)=>e.toJson()).toList(),
      'payments':(await payments()).map((e)=>e.toJson()).toList(),
      'notifications':(await notifications()).map((e)=>e.toJson()).toList(),
      'inventory':(await inventory()).map((e)=>e.toJson()).toList(),
      'inventorySales':(await sales()).map((e)=>e.toJson()).toList(),
      'suppliers':(await suppliers()).map((e)=>e.toJson()).toList(),
      'staff':(await staff()).map((e)=>e.toJson()).toList(),
      'expenses':(await expenses()).map((e)=>e.toJson()).toList(),
      'attendance':(await attendance()).map((e)=>e.toJson()).toList(),
      'payrollEntries':(await payrollEntries()).map((e)=>e.toJson()).toList(),
      'serviceDirectoryRaw':(await SharedPreferences.getInstance()).getStringList('service_directory_v1')??[],
      'packageCatalogRaw':(await SharedPreferences.getInstance()).getStringList('package_catalog_v1')??[],
      'settings':await settings()
    };
  }
  static Future<void> importData(Map<String,dynamic> x) async {
    if(x['patients'] is List) await savePatients((x['patients'] as List).map((e)=>Patient.fromJson(Map<String,dynamic>.from(e))).toList());
    if(x['appointments'] is List) await saveAppointments((x['appointments'] as List).map((e)=>Appointment.fromJson(Map<String,dynamic>.from(e))).toList());
    if(x['packages'] is List) await savePackages((x['packages'] as List).map((e)=>PackageRecord.fromJson(Map<String,dynamic>.from(e))).toList());
    if(x['sessions'] is List) await saveSessions((x['sessions'] as List).map((e)=>SessionRecord.fromJson(Map<String,dynamic>.from(e))).toList());
    if(x['examinations'] is List) await saveExaminations((x['examinations'] as List).map((e)=>ExaminationRecord.fromJson(Map<String,dynamic>.from(e))).toList());
    if(x['invoices'] is List) await saveInvoices((x['invoices'] as List).map((e)=>Invoice.fromJson(Map<String,dynamic>.from(e))).toList());
    if(x['payments'] is List) await savePayments((x['payments'] as List).map((e)=>PaymentRecord.fromJson(Map<String,dynamic>.from(e))).toList());
    if(x['notifications'] is List) await saveNotifications((x['notifications'] as List).map((e)=>AppNotification.fromJson(Map<String,dynamic>.from(e))).toList());
    if(x['inventory'] is List) await saveInventory((x['inventory'] as List).map((e)=>InventoryItem.fromJson(Map<String,dynamic>.from(e))).toList());
    if(x['inventorySales'] is List) await saveSales((x['inventorySales'] as List).map((e)=>InventorySale.fromJson(Map<String,dynamic>.from(e))).toList());
    if(x['suppliers'] is List) await saveSuppliers((x['suppliers'] as List).map((e)=>Supplier.fromJson(Map<String,dynamic>.from(e))).toList());
    if(x['staff'] is List) await saveStaff((x['staff'] as List).map((e)=>StaffMember.fromJson(Map<String,dynamic>.from(e))).toList());
    if(x['expenses'] is List) await saveExpenses((x['expenses'] as List).map((e)=>ExpenseRecord.fromJson(Map<String,dynamic>.from(e))).toList());
    if(x['attendance'] is List) await saveAttendance((x['attendance'] as List).map((e)=>AttendanceRecord.fromJson(Map<String,dynamic>.from(e))).toList());
    if(x['payrollEntries'] is List) await savePayrollEntries((x['payrollEntries'] as List).map((e)=>PayrollEntry.fromJson(Map<String,dynamic>.from(e))).toList());
    if(x['settings'] is Map) await saveSettings(Map<String,String>.from(x['settings']));
    final prefs=await SharedPreferences.getInstance();
    if(x['serviceDirectoryRaw'] is List) await prefs.setStringList('service_directory_v1',(x['serviceDirectoryRaw'] as List).map((e)=>e.toString()).toList());
    if(x['packageCatalogRaw'] is List) await prefs.setStringList('package_catalog_v1',(x['packageCatalogRaw'] as List).map((e)=>e.toString()).toList());
  }
  static Future<Map<String,String>> settings() async { final p=await SharedPreferences.getInstance(); return {'name':p.getString('clinic_name')??'نظام وسيم الطبي PRO','phone':p.getString('clinic_phone')??'','address':p.getString('clinic_address')??'','whatsapp':p.getString('clinic_whatsapp')??'false','sms':p.getString('clinic_sms')??'false'}; }
  static Future<void> saveSettings(Map<String,String> x) async { final p=await SharedPreferences.getInstance(); await p.setString('clinic_name',x['name']??''); await p.setString('clinic_phone',x['phone']??''); await p.setString('clinic_address',x['address']??''); await p.setString('clinic_whatsapp',x['whatsapp']??'false'); await p.setString('clinic_sms',x['sms']??'false'); }
}
