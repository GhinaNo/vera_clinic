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

  Future<void> fetchClients() async {
    emit(ClientLoading('جارٍ تحميل العملاء...'));
    try {
      final clients = await repository.fetchClients();
      emit(ClientLoaded(clients));
    } catch (e) {
      emit(ClientError('فشل تحميل العملاء'));
      print('[Cubit] خطأ: $e');
    }
  }

  Future<void> addClient(Client client, String password, String confirmPassword) async {
    emit(ClientLoading('جارٍ إضافة العميل...'));
    try {
      final newClient = await repository.addClient(client, password, confirmPassword);

      final currentClients = state is ClientLoaded ? (state as ClientLoaded).clients : [];
      final updatedClients = List<Client>.from(currentClients)..add(newClient);

      emit(ClientLoaded(updatedClients));
    } catch (e) {
      emit(ClientError('فشل إضافة العميل'));
      print('[Cubit] خطأ: $e');
      rethrow;
    }
  }

  Future<void> toggleStatus(int id) async {
    if (state is! ClientLoaded) return;

    final clients = (state as ClientLoaded).clients;
    // تحديث الحالة مؤقتًا على الواجهة
    final updatedClients = clients.map((c) {
      if (c.id == id) return c.copyWith(isActive: !c.isActive);
      return c;
    }).toList();

    emit(ClientLoaded(updatedClients));

    try {
      await repository.toggleStatus(id);
      // لا حاجة لإعادة emit إذا نجح الباك
    } catch (e) {
      // إذا فشل الباك، نرجع الحالة كما كانت
      emit(ClientLoaded(clients));
      print('[Cubit] خطأ: $e');
    }
  }

  Future<void> searchClient(String query) async {
    emit(ClientLoading('جارٍ البحث عن العملاء...'));
    try {
      final clients = await repository.searchClient(query);
      emit(ClientLoaded(clients));
    } catch (e) {
      emit(ClientError('فشل البحث عن العملاء'));
      print('[Cubit] خطأ: $e');
    }
  }
}
