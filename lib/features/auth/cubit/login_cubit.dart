import 'package:bloc/bloc.dart';
import '../../../core/services/token_storage.dart';
import '../model/login_response.dart';
import '../repository/auth_repository.dart';
part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository authRepository;

  LoginCubit(this.authRepository) : super(LoginInitial());

  Future<void> login({
    required String email,
    required String password,
    required String role,
  }) async {
    emit(LoginLoading());
    try {
      final loginResponse = await authRepository.login(
        email: email,
        password: password,
        role: role,
      );
      await TokenStorage.saveTokenAndRole(
        loginResponse.token,
        loginResponse.role,
      );

      emit(LoginSuccess(loginResponse));
    } catch (e) {
      if (e is AuthException) {
        emit(LoginFailure(e.message));
      } else {
        emit(LoginFailure("حدث خطأ غير متوقع"));
      }
    }
  }
}


