class ApiConstants {

  static const String baseUrl = 'http://10.0.2.2:8080';
  //static const String baseUrl = 'https://shade-perry-bomb-breakfast.trycloudflare.com' // Placeholder

  static const String loginEndpoint = '/api/auth/login';
  static const String passwordResetRequestEndpoint = '/api/auth/password-reset/request';
  static const String registerEndpoint = '/api/auth/register';

  static const String categoriesEndpoint = '/api/categories';
  static const String categoriesPreferencesEndpoint = '/api/categories/preferences';

  static const String dashboardEndpoint = '/api/dashboard';
  static const String completeChallengeEndpoint = '/api/challenges/{id}/complete';
  static const String skipChallengeEndpoint = '/api/challenges/{id}/skip';

}

