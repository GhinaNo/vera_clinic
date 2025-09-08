import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vera_clinic/core/services/token_storage.dart';
import '../../../core/constant/ApiConstants.dart';
import '../model/login_response.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  /// تسجيل الدخول
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    print('--- LOGIN REQUEST ---');
    print('Email: $email');

    try {
      final responseAdmin = await http.post(
        Uri.parse(ApiConstants.adminLoginUrl()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Admin Status: ${responseAdmin.statusCode}');
      print('Admin Response: ${responseAdmin.body}');

      final dataAdmin = json.decode(responseAdmin.body);

      if (responseAdmin.statusCode == 200 &&
          dataAdmin['status'] == 1 &&
          dataAdmin['data'] != null) {
        final loginResponse = LoginResponse.fromJson(dataAdmin);
        print("🚀 ROLE (admin login): ${loginResponse.role}");
        return loginResponse;
      }

      // إذا فشل admin، جرب receptionist login
      final responseReceptionist = await http.post(
        Uri.parse(ApiConstants.receptionistLoginUrl()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Receptionist Status: ${responseReceptionist.statusCode}');
      print('Receptionist Response: ${responseReceptionist.body}');

      final dataReceptionist = json.decode(responseReceptionist.body);

      if (responseReceptionist.statusCode == 200 &&
          dataReceptionist['status'] == 1 &&
          dataReceptionist['data'] != null) {
        final loginResponse = LoginResponse.fromJson(dataReceptionist);
        print("🚀 ROLE (receptionist login): ${loginResponse.role}");
        return loginResponse;
      }

      // إذا الاثنين فشلوا
      final msg = dataReceptionist['message'] ??
          dataAdmin['message'] ??
          "فشل تسجيل الدخول";
      throw AuthException(msg);
    } catch (e) {
      print('Login Error: $e');
      if (e.toString().contains("SocketException")) {
        throw AuthException("تحقق من اتصال الإنترنت");
      } else if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException("حدث خطأ غير متوقع");
      }
    }
  }


  /// تسجيل الخروج
  Future<void> logout() async {
    final url = ApiConstants.logoutUrl();
    final token = await TokenStorage.getToken();

    print('Logout URL: $url');
    print('Logout Token Exists: ${token != null}');

    if (token == null || token.isEmpty) {
      throw Exception('no_token');
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Logout Status Code: ${response.statusCode}');
      print('Logout Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('unauthorized');
      } else if (response.statusCode >= 500) {
        throw Exception('server_error');
      } else {
        throw Exception('unknown_error');
      }
    } catch (e) {
      print('Logout Error: $e');
      rethrow;
    }
  }

  /// نسيت كلمة المرور
  Future<String> forgetPassword(String email) async {
    final url = ApiConstants.forgetPasswordUrl();

    print('--- FORGET PASSWORD REQUEST ---');
    print('URL: $url');
    print('Email: $email');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({'email': email}),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('-------------------------------');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data['message'] ??
            "تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني";
      } else {
        throw AuthException(
            data['message'] ?? "حدث خطأ أثناء إرسال رابط إعادة التعيين");
      }
    } catch (e) {
      print('ForgetPassword Error: $e');
      if (e.toString().contains("SocketException")) {
        throw AuthException("تحقق من اتصال الإنترنت");
      } else if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException("حدث خطأ غير متوقع");
      }
    }
  }

  /// التحقق من الكود المرسل
  Future<String> checkCode(String code) async {
    final url = ApiConstants.checkCodeUrl();

    print('--- CHECK CODE REQUEST ---');
    print('URL: $url | Code: $code');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({'code': code}),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('---------------------------');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data['message'] ?? "الكود صحيح";
      } else {
        throw AuthException(
            data['message'] ?? "الكود الذي أدخلته غير صحيح");
      }
    } catch (e) {
      print('CheckCode Error: $e');
      if (e.toString().contains("SocketException")) {
        throw AuthException("تحقق من اتصال الإنترنت");
      } else if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException("حدث خطأ غير متوقع");
      }
    }
  }

  /// إعادة تعيين كلمة المرور
  Future<String> resetPassword(
      String code,
      String password,
      String passwordConfirmation,
      ) async {
    final url = ApiConstants.resetPasswordUrl();

    print('--- RESET PASSWORD REQUEST ---');
    print('URL: $url | Code: $code');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          'code': code,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('-------------------------------');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data['message'] ?? "تم تغيير كلمة المرور بنجاح";
      } else {
        throw AuthException(
            data['message'] ?? "حدث خطأ أثناء إعادة تعيين كلمة المرور");
      }
    } catch (e) {
      print('ResetPassword Error: $e');
      if (e.toString().contains("SocketException")) {
        throw AuthException("تحقق من اتصال الإنترنت");
      } else if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException("حدث خطأ غير متوقع");
      }
    }
  }
}
