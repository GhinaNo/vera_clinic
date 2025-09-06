class ClientCountModel {
  final int count;

  ClientCountModel({required this.count});

  factory ClientCountModel.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] ?? 0;
    return ClientCountModel(count: int.tryParse(raw.toString()) ?? 0);
  }
}
