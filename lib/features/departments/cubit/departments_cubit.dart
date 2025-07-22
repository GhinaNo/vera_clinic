import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/department.dart';

class DepartmentsCubit extends Cubit<List<Department>> {
  DepartmentsCubit() : super([]);

  void addDepartment(Department department) {
    final updated = List<Department>.from(state)..add(department);
    emit(updated);
  }

  void updateDepartment(int index, Department department) {
    final updated = List<Department>.from(state)..[index] = department;
    emit(updated);
  }

  void removeDepartment(int index) {
    final updated = List<Department>.from(state)..removeAt(index);
    emit(updated);
  }

  void loadInitial(List<Department> departments) {
    emit(departments);
  }
}
