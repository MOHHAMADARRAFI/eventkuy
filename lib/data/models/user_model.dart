// lib/data/models/user_model.dart

enum UserRole { participant, organizer, admin }

enum VerificationStatus { none, pending, approved, rejected }

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
  
  // Organizer specific fields
  final UserRole role;
  final String? organizationName;
  final String? organizationLogo;
  final VerificationStatus verificationStatus;
  final String? verificationDocsUrl;
  final String? bankName;
  final String? bankAccountNo;
  final String? bankAccountName;
  final Map<String, String>? socialMediaLinks;
  final String? phoneNumber;

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
    this.role = UserRole.participant,
    this.organizationName,
    this.organizationLogo,
    this.verificationStatus = VerificationStatus.none,
    this.verificationDocsUrl,
    this.bankName,
    this.bankAccountNo,
    this.bankAccountName,
    this.socialMediaLinks,
    this.phoneNumber,
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
    UserRole? role,
    String? organizationName,
    String? organizationLogo,
    VerificationStatus? verificationStatus,
    String? verificationDocsUrl,
    String? bankName,
    String? bankAccountNo,
    String? bankAccountName,
    Map<String, String>? socialMediaLinks,
    String? phoneNumber,
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
      role: role ?? this.role,
      organizationName: organizationName ?? this.organizationName,
      organizationLogo: organizationLogo ?? this.organizationLogo,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationDocsUrl: verificationDocsUrl ?? this.verificationDocsUrl,
      bankName: bankName ?? this.bankName,
      bankAccountNo: bankAccountNo ?? this.bankAccountNo,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      socialMediaLinks: socialMediaLinks ?? this.socialMediaLinks,
      phoneNumber: phoneNumber ?? this.phoneNumber,
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
