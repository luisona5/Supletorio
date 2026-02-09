import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

/// Implementa la interfaz del dominio delegando a los DataSources
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await dataSource.login(email, password);
      return userModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    required UserType userType,
  }) async {
    try {
      final userModel = await dataSource.register(
        email: email,
        password: password,
        fullName: fullName,
        userType: userType,
      );
      return userModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userModel = await dataSource.getCurrentUser();
      return userModel?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dataSource.logout();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final user = await getCurrentUser();
    return user != null;
  }

  @override
  Stream<User?> get authStateChanges {
    return dataSource.authStateChanges.map((userModel) {
      return userModel?.toEntity();
    });
  }

  /// ✅ NUEVO: Reenviar email de confirmación
  @override
  Future<void> resendConfirmationEmail(String email) async {
    try {
      await dataSource.resendConfirmationEmail(email);
    } catch (e) {
      rethrow;
    }
  }
}