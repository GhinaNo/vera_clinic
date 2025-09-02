import '../model/offersModel.dart';

enum OffersFilter { all, active, expired }

class OffersState {
  final List<Offer> offers;
  final OffersFilter filter;
  final String? successMessage;
  final String? errorMessage;

  OffersState({
    required this.offers,
    this.filter = OffersFilter.all,
    this.successMessage,
    this.errorMessage,
  });

  List<Offer> get filteredOffers {
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

  OffersState copyWith({
    List<Offer>? offers,
    OffersFilter? filter,
    String? successMessage,
    String? errorMessage,
  }) {
    return OffersState(
      offers: offers ?? this.offers,
      filter: filter ?? this.filter,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}
