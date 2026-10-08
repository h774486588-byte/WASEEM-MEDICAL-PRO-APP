import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const WaseemMedicalPro());
}

class WaseemMedicalPro extends StatelessWidget {
  const WaseemMedicalPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نظام وسيم الطبي PRO',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1565C0),
        fontFamily: 'Arial',
      ),
      locale: const Locale('ar'),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final user = TextEditingController();
  final password = TextEditingController();

  void login() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: const Icon(Icons.local_hospital, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 18),
                    const Text('نظام وسيم الطبي PRO',
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('إدارة مركزك الطبي بسهولة واحترافية'),
                    const SizedBox(height: 32),
                    TextField(
                      controller: user,
                      decoration: const InputDecoration(
                        labelText: 'اسم المستخدم',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: login,
                        icon: const Icon(Icons.login),
                        label: const Text('دخول'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int index = 0;

  final pages = const [
    HomeTab(),
    PatientsTab(),
    AppointmentsTab(),
    MoreTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نظام وسيم الطبي PRO'),
          actions: [
            IconButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('لا توجد إشعارات جديدة')),
              ),
              icon: const Icon(Icons.notifications_none),
            ),
          ],
        ),
        body: pages[index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (v) => setState(() => index = v),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'المرضى'),
            NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'المواعيد'),
            NavigationDestination(icon: Icon(Icons.more_horiz), selectedIcon: Icon(Icons.more_horiz), label: 'المزيد'),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('مرحباً بك 👋', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now())),
        const SizedBox(height: 18),
        const Row(
          children: [
            Expanded(child: StatCard(title: 'المرضى', value: '0', icon: Icons.people)),
            SizedBox(width: 10),
            Expanded(child: StatCard(title: 'مواعيد اليوم', value: '0', icon: Icons.event)),
          ],
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(child: StatCard(title: 'الجلسات', value: '0', icon: Icons.medical_services)),
            SizedBox(width: 10),
            Expanded(child: StatCard(title: 'المتبقي', value: '0', icon: Icons.payments)),
          ],
        ),
        const SizedBox(height: 22),
        const Text('الوصول السريع', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: const [
            QuickCard('مريض جديد', Icons.person_add),
            QuickCard('موعد جديد', Icons.add_alarm),
            QuickCard('جلسة جديدة', Icons.medical_services_outlined),
            QuickCard('فاتورة جديدة', Icons.receipt_long),
          ],
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const StatCard({super.key, required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        Text(title),
      ]),
    ),
  );
}

class QuickCard extends StatelessWidget {
  final String title;
  final IconData icon;
  const QuickCard(this.title, this.icon, {super.key});
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('سيتم فتح: $title'))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 30),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

class PatientsTab extends StatelessWidget {
  const PatientsTab({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Row(children: [
        const Expanded(child: Text('المرضى', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold))),
        FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('مريض جديد')),
      ]),
      const SizedBox(height: 16),
      const TextField(decoration: InputDecoration(hintText: 'بحث بالاسم أو رقم الملف أو الهاتف', prefixIcon: Icon(Icons.search), border: OutlineInputBorder())),
      const SizedBox(height: 18),
      const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('لا يوجد مرضى حتى الآن'))),
    ],
  );
}

class AppointmentsTab extends StatelessWidget {
  const AppointmentsTab({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Row(children: [
        const Expanded(child: Text('مواعيد اليوم', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold))),
        FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('موعد جديد')),
      ]),
      const SizedBox(height: 16),
      const Card(child: ListTile(leading: Icon(Icons.event_available), title: Text('لا توجد مواعيد اليوم'), subtitle: Text('ستظهر المواعيد المسجلة هنا'))),
    ],
  );
}

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: const [
      Text('المزيد', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      ListTile(leading: Icon(Icons.inventory_2_outlined), title: Text('الباقات والجلسات')),
      ListTile(leading: Icon(Icons.receipt_long), title: Text('الفواتير والمدفوعات')),
      ListTile(leading: Icon(Icons.notifications_none), title: Text('مركز الإشعارات')),
      ListTile(leading: Icon(Icons.bar_chart), title: Text('التقارير')),
      ListTile(leading: Icon(Icons.settings_outlined), title: Text('الإعدادات')),
    ],
  );
}
