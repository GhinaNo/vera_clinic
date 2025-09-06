import 'package:vera_clinic/features/invoices/models/payment_model.dart';

import '../../booking/booking_model.dart';

class Invoice {
  final int id;
  final int userId;
  final int bookingId;
  final String status;
  final String invoiceDate;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Booking booking; // <--- هنا نستخدم الموديل الحالي عندك
  final List<Payment> payments;

  Invoice({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.status,
    required this.invoiceDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.booking,
    required this.payments,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      userId: json['user_id'],
      bookingId: json['booking_id'],
      status: json['status'] ?? 'unpaid',
      invoiceDate: json['invoice_date'],
      totalAmount: double.parse(json['total_amount'].toString()),
      paidAmount: double.parse(json['paid_amount'].toString()),
      remainingAmount: double.parse(json['remaining_amount'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      booking: Booking.fromJson(json['booking']), // <--- هنا نستخدم موديلك الحالي
      payments: (json['payments'] as List<dynamic>?)
          ?.map((p) => Payment.fromJson(p))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'booking_id': bookingId,
    'status': status,
    'invoice_date': invoiceDate,
    'total_amount': totalAmount,
    'paid_amount': paidAmount,
    'remaining_amount': remainingAmount,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'booking': booking.toJson(),
    'payments': payments.map((p) => p.toJson()).toList(),
  };
}
