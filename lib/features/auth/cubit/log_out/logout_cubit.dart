import 'package:bloc/bloc.dart';
import '../../../../core/services/token_storage.dart';
import '../../repository/auth_repository.dart';
import 'logout_state.dart';


class LogoutCubit extends Cubit<LogoutState> {
  final AuthRepository repo;
  LogoutCubit(this.repo) : super(LogoutInitial());

  Future<void> logout() async {
    emit(LogoutLoading());
    try {
      await repo.logout();
      await TokenStorage.clear();
      emit(LogoutSuccess());
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('no_token') || msg.contains('unauthorized')) {
        // الجلسة منتهية أصلاً
        await TokenStorage.clear();
        emit(LogoutSuccess());
      } else if (msg.contains('server_error')) {
        emit(LogoutFailure('خطأ في الخادم أثناء تسجيل الخروج'));
      } else if (msg.contains('SocketException')) {
        emit(LogoutFailure('تحقق من اتصال الإنترنت'));
      } else {
        emit(LogoutFailure('تعذر تسجيل الخروج'));
      }
    }
  }
}
