import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/PaymentRepository.dart';
import '../models/payment_model.dart';
import 'payments_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository repository;

  PaymentCubit(this.repository) : super(PaymentInitial());

  Future<void> loadPayments() async {
    try {
      emit(PaymentLoading());
      final payments = await repository.fetchPayments();
      emit(PaymentLoaded(payments));
    } catch (e) {
      print("Error loading payments: $e");
      emit(PaymentError(e.toString()));
    }
  }

  /// تم تعديلها لتستخدم Booking ID بدل Invoice ID
  Future<void> addPayment(int bookingId, double amount) async {
    try {
      final payment = await repository.addPayment(bookingId, amount);
      if (state is PaymentLoaded) {
        final updatedList = List<Payment>.from((state as PaymentLoaded).payments)
          ..add(payment);
        emit(PaymentLoaded(updatedList));
      } else {
        emit(PaymentLoaded([payment]));
      }
    } catch (e) {
      print("Error adding payment: $e");
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> fetchPayment(int id) async {
    try {
      final payment = await repository.getPayment(id);
      print("Fetched single payment: $payment");
    } catch (e) {
      print("Error fetching payment: $e");
      emit(PaymentError(e.toString()));
    }
  }
}
