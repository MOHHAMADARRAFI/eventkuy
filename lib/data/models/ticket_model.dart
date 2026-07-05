// lib/data/models/ticket_model.dart

class TicketModel {
  final String id;
  final String eventId;
  final String ticketName;
  final String description;
  final int price;
  final int quota;
  final int remainingQuota;
  final int soldQuantity;
  final DateTime registrationStart;
  final DateTime registrationEnd;
  final List<String> benefits;
  final bool isActive;
  final int maxPurchasePerUser;
  final String colorLabel; // Hex color string or color name
  final int sortOrder;

  const TicketModel({
    required this.id,
    required this.eventId,
    required this.ticketName,
    required this.description,
    required this.price,
    required this.quota,
    required this.remainingQuota,
    required this.soldQuantity,
    required this.registrationStart,
    required this.registrationEnd,
    required this.benefits,
    required this.isActive,
    required this.maxPurchasePerUser,
    required this.colorLabel,
    required this.sortOrder,
  });

  String get priceLabel {
    if (price == 0) return 'Gratis';
    return price >= 1000 ? 'Rp ${(price / 1000).toStringAsFixed(0)}k' : 'Rp $price';
  }

  TicketModel copyWith({
    String? ticketName,
    String? description,
    int? price,
    int? quota,
    int? remainingQuota,
    int? soldQuantity,
    DateTime? registrationStart,
    DateTime? registrationEnd,
    List<String>? benefits,
    bool? isActive,
    int? maxPurchasePerUser,
    String? colorLabel,
    int? sortOrder,
  }) {
    return TicketModel(
      id: id,
      eventId: eventId,
      ticketName: ticketName ?? this.ticketName,
      description: description ?? this.description,
      price: price ?? this.price,
      quota: quota ?? this.quota,
      remainingQuota: remainingQuota ?? this.remainingQuota,
      soldQuantity: soldQuantity ?? this.soldQuantity,
      registrationStart: registrationStart ?? this.registrationStart,
      registrationEnd: registrationEnd ?? this.registrationEnd,
      benefits: benefits ?? this.benefits,
      isActive: isActive ?? this.isActive,
      maxPurchasePerUser: maxPurchasePerUser ?? this.maxPurchasePerUser,
      colorLabel: colorLabel ?? this.colorLabel,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
