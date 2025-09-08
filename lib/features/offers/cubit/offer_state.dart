import '../model/offersModel.dart';

enum OffersFilter { all, active, expired }

class offer_state {
  final List<offersModel> offers;
  final OffersFilter filter;
  final String? successMessage;
  final String? errorMessage;

  offer_state({
    required this.offers,
    this.filter = OffersFilter.all,
    this.successMessage,
    this.errorMessage,
  });

  List<offersModel> get filteredOffers {
    final now = DateTime.now();
    switch (filter) {
      case OffersFilter.active:
        return offers.where((offer) => offer.endDate.isAfter(now)).toList();
      case OffersFilter.expired:
        return offers.where((offer) => offer.endDate.isBefore(now)).toList();
      case OffersFilter.all:
      default:
        return offers;
    }
  }

  offer_state copyWith({
    List<offersModel>? offers,
    OffersFilter? filter,
    String? successMessage,
    String? errorMessage,
  }) {
    return offer_state(
      offers: offers ?? this.offers,
      filter: filter ?? this.filter,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}
