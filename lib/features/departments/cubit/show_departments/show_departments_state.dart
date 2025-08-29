import 'package:equatable/equatable.dart';
import '../../models/department.dart';

abstract class ShowDepartmentsState extends Equatable {
  const ShowDepartmentsState();

  @override
  List<Object?> get props => [];
}

class ShowDepartmentsInitial extends ShowDepartmentsState {}
class ShowDepartmentsLoading extends ShowDepartmentsState {}
class ShowDepartmentsSuccess extends ShowDepartmentsState {
  final List<Department> departments;
  const ShowDepartmentsSuccess(this.departments);

  @override
  List<Object?> get props => [departments];
}
class ShowDepartmentsFailure extends ShowDepartmentsState {
  final String error;
  const ShowDepartmentsFailure(this.error);

  @override
  List<Object?> get props => [error];
}
