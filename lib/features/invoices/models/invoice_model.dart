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
  final bool isArchived;

  Invoice({
     required this.id,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    required this.payments,
    required this.date,
    required this.createdBy,
    this.isArchived = false,
  }) ;
      // : id = const Uuid().v4();

  double get paidAmount => payments.fold(0, (sum, payment) => sum + payment.amount);
  double get remainingAmount => totalAmount - paidAmount;

  Invoice copyWith({
    String? customerName,
    List<InvoiceItem>? items,
    double? totalAmount,
    List<Payment>? payments,
    DateTime? date,
    String? createdBy,
    bool? isArchived,
  }) {
    return Invoice(
      id: id?? this.id,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      payments: payments ?? this.payments,
      date: date ?? this.date,
      createdBy: createdBy ?? this.createdBy,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerName': customerName,
    'items': items.map((e) => e.toJson()).toList(),
    'totalAmount': totalAmount,
    'payments': payments.map((e) => e.toJson()).toList(),
    'date': date.toIso8601String(),
    'createdBy': createdBy,
    'isArchived': isArchived,
  };

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    id: json['id'],
    customerName: json['customerName'],
    items: (json['items'] as List).map((e) => InvoiceItem.fromJson(e)).toList(),
    totalAmount: json['totalAmount'],
    payments: (json['payments'] as List).map((e) => Payment.fromJson(e)).toList(),
    date: DateTime.parse(json['date']),
    createdBy: json['createdBy'],
    isArchived: json['isArchived'] ?? false,
  );


}
