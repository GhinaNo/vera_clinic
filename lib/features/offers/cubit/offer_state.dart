import '../model/offersModel.dart';

enum OffersFilter { all, active, expired }

class OffersState {
  final List<Offer> offers;
  final OffersFilter filter;

  OffersState({
    required this.offers,
    this.filter = OffersFilter.all,
  });

  List<Offer> get filteredOffers {
    final now = DateTime.now();
    switch (filter) {
      case OffersFilter.active:
        return offers.where((o) => o.endDate.isAfter(now)).toList();
      case OffersFilter.expired:
        return offers.where((o) => !o.endDate.isAfter(now)).toList();
      case OffersFilter.all:
      default:
        return offers;
    }
  }

  OffersState copyWith({
    List<Offer>? offers,
    OffersFilter? filter,
  }) {
    return OffersState(
      offers: offers ?? this.offers,
      filter: filter ?? this.filter,
    );
  }
}
