abstract class CheckCodeState {}

class CheckCodeInitial extends CheckCodeState {}

class CheckCodeLoading extends CheckCodeState {}

class CheckCodeSuccess extends CheckCodeState {
  final String message;
  CheckCodeSuccess(this.message);
}

class CheckCodeFailure extends CheckCodeState {
  final String error;
  CheckCodeFailure(this.error);
}
