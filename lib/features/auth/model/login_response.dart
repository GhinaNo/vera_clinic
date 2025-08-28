class LoginResponse {
  final String token;
  final String role;
  final String name;

  LoginResponse({
    required this.token,
    required this.role,
    required this.name,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return LoginResponse(
      token: data['token'] ?? '',
      role: data['role'] ?? '',
      name: data['name'] ?? '',
    );
  }
}
