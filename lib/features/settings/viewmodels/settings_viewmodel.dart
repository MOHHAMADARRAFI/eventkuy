// lib/features/settings/viewmodels/settings_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:eventkuy/services/storage/local_storage.dart';

class SettingsViewModel extends ChangeNotifier {
  final LocalStorage _storage;

  SettingsViewModel(this._storage) {
    _isDarkMode = _storage.isDarkMode;
    _isNotificationEnabled = true;
    _language = 'Indonesia';
  }

  bool _isDarkMode = false;
  bool _isNotificationEnabled = true;
  String _language = 'Indonesia';

  bool get isDarkMode => _isDarkMode;
  bool get isNotificationEnabled => _isNotificationEnabled;
  String get language => _language;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _storage.isDarkMode = _isDarkMode;
    notifyListeners();
  }

  void toggleNotification() {
    _isNotificationEnabled = !_isNotificationEnabled;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }
}
