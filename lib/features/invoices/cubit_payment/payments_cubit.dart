// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../models/PaymentRepository.dart';
// import '../models/payment_model.dart';
// import 'payments_state.dart';
//
// class PaymentsCubit extends Cubit<PaymentsState> {
//   final PaymentRepository repository;
//
//   PaymentsCubit({required this.repository}) : super(PaymentsInitial());
//
//   /// Load all payments
//   Future<void> loadPayments() async {
//     print('Cubit: loadPayments called');
//     emit(PaymentsLoading());
//     try {
//       final payments = await repository.fetchPayments();
//       print('Cubit: payments loaded, count=${payments.length}');
//       emit(PaymentsLoaded(payments));
//     } catch (e) {
//       print('Cubit: failed to load payments -> $e');
//       emit(PaymentsError('Failed to load payments: $e'));
//     }
//   }
//
//   /// Load single payment
//   Future<void> loadPayment(int id) async {
//     print('Cubit: loadPayment called for id=$id');
//     emit(PaymentsLoading());
//     try {
//       final payment = await repository.fetchPayment(id);
//       print('Cubit: payment $id loaded successfully');
//       emit(PaymentLoaded(payment));
//     } catch (e) {
//       print('Cubit: failed to load payment $id -> $e');
//       emit(PaymentsError('Failed to load payment $id: $e'));
//     }
//   }
//
//   /// Add new payment
//   Future<void> addPayment(int invoiceId, double amount) async {
//     print('Cubit: addPayment called, invoiceId=$invoiceId, amount=$amount');
//     emit(PaymentsLoading());
//     try {
//       final payment = await repository.addPayment(invoiceId, amount);
//       print('Cubit: payment added successfully with id=${payment.id}');
//       emit(PaymentActionSuccess('Payment added successfully'));
//
//       // Update current state if list is loaded
//       if (state is PaymentsLoaded) {
//         final currentState = state as PaymentsLoaded;
//         final updatedList = List<Payment>.from(currentState.payments)..add(payment);
//         emit(PaymentsLoaded(updatedList));
//       }
//     } catch (e) {
//       print('Cubit: failed to add payment -> $e');
//       emit(PaymentsError('Failed to add payment: $e'));
//     }
//   }
// }
