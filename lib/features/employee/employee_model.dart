// UserModel
class UserModel {
  final int id;
  final String name;
  final String? role;
  final String status;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    this.role,
    required this.status,
    required this.email,
  });

  UserModel copyWith({
    int? id,
    String? name,
    String? role,
    String? status,
    String? email,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      status: status ?? this.status,
      email: email ?? this.email,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      email: json['email'],
      status: (json['is_active'] == 1) ? 'active' : 'blocked',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'email': email,
      'status': status,
    };
  }
}

// EmployeeModel
class EmployeeModel {
  final int id;           // id الخاص بالموظف في جدول الموظفين
  final UserModel user;   // بيانات المستخدم
  final String? role;
  final String? departmentId;
  final String? hireDate;
  final String? createdAt;
  final String? updatedAt;
  final String? archivedAt;

  EmployeeModel({
    required this.id,
    required this.user,
    this.role,
    this.departmentId,
    this.hireDate,
    this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });

  EmployeeModel copyWith({
    int? id,
    UserModel? user,
    String? role,
    String? departmentId,
    String? hireDate,
    String? createdAt,
    String? updatedAt,
    String? archivedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      user: user ?? this.user,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      hireDate: hireDate ?? this.hireDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'],
      user: UserModel.fromJson(json['user']),
      role: json['role'],
      departmentId: json['department_id']?.toString(),
      hireDate: json['hire_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      archivedAt: json['archived_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'role': role,
      'department_id': departmentId,
      'hire_date': hireDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'archived_at': archivedAt,
    };
  }
}
