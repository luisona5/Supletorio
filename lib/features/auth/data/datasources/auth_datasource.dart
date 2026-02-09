import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';

/// Maneja la comunicación directa con Supabase Auth
abstract class AuthDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required UserType userType,
  });
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
  Future<void> resendConfirmationEmail(String email);
  Stream<UserModel?> get authStateChanges;
}

class AuthDataSourceImpl implements AuthDataSource {
  final SupabaseClient _supabase = SupabaseClientManager.instance.client;

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      // Autenticar con Supabase Auth
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Error al iniciar sesión');
      }

      // ✅ NUEVO: Verificar si el email está confirmado
      if (response.user!.emailConfirmedAt == null) {
        throw EmailNotConfirmedException(email);
      }

      // Obtener perfil del usuario
      final profile = await _getProfile(response.user!.id);
      return profile;
    } on AuthException catch (e) {
      if (e.message.contains('Email not confirmed')) {
        throw EmailNotConfirmedException(email);
      }
      throw Exception('Error de autenticación: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required UserType userType,
  }) async {
    try {
      // ✅ NUEVO: Configurar opciones de registro
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'user_type': userType.toString(),
        },
        // ✅ NUEVO: Deep link para confirmación (opcional)
        emailRedirectTo: 'veciavisa://login-callback',
      );

      if (response.user == null) {
        throw Exception('Error al registrarse');
      }

      // ✅ NUEVO: Verificar si requiere confirmación
      if (response.user!.emailConfirmedAt == null) {
        print('⚠️ Email pendiente de confirmación: $email');
        throw EmailNotConfirmedException(email);
      }

      // Si no requiere confirmación, continuar normalmente
      await Future.delayed(const Duration(milliseconds: 1000));
      final profile = await _getProfile(response.user!.id);
      return profile;
    } on AuthException catch (e) {
      if (e.message.contains('User already registered')) {
        throw UserAlreadyExistsException();
      }
      throw Exception('Error de registro: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      // ✅ NUEVO: Verificar confirmación de email
      if (user.emailConfirmedAt == null) {
        print('⚠️ Usuario con email no confirmado: ${user.email}');
        return null;
      }

      return await _getProfile(user.id);
    } catch (e) {
      print('Error al obtener usuario actual: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  /// ✅ NUEVO: Reenviar email de confirmación
  @override
  Future<void> resendConfirmationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      print('✅ Email de confirmación reenviado a: $email');
    } on AuthException catch (e) {
      throw Exception('Error reenviando email: ${e.message}');
    } catch (e) {
      throw Exception('Error reenviando email: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.asyncMap((data) async {
      final user = data.session?.user;
      if (user == null) return null;

      // ✅ NUEVO: Verificar confirmación
      if (user.emailConfirmedAt == null) {
        print('⚠️ Usuario sin confirmar en stream: ${user.email}');
        return null;
      }

      try {
        return await _getProfile(user.id);
      } catch (e) {
        return null;
      }
    });
  }

  /// Obtener perfil desde la tabla profiles
  Future<UserModel> _getProfile(String userId) async {
    try {
      final response = await _supabase
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener perfil: $e');
    }
  }
}