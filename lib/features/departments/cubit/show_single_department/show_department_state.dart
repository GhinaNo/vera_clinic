import 'package:equatable/equatable.dart';
import '../../models/department.dart';

abstract class ShowDepartmentState extends Equatable {
  const ShowDepartmentState();

  @override
  List<Object?> get props => [];
}

class ShowDepartmentInitial extends ShowDepartmentState {}
class ShowDepartmentLoading extends ShowDepartmentState {}
class ShowDepartmentSuccess extends ShowDepartmentState {
  final Department department;
  const ShowDepartmentSuccess(this.department);

  @override
  List<Object?> get props => [department];
}
class ShowDepartmentFailure extends ShowDepartmentState {
  final String error;
  const ShowDepartmentFailure(this.error);

  @override
  List<Object?> get props => [error];
}
