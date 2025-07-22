import 'package:bloc/bloc.dart';
import '../model/offersModel.dart';
import 'offer_state.dart';

class OffersCubit extends Cubit<OffersState> {
  OffersCubit() : super(OffersState(offers: []));

  void loadOffers(List<Offer> newOffers) {
    emit(state.copyWith(offers: newOffers));
  }

  void addOffer(Offer offer) {
    final updated = List<Offer>.from(state.offers)..add(offer);
    emit(state.copyWith(offers: updated));
  }

  void updateOffer(Offer updatedOffer) {
    final updated = state.offers.map((offer) {
      if (offer.id == updatedOffer.id) {
        return updatedOffer;
      }
      return offer;
    }).toList();
    emit(state.copyWith(offers: updated));
  }


  void deleteOffer(Offer offerToDelete) {
    final updated = state.offers.where((o) => o.title != offerToDelete.title).toList();
    emit(state.copyWith(offers: updated));
  }

  void setFilter(OffersFilter filter) {
    emit(state.copyWith(filter: filter));
  }
}
