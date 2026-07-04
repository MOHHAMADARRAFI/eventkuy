// lib/data/repositories/bookmark_repository.dart

import '../dummy/dummy_data.dart';
import '../models/bookmark_model.dart';
import '../models/event_model.dart';

abstract class IBookmarkRepository {
  Future<List<BookmarkModel>> getBookmarks(String userId);
  Future<bool> isBookmarked(String userId, String eventId);
  Future<void> addBookmark(String userId, EventModel event);
  Future<void> removeBookmark(String userId, String eventId);
}

class BookmarkRepository implements IBookmarkRepository {
  // In-memory bookmark store for demo
  final List<BookmarkModel> _bookmarks = List.from(DummyData.bookmarks);

  Future<void> _delay() async =>
      await Future.delayed(const Duration(milliseconds: 400));

  @override
  Future<List<BookmarkModel>> getBookmarks(String userId) async {
    await _delay();
    return _bookmarks.where((b) => b.userId == userId).toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  @override
  Future<bool> isBookmarked(String userId, String eventId) async {
    return _bookmarks.any(
      (b) => b.userId == userId && b.event.id == eventId,
    );
  }

  @override
  Future<void> addBookmark(String userId, EventModel event) async {
    await _delay();
    if (!await isBookmarked(userId, event.id)) {
      _bookmarks.add(BookmarkModel(
        id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        event: event,
        savedAt: DateTime.now(),
      ));
    }
  }

  @override
  Future<void> removeBookmark(String userId, String eventId) async {
    await _delay();
    _bookmarks.removeWhere(
      (b) => b.userId == userId && b.event.id == eventId,
    );
  }
}
