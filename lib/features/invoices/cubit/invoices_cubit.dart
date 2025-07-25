import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/invoice_model.dart';

class InvoicesCubit extends Cubit<List<Invoice>> {
  InvoicesCubit() : super([]);

  void addInvoice(Invoice invoice) {
    final updated = List<Invoice>.from(state)..add(invoice);
    emit(updated);
  }

  void removeInvoice(String id) {
    final updated = state.where((i) => i.id != id).toList();
    emit(updated);
  }

  void updateInvoice(Invoice updatedInvoice) {
    final updatedList = state.map((invoice) {
      if (invoice.id == updatedInvoice.id) {
        return updatedInvoice;
      }
      return invoice;
    }).toList();

    emit(updatedList);
  }


  void loadInitial(List<Invoice> initialInvoices) {
    emit(initialInvoices);
  }
}
