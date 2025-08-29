import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/departments_repository.dart';
import '../../models/department.dart';
import 'show_departments_state.dart';

class ShowDepartmentsCubit extends Cubit<ShowDepartmentsState> {
  final DepartmentsRepository repository;
  ShowDepartmentsCubit({required this.repository}) : super(ShowDepartmentsInitial());

  Future<void> fetchDepartments() async {
    try {
      emit(ShowDepartmentsLoading());
      final list = await repository.showDepartments();
      emit(ShowDepartmentsSuccess(list));
    } catch (e) {
      emit(ShowDepartmentsFailure(e.toString()));
    }
  }
}
