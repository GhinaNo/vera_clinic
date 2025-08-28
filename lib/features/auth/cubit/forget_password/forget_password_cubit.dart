import 'package:bloc/bloc.dart';

import '../../repository/auth_repository.dart';
import 'forget_password_state.dart';


class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  final AuthRepository authRepository;

  ForgetPasswordCubit(this.authRepository) : super(ForgetPasswordInitial());

  Future<void> forgetPassword(String email) async {
    emit(ForgetPasswordLoading());
    try {
      final message = await authRepository.forgetPassword(email);
      emit(ForgetPasswordSuccess(message));
    } catch (e) {
      emit(ForgetPasswordFailure(e.toString()));
    }
  }
}
