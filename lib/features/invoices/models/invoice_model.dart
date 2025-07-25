import 'package:uuid/uuid.dart';
import 'package:vera_clinic/features/invoices/models/payment.dart';

import 'InvoiceItem.dart';

class Invoice {
  final String id;
  final String customerName;
  final List<InvoiceItem> items;
  final double totalAmount;
  final List<Payment> payments;
  final DateTime date;
  final String createdBy;

  Invoice({
    required this.customerName,
    required this.items,
    required this.totalAmount,
    required this.payments,
    required this.date,
    required this.createdBy,
  }) : id = const Uuid().v4();

  double get paidAmount => payments.fold(0, (sum, payment) => sum + payment.amount);

  double get remainingAmount => totalAmount - paidAmount;
}

