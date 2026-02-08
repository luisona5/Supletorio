import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// UseCase: Registrar nuevo usuario
/// 
/// Encapsula la lógica de negocio para registro
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  /// Ejecutar registro
  Future<User> call({
    required String email,
    required String password,
    required String fullName,
    required UserType userType,
  }) async {
    // Validaciones de negocio
    if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
      throw Exception('Todos los campos son requeridos');
    }

    if (password.length < 6) {
      throw Exception('La contraseña debe tener al menos 6 caracteres');
    }

    if (!email.contains('@')) {
      throw Exception('Email inválido');
    }

    // Delegar al repositorio
    return await repository.register(
      email: email,
      password: password,
      fullName: fullName,
      userType: userType,
    );
  }
}