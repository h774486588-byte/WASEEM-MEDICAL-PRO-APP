import 'package:flutter_test/flutter_test.dart';
import 'package:waseem_medical_pro/models.dart';

void main() {
  group('Invoice model', () {
    test('calculates the outstanding amount', () {
      const invoice = Invoice(
        id: 'inv-1',
        patientId: 'patient-1',
        number: 'INV-1',
        total: 100,
        paid: 35,
        date: '2026-10-12',
        status: 'جزئية',
      );

      expect(invoice.remaining, 65);
    });

    test('round-trips values through JSON', () {
      const invoice = Invoice(
        id: 'inv-2',
        patientId: 'patient-2',
        number: 'INV-2',
        total: 250.5,
        paid: 50.5,
        date: '2026-10-12',
        status: 'جزئية',
      );

      final restored = Invoice.fromJson(invoice.toJson());

      expect(restored.id, invoice.id);
      expect(restored.patientId, invoice.patientId);
      expect(restored.total, invoice.total);
      expect(restored.paid, invoice.paid);
      expect(restored.remaining, 200);
    });
  });

  group('PaymentRecord model', () {
    test('preserves payment amount, method and invoice relationship', () {
      const payment = PaymentRecord(
        id: 'pay-1',
        invoiceId: 'inv-1',
        patientId: 'patient-1',
        amount: 40.25,
        method: 'تحويل بنكي',
        date: '2026-10-12',
        notes: 'دفعة أولى',
      );

      final restored = PaymentRecord.fromJson(payment.toJson());

      expect(restored.id, payment.id);
      expect(restored.invoiceId, payment.invoiceId);
      expect(restored.patientId, payment.patientId);
      expect(restored.amount, payment.amount);
      expect(restored.method, payment.method);
      expect(restored.date, payment.date);
      expect(restored.notes, payment.notes);
    });

    test('uses safe defaults for older records without optional fields', () {
      final payment = PaymentRecord.fromJson({
        'id': 'pay-old',
        'invoiceId': 'inv-old',
        'patientId': 'patient-old',
        'amount': 10,
      });

      expect(payment.method, 'نقدي');
      expect(payment.notes, isEmpty);
      expect(payment.date, isEmpty);
    });
  });

  group('Finance models', () {
    test('loads older staff records without monthly salary', () {
      final staff = StaffMember.fromJson({
        'id': 'staff-1',
        'name': 'موظف',
        'role': 'استقبال',
        'phone': '777000000',
      });

      expect(staff.monthlySalary, 0);
    });

    test('round-trips expense data', () {
      const expense = ExpenseRecord(
        id: 'expense-1',
        title: 'مستلزمات',
        category: 'مستلزمات طبية',
        payee: 'المورد',
        date: '2026-10-12',
        method: 'نقدي',
        amount: 125.5,
        notes: 'فاتورة شراء',
      );

      final restored = ExpenseRecord.fromJson(expense.toJson());
      expect(restored.title, expense.title);
      expect(restored.amount, expense.amount);
      expect(restored.payee, expense.payee);
      expect(restored.notes, expense.notes);
    });

    test('round-trips attendance status and check-in time', () {
      const record = AttendanceRecord(
        id: 'att-1',
        staffId: 'staff-1',
        staffName: 'موظف',
        date: '2026-10-12',
        status: 'متأخر',
        checkIn: '08:30',
      );

      final restored = AttendanceRecord.fromJson(record.toJson());
      expect(restored.staffId, record.staffId);
      expect(restored.status, 'متأخر');
      expect(restored.checkIn, '08:30');
    });

    test('round-trips payroll deduction entries', () {
      const entry = PayrollEntry(
        id: 'payroll-1',
        staffId: 'staff-1',
        staffName: 'موظف',
        type: 'خصم',
        month: '2026-10',
        date: '2026-10-12',
        method: 'نقدي',
        amount: 25,
        notes: 'تأخير',
      );

      final restored = PayrollEntry.fromJson(entry.toJson());
      expect(restored.staffId, entry.staffId);
      expect(restored.type, 'خصم');
      expect(restored.month, '2026-10');
      expect(restored.amount, 25);
      expect(restored.notes, 'تأخير');
    });
  });

}
