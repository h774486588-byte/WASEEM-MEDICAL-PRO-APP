class Patient {
  final String id,fileNo,name,phone,nationalId,birthDate,gender,department,service,doctor,address,notes,createdAt,notificationChannel,nurse;
  final int age;
  const Patient({required this.id,required this.fileNo,required this.name,required this.phone,this.nationalId='',this.birthDate='',this.gender='ذكر',this.department='',this.service='',this.doctor='',this.address='',this.notes='',this.notificationChannel='النظام',this.nurse='',this.age=0,required this.createdAt});
  Map<String,dynamic> toJson()=>{'id':id,'fileNo':fileNo,'name':name,'phone':phone,'nationalId':nationalId,'birthDate':birthDate,'gender':gender,'department':department,'service':service,'doctor':doctor,'address':address,'notes':notes,'createdAt':createdAt,'notificationChannel':notificationChannel,'nurse':nurse,'age':age};
  factory Patient.fromJson(Map<String,dynamic> j)=>Patient(id:j['id']??'',fileNo:j['fileNo']??'',name:j['name']??'',phone:j['phone']??'',nationalId:j['nationalId']??'',birthDate:j['birthDate']??'',gender:j['gender']??'ذكر',department:j['department']??'',service:j['service']??'',doctor:j['doctor']??'',address:j['address']??'',notes:j['notes']??'',createdAt:j['createdAt']??'',notificationChannel:j['notificationChannel']??'النظام',nurse:j['nurse']??'',age:(j['age'] as num?)?.toInt()??0);
}
class Appointment {
  final String id,patientId,date,time,doctor,status,notes;
  const Appointment({required this.id,required this.patientId,required this.date,required this.time,required this.doctor,this.status='مؤكد',this.notes=''});
  Map<String,dynamic> toJson()=>{'id':id,'patientId':patientId,'date':date,'time':time,'doctor':doctor,'status':status,'notes':notes};
  factory Appointment.fromJson(Map<String,dynamic> j)=>Appointment(id:j['id']??'',patientId:j['patientId']??'',date:j['date']??'',time:j['time']??'',doctor:j['doctor']??'',status:j['status']??'مؤكد',notes:j['notes']??'');
}
class PackageRecord {
  final String id,patientId,name,startDate,endDate,therapist;
  final double price,paid;
  final int sessions,remaining;
  const PackageRecord({required this.id,required this.patientId,required this.name,required this.price,required this.paid,required this.sessions,required this.remaining,required this.startDate,required this.endDate,this.therapist=''});
  Map<String,dynamic> toJson()=>{'id':id,'patientId':patientId,'name':name,'price':price,'paid':paid,'sessions':sessions,'remaining':remaining,'startDate':startDate,'endDate':endDate,'therapist':therapist};
  factory PackageRecord.fromJson(Map<String,dynamic> j)=>PackageRecord(id:j['id']??'',patientId:j['patientId']??'',name:j['name']??'',price:(j['price'] as num?)?.toDouble()??0,paid:(j['paid'] as num?)?.toDouble()??0,sessions:(j['sessions'] as num?)?.toInt()??0,remaining:(j['remaining'] as num?)?.toInt()??0,startDate:j['startDate']??'',endDate:j['endDate']??'',therapist:j['therapist']??'');
}
class Invoice {
  final String id,patientId,number,date,status;
  final double total,paid;
  const Invoice({required this.id,required this.patientId,required this.number,required this.total,required this.paid,required this.date,required this.status});
  double get remaining=>total-paid;
  Map<String,dynamic> toJson()=>{'id':id,'patientId':patientId,'number':number,'total':total,'paid':paid,'date':date,'status':status};
  factory Invoice.fromJson(Map<String,dynamic> j)=>Invoice(id:j['id']??'',patientId:j['patientId']??'',number:j['number']??'',total:(j['total'] as num?)?.toDouble()??0,paid:(j['paid'] as num?)?.toDouble()??0,date:j['date']??'',status:j['status']??'غير مدفوعة');
}
class PaymentRecord {
  final String id, invoiceId, patientId, method, date, notes;
  final double amount;

  const PaymentRecord({
    required this.id,
    required this.invoiceId,
    required this.patientId,
    required this.amount,
    required this.method,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'invoiceId': invoiceId,
    'patientId': patientId,
    'amount': amount,
    'method': method,
    'date': date,
    'notes': notes,
  };

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
    id: json['id']?.toString() ?? '',
    invoiceId: json['invoiceId']?.toString() ?? '',
    patientId: json['patientId']?.toString() ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    method: json['method']?.toString() ?? 'نقدي',
    date: json['date']?.toString() ?? '',
    notes: json['notes']?.toString() ?? '',
  );
}

class AppNotification {
  final String id,title,body,channel,status,date,recipientPhone;
  const AppNotification({required this.id,required this.title,required this.body,required this.channel,required this.status,required this.date,this.recipientPhone=''});
  Map<String,dynamic> toJson()=>{'id':id,'title':title,'body':body,'channel':channel,'status':status,'date':date,'recipientPhone':recipientPhone};
  factory AppNotification.fromJson(Map<String,dynamic> j)=>AppNotification(id:j['id']??'',title:j['title']??'',body:j['body']??'',channel:j['channel']??'',status:j['status']??'جاهز',date:j['date']??'',recipientPhone:j['recipientPhone']??'');
}

class InventoryItem {
 final String id,name,unit,code,supplierId;
 final double quantity,cost,sellPrice;
 const InventoryItem({required this.id,required this.name,required this.unit,required this.code,required this.quantity,required this.cost,this.sellPrice=0,this.supplierId=''});
 Map<String,dynamic> toJson()=>{'id':id,'name':name,'unit':unit,'code':code,'quantity':quantity,'cost':cost,'sellPrice':sellPrice,'supplierId':supplierId};
 factory InventoryItem.fromJson(Map<String,dynamic> j)=>InventoryItem(id:j['id']??'',name:j['name']??'',unit:j['unit']??'قطعة',code:j['code']??'',quantity:(j['quantity'] as num?)?.toDouble()??0,cost:(j['cost'] as num?)?.toDouble()??0,sellPrice:(j['sellPrice'] as num?)?.toDouble()??0,supplierId:j['supplierId']??'');
}
class StaffMember {
 final String id,name,role,phone;
 final double monthlySalary,commissionPercent,sessionFee;
 const StaffMember({required this.id,required this.name,required this.role,required this.phone,this.monthlySalary=0,this.commissionPercent=0,this.sessionFee=0});
 Map<String,dynamic> toJson()=>{'id':id,'name':name,'role':role,'phone':phone,'monthlySalary':monthlySalary,'commissionPercent':commissionPercent,'sessionFee':sessionFee};
 factory StaffMember.fromJson(Map<String,dynamic> j)=>StaffMember(id:j['id']?.toString()??'',name:j['name']?.toString()??'',role:j['role']?.toString()??'',phone:j['phone']?.toString()??'',monthlySalary:(j['monthlySalary'] as num?)?.toDouble()??0,commissionPercent:(j['commissionPercent'] as num?)?.toDouble()??0,sessionFee:(j['sessionFee'] as num?)?.toDouble()??0);
}

class ExpenseRecord {
  final String id, title, category, payee, date, method, notes;
  final double amount;
  const ExpenseRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.payee,
    required this.date,
    required this.method,
    required this.amount,
    this.notes = '',
  });
  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'category': category, 'payee': payee,
    'date': date, 'method': method, 'amount': amount, 'notes': notes,
  };
  factory ExpenseRecord.fromJson(Map<String, dynamic> j) => ExpenseRecord(
    id: j['id']?.toString() ?? '',
    title: j['title']?.toString() ?? '',
    category: j['category']?.toString() ?? 'عام',
    payee: j['payee']?.toString() ?? '',
    date: j['date']?.toString() ?? '',
    method: j['method']?.toString() ?? 'نقدي',
    amount: (j['amount'] as num?)?.toDouble() ?? 0,
    notes: j['notes']?.toString() ?? '',
  );
}

class AttendanceRecord {
  final String id, staffId, staffName, date, status, checkIn, notes;
  const AttendanceRecord({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.date,
    required this.status,
    this.checkIn = '',
    this.notes = '',
  });
  Map<String, dynamic> toJson() => {
    'id': id, 'staffId': staffId, 'staffName': staffName, 'date': date,
    'status': status, 'checkIn': checkIn, 'notes': notes,
  };
  factory AttendanceRecord.fromJson(Map<String, dynamic> j) => AttendanceRecord(
    id: j['id']?.toString() ?? '',
    staffId: j['staffId']?.toString() ?? '',
    staffName: j['staffName']?.toString() ?? '',
    date: j['date']?.toString() ?? '',
    status: j['status']?.toString() ?? 'حاضر',
    checkIn: j['checkIn']?.toString() ?? '',
    notes: j['notes']?.toString() ?? '',
  );
}

class PayrollEntry {
  final String id, staffId, staffName, type, month, date, method, notes;
  final double amount;
  const PayrollEntry({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.type,
    required this.month,
    required this.date,
    required this.method,
    required this.amount,
    this.notes = '',
  });
  Map<String, dynamic> toJson() => {
    'id': id, 'staffId': staffId, 'staffName': staffName, 'type': type,
    'month': month, 'date': date, 'method': method, 'amount': amount, 'notes': notes,
  };
  factory PayrollEntry.fromJson(Map<String, dynamic> j) => PayrollEntry(
    id: j['id']?.toString() ?? '',
    staffId: j['staffId']?.toString() ?? '',
    staffName: j['staffName']?.toString() ?? '',
    type: j['type']?.toString() ?? 'صرف راتب',
    month: j['month']?.toString() ?? '',
    date: j['date']?.toString() ?? '',
    method: j['method']?.toString() ?? 'نقدي',
    amount: (j['amount'] as num?)?.toDouble() ?? 0,
    notes: j['notes']?.toString() ?? '',
  );
}

class Supplier {
 final String id,name,phone,address,notes;
 const Supplier({required this.id,required this.name,this.phone='',this.address='',this.notes=''});
 Map<String,dynamic> toJson()=>{'id':id,'name':name,'phone':phone,'address':address,'notes':notes};
 factory Supplier.fromJson(Map<String,dynamic> j)=>Supplier(id:j['id']??'',name:j['name']??'',phone:j['phone']??'',address:j['address']??'',notes:j['notes']??'');
}
class InventorySale {
 final String id,itemId,itemName,date;
 final double quantity,unitPrice,total,costTotal;
 const InventorySale({required this.id,required this.itemId,required this.itemName,required this.date,required this.quantity,required this.unitPrice,required this.total,required this.costTotal});
 double get profit=>total-costTotal;
 Map<String,dynamic> toJson()=>{'id':id,'itemId':itemId,'itemName':itemName,'date':date,'quantity':quantity,'unitPrice':unitPrice,'total':total,'costTotal':costTotal};
 factory InventorySale.fromJson(Map<String,dynamic> j)=>InventorySale(id:j['id']??'',itemId:j['itemId']??'',itemName:j['itemName']??'',date:j['date']??'',quantity:(j['quantity'] as num?)?.toDouble()??0,unitPrice:(j['unitPrice'] as num?)?.toDouble()??0,total:(j['total'] as num?)?.toDouble()??0,costTotal:(j['costTotal'] as num?)?.toDouble()??0);
}

class SessionRecord {
  final String id,patientId,packageId,packageName,date,time,therapist,status,notes;
  const SessionRecord({required this.id,required this.patientId,required this.packageId,required this.packageName,required this.date,required this.time,required this.therapist,this.status='حضر',this.notes=''});
  Map<String,dynamic> toJson()=>{'id':id,'patientId':patientId,'packageId':packageId,'packageName':packageName,'date':date,'time':time,'therapist':therapist,'status':status,'notes':notes};
  factory SessionRecord.fromJson(Map<String,dynamic> j)=>SessionRecord(id:j['id']??'',patientId:j['patientId']??'',packageId:j['packageId']??'',packageName:j['packageName']??'',date:j['date']??'',time:j['time']??'',therapist:j['therapist']??'',status:j['status']??'حضر',notes:j['notes']??'');
}


class ExaminationRecord {
  final String id, patientId, date, complaint, history, diagnosis, treatment, notes, examiner, bloodPressure, temperature, weight;
  const ExaminationRecord({required this.id,required this.patientId,required this.date,this.complaint='',this.history='',this.diagnosis='',this.treatment='',this.notes='',this.examiner='',this.bloodPressure='',this.temperature='',this.weight=''});
  Map<String,dynamic> toJson()=>{'id':id,'patientId':patientId,'date':date,'complaint':complaint,'history':history,'diagnosis':diagnosis,'treatment':treatment,'notes':notes,'examiner':examiner,'bloodPressure':bloodPressure,'temperature':temperature,'weight':weight};
  factory ExaminationRecord.fromJson(Map<String,dynamic> j)=>ExaminationRecord(id:j['id']?.toString()??'',patientId:j['patientId']?.toString()??'',date:j['date']?.toString()??'',complaint:j['complaint']?.toString()??'',history:j['history']?.toString()??'',diagnosis:j['diagnosis']?.toString()??'',treatment:j['treatment']?.toString()??'',notes:j['notes']?.toString()??'',examiner:j['examiner']?.toString()??'',bloodPressure:j['bloodPressure']?.toString()??'',temperature:j['temperature']?.toString()??'',weight:j['weight']?.toString()??'');
}
