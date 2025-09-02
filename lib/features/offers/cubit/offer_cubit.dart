import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/offersModel.dart';
import '../model/offers_repository.dart';
import 'offer_state.dart';

class OffersCubit extends Cubit<OffersState> {
  final OffersRepository repository;

  OffersCubit({required this.repository}) : super(OffersState(offers: []));

  Future<void> loadOffers({String status = 'all'}) async {
    try {
      final offers = await repository.fetchOffers(status: status);
      emit(state.copyWith(offers: offers));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'فشل في تحميل العروض'));
    }
  }

  Future<void> addOffer(Offer offer) async {
    try {
      final added = await repository.addOffer(offer);
      final updatedList = [added, ...state.offers];
      emit(state.copyWith(
        offers: updatedList,
        successMessage: 'تمت إضافة العرض بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'فشل في إضافة العرض'));
    }
  }

  Future<void> updateOffer(Offer offer) async {
    try {
      final updated = await repository.updateOffer(offer);
      final updatedList = state.offers.map((o) => o.id == updated.id ? updated : o).toList();
      emit(state.copyWith(
        offers: updatedList,
        successMessage: 'تم تعديل العرض بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'فشل في تعديل العرض'));
    }
  }

  Future<void> deleteOffer(String id) async {
    try {
      await repository.deleteOffer(id);
      final updatedList = state.offers.where((o) => o.id != id).toList();
      emit(state.copyWith(
        offers: updatedList,
        successMessage: 'تم حذف العرض بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'فشل في حذف العرض'));
    }
  }

  void setFilter(OffersFilter filter) {
    emit(state.copyWith(filter: filter));
  }
}
