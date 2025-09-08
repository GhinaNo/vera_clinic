class LoginResponse {
  final String token;
  final String role;
  final String name;
  final int id;
  final String email;

  LoginResponse({
    required this.token,
    required this.role,
    required this.name,
    required this.id,
    required this.email,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final roles = (data['roles'] as List?)?.cast<String>() ?? [];
    return LoginResponse(
      token: data['token'] ?? '',
      role: (data['role'] ?? (roles.isNotEmpty ? roles.first : '')).toString(),
      name: data['name'] ?? '',
      id: data['id'] ?? 0,
      email: data['email'] ?? '',
    );
  }
}
