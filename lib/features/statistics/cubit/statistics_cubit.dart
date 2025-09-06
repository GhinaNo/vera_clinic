import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/client_count_model.dart';
import '../models/popular_service_model.dart';
import '../repository/statistics_repository.dart';
import 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final StatisticsRepository repository;

  StatisticsCubit(this.repository) : super(StatisticsInitial());

  /// تحديث إحصائيات العملاء حسب الفترة الزمنية
  Future<void> loadClientCount({required String startDate, required String endDate}) async {
    try {
      final clientCount = await repository.fetchClientCount(
        startDate: startDate,
        endDate: endDate,
      );

      // احتفظ بالخدمات الحالية إذا موجودة
      final currentServices = (state is StatisticsLoaded)
          ? (state as StatisticsLoaded).popularServices
          : <PopularServiceModel>[];

      emit(StatisticsLoaded(clientCount: clientCount, popularServices: currentServices));
    } catch (e) {
      emit(StatisticsError(e.toString()));
    }
  }

  /// تحميل الخدمات الأكثر طلبًا (لكل الوقت)
  Future<void> loadPopularServices() async {
    try {
      final popularServices = await repository.fetchPopularServices();

      // احتفظ بعدد العملاء الحالي إذا موجود
      final currentClientCount = (state is StatisticsLoaded)
          ? (state as StatisticsLoaded).clientCount
          : ClientCountModel(count: 0);

      emit(StatisticsLoaded(clientCount: currentClientCount, popularServices: popularServices));
    } catch (e) {
      emit(StatisticsError(e.toString()));
    }
  }
}
