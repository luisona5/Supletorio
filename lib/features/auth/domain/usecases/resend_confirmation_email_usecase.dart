import '../repositories/auth_repository.dart';

/// UseCase: Reenviar email de confirmación
class ResendConfirmationEmailUseCase {
  final AuthRepository repository;

  ResendConfirmationEmailUseCase(this.repository);

  /// Ejecutar reenvío
  Future<void> call(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Email inválido');
    }

    await repository.resendConfirmationEmail(email);
  }
}