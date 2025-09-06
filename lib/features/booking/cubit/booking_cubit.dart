

import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_state.dart';
import '../model/booking_repository.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository repository;

  BookingCubit(this.repository) : super(BookingInitial());

  // إضافة حجز
  Future<void> addBooking(int userId, int serviceId, DateTime date) async {
    emit(BookingLoading());
    try {
      final booking = await repository.addBooking(userId, serviceId, date);
      emit(BookingSuccess(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // الموافقة على الحجز
  Future<void> approveBooking(int id) async {
    emit(BookingLoading());
    try {
      final booking = await repository.approveBooking(id);
      emit(BookingSuccess(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // رفض الحجز
  Future<void> rejectBooking(int id) async {
    emit(BookingLoading());
    try {
      final booking = await repository.rejectBooking(id);
      emit(BookingSuccess(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // إلغاء الحجز
  Future<void> cancelBooking(int id) async {
    emit(BookingLoading());
    try {
      final booking = await repository.cancelBooking(id);
      emit(BookingSuccess(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // أرشفة الحجز
  Future<void> archiveBooking(int id) async {
    emit(BookingLoading());
    try {
      final booking = await repository.archiveBooking(id);
      emit(BookingSuccess(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // استرجاع الحجز من الأرشيف
  Future<void> unarchiveBooking(int id) async {
    emit(BookingLoading());
    try {
      final booking = await repository.unarchiveBooking(id);
      emit(BookingSuccess(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // تحديث الحجز
  Future<void> updateBooking(int id, int serviceId, DateTime date, String? notes) async {
    emit(BookingLoading());
    try {
      final booking = await repository.updateBooking(id, serviceId, date, notes);
      emit(BookingSuccess(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // التحقق من الأوقات المتاحة
  Future<void> availableBooking(int serviceId, String date) async {
    emit(BookingLoading());
    try {
      final slots = await repository.availableBooking(serviceId, date);
      emit(BookingSuccess(slots));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // جلب جميع الحجوزات
  Future<void> getBookings() async {
    emit(BookingLoading());
    try {
      final bookings = await repository.getBookings();
      emit(BookingSuccess(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // جلب حجز محدد
  Future<void> getBooking(int id) async {
    emit(BookingLoading());
    try {
      final booking = await repository.getBooking(id);
      emit(BookingSuccess(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // جلب الحجوزات اليومية
  Future<void> getDailyBooking(String date) async {
    emit(BookingLoading());
    try {
      final bookings = await repository.getDailyBooking(date);
      emit(BookingSuccess(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}
