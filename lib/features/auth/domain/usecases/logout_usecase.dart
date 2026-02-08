import '../repositories/auth_repository.dart';

/// UseCase: Cerrar sesión
/// 
/// Encapsula la lógica de negocio para logout
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  /// Ejecutar logout
  Future<void> call() async {
    await repository.logout();
  }
}