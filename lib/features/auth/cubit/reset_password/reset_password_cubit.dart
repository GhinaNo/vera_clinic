import 'package:bloc/bloc.dart';
import 'reset_password_state.dart';
import '../../repository/auth_repository.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthRepository authRepository;
  ResetPasswordCubit(this.authRepository) : super(ResetPasswordInitial());

  Future<void> resetPassword(String code, String password, String confirm) async {
    print('[ResetPasswordCubit] Resetting password...');
    emit(ResetPasswordLoading());
    try {
      final message = await authRepository.resetPassword(code, password, confirm);
      print('[ResetPasswordCubit] Success: $message');
      emit(ResetPasswordSuccess(message));
    } catch (e) {
      print('[ResetPasswordCubit] Failure: $e');
      emit(ResetPasswordFailure(e.toString()));
    }
  }
}
