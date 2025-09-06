import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/InvoiceRepository.dart';
import '../models/invoice_model.dart';
import 'invoices_state.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  final InvoiceRepository repository;

  InvoiceCubit(this.repository) : super(InvoiceInitial());

  Future<void> loadInvoices() async {
    emit(InvoiceLoading());
    try {
      final invoices = await repository.getInvoices();
      emit(InvoicesLoaded(invoices));
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  Future<void> loadInvoice(int id) async {
    emit(InvoiceLoading());
    try {
      final invoice = await repository.getInvoice(id);
      emit(InvoiceLoaded(invoice));
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  /// تم تعديلها لتستخدم Booking ID
  Future<void> createInvoice(int bookingId) async {
    emit(InvoiceLoading());
    try {
      final invoice = await repository.createInvoice(bookingId);
      emit(InvoiceLoaded(invoice));
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  Future<void> archiveInvoice(int id) async {
    emit(InvoiceLoading());
    try {
      await repository.archiveInvoice(id);
      await loadInvoices();
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  Future<void> restoreInvoice(int id) async {
    emit(InvoiceLoading());
    try {
      await repository.restoreInvoice(id);
      await loadInvoices();
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  Future<void> loadArchives() async {
    emit(InvoiceLoading());
    try {
      final archives = await repository.getArchives();
      emit(InvoicesLoaded(archives));
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  Future<void> loadArchive(int id) async {
    emit(InvoiceLoading());
    try {
      final archive = await repository.getArchive(id);
      emit(InvoiceLoaded(archive));
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  Future<void> loadReport({required String reportType, required String date}) async {
    emit(InvoiceLoading());
    try {
      final report = await repository.getReport(reportType: reportType, date: date);
      emit(ReportLoaded(report));
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }
}
