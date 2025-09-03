import '../model/model_user.dart';

abstract class ClientState {}

class ClientInitial extends ClientState {}

class ClientLoading extends ClientState {
  final String message;
  ClientLoading({this.message = 'جارٍ التحميل...'});
}

class ClientLoaded extends ClientState {
  final List<Client> clients;
  ClientLoaded(this.clients);
}

class ClientError extends ClientState {
  final String message;
  ClientError(this.message);
}
