import 'package:bloc/bloc.dart';
import '../../repository/auth_repository.dart';
import 'check_code_state.dart';

class CheckCodeCubit extends Cubit<CheckCodeState> {
  final AuthRepository authRepository;
  String? verifiedCode;

  CheckCodeCubit(this.authRepository) : super(CheckCodeInitial());

  Future<void> checkCode(String code) async {
    print('[CheckCodeCubit] Checking code: $code');
    emit(CheckCodeLoading());
    try {
      final message = await authRepository.checkCode(code);
      print('[CheckCodeCubit] Success: $message');

      verifiedCode = code;
      emit(CheckCodeSuccess(message));
    } catch (e) {
      print('[CheckCodeCubit] Failure: $e');
      emit(CheckCodeFailure(e.toString()));
    }
  }
}
