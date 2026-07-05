// lib/features/explore/viewmodels/explore_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:eventkuy/data/dummy/dummy_data.dart';
import 'package:eventkuy/data/models/event_model.dart';
import 'package:eventkuy/data/repositories/event_repository.dart';
import 'package:eventkuy/services/storage/local_storage.dart';

enum ExploreState { initial, loading, success, empty, error }

class FilterOptions {
  final String? categoryId;
  final EventMode? mode;
  final bool? isFree;
  final String? location;

  const FilterOptions({
    this.categoryId,
    this.mode,
    this.isFree,
    this.location,
  });

  bool get hasFilters =>
      categoryId != null || mode != null || isFree != null || location != null;

  FilterOptions copyWith({
    String? categoryId,
    EventMode? mode,
    bool? isFree,
    String? location,
    bool clearCategory = false,
    bool clearMode = false,
    bool clearPrice = false,
  }) {
    return FilterOptions(
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      mode: clearMode ? null : (mode ?? this.mode),
      isFree: clearPrice ? null : (isFree ?? this.isFree),
      location: location ?? this.location,
    );
  }

  FilterOptions clear() => const FilterOptions();
}

class ExploreViewModel extends ChangeNotifier {
  final EventRepository _eventRepo;
  final LocalStorage _storage;

  ExploreViewModel(this._eventRepo, this._storage);

  ExploreState _state = ExploreState.initial;
  List<EventModel> _results = [];
  String _query = '';
  FilterOptions _filters = const FilterOptions();
  List<String> _recentSearches = [];
  String? _error;

  ExploreState get state => _state;
  List<EventModel> get results => _results;
  String get query => _query;
  FilterOptions get filters => _filters;
  List<String> get recentSearches => _recentSearches;
  List<String> get popularSearches => DummyData.popularSearches;
  String? get error => _error;
  bool get isLoading => _state == ExploreState.loading;
  bool get hasFilters => _filters.hasFilters;
  bool get showInitialState => _state == ExploreState.initial && _query.isEmpty;

  void loadRecentSearches() {
    _recentSearches = _storage.recentSearches;
    notifyListeners();
  }

  Future<void> search(String query) async {
    _query = query;

    if (query.trim().isEmpty && !_filters.hasFilters) {
      _state = ExploreState.initial;
      _results = [];
      notifyListeners();
      return;
    }

    _state = ExploreState.loading;
    notifyListeners();

    try {
      if (query.trim().isNotEmpty) {
        _storage.addRecentSearch(query.trim());
        _recentSearches = _storage.recentSearches;
      }

      final results = await _eventRepo.getEvents(
        query: query,
        categoryId: _filters.categoryId,
        mode: _filters.mode,
        isFree: _filters.isFree,
      );

      _results = results;
      _state = results.isEmpty ? ExploreState.empty : ExploreState.success;
    } catch (e) {
      _error = e.toString();
      _state = ExploreState.error;
    }

    notifyListeners();
  }

  void applyFilters(FilterOptions filters) {
    _filters = filters;
    if (_query.isNotEmpty || filters.hasFilters) {
      search(_query);
    }
  }

  void clearFilters() {
    _filters = const FilterOptions();
    search(_query);
  }

  void clearRecentSearches() {
    _storage.clearRecentSearches();
    _recentSearches = [];
    notifyListeners();
  }

  void selectRecentSearch(String query) {
    search(query);
  }

  void clearQuery() {
    _query = '';
    _state = ExploreState.initial;
    _results = [];
    notifyListeners();
  }
}
