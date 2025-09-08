import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/model_user.dart';
import '../model/user_repository.dart';

abstract class ClientState {}

class ClientInitial extends ClientState {}

class ClientLoading extends ClientState {
  final String message;
  ClientLoading(this.message);
}

class ClientLoaded extends ClientState {
  final List<Client> clients;
  ClientLoaded(this.clients);
}

class ClientError extends ClientState {
  final String message;
  ClientError(this.message);
}

class ClientCubit extends Cubit<ClientState> {
  final ClientRepository repository;
  ClientCubit({required this.repository}) : super(ClientInitial());

  /// ---------------- جلب العملاء ----------------
  Future<void> fetchClients() async {
    print('Cubit: fetchClients بدأ');
    emit(ClientLoading('جارٍ تحميل العملاء...'));
    try {
      final clients = await repository.fetchClients();
      emit(ClientLoaded(clients));
      print('Cubit: fetchClients انتهى بنجاح');
    } catch (e) {
      print('Cubit: fetchClients فشل $e');
      emit(ClientError('فشل تحميل العملاء'));
    }
  }

  /// ---------------- جلب عميل واحد ----------------
  Future<void> showClient(int id) async {
    print('Cubit: showClient ID=$id');
    emit(ClientLoading('جارٍ تحميل تفاصيل العميل...'));
    try {
      final client = await repository.showClient(id);
      emit(ClientLoaded([client]));
      print('Cubit: showClient تم بنجاح');
    } catch (e) {
      print('Cubit: showClient فشل $e');
      emit(ClientError('فشل تحميل العميل'));
    }
  }

  /// ---------------- إضافة عميل ----------------
  Future<void> addClient(Client client) async {
    print('Cubit: addClient ${client.name}');
    emit(ClientLoading('جارٍ إضافة العميل...'));
    try {
      await repository.addClient(client);
      await fetchClients(); // ✅ ريفرش بعد الإضافة
      print('Cubit: addClient تم بنجاح');
    } catch (e) {
      print('Cubit: addClient فشل $e');
      emit(ClientError('فشل إضافة العميل'));
    }
  }

  /// ---------------- تبديل حالة العميل ----------------
  Future<void> toggleStatus(int id) async {
    print('Cubit: toggleStatus ID=$id');
    emit(ClientLoading('جارٍ تبديل حالة العميل...'));
    try {
      await repository.toggleStatus(id);
      await fetchClients(); // ✅ ريفرش بعد تبديل الحالة
      print('Cubit: toggleStatus تم بنجاح');
    } catch (e) {
      print('Cubit: toggleStatus فشل $e');
      emit(ClientError('فشل تبديل حالة العميل'));
    }
  }

  /// ---------------- البحث عن العملاء ----------------
  Future<void> searchClient(String query) async {
    print('Cubit: searchClient بدأ للبحث عن "$query"');
    emit(ClientLoading('جارٍ البحث عن العملاء...'));
    try {
      final clients = await repository.searchClient(query);
      emit(ClientLoaded(clients));
      print('Cubit: searchClient انتهى بنجاح');
    } catch (e) {
      print('Cubit: searchClient فشل $e');
      emit(ClientError('فشل البحث عن العملاء'));
    }
  }
}
