class Patient {
  final String id,fileNo,name,phone,nationalId,birthDate,gender,department,service,doctor,address,notes,createdAt,notificationChannel;
  final int age;
  const Patient({required this.id,required this.fileNo,required this.name,required this.phone,this.nationalId='',this.birthDate='',this.gender='ذكر',this.department='',this.service='',this.doctor='',this.address='',this.notes='',this.notificationChannel='النظام',this.age=0,required this.createdAt});
  Map<String,dynamic> toJson()=>{'id':id,'fileNo':fileNo,'name':name,'phone':phone,'nationalId':nationalId,'birthDate':birthDate,'gender':gender,'department':department,'service':service,'doctor':doctor,'address':address,'notes':notes,'createdAt':createdAt,'notificationChannel':notificationChannel,'age':age};
  factory Patient.fromJson(Map<String,dynamic> j)=>Patient(id:j['id']??'',fileNo:j['fileNo']??'',name:j['name']??'',phone:j['phone']??'',nationalId:j['nationalId']??'',birthDate:j['birthDate']??'',gender:j['gender']??'ذكر',department:j['department']??'',service:j['service']??'',doctor:j['doctor']??'',address:j['address']??'',notes:j['notes']??'',createdAt:j['createdAt']??'',notificationChannel:j['notificationChannel']??'النظام',age:(j['age'] as num?)?.toInt()??0);
}
class Appointment {
  final String id,patientId,date,time,doctor,status,notes;
  const Appointment({required this.id,required this.patientId,required this.date,required this.time,required this.doctor,this.status='مؤكد',this.notes=''});
  Map<String,dynamic> toJson()=>{'id':id,'patientId':patientId,'date':date,'time':time,'doctor':doctor,'status':status,'notes':notes};
  factory Appointment.fromJson(Map<String,dynamic> j)=>Appointment(id:j['id']??'',patientId:j['patientId']??'',date:j['date']??'',time:j['time']??'',doctor:j['doctor']??'',status:j['status']??'مؤكد',notes:j['notes']??'');
}
class PackageRecord {
  final String id,patientId,name,startDate,endDate;
  final double price,paid;
  final int sessions,remaining;
  const PackageRecord({required this.id,required this.patientId,required this.name,required this.price,required this.paid,required this.sessions,required this.remaining,required this.startDate,required this.endDate});
  Map<String,dynamic> toJson()=>{'id':id,'patientId':patientId,'name':name,'price':price,'paid':paid,'sessions':sessions,'remaining':remaining,'startDate':startDate,'endDate':endDate};
  factory PackageRecord.fromJson(Map<String,dynamic> j)=>PackageRecord(id:j['id']??'',patientId:j['patientId']??'',name:j['name']??'',price:(j['price'] as num?)?.toDouble()??0,paid:(j['paid'] as num?)?.toDouble()??0,sessions:(j['sessions'] as num?)?.toInt()??0,remaining:(j['remaining'] as num?)?.toInt()??0,startDate:j['startDate']??'',endDate:j['endDate']??'');
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
 const StaffMember({required this.id,required this.name,required this.role,required this.phone});
 Map<String,dynamic> toJson()=>{'id':id,'name':name,'role':role,'phone':phone};
 factory StaffMember.fromJson(Map<String,dynamic> j)=>StaffMember(id:j['id']??'',name:j['name']??'',role:j['role']??'',phone:j['phone']??'');
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
