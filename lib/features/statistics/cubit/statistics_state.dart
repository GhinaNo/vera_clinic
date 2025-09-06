import 'package:equatable/equatable.dart';
import '../models/client_count_model.dart';
import '../models/popular_service_model.dart';

abstract class StatisticsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

/// حالة تحميل عدد العملاء فقط
class ClientCountLoaded extends StatisticsState {
  final ClientCountModel clientCount;
  ClientCountLoaded(this.clientCount);

  @override
  List<Object?> get props => [clientCount];
}

/// حالة تحميل الخدمات الأكثر طلبًا فقط
class PopularServicesLoaded extends StatisticsState {
  final List<PopularServiceModel> popularServices;
  PopularServicesLoaded(this.popularServices);

  @override
  List<Object?> get props => [popularServices];
}

/// حالة تحميل كلا البيانات معًا
class StatisticsLoaded extends StatisticsState {
  final ClientCountModel clientCount;
  final List<PopularServiceModel> popularServices;

  StatisticsLoaded({required this.clientCount, required this.popularServices});

  @override
  List<Object?> get props => [clientCount, popularServices];
}

class StatisticsError extends StatisticsState {
  final String message;
  StatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}
