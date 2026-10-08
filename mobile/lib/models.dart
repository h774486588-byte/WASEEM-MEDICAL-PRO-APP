class Patient {
  final String id,fileNo,name,phone,nationalId,birthDate,gender,department,service,doctor,address,notes,createdAt;
  const Patient({required this.id,required this.fileNo,required this.name,required this.phone,this.nationalId='',this.birthDate='',this.gender='ذكر',this.department='',this.service='',this.doctor='',this.address='',this.notes='',required this.createdAt});
  Map<String,dynamic> toJson()=>{'id':id,'fileNo':fileNo,'name':name,'phone':phone,'nationalId':nationalId,'birthDate':birthDate,'gender':gender,'department':department,'service':service,'doctor':doctor,'address':address,'notes':notes,'createdAt':createdAt};
  factory Patient.fromJson(Map<String,dynamic> j)=>Patient(id:j['id']??'',fileNo:j['fileNo']??'',name:j['name']??'',phone:j['phone']??'',nationalId:j['nationalId']??'',birthDate:j['birthDate']??'',gender:j['gender']??'ذكر',department:j['department']??'',service:j['service']??'',doctor:j['doctor']??'',address:j['address']??'',notes:j['notes']??'',createdAt:j['createdAt']??'');
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
class AppNotification {
  final String id,title,body,channel,status,date;
  const AppNotification({required this.id,required this.title,required this.body,required this.channel,required this.status,required this.date});
  Map<String,dynamic> toJson()=>{'id':id,'title':title,'body':body,'channel':channel,'status':status,'date':date};
  factory AppNotification.fromJson(Map<String,dynamic> j)=>AppNotification(id:j['id']??'',title:j['title']??'',body:j['body']??'',channel:j['channel']??'',status:j['status']??'جاهز',date:j['date']??'');
}
