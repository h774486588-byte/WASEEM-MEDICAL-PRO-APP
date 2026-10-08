# معماريّة نظام وسيم الطبي PRO

## Mobile
Flutter + Material 3 + RTL. التخزين المحلي في المرحلة الحالية عبر SharedPreferences مع فصل نماذج البيانات وطبقة التخزين.

## Backend
Laravel REST API + PostgreSQL. التطبيق المحمول سيستخدم API في المرحلة التالية مع مزامنة محلية مؤقتة عند انقطاع الشبكة.

## Notifications
Notification Engine مستقل. القنوات المخططة:
- WhatsApp Business API
- SMS Gateway
- إشعارات داخلية

لا يتم اعتبار فتح تطبيق WhatsApp أو SMS إرسالاً آلياً؛ الإرسال الآلي الحقيقي يحتاج مزود API معتمد.

## الصلاحيات
admin / reception / specialist / accountant.

## دورة المريض
تسجيل الملف → إشعار التسجيل → موعد → تذكير → باقة → جلسات → تحديث الرصيد → تنبيه قرب الانتهاء → انتهاء الباقة → الفاتورة والمدفوعات → التقارير.
