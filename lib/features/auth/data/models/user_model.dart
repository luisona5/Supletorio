import '../../domain/entities/user.dart';

/// Extiende la entidad y añade métodos de serialización
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.userType,
    super.phone,
    required super.createdAt,
  });

  /// Crear desde JSON (Supabase)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String? ?? '',
      userType: UserType.fromString(json['user_type'] as String? ?? 'ciudadano'),
      phone: json['phone'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convertir a JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'user_type': userType.toString(),
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convertir a entidad del dominio
  User toEntity() {
    return User(
      id: id,
      email: email,
      fullName: fullName,
      userType: userType,
      phone: phone,
      createdAt: createdAt,
    );
  }

  /// Crear desde entidad del dominio
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      userType: user.userType,
      phone: user.phone,
      createdAt: user.createdAt,
    );
  }
}