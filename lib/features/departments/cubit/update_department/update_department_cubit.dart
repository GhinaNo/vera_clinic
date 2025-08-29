import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/department.dart';
import '../../models/departments_repository.dart';
import 'update_department_state.dart';

class UpdateDepartmentCubit extends Cubit<UpdateDepartmentState> {
  final DepartmentsRepository repository;
  UpdateDepartmentCubit({required this.repository}) : super(UpdateDepartmentInitial());

  Future<void> updateDepartment(int id, Department department) async {
    try {
      emit(UpdateDepartmentLoading());
      final updated = await repository.updateDepartment(id,department);
      emit(UpdateDepartmentSuccess(updated));
    } catch (e) {
      emit(UpdateDepartmentFailure(e.toString()));
    }
  }
}
