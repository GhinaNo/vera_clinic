class EmployeeModel {
  final int id;
  final String? role;
  final int? departmentId;
  final String? hireDate;
  final String? archivedAt;
  final String? createdAt;
  final String? updatedAt;
  final UserModel user;

  EmployeeModel({
    required this.id,
    required this.user,
    this.role,
    this.departmentId,
    this.hireDate,
    this.archivedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'],
      role: json['role'],
      departmentId: json['department_id'],
      hireDate: json['hire_date'],
      archivedAt: json['archived_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: UserModel.fromJson(json['user']),
    );
  }
}

class UserModel {
  final String name;
  final String email;
  final String? role;

  UserModel({
    required this.name,
    required this.email,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'],
    );
  }
}


class User {
  final String name;
  final String email;
  final String? role;

  User({
    required this.name,
    required this.email,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }
}
