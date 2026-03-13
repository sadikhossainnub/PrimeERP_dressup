/// App-wide constants
class AppConstants {
  AppConstants._();

  static const String appName = 'PrimeERP';
  static const String appVersion = '1.0.0';

  // Secure Storage Keys
  static const String keyBaseUrl = 'base_url';
  static const String keyApiKey = 'api_key';
  static const String keyApiSecret = 'api_secret';
  static const String keyUsername = 'username';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserFullName = 'user_full_name';
  static const String keyUserEmail = 'user_email';
  static const String keyUserImage = 'user_image';

  // Hive Box Names
  static const String hiveMetaBox = 'doctype_meta_cache';
  static const String hiveSettingsBox = 'app_settings';

  // Pagination
  static const int pageSize = 20;

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;

  // DocStatus values
  static const int docstatusDraft = 0;
  static const int docstatusSubmitted = 1;
  static const int docstatusCancelled = 2;
}
