import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/offersModel.dart';
import '../model/offers_repository.dart';
import 'offer_state.dart';

class offer_cubit extends Cubit<offer_state> {
  final offers_repository repository;

  offer_cubit({required this.repository}) : super(offer_state(offers: []));

  Future<void> loadOffers({String status = 'all'}) async {
    try {
      final offers = await repository.fetchOffers(status: status);
      emit(state.copyWith(offers: offers));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'فشل في تحميل العروض'));
    }
  }

  Future<void> addOffer(offersModel offer) async {
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

  Future<void> updateOffer(offersModel offer) async {
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
