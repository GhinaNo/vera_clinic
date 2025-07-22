import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/service.dart' ;

class ServicesCubit extends Cubit<List<Service>> {
  ServicesCubit() : super([]);

  void addService(Service service) {
    emit([...state, service]);
  }

  void updateService(int index, Service service) {
    final updated = List<Service>.from(state);
    updated[index] = service;
    emit(updated);
  }

  void removeService(int index) {
    final updated = List<Service>.from(state)..removeAt(index);
    emit(updated);
  }

  void loadInitial(List<Service> services) {
    emit(services);
  }
}