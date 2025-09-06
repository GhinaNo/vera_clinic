
import 'booking_model.dart';

abstract class BookingState  {
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final Booking booking;
  BookingSuccess(this.booking);

  @override
  List<Object?> get props => [booking];
}

class BookingFailure extends BookingState {
  final String message;
  final List<Map<String, String>>? availableSlots;

  BookingFailure(this.message, {this.availableSlots});

  @override
  List<Object?> get props => [message, availableSlots ?? []];
}
