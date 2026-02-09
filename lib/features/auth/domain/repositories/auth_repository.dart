import '../entities/user.dart';

/// Interfaz del repositorio de autenticación (Domain Layer)
/// 
/// Define los contratos que debe implementar el repositorio
abstract class AuthRepository {
  /// Login con email y contraseña
  Future<User> login({
    required String email,
    required String password,
  });

  /// Registro de nuevo usuario
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    required UserType userType,
  });

  /// Obtener usuario actual
  Future<User?> getCurrentUser();

  /// Cerrar sesión
  Future<void> logout();

  /// Verificar si hay sesión activa
  Future<bool> isAuthenticated();

  /// Stream de cambios de autenticación
  Stream<User?> get authStateChanges;

   /// Reenviar email de confirmación
  Future<void> resendConfirmationEmail(String email);
}