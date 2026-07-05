// lib/features/event_detail/viewmodels/event_detail_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:eventkuy/data/models/event_model.dart';
import 'package:eventkuy/data/repositories/event_repository.dart';
import 'package:eventkuy/data/repositories/bookmark_repository.dart';
import 'package:eventkuy/data/repositories/user_repository.dart';

enum DetailState { initial, loading, success, error }

class EventDetailViewModel extends ChangeNotifier {
  final EventRepository _eventRepo;
  final BookmarkRepository _bookmarkRepo;
  final UserRepository _userRepo;

  EventDetailViewModel(this._eventRepo, this._bookmarkRepo, this._userRepo);

  DetailState _state = DetailState.initial;
  EventModel? _event;
  bool _isBookmarked = false;
  bool _isRegistered = false;
  bool _isRegistering = false;
  String? _error;

  DetailState get state => _state;
  EventModel? get event => _event;
  bool get isBookmarked => _isBookmarked;
  bool get isRegistered => _isRegistered;
  bool get isRegistering => _isRegistering;
  String? get error => _error;
  bool get isLoading => _state == DetailState.loading;

  Future<void> loadEvent(String eventId, String userId) async {
    _state = DetailState.loading;
    notifyListeners();

    try {
      final results = await Future.wait([
        _eventRepo.getEventById(eventId),
        _bookmarkRepo.isBookmarked(userId, eventId),
      ]);

      _event = results[0] as EventModel?;
      _isBookmarked = results[1] as bool;

      if (_event == null) {
        _error = 'Event tidak ditemukan';
        _state = DetailState.error;
      } else {
        _state = DetailState.success;
      }
    } catch (e) {
      _error = e.toString();
      _state = DetailState.error;
    }

    notifyListeners();
  }

  Future<bool> toggleBookmark(String userId) async {
    if (_event == null) return false;
    final wasBookmarked = _isBookmarked;

    // Optimistic update
    _isBookmarked = !_isBookmarked;
    notifyListeners();

    try {
      if (wasBookmarked) {
        await _bookmarkRepo.removeBookmark(userId, _event!.id);
      } else {
        await _bookmarkRepo.addBookmark(userId, _event!);
      }
      return true;
    } catch (e) {
      // Revert on failure
      _isBookmarked = wasBookmarked;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerForEvent(String userId) async {
    if (_event == null || _isRegistered) return false;
    _isRegistering = true;
    notifyListeners();

    try {
      await _userRepo.registerForEvent(userId, _event!.id);
      _isRegistered = true;
      _isRegistering = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isRegistering = false;
      notifyListeners();
      return false;
    }
  }
}
