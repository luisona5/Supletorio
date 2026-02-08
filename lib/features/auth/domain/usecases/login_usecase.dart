import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// UseCase: Iniciar sesión
/// 
/// Encapsula la lógica de negocio para login
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Ejecutar login
  Future<User> call({
    required String email,
    required String password,
  }) async {
    // Validaciones de negocio
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email y contraseña son requeridos');
    }

    // Delegar al repositorio
    return await repository.login(
      email: email,
      password: password,
    );
  }
}