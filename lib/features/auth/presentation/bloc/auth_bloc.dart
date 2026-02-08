import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Bloc de Autenticación
/// 
/// Maneja los estados de autenticación de la aplicación
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);

    // Escuchar cambios de autenticación
    _listenAuthChanges();
  }

  /// Verificar estado de autenticación al iniciar
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await authRepository.getCurrentUser();

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Manejar login
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await loginUseCase(
        email: event.email,
        password: event.password,
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }

  /// Manejar registro
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await registerUseCase(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        userType: event.userType,
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }

  /// Manejar logout
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await logoutUseCase();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }

  /// Escuchar cambios de autenticación en tiempo real
  void _listenAuthChanges() {
    authRepository.authStateChanges.listen((user) {
      if (user != null) {
        add(const AuthCheckRequested());
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }

  /// Parsear errores para mostrar mensajes amigables
  String _parseError(Object error) {
    final errorString = error.toString();

    if (errorString.contains('Invalid login credentials')) {
      return 'Email o contraseña incorrectos';
    }

    if (errorString.contains('Email not confirmed')) {
      return 'Por favor confirma tu email';
    }

    if (errorString.contains('User already registered')) {
      return 'Este email ya está registrado';
    }

    if (errorString.contains('Invalid email')) {
      return 'Email inválido';
    }

    if (errorString.contains('Password should be at least 6 characters')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    // Error genérico
    return errorString.replaceAll('Exception: ', '');
  }
}