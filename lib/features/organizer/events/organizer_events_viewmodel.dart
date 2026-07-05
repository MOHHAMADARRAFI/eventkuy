// lib/features/organizer/events/organizer_events_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:eventkuy/data/models/event_model.dart';
import 'package:eventkuy/data/repositories/event_repository.dart';

class OrganizerEventsViewModel extends ChangeNotifier {
  final EventRepository _eventRepo;

  OrganizerEventsViewModel(this._eventRepo);

  List<EventModel> _allEvents = [];
  List<EventModel> _filteredEvents = [];
  bool _isLoading = false;
  String _searchQuery = '';
  EventStatus? _selectedStatus;

  List<EventModel> get events => _filteredEvents;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  EventStatus? get selectedStatus => _selectedStatus;

  Future<void> loadEvents(String organizerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _allEvents = await _eventRepo.getEventsByOrganizer(organizerId);
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading organizer events: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setFilterStatus(EventStatus? status) {
    _selectedStatus = status;
    _applyFilters();
  }

  void _applyFilters() {
    var list = List<EventModel>.from(_allEvents);

    // Search query filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((e) {
        return e.title.toLowerCase().contains(q) ||
            e.description.toLowerCase().contains(q) ||
            e.location.toLowerCase().contains(q);
      }).toList();
    }

    // Status filter
    if (_selectedStatus != null) {
      list = list.where((e) => e.status == _selectedStatus).toList();
    }

    _filteredEvents = list..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> createEvent(EventModel event) async {
    // In real app, call API. For mock, add to DummyData.events
    _allEvents.add(event);
    _applyFilters();
  }

  Future<void> updateEvent(EventModel event) async {
    final idx = _allEvents.indexWhere((e) => e.id == event.id);
    if (idx != -1) {
      _allEvents[idx] = event;
      _applyFilters();
    }
  }

  Future<void> deleteEvent(String id) async {
    _allEvents.removeWhere((e) => e.id == id);
    _applyFilters();
  }
}
