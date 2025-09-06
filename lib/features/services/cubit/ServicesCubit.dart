import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/ServicesRepository.dart';
import 'ServicesState.dart';

class ServicesCubit extends Cubit<ServicesState> {
  final ServicesRepository repository;

  ServicesCubit({required this.repository}) : super(ServicesInitial());

  Future<void> fetchServices() async {
    print("بدء تحميل جميع الخدمات");
    emit(ServicesLoading());
    try {
      final services = await repository.fetchServices();

      services.sort((a, b) => b.id.compareTo(a.id));

      print("تم تحميل الخدمات بنجاح، عدد الخدمات: ${services.length}");
      emit(ServicesLoaded(services));
    } catch (e) {
      print("حدث خطأ أثناء تحميل الخدمات: $e");
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> addService(Map<String, dynamic> data, {File? image, Uint8List? imageBytes}) async {
    print("بدء إضافة خدمة جديدة");
    emit(ServicesLoading());
    try {
      await repository.addService(data, image: image, imageBytes: imageBytes);
      print("تمت إضافة الخدمة بنجاح، الآن جلب الخدمات المحدثة");

      final services = await repository.fetchServices();
      services.sort((a, b) => b.id.compareTo(a.id));

      emit(ServiceActionSuccess("تمت إضافة الخدمة بنجاح"));
      emit(ServicesLoaded(services));
    } catch (e) {
      print("حدث خطأ أثناء إضافة الخدمة: $e");
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> updateService(int id, Map<String, dynamic> data, {File? image, Uint8List? imageBytes}) async {
    print("بدء تعديل الخدمة برقم: $id");
    emit(ServicesLoading());
    try {
      await repository.updateService(id, data, image: image, imageBytes: imageBytes);
      print("تم تعديل الخدمة بنجاح، الآن جلب الخدمات المحدثة");

      final services = await repository.fetchServices();
      services.sort((a, b) => b.id.compareTo(a.id));

      emit(ServiceActionSuccess("تم تعديل الخدمة بنجاح"));
      emit(ServicesLoaded(services));
    } catch (e) {
      print("حدث خطأ أثناء تعديل الخدمة: $e");
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> deleteService(int id) async {
    print("بدء حذف الخدمة برقم: $id");
    emit(ServicesLoading());
    try {
      await repository.deleteService(id);
      print("تم حذف الخدمة بنجاح، الآن جلب الخدمات المحدثة");

      final services = await repository.fetchServices();
      services.sort((a, b) => b.id.compareTo(a.id));

      emit(ServiceActionSuccess("تم حذف الخدمة بنجاح"));
      emit(ServicesLoaded(services));
    } catch (e) {
      print("حدث خطأ أثناء حذف الخدمة: $e");
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> searchServices(String query) async {
    print("بدء البحث عن الخدمات باستخدام الكلمة: $query");
    emit(ServicesLoading());
    try {
      final results = await repository.searchServices(query);

      results.sort((a, b) => b.id.compareTo(a.id));

      print("تم الحصول على نتائج البحث، عدد النتائج: ${results.length}");
      emit(ServicesLoaded(results));
    } catch (e) {
      print("حدث خطأ أثناء البحث عن الخدمات: $e");
      emit(ServicesError(e.toString()));
    }
  }
}
