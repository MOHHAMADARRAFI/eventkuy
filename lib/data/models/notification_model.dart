// lib/data/models/notification_model.dart

enum NotificationType {
  eventReminder,
  scheduleChange,
  newEvent,
  registrationSuccess,
  eventCancelled,
  general,
}

extension NotificationTypeExt on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.eventReminder: return 'Pengingat Event';
      case NotificationType.scheduleChange: return 'Perubahan Jadwal';
      case NotificationType.newEvent: return 'Event Baru';
      case NotificationType.registrationSuccess: return 'Registrasi Berhasil';
      case NotificationType.eventCancelled: return 'Event Dibatalkan';
      case NotificationType.general: return 'Informasi';
    }
  }

  String get emoji {
    switch (this) {
      case NotificationType.eventReminder: return '🔔';
      case NotificationType.scheduleChange: return '📅';
      case NotificationType.newEvent: return '🎉';
      case NotificationType.registrationSuccess: return '✅';
      case NotificationType.eventCancelled: return '❌';
      case NotificationType.general: return 'ℹ️';
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final String? eventId;
  final String? imageUrl;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.eventId,
    this.imageUrl,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      eventId: eventId,
      imageUrl: imageUrl,
    );
  }
}
