// lib/services/storage/local_storage.dart
// Key-value local storage abstraction using SharedPreferences
// Currently implemented in-memory; swap with shared_preferences when ready

class LocalStorage {
  LocalStorage._();
  static final LocalStorage _instance = LocalStorage._();
  static LocalStorage get instance => _instance;

  // In-memory store (replace with SharedPreferences)
  final Map<String, dynamic> _store = {};

  // ── Auth ──────────────────────────────────────────
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyOnboardingDone = 'onboarding_done';

  // ── Theme ─────────────────────────────────────────
  static const String _keyDarkMode = 'dark_mode';

  // ── Search ────────────────────────────────────────
  static const String _keyRecentSearches = 'recent_searches';

  // ── Methods ───────────────────────────────────────
  void setString(String key, String value) => _store[key] = value;
  String? getString(String key) => _store[key] as String?;

  void setBool(String key, {required bool value}) => _store[key] = value;
  bool getBool(String key, {bool defaultValue = false}) =>
      (_store[key] as bool?) ?? defaultValue;

  void setList(String key, List<String> value) => _store[key] = value;
  List<String> getList(String key) =>
      (_store[key] as List<String>?) ?? [];

  void remove(String key) => _store.remove(key);
  void clear() => _store.clear();

  // ── Convenience Accessors ─────────────────────────
  String? get authToken => getString(_keyAuthToken);
  set authToken(String? v) =>
      v == null ? remove(_keyAuthToken) : setString(_keyAuthToken, v);

  bool get isLoggedIn => getBool(_keyIsLoggedIn);
  set isLoggedIn(bool v) => setBool(_keyIsLoggedIn, value: v);

  bool get onboardingDone => getBool(_keyOnboardingDone);
  set onboardingDone(bool v) => setBool(_keyOnboardingDone, value: v);

  bool get isDarkMode => getBool(_keyDarkMode);
  set isDarkMode(bool v) => setBool(_keyDarkMode, value: v);

  String? get userId => getString(_keyUserId);
  set userId(String? v) =>
      v == null ? remove(_keyUserId) : setString(_keyUserId, v);

  List<String> get recentSearches => getList(_keyRecentSearches);
  void addRecentSearch(String query) {
    final searches = recentSearches;
    searches.remove(query);
    searches.insert(0, query);
    if (searches.length > 10) searches.removeLast();
    setList(_keyRecentSearches, searches);
  }
  void clearRecentSearches() => remove(_keyRecentSearches);
}
