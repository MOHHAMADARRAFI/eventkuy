// lib/config/env.dart
// Environment-specific configuration

enum Environment { development, staging, production }

class Env {
  Env._();

  static Environment current = Environment.development;

  static bool get isDevelopment => current == Environment.development;
  static bool get isStaging => current == Environment.staging;
  static bool get isProduction => current == Environment.production;
  static bool get isDebug => !isProduction;

  static String get apiBaseUrl {
    switch (current) {
      case Environment.development:
        return 'http://localhost:8000/api/v1';
      case Environment.staging:
        return 'https://staging-api.eventkuy.id/api/v1';
      case Environment.production:
        return 'https://api.eventkuy.id/api/v1';
    }
  }

  static String get googleClientId {
    switch (current) {
      case Environment.development:
        return 'YOUR_DEV_GOOGLE_CLIENT_ID.apps.googleusercontent.com';
      case Environment.staging:
        return 'YOUR_STAGING_GOOGLE_CLIENT_ID.apps.googleusercontent.com';
      case Environment.production:
        return 'YOUR_PROD_GOOGLE_CLIENT_ID.apps.googleusercontent.com';
    }
  }

  static String get firebaseProjectId {
    switch (current) {
      case Environment.development:
        return 'eventkuy-dev';
      case Environment.staging:
        return 'eventkuy-staging';
      case Environment.production:
        return 'eventkuy-prod';
    }
  }

  static int get connectTimeoutMs => isProduction ? 10000 : 30000;
  static int get receiveTimeoutMs => isProduction ? 10000 : 30000;
}
