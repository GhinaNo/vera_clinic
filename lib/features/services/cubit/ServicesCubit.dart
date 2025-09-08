import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vera_clinic/features/services/cubit/ServicesState.dart';
import 'package:vera_clinic/features/services/models/service.dart';
import '../models/services_repository.dart .dart';

class ServicesCubit extends Cubit<ServicesState> {
  final ServicesRepository repository;

  ServicesCubit({required this.repository}) : super(ServicesInitial());

  Future<void> fetchServices() async {
    emit(ServicesLoading());
    try {
      final services = await repository.fetchServices();
      services.sort((a, b) => b.id.compareTo(a.id));
      emit(ServicesLoaded(services));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> addService(Map<String, dynamic> data, {File? image, Uint8List? imageBytes}) async {
    emit(ServicesLoading());
    try {
      final result = await repository.addService(
        name: data['name'],
        description: data['description'],
        price: double.tryParse(data['price'].toString()) ?? 0.0,   // ✅ parsing
        duration: int.tryParse(data['duration'].toString()) ?? 0, // ✅ parsing
        departmentId: int.tryParse(data['department_id'].toString()) ?? 0, // ✅ parsing
        image: image,
        imageBytes: imageBytes,
      );

      final services = await repository.fetchServices();
      services.sort((a, b) => b.id.compareTo(a.id));

      emit(ServiceActionSuccess(result['message'], service: result['service']));
      emit(ServicesLoaded(services));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> updateService(int id, Map<String, dynamic> data, {File? image, Uint8List? imageBytes}) async {
    emit(ServicesLoading());
    try {
      final result = await repository.updateService(
        id,
        name: data['name'],
        description: data['description'],
        price: double.tryParse(data['price'].toString()) ?? 0.0,   // ✅ parsing
        duration: int.tryParse(data['duration'].toString()) ?? 0, // ✅ parsing
        departmentId: int.tryParse(data['department_id'].toString()) ?? 0, // ✅ parsing
        image: image,
        imageBytes: imageBytes,
      );

      final services = await repository.fetchServices();
      services.sort((a, b) => b.id.compareTo(a.id));

      emit(ServiceActionSuccess(result['message'], service: result['service']));
      emit(ServicesLoaded(services));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> deleteService(int id) async {
    emit(ServicesLoading());
    try {
      final result = await repository.deleteService(id);

      final services = await repository.fetchServices();
      services.sort((a, b) => b.id.compareTo(a.id));

      emit(ServiceActionSuccess(result['message']));
      emit(ServicesLoaded(services));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> searchServices(String query) async {
    emit(ServicesLoading());
    try {
      final result = await repository.searchServices(query);
      final services = result['services'] as List<Service>;
      services.sort((a, b) => b.id.compareTo(a.id));

      emit(ServiceActionSuccess(result['message']));
      emit(ServicesLoaded(services));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }
}
