class Department {
  final int? id;
  final String name;
  final String description;
  final String suite_no;

  Department({
    this.id,
    required this.name,
    required this.description,
    required this.suite_no,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      suite_no: json['suite_no'] ?? '',
    );
  }
}
