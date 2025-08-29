import 'package:equatable/equatable.dart';
import '../../models/department.dart';

/// Abstract state class for Add Department feature
abstract class AddDepartmentState extends Equatable {
  const AddDepartmentState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action
class AddDepartmentInitial extends AddDepartmentState {}

/// State when the add department API call is in progress
class AddDepartmentLoading extends AddDepartmentState {}

/// State when adding a department succeeds
class AddDepartmentSuccess extends AddDepartmentState {
  final Department department;

  const AddDepartmentSuccess(this.department);

  @override
  List<Object?> get props => [department];
}

/// State when adding a department fails
class AddDepartmentFailure extends AddDepartmentState {
  final String error;

  const AddDepartmentFailure(this.error);

  @override
  List<Object?> get props => [error];
}
