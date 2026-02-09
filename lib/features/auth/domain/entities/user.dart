import 'package:equatable/equatable.dart';

/// Tipos de usuario en el sistema
enum UserType {
  ciudadano,
  administrador;

  /// Convertir desde string
  static UserType fromString(String type) {
    switch (type) {
      case 'ciudadano':
        return UserType.ciudadano;
      case 'administrador':
        return UserType.administrador;
      default:
        return UserType.ciudadano;
    }
  }

  /// Convertir a string
  @override
  String toString() {
    switch (this) {
      case UserType.ciudadano:
        return 'ciudadano';
      case UserType.administrador:
        return 'administrador';
    }
  }

  /// Descripción amigable
  String get displayName {
    switch (this) {
      case UserType.ciudadano:
        return 'Ciudadano';
      case UserType.administrador:
        return 'Administrador';
    }
  }
}

/// Entidad de Usuario (Domain Layer)
/// 
/// Representa un usuario del sistema independientemente de la fuente de datos
class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final UserType userType;
  final String? phone;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.userType,
    this.phone,
    required this.createdAt,
  });

  /// ¿Es administrador?
  bool get isAdministrador => userType == UserType.administrador;

  /// ¿Es ciudadano?
  bool get isCiudadano => userType == UserType.ciudadano;

  @override
  List<Object?> get props => [id, email, fullName, userType, phone, createdAt];
}