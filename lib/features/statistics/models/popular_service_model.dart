class PopularServiceModel {
  final int id;
  final String name;
  final String image;
  final double price;
  final int bookingCount;

  PopularServiceModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.bookingCount,
  });

  factory PopularServiceModel.fromJson(Map<String, dynamic> json) {
    return PopularServiceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      bookingCount: int.tryParse(json['booking_count']?.toString() ?? '0') ?? 0,
    );
  }
}
