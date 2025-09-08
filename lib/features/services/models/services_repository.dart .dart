import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../../../core/constant/ApiConstants.dart';
import '../models/service.dart';

class ServicesRepository {
  final String token;
  ServicesRepository({required this.token});

  Map<String, String> get _headers => {
    "Accept": "application/json",
    "Authorization": "Bearer $token",
  };

  Future<Map<String, dynamic>> addService({
    required String name,
    String? description,
    required double price,
    required int duration,
    required int departmentId,
    File? image,
    Uint8List? imageBytes,
  }) async {
    log("بدء عملية إضافة خدمة جديدة");
    var request =
    http.MultipartRequest('POST', Uri.parse(ApiConstants.addServiceUrl()));
    request.headers.addAll(_headers);

    request.fields['name'] = name;
    if (description != null && description.isNotEmpty) {
      request.fields['description'] = description;
    }
    request.fields['price'] = price.toString();
    request.fields['duration'] = duration.toString();
    request.fields['department_id'] = departmentId.toString();

    if (!kIsWeb && image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    } else if (kIsWeb && imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'service_image.png',
        contentType: MediaType('image', 'png'),
      ));
    }

    final response = await request.send();
    final resBody = await response.stream.bytesToString();
    log("Status: ${response.statusCode}, Body: $resBody");

    final decoded = json.decode(resBody);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        decoded['status'] == 1) {
      return {
        "service": Service.fromJson(decoded['data']),
        "message": decoded['message'] ?? "تمت إضافة الخدمة بنجاح"
      };
    } else {
      throw Exception(decoded['message'] ?? "فشل في إضافة الخدمة");
    }
  }

  Future<Map<String, dynamic>> updateService(
      int id, {
        required String name,
        String? description,
        required double price,
        required int duration,
        required int departmentId,
        File? image,
        Uint8List? imageBytes,
      }) async {
    log("بدء عملية تعديل الخدمة برقم: $id");
    var request = http.MultipartRequest(
        'POST', Uri.parse(ApiConstants.updateServiceUrl(id)));
    request.headers.addAll(_headers);

    request.fields['name'] = name;
    if (description != null && description.isNotEmpty) {
      request.fields['description'] = description;
    }
    request.fields['price'] = price.toString();
    request.fields['duration'] = duration.toString();
    request.fields['department_id'] = departmentId.toString();

    if (!kIsWeb && image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    } else if (kIsWeb && imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'service_image.png',
        contentType: MediaType('image', 'png'),
      ));
    }

    final response = await request.send();
    final resBody = await response.stream.bytesToString();
    log("Status: ${response.statusCode}, Body: $resBody");

    final decoded = json.decode(resBody);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        decoded['status'] == 1) {
      return {
        "service": Service.fromJson(decoded['data']),
        "message": decoded['message'] ?? "تم تعديل الخدمة بنجاح"
      };
    } else {
      throw Exception(decoded['message'] ?? "فشل في تعديل الخدمة");
    }
  }

  Future<List<Service>> fetchServices() async {
    log("بدء جلب جميع الخدمات");
    final response = await http.get(Uri.parse(ApiConstants.showServicesUrl()), headers: _headers);

    log("Status: ${response.statusCode}, Body: ${response.body}");
    final decoded = json.decode(response.body);

    if (response.statusCode == 200 && decoded['status'] == 1) {
      final data = decoded['data'] as List;
      return data.map((s) => Service.fromJson(s)).toList();
    } else {
      throw Exception(decoded['message'] ?? "فشل في جلب الخدمات");
    }
  }

  Future<Map<String, dynamic>> deleteService(int id) async {
    log("بدء عملية حذف الخدمة برقم: $id");
    final response = await http.delete(
      Uri.parse(ApiConstants.deleteServiceUrl(id)),
      headers: _headers,
    );

    log("Status: ${response.statusCode}, Body: ${response.body}");
    final decoded = json.decode(response.body);

    if (response.statusCode == 200 && decoded['status'] == 1) {
      return {
        "message": decoded['message'] ?? "تم حذف الخدمة بنجاح"
      };
    } else {
      throw Exception(decoded['message'] ?? "فشل في حذف الخدمة");
    }
  }

  Future<Map<String, dynamic>> searchServices(String query) async {
    log("بدء البحث عن الخدمات: $query");
    final response = await http.post(
      Uri.parse(ApiConstants.searchServiceUrl()),
      headers: _headers,
      body: {"search": query},
    );

    log("Status: ${response.statusCode}, Body: ${response.body}");
    final decoded = json.decode(response.body);

    if (response.statusCode == 200 && decoded['status'] == 1) {
      final data = decoded['data'] as List;
      final services = data.map((s) => Service.fromJson(s)).toList();

      return {
        "services": services,
        "message": decoded['message'] ?? "تمت عملية البحث بنجاح"
      };
    } else {
      throw Exception(decoded['message'] ?? "فشل في البحث عن الخدمات");
    }
  }
}
