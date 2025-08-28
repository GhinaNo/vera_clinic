import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constant/ApiConstants.dart';
import '../model/login_response.dart';

/// Exception مخصص للأخطاء الخاصة بالمصادقة
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
    required String role,
  }) async {
    final url = role == 'admin'
        ? ApiConstants.adminLoginUrl()
        : ApiConstants.receptionistLoginUrl();

    print('--- LOGIN REQUEST ---');
    print('URL: $url');
    print('Email: $email');
    print('Role: $role');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('---------------------');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(data);
      } else {
        final serverMsg = data['message'] ?? "فشل تسجيل الدخول";

        // ترجمة الرسائل حسب نص السيرفر
        String userMessage;
        switch (serverMsg.toLowerCase()) {
          case "invalid email or password":
            userMessage = "البريد الإلكتروني أو كلمة المرور غير صحيحة";
            break;
          case "user not found":
            userMessage = "المستخدم غير موجود";
            break;
          default:
            userMessage = "حدث خطأ أثناء تسجيل الدخول";
        }

        throw AuthException(userMessage);
      }
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

  /// نسيت كلمة المرور
  Future<String> forgetPassword(String email) async {
    final url = ApiConstants.forgetPasswordUrl();

    print('--- FORGET PASSWORD REQUEST ---');
    print('URL: $url');
    print('Email: $email');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('-------------------------------');

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // رسائل UI بالعربي حسب حالة السيرفر
        return "تم إرسال رمز إعادة تعيين كلمة المرور إلى بريدك الإلكتروني";
      } else {
        final serverMsg = data['message'] ?? "";
        String userMessage;

        if (serverMsg.toLowerCase().contains("not found") || serverMsg.toLowerCase().contains("email")) {
          userMessage = "البريد الإلكتروني غير صحيح";
        } else {
          userMessage = "حدث خطأ أثناء إرسال رمز إعادة التعيين";
        }

        throw AuthException(userMessage);
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
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('---------------------------');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return "الكود صحيح";
      } else {
        final serverMsg = data['message'] ?? "";
        String userMessage;

        if (serverMsg.toLowerCase().contains("invalid code") || serverMsg.toLowerCase().contains("the selected code is invalid")) {
          userMessage = "الكود الذي أدخلته غير صحيح";
        } else {
          userMessage = "حدث خطأ أثناء التحقق من الكود";
        }

        throw AuthException(userMessage);
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
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
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
        return "تم تغيير كلمة المرور بنجاح";
      } else {
        final serverMsg = data['message'] ?? "";
        String userMessage;

        if (serverMsg.toLowerCase().contains("invalid code")) {
          userMessage = "الكود غير صالح لإعادة التعيين";
        } else if (serverMsg.toLowerCase().contains("password")) {
          userMessage = "حدث خطأ أثناء تغيير كلمة المرور";
        } else {
          userMessage = "حدث خطأ أثناء إعادة تعيين كلمة المرور";
        }

        throw AuthException(userMessage);
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
