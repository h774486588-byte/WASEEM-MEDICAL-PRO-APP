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
}
