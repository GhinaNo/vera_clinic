import '../../services/models/service.dart';

class Offer {
  final String id;
  final String title;
  final double discountPercent;
  final DateTime startDate;
  final DateTime endDate;
  final List<Service> services;

  Offer({
    required this.id,
    required this.title,
    required this.discountPercent,
    required this.startDate,
    required this.endDate,
    required this.services,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      discountPercent: double.tryParse(json['discount_percentage'].toString()) ?? 0,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      services: (json['services'] as List? ?? [])
          .map((s) => Service.fromJson(s))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'discount_percentage': discountPercent.toString(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'services': services.map((s) => s.id).toList(),
    };
  }
}
