import 'package:bloc/bloc.dart';
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
      emit(LoginSuccess(loginResponse));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
