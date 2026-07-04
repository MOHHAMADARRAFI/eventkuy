// lib/data/models/event_model.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'category_model.dart';
import 'organizer_model.dart';

// ── EventMode ──────────────────────────────────────────
enum EventMode { online, offline, hybrid }

extension EventModeExt on EventMode {
  String get label {
    switch (this) {
      case EventMode.online:
        return 'Online';
      case EventMode.offline:
        return 'Offline';
      case EventMode.hybrid:
        return 'Hybrid';
    }
  }
}

// ── EventType (re-exported from category_model) ────────
// EventType enum is defined in category_model.dart.
// The extension below is kept here so any file that imports
// event_model.dart automatically gets .label / .color / .bgColor.
extension EventTypeDisplay on EventType {
  String get label {
    switch (this) {
      case EventType.seminar:
        return 'Seminar';
      case EventType.workshop:
        return 'Workshop';
      case EventType.bootcamp:
        return 'Bootcamp';
      case EventType.competition:
        return 'Lomba';
      case EventType.webinar:
        return 'Webinar';
      case EventType.conference:
        return 'Konferensi';
      case EventType.talkshow:
        return 'Talkshow';
    }
  }

  Color get color {
    switch (this) {
      case EventType.seminar:
        return AppColors.catTechnology;
      case EventType.workshop:
        return AppColors.catDesign;
      case EventType.bootcamp:
        return AppColors.secondary;
      case EventType.competition:
        return AppColors.catArts;
      case EventType.webinar:
        return AppColors.catPersonalDev;
      case EventType.conference:
        return AppColors.catBusiness;
      case EventType.talkshow:
        return AppColors.catMarketing;
    }
  }

  Color get bgColor {
    switch (this) {
      case EventType.seminar:
        return AppColors.primaryContainer;
      case EventType.workshop:
        return const Color(0xFFFCE7F3);
      case EventType.bootcamp:
        return AppColors.secondaryContainer;
      case EventType.competition:
        return AppColors.errorLight;
      case EventType.webinar:
        return AppColors.infoLight;
      case EventType.conference:
        return AppColors.successLight;
      case EventType.talkshow:
        return AppColors.warningLight;
    }
  }
}

// ── Speaker ────────────────────────────────────────────
class SpeakerModel {
  final String name;
  final String title;
  final String company;
  final String photoUrl;
  final String? linkedIn;

  const SpeakerModel({
    required this.name,
    required this.title,
    required this.company,
    required this.photoUrl,
    this.linkedIn,
  });
}

// ── Agenda ─────────────────────────────────────────────
class AgendaItem {
  final String time;
  final String title;
  final String? description;

  const AgendaItem({
    required this.time,
    required this.title,
    this.description,
  });
}

// ── EventModel ─────────────────────────────────────────
class EventModel {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final String categoryId;
  final String categoryName;
  final EventType eventType;
  final EventMode mode;
  final OrganizerModel organizer;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String? mapsUrl;
  final double? latitude;
  final double? longitude;
  final bool isFree;
  final int? price;
  final int quota;
  final int registered;
  final List<String> benefits;
  final List<SpeakerModel> speakers;
  final List<AgendaItem> agenda;
  final List<String> tags;
  final bool isTrending;
  final bool isFeatured;
  final double rating;
  final int views;
  final DateTime createdAt;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.categoryId,
    required this.categoryName,
    required this.eventType,
    required this.mode,
    required this.organizer,
    required this.startDate,
    required this.endDate,
    required this.location,
    this.mapsUrl,
    this.latitude,
    this.longitude,
    required this.isFree,
    this.price,
    required this.quota,
    required this.registered,
    required this.benefits,
    required this.speakers,
    required this.agenda,
    required this.tags,
    required this.isTrending,
    required this.isFeatured,
    required this.rating,
    required this.views,
    required this.createdAt,
  });

  int get seatsLeft => quota - registered;
  bool get isFull => seatsLeft <= 0;
  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isOngoing =>
      startDate.isBefore(DateTime.now()) && endDate.isAfter(DateTime.now());
  bool get isCompleted => endDate.isBefore(DateTime.now());

  String get priceLabel {
    if (isFree) return 'Gratis';
    if (price != null) {
      final formatted = price! >= 1000
          ? 'Rp ${(price! / 1000).toStringAsFixed(0)}k'
          : 'Rp $price';
      return formatted;
    }
    return 'Berbayar';
  }

  String get formattedViews {
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}k views';
    return '$views views';
  }
}
