import '../../../core/constant/ApiConstants.dart';

class Service {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int duration;
  final int departmentId;
  final String? imageUrl;
  final String? createdAt;
  final String? updatedAt;
  final double? discountedPrice;

  Service({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.duration,
    required this.departmentId,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.discountedPrice,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      duration: int.tryParse(json['duration'].toString()) ?? 0,
      departmentId: int.tryParse(json['department_id'].toString()) ?? 0,
      imageUrl: (json['image'] != null && json['image'].toString().isNotEmpty)
          ? (json['image'].toString().startsWith('http')
          ? json['image']
          : "${ApiConstants.baseUrl}/storage/${json['image']}")
          : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      discountedPrice: json['pivot']?['discounted_price'] != null
          ? double.tryParse(json['pivot']['discounted_price'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "price": price.toString(),
      "duration": duration.toString(),
      "department_id": departmentId.toString(),
      "image": imageUrl,
    };
  }
}
