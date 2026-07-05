// lib/data/models/payment_model.dart

enum PaymentStatus { pending, paid, failed, expired, refunded }

extension PaymentStatusDisplay on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.pending: return 'Menunggu Pembayaran';
      case PaymentStatus.paid: return 'Lunas';
      case PaymentStatus.failed: return 'Gagal';
      case PaymentStatus.expired: return 'Kedaluwarsa';
      case PaymentStatus.refunded: return 'Dikembalikan';
    }
  }
}

class PaymentModel {
  final String id;
  final String ticketId;
  final String userId;
  final int amount;
  final String paymentMethod;
  final PaymentStatus paymentStatus;
  final DateTime? paymentDate;
  final DateTime expiredAt;
  final String transactionNumber;
  final String? refundStatus;

  const PaymentModel({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paymentDate,
    required this.expiredAt,
    required this.transactionNumber,
    this.refundStatus,
  });

  PaymentModel copyWith({
    PaymentStatus? paymentStatus,
    DateTime? paymentDate,
    String? refundStatus,
  }) {
    return PaymentModel(
      id: id,
      ticketId: ticketId,
      userId: userId,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentDate: paymentDate ?? this.paymentDate,
      expiredAt: expiredAt,
      transactionNumber: transactionNumber,
      refundStatus: refundStatus ?? this.refundStatus,
    );
  }
}
