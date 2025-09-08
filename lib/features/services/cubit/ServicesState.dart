
import 'package:vera_clinic/features/services/models/service.dart';

abstract class ServicesState {}

class ServicesInitial extends ServicesState {}

class ServicesLoading extends ServicesState {}

class ServicesLoaded extends ServicesState {
  final List<Service> services;
  ServicesLoaded(this.services);
}

class ServiceLoaded extends ServicesState {
  final Service service;
  ServiceLoaded(this.service);
}

class ServicesError extends ServicesState {
  final String message;
  ServicesError(this.message);
}

class ServiceActionSuccess extends ServicesState {
  final String message;
  final Service? service;

  ServiceActionSuccess(this.message, {this.service});
}
