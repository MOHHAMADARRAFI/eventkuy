// lib/features/organizer/viewmodels/organizer_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:eventkuy/data/models/event_model.dart';
import 'package:eventkuy/data/models/organizer_model.dart';
import 'package:eventkuy/data/repositories/event_repository.dart';
import 'package:eventkuy/data/dummy/dummy_data.dart';

enum OrganizerState { initial, loading, success, error }

class OrganizerViewModel extends ChangeNotifier {
  final EventRepository _eventRepo;

  OrganizerViewModel(this._eventRepo);

  OrganizerState _state = OrganizerState.initial;
  OrganizerModel? _organizer;
  List<EventModel> _events = [];
  bool _isFollowing = false;
  String? _error;

  OrganizerState get state => _state;
  OrganizerModel? get organizer => _organizer;
  List<EventModel> get events => _events;
  bool get isFollowing => _isFollowing;
  String? get error => _error;
  bool get isLoading => _state == OrganizerState.loading;

  Future<void> load(String organizerId) async {
    _state = OrganizerState.loading;
    notifyListeners();

    try {
      _organizer = DummyData.organizers.firstWhere((o) => o.id == organizerId);
      _events = await _eventRepo.getEventsByOrganizer(organizerId);
      _state = OrganizerState.success;
    } catch (e) {
      _error = e.toString();
      _state = OrganizerState.error;
    }

    notifyListeners();
  }

  void toggleFollow() {
    _isFollowing = !_isFollowing;
    notifyListeners();
  }
}
