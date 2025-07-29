import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/department.dart';

class DepartmentsCubit extends Cubit<List<Department>> {
  DepartmentsCubit() : super([]);

  void addDepartment(Department department) {
    final currentDepartments = List<Department>.from(state);
    currentDepartments.add(department);
    emit(currentDepartments);
  }

  void updateDepartment(int index, Department updatedDepartment) {
    final updatedList = List<Department>.from(state);
    if (index >= 0 && index < updatedList.length) {
      updatedList[index] = updatedDepartment;
      emit(updatedList);
    }
  }

  void removeDepartment(int index) {
    final updatedList = List<Department>.from(state);
    if (index >= 0 && index < updatedList.length) {
      updatedList.removeAt(index);
      emit(updatedList);
    }
  }

  // تحميل بيانات أولية عند بدء التطبيق أو التهيئة
  void loadInitial(List<Department> departments) {
    emit(List<Department>.from(departments));
  }
}
