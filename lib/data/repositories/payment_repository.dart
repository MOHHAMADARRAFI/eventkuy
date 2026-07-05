// lib/data/repositories/payment_repository.dart

import '../dummy/dummy_data.dart';
import '../models/payment_model.dart';

abstract class IPaymentRepository {
  Future<PaymentModel> createPayment(PaymentModel payment);
  Future<PaymentModel> verifyPayment(String transactionNumber);
  Future<List<PaymentModel>> getPayments();
  Future<void> refundPayment(String paymentId);
  Future<Map<String, dynamic>> getRevenueSummary();
}

class PaymentRepository implements IPaymentRepository {
  final List<PaymentModel> _payments = [];

  PaymentRepository() {
    _payments.addAll(DummyData.payments);
  }

  Future<void> _delay() async =>
      await Future.delayed(const Duration(milliseconds: 600));

  @override
  Future<PaymentModel> createPayment(PaymentModel payment) async {
    await _delay();
    _payments.add(payment);
    return payment;
  }

  @override
  Future<PaymentModel> verifyPayment(String transactionNumber) async {
    await _delay();
    final idx = _payments.indexWhere((p) => p.transactionNumber == transactionNumber);
    if (idx != -1) {
      _payments[idx] = _payments[idx].copyWith(
        paymentStatus: PaymentStatus.paid,
        paymentDate: DateTime.now(),
      );
      return _payments[idx];
    }
    throw Exception('Transaksi tidak ditemukan');
  }

  @override
  Future<List<PaymentModel>> getPayments() async {
    await _delay();
    return List.from(_payments)..sort((a, b) => b.expiredAt.compareTo(a.expiredAt));
  }

  @override
  Future<void> refundPayment(String paymentId) async {
    await _delay();
    final idx = _payments.indexWhere((p) => p.id == paymentId);
    if (idx != -1) {
      _payments[idx] = _payments[idx].copyWith(
        paymentStatus: PaymentStatus.refunded,
        refundStatus: 'Approved',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getRevenueSummary() async {
    await _delay();
    int totalRevenue = 0;
    int pendingRevenue = 0;
    int refundCount = 0;
    int totalPayments = 0;

    for (var p in _payments) {
      if (p.paymentStatus == PaymentStatus.paid) {
        totalRevenue += p.amount;
        totalPayments++;
      } else if (p.paymentStatus == PaymentStatus.pending) {
        pendingRevenue += p.amount;
      } else if (p.paymentStatus == PaymentStatus.refunded) {
        refundCount += p.amount;
      }
    }

    return {
      'totalRevenue': totalRevenue,
      'pendingRevenue': pendingRevenue,
      'refundedRevenue': refundCount,
      'paymentCount': totalPayments,
    };
  }
}
