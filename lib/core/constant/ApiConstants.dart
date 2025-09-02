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



  // Services
  static String addServiceUrl() => "$baseUrl/web/add-service";
  static String updateServiceUrl(int id) => "$baseUrl/web/update-service/$id";
  static String showServicesUrl() => "$baseUrl/web/services";
  static String showServiceUrl(int id) => "$baseUrl/web/service/$id";
  static String deleteServiceUrl(int id) => "$baseUrl/web/delete-service/$id";
  static String searchServiceUrl() => "$baseUrl/web/search-service";


  // offers
  static String showOffersUrl() => '$baseUrl/web/offers';
  static String showOfferUrl(int id) => '$baseUrl/web/offer/$id';
  static String addOfferUrl() => '$baseUrl/web/add-offer';
  static String updateOfferUrl(int id) => '$baseUrl/web/update-offer/$id';
  static String deleteOfferUrl(int id) => '$baseUrl/web/delete-offer/$id';


}
