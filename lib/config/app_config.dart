// lib/config/app_config.dart
// Global application configuration constants

class AppConfig {
  AppConfig._();

  static const String appName = 'EventKuy';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appDescription =
      'Platform informasi event terbaik untuk seminar, workshop, bootcamp, lomba, dan webinar.';
  static const String supportEmail = 'support@eventkuy.id';
  static const String websiteUrl = 'https://eventkuy.id';
  static const String privacyPolicyUrl = 'https://eventkuy.id/privacy';
  static const String termsUrl = 'https://eventkuy.id/terms';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=id.eventkuy';

  // Pagination
  static const int defaultPageSize = 10;
  static const int bannerAutoPlaySeconds = 4;

  // Cache duration
  static const Duration cacheDuration = Duration(minutes: 30);
  static const Duration shortCacheDuration = Duration(minutes: 5);

  // Image dimensions
  static const double eventCardImageHeight = 180.0;
  static const double bannerImageHeight = 200.0;
  static const double organizerLogoSize = 56.0;
  static const double avatarSize = 80.0;

  // Minimum interests selection
  static const int minInterestSelection = 2;
}
