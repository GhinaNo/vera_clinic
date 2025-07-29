import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/invoice_model.dart';

class InvoicesCubit extends Cubit<List<Invoice>> {
  InvoicesCubit() : super([]);

  void addInvoice(Invoice invoice) {
    final updatedList = List<Invoice>.from(state)..add(invoice);
    emit(updatedList);
  }

  void removeInvoice(String id) {
    final updatedList = state.where((invoice) => invoice.id != id).toList();
    emit(updatedList);
  }

  void updateInvoice(Invoice updatedInvoice) {
    final updatedList = state.map((invoice) {
      return invoice.id == updatedInvoice.id ? updatedInvoice : invoice;
    }).toList();

    emit(updatedList);
  }

  void loadInitial(List<Invoice> initialInvoices) {
    emit(List<Invoice>.from(initialInvoices));
  }
}
