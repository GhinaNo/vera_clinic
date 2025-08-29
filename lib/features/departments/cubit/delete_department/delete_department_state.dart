import 'package:equatable/equatable.dart';

abstract class DeleteDepartmentState extends Equatable {
  const DeleteDepartmentState();

  @override
  List<Object?> get props => [];
}

class DeleteDepartmentInitial extends DeleteDepartmentState {}
class DeleteDepartmentLoading extends DeleteDepartmentState {}
class DeleteDepartmentSuccess extends DeleteDepartmentState {}
class DeleteDepartmentFailure extends DeleteDepartmentState {
  final String error;
  const DeleteDepartmentFailure(this.error);

  @override
  List<Object?> get props => [error];
}
