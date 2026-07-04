// lib/data/repositories/notification_repository.dart

import '../dummy/dummy_data.dart';
import '../models/notification_model.dart';

abstract class INotificationRepository {
  Future<List<NotificationModel>> getNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<int> getUnreadCount(String userId);
}

class NotificationRepository implements INotificationRepository {
  final List<NotificationModel> _notifications =
      List.from(DummyData.notifications);

  Future<void> _delay() async =>
      await Future.delayed(const Duration(milliseconds: 400));

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    await _delay();
    return List.from(_notifications)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    return _notifications.where((n) => !n.isRead).length;
  }
}
