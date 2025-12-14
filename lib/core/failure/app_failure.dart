import 'package:equatable/equatable.dart';

abstract class AppFailure extends Equatable {
  final String message;

  const AppFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends AppFailure {
  const AuthFailure(String message) : super(message);
}

class ImageFailure extends AppFailure {
  const ImageFailure(String message) : super(message);
}

class DeviceFailure extends AppFailure {
  const DeviceFailure(String message) : super(message);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(String message) : super(message);
}

class NetworkFailure extends AppFailure {
  const NetworkFailure(String message) : super(message);
}

class EffectFailure extends AppFailure {
  const EffectFailure(String message) : super(message);
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure(String message) : super(message);
}