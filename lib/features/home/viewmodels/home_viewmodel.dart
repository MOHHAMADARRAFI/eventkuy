// lib/features/home/viewmodels/home_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:eventkuy/data/models/category_model.dart';
import 'package:eventkuy/data/models/event_model.dart';
import 'package:eventkuy/data/models/organizer_model.dart';
import 'package:eventkuy/data/repositories/event_repository.dart';
import 'package:eventkuy/data/dummy/dummy_data.dart';

enum HomeLoadState { initial, loading, success, error }

class HomeViewModel extends ChangeNotifier {
  final EventRepository _eventRepo;

  HomeViewModel(this._eventRepo);

  HomeLoadState _state = HomeLoadState.initial;
  String? _error;

  List<EventModel> _bannerEvents = [];
  List<EventModel> _trendingEvents = [];
  List<EventModel> _upcomingEvents = [];
  List<EventModel> _recommendedEvents = [];
  List<EventModel> _nearbyEvents = [];
  List<CategoryModel> _categories = [];
  List<OrganizerModel> _popularOrganizers = [];
  String _selectedCategoryId = '';
  bool _isRefreshing = false;

  HomeLoadState get state => _state;
  String? get error => _error;
  List<EventModel> get bannerEvents => _bannerEvents;
  List<EventModel> get trendingEvents => _trendingEvents;
  List<EventModel> get upcomingEvents => _upcomingEvents;
  List<EventModel> get recommendedEvents => _recommendedEvents;
  List<EventModel> get nearbyEvents => _nearbyEvents;
  List<CategoryModel> get categories => _categories;
  List<OrganizerModel> get popularOrganizers => _popularOrganizers;
  String get selectedCategoryId => _selectedCategoryId;
  bool get isRefreshing => _isRefreshing;
  bool get isLoading => _state == HomeLoadState.loading;

  Future<void> loadHome(List<String> userInterests) async {
    _state = HomeLoadState.loading;
    notifyListeners();

    try {
      final results = await Future.wait([
        _eventRepo.getFeaturedEvents(),
        _eventRepo.getTrendingEvents(),
        _eventRepo.getUpcomingEvents(),
        _eventRepo.getRecommendedEvents(userInterests),
        _eventRepo.getNearbyEvents(),
      ]);

      _bannerEvents = results[0];
      _trendingEvents = results[1];
      _upcomingEvents = results[2];
      _recommendedEvents = results[3];
      _nearbyEvents = results[4];
      _categories = DummyData.categories;
      _popularOrganizers = DummyData.organizers;

      _state = HomeLoadState.success;
    } catch (e) {
      _error = e.toString();
      _state = HomeLoadState.error;
    }

    notifyListeners();
  }

  Future<void> refresh(List<String> userInterests) async {
    _isRefreshing = true;
    notifyListeners();
    await loadHome(userInterests);
    _isRefreshing = false;
    notifyListeners();
  }

  void selectCategory(String categoryId) {
    _selectedCategoryId =
        _selectedCategoryId == categoryId ? '' : categoryId;
    notifyListeners();
  }
}
