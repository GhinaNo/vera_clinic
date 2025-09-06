import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:vera_clinic/core/services/token_storage.dart';

import 'booking_state.dart';
import 'booking_model.dart';

class BookingCubit extends Cubit<BookingState> {


  BookingCubit() : super(BookingInitial());

  Future<void> storeBooking({
    required String userId,
    required String serviceId,
    required String bookingDate,
  }) async {
    emit(BookingLoading());

    try {
      final token = await TokenStorage.getToken(); 
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/web/store-booking"),
        body: {
          "user_id": userId,
          "service_id": serviceId,
          "booking_date": bookingDate,
        },
        headers: {
    "Accept": "application/json",
    "Authorization": "Bearer $token",
    // if (extraHeaders != null) ...extraHeaders,
  },
      );

print("Response status: ${response.statusCode}");
print("Response body: ${response.body}");

      final data = json.decode(response.body);
      print("Response status: ${response.statusCode}");
print("Response body: ${response.body}");


      if (data["status"] == 1) {
        final booking = Booking.fromJson(data["data"]);
        emit(BookingSuccess(booking));
      } else {
        List<Map<String, String>>? slots;
        if (data["available_slots"] != null) {
          slots = (data["available_slots"] as List)
              .map((s) => {
                    "start": s["start"].toString(),
                    "end": s["end"].toString(),
                  })
              .toList();
        }
        emit(BookingFailure(data["message"].toString(), availableSlots: slots));
      }
    } catch (e) {
      emit(BookingFailure("خطأ في الاتصال بالسيرفر: $e"));
      
    }
  }
}
