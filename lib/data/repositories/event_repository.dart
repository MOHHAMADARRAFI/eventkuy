// lib/data/repositories/event_repository.dart
// Event data source abstraction – uses dummy data, ready for API swap

import 'dart:async';
import '../dummy/dummy_data.dart';
import '../models/event_model.dart';

abstract class IEventRepository {
  Future<List<EventModel>> getEvents({
    String? categoryId,
    String? query,
    EventMode? mode,
    bool? isFree,
    String? sortBy,
  });
  Future<List<EventModel>> getTrendingEvents();
  Future<List<EventModel>> getUpcomingEvents();
  Future<List<EventModel>> getFeaturedEvents();
  Future<List<EventModel>> getNearbyEvents();
  Future<List<EventModel>> getRecommendedEvents(List<String> interests);
  Future<List<EventModel>> getEventsByOrganizer(String organizerId);
  Future<EventModel?> getEventById(String id);
}

class EventRepository implements IEventRepository {
  EventRepository();

  // Simulate network delay for realistic behavior
  Future<void> _delay() async =>
      await Future.delayed(const Duration(milliseconds: 800));

  @override
  Future<List<EventModel>> getEvents({
    String? categoryId,
    String? query,
    EventMode? mode,
    bool? isFree,
    String? sortBy,
  }) async {
    await _delay();
    var events = DummyData.events;

    if (categoryId != null && categoryId.isNotEmpty) {
      events = events.where((e) => e.categoryId == categoryId).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      events = events.where((e) {
        return e.title.toLowerCase().contains(q) ||
            e.description.toLowerCase().contains(q) ||
            e.categoryName.toLowerCase().contains(q) ||
            e.tags.any((t) => t.toLowerCase().contains(q)) ||
            e.organizer.name.toLowerCase().contains(q) ||
            e.location.toLowerCase().contains(q);
      }).toList();
    }

    if (mode != null) {
      events = events.where((e) => e.mode == mode).toList();
    }

    if (isFree != null) {
      events = events.where((e) => e.isFree == isFree).toList();
    }

    return events;
  }

  @override
  Future<List<EventModel>> getTrendingEvents() async {
    await _delay();
    return DummyData.trendingEvents;
  }

  @override
  Future<List<EventModel>> getUpcomingEvents() async {
    await _delay();
    return DummyData.upcomingEvents;
  }

  @override
  Future<List<EventModel>> getFeaturedEvents() async {
    await _delay();
    return DummyData.bannerEvents;
  }

  @override
  Future<List<EventModel>> getNearbyEvents() async {
    await _delay();
    return DummyData.nearbyEvents;
  }

  @override
  Future<List<EventModel>> getRecommendedEvents(
      List<String> interests) async {
    await _delay();
    return DummyData.getRecommended(interests);
  }

  @override
  Future<List<EventModel>> getEventsByOrganizer(String organizerId) async {
    await _delay();
    return DummyData.getEventsByOrganizer(organizerId);
  }

  @override
  Future<EventModel?> getEventById(String id) async {
    await _delay();
    try {
      return DummyData.events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
