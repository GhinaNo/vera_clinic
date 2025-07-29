import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/offersModel.dart';
import 'offer_state.dart';

class OffersCubit extends Cubit<OffersState> {
  OffersCubit() : super(OffersState(offers: []));

  void loadOffers(List<Offer> newOffers) {
    emit(state.copyWith(offers: newOffers));
  }

  void addOffer(Offer offer) {
    final updatedList = List<Offer>.from(state.offers)..add(offer);
    emit(state.copyWith(offers: updatedList));
  }

  void updateOffer(Offer updatedOffer) {
    final updatedList = state.offers.map((offer) {
      return offer.id == updatedOffer.id ? updatedOffer : offer;
    }).toList();

    emit(state.copyWith(offers: updatedList));
  }

  void deleteOffer(Offer offerToDelete) {
    final updatedList = state.offers
        .where((offer) => offer.id != offerToDelete.id)
        .toList();

    emit(state.copyWith(offers: updatedList));
  }

  void setFilter(OffersFilter filter) {
    emit(state.copyWith(filter: filter));
  }
}
