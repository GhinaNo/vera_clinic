class Payment {
  final double amount;
  final DateTime date;

  Payment({
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'date': date.toIso8601String(),
  };

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    amount: json['amount'],
    date: DateTime.parse(json['date']),
  );
}
