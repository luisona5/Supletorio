import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Eventos del Bloc de Autenticación
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Verificar estado de autenticación
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Iniciar sesión
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Registrarse
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final UserType userType;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.userType,
  });

  @override
  List<Object?> get props => [email, password, fullName, userType];
}

/// Cerrar sesión
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}