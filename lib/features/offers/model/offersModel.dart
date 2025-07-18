class Offer {
  final String title;
  final double discountPercent;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> serviceIds;

  Offer({
    required this.title,
    required this.discountPercent,
    required this.startDate,
    required this.endDate,
    required this.serviceIds,
  });
}
