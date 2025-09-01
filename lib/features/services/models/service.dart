import '../../../core/constant/ApiConstants.dart';

class Service {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int duration;
  final int departmentId;
  final String? imageUrl;

  Service({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.duration,
    required this.departmentId,
    this.imageUrl,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image'];
    String? fullImageUrl;

    if (rawImage != null && rawImage.toString().isNotEmpty) {
      final safePath = rawImage.toString().replaceAll(r'\', '/');

      // إذا الرابط كامل، نستخدمه كما هو
      if (safePath.startsWith('http')) {
        fullImageUrl = safePath;
      } else {
        fullImageUrl = "${ApiConstants.baseUrl}/storage/$safePath";
      }

      print("🖼️ Image URL: $fullImageUrl"); // للمراجعة أثناء التطوير
    }

    return Service(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      duration: int.tryParse(json['duration'].toString()) ?? 0,
      departmentId: json['department_id'] is String
          ? int.tryParse(json['department_id']) ?? 0
          : json['department_id'] ?? 0,
      imageUrl: fullImageUrl,
    );
  }
}
