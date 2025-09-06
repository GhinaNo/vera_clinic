class Client {
  final int id;
  final String name;
  final String email;
  final bool isActive;
  final String? role;
  final String? createdAt;
  final String? updatedAt;
  final List<dynamic>? bookings;

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.bookings,
  });

  factory Client.fromJson(Map<String, dynamic> json) => Client(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    isActive: json['is_active'] == 1,
    role: json['role'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
    bookings: json['bookings'] ?? [],
  );

  Client copyWith({
    int? id,
    String? name,
    String? email,
    bool? isActive,
    String? role,
    String? createdAt,
    String? updatedAt,
    List<dynamic>? bookings,
  }) =>
      Client(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        isActive: isActive ?? this.isActive,
        role: role ?? this.role,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        bookings: bookings ?? this.bookings,
      );
}
