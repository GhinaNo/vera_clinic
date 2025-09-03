import 'package:vera_clinic/features/employee/employee_model.dart';

abstract class EmployeeState  {
  const EmployeeState();

  @override
  List<Object?> get props => [];
}

class EmployeeInitial extends EmployeeState {
  const EmployeeInitial();
}

class EmployeeLoading extends EmployeeState {
  const EmployeeLoading();
}

class EmployeeLoaded extends EmployeeState {
  final List<EmployeeModel> employees;

  const EmployeeLoaded(this.employees);

  @override
  List<Object?> get props => [employees];
}

class EmployeeError extends EmployeeState {
  final String message;

  const EmployeeError(this.message);

  @override
  List<Object?> get props => [message];
}

// إضافة موظف
class EmployeeAdding extends EmployeeState {
  const EmployeeAdding();
}

class EmployeeAdded extends EmployeeState {
  final Map<String, dynamic> employee;

  const EmployeeAdded(this.employee);

  @override
  List<Object?> get props => [employee];
}

class EmployeeAddError extends EmployeeState {
  final String message;

  const EmployeeAddError(this.message);

  @override
  List<Object?> get props => [message];
}

// تعديل موظف
class EmployeeUpdating extends EmployeeState {
  const EmployeeUpdating();
}

class EmployeeUpdated extends EmployeeState {
  final Map<String, dynamic> employee;

  const EmployeeUpdated(this.employee);

  @override
  List<Object?> get props => [employee];
}

class EmployeeUpdateError extends EmployeeState {
  final String message;

  const EmployeeUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}

class ArchivedEmployeesLoading extends EmployeeState {
  const ArchivedEmployeesLoading();
}

class ArchivedEmployeesLoaded extends EmployeeState {
  final List<EmployeeModel> archivedEmployees;

  const ArchivedEmployeesLoaded(this.archivedEmployees);

  @override
  List<Object?> get props => [archivedEmployees];
}

class ArchivedEmployeesError extends EmployeeState {
  final String message;

  const ArchivedEmployeesError(this.message);

  @override
  List<Object?> get props => [message];
}

class EmployeeArchiving extends EmployeeState {
  const EmployeeArchiving();
}

class EmployeeArchivedSuccessfully extends EmployeeState {
  final String message;

  const EmployeeArchivedSuccessfully(this.message);

  @override
  List<Object?> get props => [message];
}

class EmployeeArchiveError extends EmployeeState {
  final String message;

  const EmployeeArchiveError(this.message);

  @override
  List<Object?> get props => [message];
}

class EmployeeSearching extends EmployeeState {
  const EmployeeSearching();
}

class EmployeeSearchResults extends EmployeeState {
  final List<EmployeeModel> employees;

  const EmployeeSearchResults(this.employees);

  @override
  List<Object?> get props => [employees];
}

class EmployeeSearchError extends EmployeeState {
  final String message;

  const EmployeeSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
