class Service {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int duration;
  final int departmentId;
  final String? imageUrl;
  final double? discountedPrice; // موجود فقط لو جاي من pivot (عروض)

  Service({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.duration,
    required this.departmentId,
    this.imageUrl,
    this.discountedPrice,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      duration: int.tryParse(json['duration'].toString()) ?? 0,
      departmentId: json['department_id'] is String
          ? int.tryParse(json['department_id']) ?? 0
          : json['department_id'] ?? 0,
      imageUrl: json['image'], // بالباك إند بيرجع رابط كامل ✔
      discountedPrice: json['pivot']?['discounted_price'] != null
          ? double.tryParse(json['pivot']['discounted_price'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'duration': duration,
    'department_id': departmentId,
    'image': imageUrl,
  };
}
