import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/departments_repository.dart';
import 'delete_department_state.dart';

class DeleteDepartmentCubit extends Cubit<DeleteDepartmentState> {
  final DepartmentsRepository repository;
  DeleteDepartmentCubit({required this.repository}) : super(DeleteDepartmentInitial());

  Future<void> deleteDepartment(int id) async {
    try {
      emit(DeleteDepartmentLoading());
      await repository.deleteDepartment(id);
      emit(DeleteDepartmentSuccess());
    } catch (e) {
      emit(DeleteDepartmentFailure(e.toString()));
    }
  }
}
