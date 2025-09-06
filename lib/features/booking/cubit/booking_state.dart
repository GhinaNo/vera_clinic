
abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final dynamic data;
  BookingSuccess(this.data);
}

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}
