import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/invoice_model.dart';
import '../../../core/utils/local_storage_helper.dart';
import '../storage/storage.dart';

class InvoicesCubit extends Cubit<List<Invoice>> {
  InvoicesCubit() : super([]);

  Future<void> loadInitial() async {
    final loaded = await InvoiceStorage.loadInvoices();
    emit(loaded);
  }

  void addInvoice(Invoice invoice) {
    final updatedList = List<Invoice>.from(state)..add(invoice);
    _syncArchivedIds(updatedList);
    emit(updatedList);
    InvoiceStorage.saveInvoices(updatedList);

  }

  void updateInvoice(Invoice updatedInvoice) {
    final updatedList = state.map((invoice) {
      return invoice.id == updatedInvoice.id ? updatedInvoice : invoice;
    }).toList();
    _syncArchivedIds(updatedList);
    emit(updatedList);
    InvoiceStorage.saveInvoices(updatedList);
  }

  void removeInvoice(String id) {
    final updatedList = state.where((invoice) => invoice.id != id).toList();
    _syncArchivedIds(updatedList);
    emit(updatedList);
    InvoiceStorage.saveInvoices(updatedList);

  }

  void archiveInvoice(String id) {
    final updatedList = state.map((invoice) {
      return invoice.id == id ? invoice.copyWith(isArchived: true) : invoice;
    }).toList();
    _syncArchivedIds(updatedList);
    emit(updatedList);
    InvoiceStorage.saveInvoices(updatedList);
  }

  void unarchiveInvoice(String id) {
    final updatedList = state.map((invoice) {
      return invoice.id == id ? invoice.copyWith(isArchived: false) : invoice;
    }).toList();
    _syncArchivedIds(updatedList);
    emit(updatedList);
    InvoiceStorage.saveInvoices(updatedList);

  }

  void _syncArchivedIds(List<Invoice> invoices) {
    final archivedIds = invoices.where((i) => i.isArchived).map((i) => i.id).toList();
    LocalStorageHelper.saveArchivedInvoiceIds(archivedIds);

  }
}
