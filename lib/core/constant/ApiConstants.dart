class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static String adminLoginUrl() => '$baseUrl/web/admin/login';
  static String receptionistLoginUrl() => '$baseUrl/web/receptionist/login';

  static String forgetPasswordUrl() => '$baseUrl/client/forget-password';
  static String checkCodeUrl()=> '$baseUrl/client/check-code';
  static String resetPasswordUrl() => '$baseUrl/client/reset-password';
}
