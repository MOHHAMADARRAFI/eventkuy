// lib/data/models/event_model.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'category_model.dart';
import 'organizer_model.dart';
import 'ticket_model.dart';

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

// ── EventStatus ────────────────────────────────────────
enum EventStatus {
  draft,
  submittedForReview,
  approved,
  rejected,
  published,
  registrationOpen,
  registrationClosed,
  ongoing,
  finished,
  archived,
  cancelled
}

extension EventStatusDisplay on EventStatus {
  String get label {
    switch (this) {
      case EventStatus.draft:
        return 'Draft';
      case EventStatus.submittedForReview:
        return 'Menunggu Review';
      case EventStatus.approved:
        return 'Disetujui';
      case EventStatus.rejected:
        return 'Ditolak';
      case EventStatus.published:
        return 'Diterbitkan';
      case EventStatus.registrationOpen:
        return 'Registrasi Buka';
      case EventStatus.registrationClosed:
        return 'Registrasi Tutup';
      case EventStatus.ongoing:
        return 'Berlangsung';
      case EventStatus.finished:
        return 'Selesai';
      case EventStatus.archived:
        return 'Diarsipkan';
      case EventStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  Color get color {
    switch (this) {
      case EventStatus.draft:
        return AppColors.textSecondary;
      case EventStatus.submittedForReview:
        return AppColors.warning;
      case EventStatus.approved:
        return AppColors.info;
      case EventStatus.rejected:
        return AppColors.error;
      case EventStatus.published:
        return AppColors.primary;
      case EventStatus.registrationOpen:
        return AppColors.success;
      case EventStatus.registrationClosed:
        return AppColors.textTertiary;
      case EventStatus.ongoing:
        return AppColors.secondary;
      case EventStatus.finished:
        return AppColors.successDark;
      case EventStatus.archived:
        return AppColors.textDisabled;
      case EventStatus.cancelled:
        return AppColors.errorDark;
    }
  }
}

// ── EventType (re-exported from category_model) ────────
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

// ── Timeline ───────────────────────────────────────────
class TimelineItem {
  final String time;
  final String title;
  final String? description;

  const TimelineItem({
    required this.time,
    required this.title,
    this.description,
  });
}

// ── FAQ ────────────────────────────────────────────────
class FaqItem {
  final String question;
  final String answer;

  const FaqItem({
    required this.question,
    required this.answer,
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

  // New features for Organizer and Admin roles
  final EventStatus status;
  final List<TicketModel> tickets;
  final List<String> galleryUrls;
  final DateTime? registrationDeadline;
  final List<TimelineItem> timeline;
  final List<FaqItem> faq;
  final String? termsConditions;
  final String? refundPolicy;
  final List<String> sponsors;
  final String? contactPerson;
  final bool certificateAvailable;
  final String? certificateTemplateUrl;
  final String? googleMapsLink;

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
    
    // Default values for backward compatibility
    this.status = EventStatus.published,
    this.tickets = const [],
    this.galleryUrls = const [],
    this.registrationDeadline,
    this.timeline = const [],
    this.faq = const [],
    this.termsConditions,
    this.refundPolicy,
    this.sponsors = const [],
    this.contactPerson,
    this.certificateAvailable = false,
    this.certificateTemplateUrl,
    this.googleMapsLink,
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

  EventModel copyWith({
    String? title,
    String? description,
    String? posterUrl,
    String? categoryId,
    String? categoryName,
    EventType? eventType,
    EventMode? mode,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? mapsUrl,
    bool? isFree,
    int? price,
    int? quota,
    int? registered,
    List<String>? benefits,
    List<SpeakerModel>? speakers,
    List<AgendaItem>? agenda,
    List<String>? tags,
    EventStatus? status,
    List<TicketModel>? tickets,
    List<String>? galleryUrls,
    DateTime? registrationDeadline,
    List<TimelineItem>? timeline,
    List<FaqItem>? faq,
    String? termsConditions,
    String? refundPolicy,
    List<String>? sponsors,
    String? contactPerson,
    bool? certificateAvailable,
    String? certificateTemplateUrl,
    String? googleMapsLink,
  }) {
    return EventModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      posterUrl: posterUrl ?? this.posterUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      eventType: eventType ?? this.eventType,
      mode: mode ?? this.mode,
      organizer: organizer,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      mapsUrl: mapsUrl ?? this.mapsUrl,
      latitude: latitude,
      longitude: longitude,
      isFree: isFree ?? this.isFree,
      price: price ?? this.price,
      quota: quota ?? this.quota,
      registered: registered ?? this.registered,
      benefits: benefits ?? this.benefits,
      speakers: speakers ?? this.speakers,
      agenda: agenda ?? this.agenda,
      tags: tags ?? this.tags,
      isTrending: isTrending,
      isFeatured: isFeatured,
      rating: rating,
      views: views,
      createdAt: createdAt,
      status: status ?? this.status,
      tickets: tickets ?? this.tickets,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      timeline: timeline ?? this.timeline,
      faq: faq ?? this.faq,
      termsConditions: termsConditions ?? this.termsConditions,
      refundPolicy: refundPolicy ?? this.refundPolicy,
      sponsors: sponsors ?? this.sponsors,
      contactPerson: contactPerson ?? this.contactPerson,
      certificateAvailable: certificateAvailable ?? this.certificateAvailable,
      certificateTemplateUrl: certificateTemplateUrl ?? this.certificateTemplateUrl,
      googleMapsLink: googleMapsLink ?? this.googleMapsLink,
    );
  }
}

