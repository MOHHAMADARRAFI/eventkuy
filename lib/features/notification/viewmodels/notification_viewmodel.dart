// lib/features/notification/viewmodels/notification_viewmodel.dart

import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';

enum NotifState { initial, loading, success, empty, error }

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repo;

  NotificationViewModel(this._repo);

  NotifState _state = NotifState.initial;
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  String? _error;

  NotifState get state => _state;
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  String? get error => _error;
  bool get isLoading => _state == NotifState.loading;

  Future<void> load(String userId) async {
    _state = NotifState.loading;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repo.getNotifications(userId),
        _repo.getUnreadCount(userId),
      ]);

      _notifications = results[0] as List<NotificationModel>;
      _unreadCount = results[1] as int;
      _state = _notifications.isEmpty ? NotifState.empty : NotifState.success;
    } catch (e) {
      _error = e.toString();
      _state = NotifState.error;
    }

    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    await _repo.markAsRead(notificationId);
    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      _unreadCount = (_unreadCount - 1).clamp(0, 999);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(String userId) async {
    await _repo.markAllAsRead(userId);
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();
  }
}
