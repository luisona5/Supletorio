import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Estados del Bloc de Autenticación
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial (verificando autenticación)
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Cargando (procesando login/registro)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Autenticado exitosamente
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// No autenticado
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error de autenticación
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}