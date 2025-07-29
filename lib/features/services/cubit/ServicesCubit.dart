import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/service.dart';

class ServicesCubit extends Cubit<List<Service>> {
  ServicesCubit() : super([]);

  void addService(Service service) {
    emit([...state, service]);
  }

  void updateService(int index, Service updatedService) {
    final updatedList = List<Service>.from(state);
    if (index >= 0 && index < updatedList.length) {
      updatedList[index] = updatedService;
      emit(updatedList);
    }
  }

  void removeService(int index) {
    final updatedList = List<Service>.from(state)..removeAt(index);
    emit(updatedList);
  }

  void loadInitial(List<Service> services) {
    emit(List<Service>.from(services));
  }
}
