class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // log in
  static String adminLoginUrl() => '$baseUrl/web/admin/login';
  static String receptionistLoginUrl() => '$baseUrl/web/receptionist/login';

  // log out
  static String logoutUrl() => '$baseUrl/web/logout';

  // password
  static String forgetPasswordUrl() => '$baseUrl/client/forget-password';
  static String checkCodeUrl()=> '$baseUrl/client/check-code';
  static String resetPasswordUrl() => '$baseUrl/client/reset-password';



  // Users
  static String showUsersUrl() => '$baseUrl/web/users';
  static String showUserUrl(int id) => '$baseUrl/web/user/$id';
  static String addUserUrl() => '$baseUrl/web/user';
  static String toggleUserStatusUrl(int id) => '$baseUrl/web/users/$id/toggle-status';
  static String searchUserUrl() => '$baseUrl/web/search-user';

  //employee
  static String showEmployeesUrl() => '$baseUrl/web/admin/employees';
  static String addEmployeeUrl() => '$baseUrl/web/admin/employees';
  static String updateEmployeeUrl(int id) =>
      '$baseUrl/web/admin/employees/$id';
  static String searchEmployeeUrl() =>
      '$baseUrl/web/admin/employees/search';
  static String toggleArchiveEmployeeUrl(int id) =>
      '$baseUrl/web/admin/employees/$id/toggle-archive';
  static String showArchivedEmployeesUrl() =>
      '$baseUrl/web/admin/employees/archives';


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

  // Offers
  static String showOffersUrl() => '$baseUrl/web/offers';
  static String showOfferUrl(int id) => '$baseUrl/web/offer/$id';
  static String addOfferUrl() => '$baseUrl/web/add-offer';
  static String updateOfferUrl(int id) => '$baseUrl/web/update-offer/$id';
  static String deleteOfferUrl(int id) => '$baseUrl/web/delete-offer/$id';

  // Invoices
  static String showInvoicesUrl() => '$baseUrl/web/invoices';
  static String showInvoiceUrl(int id) => '$baseUrl/web/invoice/$id';
  static String createInvoiceUrl(int id) => '$baseUrl/web/invoice/$id';
  static String archiveInvoiceUrl(int id) => '$baseUrl/web/invoice-archive/$id';
  static String restoreInvoiceUrl(int id) => '$baseUrl/web/restore-invoice/$id';
  static String showArchivesUrl() => '$baseUrl/web/archives';
  static String showArchiveUrl(int id) => '$baseUrl/web/archive/$id';
  static String reportsUrl() => '$baseUrl/web/reports';

  // Payments
  static String addPaymentUrl(int invoiceId) => '$baseUrl/web/invoice/$invoiceId/payment';
  static String showPaymentsUrl() => '$baseUrl/web/payments';
  static String showPaymentUrl(int id) => '$baseUrl/web/payment/$id';

  //statistic
static String fetchClientCountUrl () => '$baseUrl/web/num-clients';
static String fetchPopularServicesUrl() => '$baseUrl/web/popular-services';

  // Bookings
  static String addBookingUrl() => '$baseUrl/web/store-booking';
  static String approveBookingUrl(int id) => '$baseUrl/web/booking-approve/$id';
  static String rejectBookingUrl(int id) => '$baseUrl/web/booking-reject/$id';
  static String cancelBookingUrl(int id) => '$baseUrl/web/canceled-booking/$id';
  static String archiveBookingUrl(int id) => '$baseUrl/web/archive-booking/$id';
  static String unarchiveBookingUrl(int id) => '$baseUrl/web/un-archive/$id';
  static String updateBookingUrl(int id) => '$baseUrl/web/update-booking/$id';
  static String availableBookingUrl() => '$baseUrl/web/available';
  static String getBookingsUrl() => '$baseUrl/web/get-bookings';
  static String getBookingUrl(int id) => '$baseUrl/web/get-booking/$id';
  static String getDailyBookingUrl(String date) => '$baseUrl/web/daily/$date';

}
