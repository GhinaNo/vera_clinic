import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/departments_repository.dart';
import '../../models/department.dart';
import 'show_department_state.dart';

class ShowDepartmentCubit extends Cubit<ShowDepartmentState> {
  final DepartmentsRepository repository;
  ShowDepartmentCubit({required this.repository}) : super(ShowDepartmentInitial());

  Future<void> fetchDepartment(int id) async {
    try {
      emit(ShowDepartmentLoading());
      final dept = await repository.showDepartment(id);
      emit(ShowDepartmentSuccess(dept));
    } catch (e) {
      emit(ShowDepartmentFailure(e.toString()));
    }
  }
}
