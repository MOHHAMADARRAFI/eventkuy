// lib/data/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final List<String> interests;
  final String? bio;
  final String? location;
  final DateTime joinedAt;
  final int totalRegistrations;
  final int totalBookmarks;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.interests,
    this.bio,
    this.location,
    required this.joinedAt,
    required this.totalRegistrations,
    required this.totalBookmarks,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  String get avatarUrl =>
      photoUrl ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}'
          '&background=2563EB&color=fff&size=200&bold=true';

  String get level {
    if (totalRegistrations >= 20) return '🏆 Expert';
    if (totalRegistrations >= 10) return '⭐ Aktif';
    if (totalRegistrations >= 5) return '🎯 Pemula';
    return '🌱 Baru';
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    List<String>? interests,
    String? bio,
    String? location,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      interests: interests ?? this.interests,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      joinedAt: joinedAt,
      totalRegistrations: totalRegistrations,
      totalBookmarks: totalBookmarks,
    );
  }
}

class InterestModel {
  final String id;
  final String name;
  final String emoji;

  const InterestModel({
    required this.id,
    required this.name,
    required this.emoji,
  });
}
