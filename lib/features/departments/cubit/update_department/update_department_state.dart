import 'package:equatable/equatable.dart';
import '../../models/department.dart';

abstract class UpdateDepartmentState extends Equatable {
  const UpdateDepartmentState();

  @override
  List<Object?> get props => [];
}

class UpdateDepartmentInitial extends UpdateDepartmentState {}
class UpdateDepartmentLoading extends UpdateDepartmentState {}
class UpdateDepartmentSuccess extends UpdateDepartmentState {
  final Department department;
  const UpdateDepartmentSuccess(this.department);

  @override
  List<Object?> get props => [department];
}
class UpdateDepartmentFailure extends UpdateDepartmentState {
  final String error;
  const UpdateDepartmentFailure(this.error);

  @override
  List<Object?> get props => [error];
}
