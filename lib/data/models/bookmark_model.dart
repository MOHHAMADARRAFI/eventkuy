// lib/data/models/bookmark_model.dart

import 'event_model.dart';

class BookmarkModel {
  final String id;
  final String userId;
  final EventModel event;
  final DateTime savedAt;

  const BookmarkModel({
    required this.id,
    required this.userId,
    required this.event,
    required this.savedAt,
  });
}
