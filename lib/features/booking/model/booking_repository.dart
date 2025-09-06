import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/constant/ApiConstants.dart';
import '../booking_model.dart';

class BookingRepository {
  final Map<String, String> headers;

  BookingRepository({this.headers = const {'Accept': 'application/json'}});

  // إضافة حجز
  Future<Booking> addBooking(int userId, int serviceId, DateTime date) async {
    final url = Uri.parse(ApiConstants.addBookingUrl());
    print('ADDING BOOKING: $url');
    print('Payload: user_id=$userId, service_id=$serviceId, booking_date=$date');

    final response = await http.post(url, headers: headers, body: {
      'user_id': userId.toString(),
      'service_id': serviceId.toString(),
      'booking_date': date.toIso8601String(),
    });

    print('RESPONSE STATUS: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    final data = json.decode(response.body);
    if (data['status'] == 1) {
      print('Booking added successfully.');
      return Booking.fromJson(data['data']);
    } else {
      print('Failed to add booking: ${data['message']}');
      throw Exception(data['message']);
    }
  }

  // الموافقة على حجز
  Future<Booking> approveBooking(int id) async {
    final url = Uri.parse(ApiConstants.approveBookingUrl(id));
    print('APPROVING BOOKING: $url');

    final response = await http.get(url, headers: headers);
    print('RESPONSE STATUS: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    final data = json.decode(response.body);
    if (data['status'] == 1) {
      print('Booking approved successfully.');
      return Booking.fromJson(data['data']);
    } else {
      print('Failed to approve booking: ${data['message']}');
      throw Exception(data['message']);
    }
  }

  // رفض الحجز
  Future<Booking> rejectBooking(int id) async {
    final url = Uri.parse(ApiConstants.rejectBookingUrl(id));
    print('REJECTING BOOKING: $url');

    final response = await http.get(url, headers: headers);
    print('RESPONSE STATUS: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    final data = json.decode(response.body);
    if (data['status'] == 1) {
      print('Booking rejected successfully.');
      return Booking.fromJson(data['data']);
    } else {
      print('Failed to reject booking: ${data['message']}');
      throw Exception(data['message']);
    }
  }

  // إلغاء الحجز
  Future<Booking> cancelBooking(int id) async {
    final url = Uri.parse(ApiConstants.cancelBookingUrl(id));
    print('CANCELLING BOOKING: $url');

    final response = await http.get(url, headers: headers);
    print('RESPONSE STATUS: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    final data = json.decode(response.body);
    if (data['status'] == 1) {
      print('Booking cancelled successfully.');
      return Booking.fromJson(data['data']);
    } else {
      print('Failed to cancel booking: ${data['message']}');
      throw Exception(data['message']);
    }
  }

  // أرشفة الحجز
  Future<Booking> archiveBooking(int id) async {
    final url = Uri.parse(ApiConstants.archiveBookingUrl(id));
    print('ARCHIVING BOOKING: $url');

    final response = await http.get(url, headers: headers);
    print('RESPONSE STATUS: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    final data = json.decode(response.body);
    if (data['status'] == 1) {
      print('Booking archived successfully.');
      return Booking.fromJson(data['data']);
    } else {
      print('Failed to archive booking: ${data['message']}');
      throw Exception(data['message']);
    }
  }

  // استرجاع الحجز من الأرشيف
  Future<Booking> unarchiveBooking(int id) async {
    final url = Uri.parse(ApiConstants.unarchiveBookingUrl(id));
    print('UNARCHIVING BOOKING: $url');

    final response = await http.get(url, headers: headers);
    print('RESPONSE STATUS: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    final data = json.decode(response.body);
    if (data['status'] == 1) {
      print('Booking unarchived successfully.');
      return Booking.fromJson(data['data']);
    } else {
      print('Failed to unarchive booking: ${data['message']}');
      throw Exception(data['message']);
    }
  }

  // تحديث الحجز
  Future<Booking> updateBooking(int id, int serviceId, DateTime date, String? notes) async {
    final url = Uri.parse(ApiConstants.updateBookingUrl(id));
    print('UPDATING BOOKING: $url');
    print('Payload: service_id=$serviceId, booking_date=$date, notes=$notes');

    final response = await http.post(url, headers: headers, body: {
      'booking_id': id.toString(),
      'service_id': serviceId.toString(),
      'booking_date': date.toIso8601String(),
      'notes': notes ?? '',
    });

    print('RESPONSE STATUS: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    final data = json.decode(response.body);
    if (data['status'] == 1) {
      print('Booking updated successfully.');
      return Booking.fromJson(data['data']);
    } else {
      print('Failed to update booking: ${data['message']}');
      throw Exception(data['message']);
    }
  }

  // التحقق من الأوقات المتاحة
  Future<List<Map<String, String>>> availableBooking(int serviceId, String date) async {
    final url = Uri.parse(ApiConstants.availableBookingUrl());
    print('CHECKING AVAILABLE SLOTS: $url');
    print('Payload: service_id=$serviceId, date=$date');

    final response = await http.post(url, headers: headers, body: {
      'service_id': serviceId.toString(),
      'date': date,
    });

    print('RESPONSE STATUS: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    final data = json.decode(response.body);
    if (data['status'] == 1) {
      print('Available slots fetched successfully.');
      return List<Map<String, String>>.from(data['data']['available_slots']);
    } else {
      print('Failed to fetch available slots: ${data['message']}');
      throw Exception(data['message']);
    }
  }

  // جلب جميع الحجوزات
  Future<List<Booking>> getBookings() async {
    final url = Uri.parse(ApiConstants.getBookingsUrl());
    print('FETCHING ALL BOOKINGS: $url');

    final response = await http.get(url, headers: headers);
    print('RESPONSE STATUS: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    final data = json.decode(response.body);
    if (data['status'] == 1) {
      final bookings = (data['data'] as List)
          .map((b) => Booking.fromJson(b))
          .toList();
      print('Fetched ${bookings.length} bookings.');
      return bookings;
    } else {
      print('Failed to fetch bookings: ${data['message']}');
      throw Exception(data['message']);
    }
  }

  // جلب حجز محدد
  Future<Booking> getBooking(int id) async {
    final url = Uri.parse(ApiConstants.getBookingUrl(id));
    print('FETCHING BOOKING: $url');

    final response = await http.get(url, headers: headers);
    print('RESPONSE STATUS: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    final data = json.decode(response.body);
    if (data['status'] == 1) {
      print('Booking fetched successfully.');
      return Booking.fromJson(data['data']);
    } else {
      print('Failed to fetch booking: ${data['message']}');
      throw Exception(data['message']);
    }
  }

  // جلب الحجوزات اليومية
  Future<List<Booking>> getDailyBooking(String date) async {
    final url = Uri.parse(ApiConstants.getDailyBookingUrl(date));
    print('FETCH DAILY BOOKINGS: $url');

    final response = await http.get(url, headers: headers);
    print('RESPONSE STATUS: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    final data = json.decode(response.body);
    if (data['status'] == 1) {
      final bookings = (data['data'] as List)
          .map((b) => Booking.fromJson(b))
          .toList();
      print('Fetched ${bookings.length} bookings.');
      return bookings;
    } else {
      print('Failed to fetch bookings: ${data['message']}');
      throw Exception(data['message']);
    }
  }
}
