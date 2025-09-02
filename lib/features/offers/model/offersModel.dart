class Offer {
  final String id;
  final String title;
  final double discountPercent;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> serviceIds;

  Offer({
    required this.id,
    required this.title,
    required this.discountPercent,
    required this.startDate,
    required this.endDate,
    required this.serviceIds,
  });

  // تحويل JSON إلى كائن Offer
  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      discountPercent: double.tryParse(json['discount_percentage'].toString()) ?? 0,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      serviceIds: (json['services'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }

  // تحويل Offer إلى JSON للإرسال للـ API
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'discount_percentage': discountPercent.toString(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'services': serviceIds.map((e) => int.tryParse(e) ?? 0).toList(),
    };
  }
}
