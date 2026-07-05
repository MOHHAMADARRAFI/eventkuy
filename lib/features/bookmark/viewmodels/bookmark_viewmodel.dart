// lib/features/bookmark/viewmodels/bookmark_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:eventkuy/data/models/bookmark_model.dart';
import 'package:eventkuy/data/repositories/bookmark_repository.dart';

enum BookmarkState { initial, loading, success, empty, error }

class BookmarkViewModel extends ChangeNotifier {
  final BookmarkRepository _bookmarkRepo;

  BookmarkViewModel(this._bookmarkRepo);

  BookmarkState _state = BookmarkState.initial;
  List<BookmarkModel> _bookmarks = [];
  Set<String> _bookmarkedIds = {};
  String? _error;

  BookmarkState get state => _state;
  List<BookmarkModel> get bookmarks => _bookmarks;
  Set<String> get bookmarkedIds => _bookmarkedIds;
  String? get error => _error;
  bool get isLoading => _state == BookmarkState.loading;

  Future<void> loadBookmarks(String userId) async {
    _state = BookmarkState.loading;
    notifyListeners();

    try {
      _bookmarks = await _bookmarkRepo.getBookmarks(userId);
      _bookmarkedIds = _bookmarks.map((b) => b.event.id).toSet();
      _state = _bookmarks.isEmpty ? BookmarkState.empty : BookmarkState.success;
    } catch (e) {
      _error = e.toString();
      _state = BookmarkState.error;
    }

    notifyListeners();
  }

  Future<void> removeBookmark(String userId, String eventId) async {
    await _bookmarkRepo.removeBookmark(userId, eventId);
    _bookmarks.removeWhere((b) => b.event.id == eventId);
    _bookmarkedIds.remove(eventId);
    _state = _bookmarks.isEmpty ? BookmarkState.empty : BookmarkState.success;
    notifyListeners();
  }

  bool isBookmarked(String eventId) => _bookmarkedIds.contains(eventId);
}
