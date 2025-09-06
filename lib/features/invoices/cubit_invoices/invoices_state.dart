import 'package:equatable/equatable.dart';
import '../models/invoice_model.dart';

abstract class InvoiceState extends Equatable {
  const InvoiceState();

  @override
  List<Object?> get props => [];
}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoicesLoaded extends InvoiceState {
  final List<Invoice> invoices;

  const InvoicesLoaded(this.invoices);

  @override
  List<Object?> get props => [invoices];
}

class InvoiceLoaded extends InvoiceState {
  final Invoice invoice;

  const InvoiceLoaded(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class InvoiceError extends InvoiceState {
  final String message;

  const InvoiceError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReportLoaded extends InvoiceState {
  final Map<String, dynamic> report;

  const ReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}
