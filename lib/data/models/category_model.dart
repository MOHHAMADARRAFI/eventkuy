// lib/data/models/category_model.dart

import 'package:flutter/material.dart';

// ── CategoryModel ──────────────────────────────────────
class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final Color bgColor;
  final int eventCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.eventCount,
  });
}

// ── EventType enum ─────────────────────────────────────
// Extension (label / color / bgColor) is defined in event_model.dart
// so that importing event_model.dart is sufficient for all widgets.
enum EventType {
  seminar,
  workshop,
  bootcamp,
  competition,
  webinar,
  conference,
  talkshow,
}
