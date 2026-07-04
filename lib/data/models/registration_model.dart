// lib/data/models/registration_model.dart

import 'event_model.dart';

enum RegistrationStatus { upcoming, completed, cancelled, pending }

extension RegistrationStatusExt on RegistrationStatus {
  String get label {
    switch (this) {
      case RegistrationStatus.upcoming: return 'Upcoming';
      case RegistrationStatus.completed: return 'Selesai';
      case RegistrationStatus.cancelled: return 'Dibatalkan';
      case RegistrationStatus.pending: return 'Menunggu';
    }
  }

  String get emoji {
    switch (this) {
      case RegistrationStatus.upcoming: return '🗓️';
      case RegistrationStatus.completed: return '✅';
      case RegistrationStatus.cancelled: return '❌';
      case RegistrationStatus.pending: return '⏳';
    }
  }
}

class RegistrationModel {
  final String id;
  final String userId;
  final EventModel event;
  final RegistrationStatus status;
  final DateTime registeredAt;
  final String? ticketCode;
  final String? notes;

  const RegistrationModel({
    required this.id,
    required this.userId,
    required this.event,
    required this.status,
    required this.registeredAt,
    this.ticketCode,
    this.notes,
  });
}
