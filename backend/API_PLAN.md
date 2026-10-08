# WASEEM MEDICAL PRO REST API

النسخة التالية من الـ Laravel API ستستخدم JWT/Sanctum للمصادقة وتوفر:

- POST /api/auth/login
- GET/POST /api/patients
- GET/PUT/DELETE /api/patients/{id}
- GET/POST /api/appointments
- GET/POST /api/packages
- POST /api/sessions
- GET/POST /api/invoices
- POST /api/payments
- GET /api/notifications
- POST /api/notifications/queue
- GET /api/reports/dashboard

قواعد العمل الأساسية:
1. رقم الملف يولد تلقائياً بصيغة P-1001.
2. تسجيل جلسة ينقص remaining_sessions بمقدار واحد داخل معاملة قاعدة بيانات.
3. عند وصول الجلسات إلى 2 أو أقل ينشأ تنبيه.
4. عند وصول الجلسات إلى 0 ينشأ تنبيه انتهاء الباقة.
5. الفاتورة المدفوعة بالكامل تتحول إلى paid، وإلا partial أو unpaid.
6. كل تعديل حساس يسجل في audit_logs.


## PRO additions
- Auth: login/logout, token rotation, password reset, role/permission middleware.
- Settings: branch settings, services, users, message templates.
- Finance: invoice items, payments, expenses, cash summary.
- Reports: patients, appointments, sessions, revenue, expenses, outstanding balances.
- Notifications: queue, retries, provider message IDs, delivery status, WhatsApp Business/SMS adapters.
- Backup: scheduled database backup metadata and restore workflow.
- Audit: immutable audit events for authentication, patient edits, finance and permissions.
