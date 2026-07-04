// lib/features/my_event/viewmodels/my_event_viewmodel.dart

import 'package:flutter/material.dart';
import '../../../data/models/registration_model.dart';
import '../../../data/repositories/user_repository.dart';

enum MyEventState { initial, loading, success, empty, error }

class MyEventViewModel extends ChangeNotifier {
  final UserRepository _userRepo;

  MyEventViewModel(this._userRepo);

  MyEventState _state = MyEventState.initial;
  List<RegistrationModel> _allRegistrations = [];
  String? _error;
  int _tabIndex = 0;

  MyEventState get state => _state;
  String? get error => _error;
  int get tabIndex => _tabIndex;
  bool get isLoading => _state == MyEventState.loading;

  List<RegistrationModel> get upcomingRegistrations => _allRegistrations
      .where((r) => r.status == RegistrationStatus.upcoming || r.status == RegistrationStatus.pending)
      .toList();

  List<RegistrationModel> get completedRegistrations => _allRegistrations
      .where((r) => r.status == RegistrationStatus.completed)
      .toList();

  List<RegistrationModel> get cancelledRegistrations => _allRegistrations
      .where((r) => r.status == RegistrationStatus.cancelled)
      .toList();

  List<RegistrationModel> get currentTabRegistrations {
    switch (_tabIndex) {
      case 0: return upcomingRegistrations;
      case 1: return completedRegistrations;
      case 2: return cancelledRegistrations;
      default: return upcomingRegistrations;
    }
  }

  Future<void> load(String userId) async {
    _state = MyEventState.loading;
    notifyListeners();

    try {
      _allRegistrations = await _userRepo.getRegistrations(userId);
      _state = _allRegistrations.isEmpty ? MyEventState.empty : MyEventState.success;
    } catch (e) {
      _error = e.toString();
      _state = MyEventState.error;
    }

    notifyListeners();
  }

  void setTab(int index) {
    _tabIndex = index;
    notifyListeners();
  }
}
