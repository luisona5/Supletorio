/// Excepción cuando el email no está confirmado
class EmailNotConfirmedException implements Exception {
  final String email;
  
  EmailNotConfirmedException(this.email);
  
  @override
  String toString() => 'El email $email aún no ha sido confirmado';
}

/// Excepción cuando el usuario ya existe
class UserAlreadyExistsException implements Exception {
  @override
  String toString() => 'Este email ya está registrado';
}