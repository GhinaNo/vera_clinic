class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000';

  //log in
  static String adminLoginUrl() => '$baseUrl/web/admin/login';
  static String receptionistLoginUrl() => '$baseUrl/web/receptionist/login';

  //log out
  static String logoutUrl() => '$baseUrl/web/logout';

  //password
  static String forgetPasswordUrl() => '$baseUrl/client/forget-password';
  static String checkCodeUrl()=> '$baseUrl/client/check-code';
  static String resetPasswordUrl() => '$baseUrl/client/reset-password';

  // Departments
  static String addDepartmentUrl() => '$baseUrl/web/admin/departments';
  static String updateDepartmentUrl(int id) => '$baseUrl/web/admin/departments/$id';
  static String deleteDepartmentUrl(int id) => '$baseUrl/web/admin/departments/$id';
  static String showDepartmentsUrl() => '$baseUrl/web/admin/departments';
  static String showDepartmentUrl(int id) => '$baseUrl/web/admin/departments/$id';
}
