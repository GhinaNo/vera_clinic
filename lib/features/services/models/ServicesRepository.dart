import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../core/constant/ApiConstants.dart';
import '../models/service.dart';
import 'dart:convert';

class ServicesRepository {
  final String token;
  ServicesRepository({required this.token});

  Map<String, String> get _headers => {
    "Accept": "application/json",
    "Authorization": "Bearer $token",
  };

  Future<void> addService(Map<String, dynamic> data, {File? image, Uint8List? imageBytes}) async {
    print("بدء عملية إضافة خدمة جديدة");
    var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.addServiceUrl()));
    request.headers.addAll(_headers);

    data.forEach((key, value) => request.fields[key] = value.toString());
    print("البيانات المرسلة: $data");

    if (!kIsWeb && image != null) {
      print("تم اختيار صورة من الجهاز: ${image.path}");
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    } else if (kIsWeb && imageBytes != null) {
      print("تم إضافة صورة من Bytes");
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'service_image.png',
        contentType: MediaType('image', 'png'),
      ));
    } else {
      print("لا توجد صورة مرفقة");
    }

    final response = await request.send();
    final resBody = await response.stream.bytesToString();
    print("تم استلام الرد من الخادم، حالة الرد: ${response.statusCode}");
    print("محتوى الرد: $resBody");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("فشل في إضافة الخدمة: $resBody");
    }
    print("تمت إضافة الخدمة بنجاح");
  }

  Future<void> updateService(int id, Map<String, dynamic> data, {File? image, Uint8List? imageBytes}) async {
    print("بدء عملية تعديل الخدمة برقم: $id");
    var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.updateServiceUrl(id)));
    request.headers.addAll(_headers);

    data.forEach((key, value) => request.fields[key] = value.toString());
    print("البيانات المرسلة للتعديل: $data");

    if (!kIsWeb && image != null) {
      print("تم اختيار صورة جديدة من الجهاز");
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    } else if (kIsWeb && imageBytes != null) {
      print("تم إضافة صورة جديدة من Bytes");
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'service_image.png',
        contentType: MediaType('image', 'png'),
      ));
    } else {
      print("لم يتم تغيير الصورة");
    }

    final response = await request.send();
    final resBody = await response.stream.bytesToString();
    print("تم استلام الرد من الخادم، حالة الرد: ${response.statusCode}");
    print("محتوى الرد: $resBody");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("فشل في تعديل الخدمة: $resBody");
    }
    print("تم تعديل الخدمة بنجاح");
  }

  Future<List<Service>> fetchServices() async {
    print("بدء جلب جميع الخدمات من الخادم");
    final response = await http.get(Uri.parse(ApiConstants.showServicesUrl()), headers: _headers);

    print("تم استلام الرد من الخادم، حالة الرد: ${response.statusCode}");
    print("محتوى الرد: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      print("عدد الخدمات المسترجعة: ${data.length}");
      return data.map((s) => Service.fromJson(s)).toList();
    } else {
      throw Exception("فشل في جلب الخدمات");
    }
  }

  Future<void> deleteService(int id) async {
    print("بدء عملية حذف الخدمة برقم: $id");
    final response = await http.delete(Uri.parse(ApiConstants.deleteServiceUrl(id)), headers: _headers);

    print("تم استلام الرد من الخادم، حالة الرد: ${response.statusCode}");
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("فشل في حذف الخدمة");
    }
    print("تم حذف الخدمة بنجاح");
  }

  Future<List<Service>> searchServices(String query) async {
    print("بدء البحث عن الخدمات باستخدام الكلمة: $query");
    final response = await http.post(Uri.parse(ApiConstants.searchServiceUrl()),
        headers: _headers, body: {"search": query});

    print("تم استلام الرد من الخادم، حالة الرد: ${response.statusCode}");
    print("محتوى الرد: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      print("عدد الخدمات المطابقة للبحث: ${data.length}");
      return data.map((s) => Service.fromJson(s)).toList();
    } else {
      throw Exception("فشل في البحث عن الخدمات");
    }
  }
}
