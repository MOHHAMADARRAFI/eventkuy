// lib/data/models/organizer_model.dart

class OrganizerModel {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final String location;
  final String website;
  final double rating;
  final int totalEvents;
  final int followers;
  final bool isVerified;
  final List<String> tags;

  const OrganizerModel({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.location,
    required this.website,
    required this.rating,
    required this.totalEvents,
    required this.followers,
    required this.isVerified,
    required this.tags,
  });

  String get formattedFollowers {
    if (followers >= 1000) return '${(followers / 1000).toStringAsFixed(1)}k';
    return followers.toString();
  }
}
