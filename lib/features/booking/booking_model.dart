import '../services/models/service.dart';

class Booking {
  final int id;
  final String userId;
  final String serviceId;
  final String bookingDate;
  final String status;
  final String? notes;
  final String createdAt;
  final String updatedAt;
  final Service service;

  Booking({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.bookingDate,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.service,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user_id'].toString(),
      serviceId: json['service_id'].toString(),
      bookingDate: json['booking_date'],
      status: json['status'],
      notes: json['notes'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      service: Service.fromJson(json['service']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'service_id': serviceId,
    'booking_date': bookingDate,
    'status': status,
    'notes': notes,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'service': service.toJson(),
  };
}