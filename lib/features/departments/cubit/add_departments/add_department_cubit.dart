import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/department.dart';
import '../../models/departments_repository.dart';
import 'add_department_state.dart';


class AddDepartmentCubit extends Cubit<AddDepartmentState> {
  final DepartmentsRepository repository;

  AddDepartmentCubit({required this.repository}) : super(AddDepartmentInitial());

  Future<void> addDepartment(Department department) async {
    try {
      emit(AddDepartmentLoading());
      final newDept = await repository.addDepartment(department);
      emit(AddDepartmentSuccess(newDept));
    } catch (e) {
      emit(AddDepartmentFailure(e.toString()));
    }
  }
}
