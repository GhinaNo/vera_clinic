
import '../../clients/model/model_user.dart';
import '../../services/models/service.dart';

class Booking {
  final int id;
  final Client user;
  final Service service;
  final int? offerId;
  final DateTime bookingDate;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.user,
    required this.service,
    this.offerId,
    required this.bookingDate,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'],
    user: Client.fromJson(json['user']),
    service: Service.fromJson(json['service']),
    offerId: json['offer_id'],
    bookingDate: DateTime.parse(json['booking_date']),
    status: json['status'],
    notes: json['notes'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );
}
