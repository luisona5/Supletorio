import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/constants/app_constants.dart';
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

      // Obtener perfil del usuario
      final profile = await _getProfile(response.user!.id);
      return profile;
    } on AuthException catch (e) {
      throw Exception('Error de autenticación: ${e.message}');
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
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
      // Registrar en Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'user_type': userType.toString(),
        },
      );

      if (response.user == null) {
        throw Exception('Error al registrarse');
      }

      // Esperar a que el trigger cree el perfil
      await Future.delayed(const Duration(milliseconds: 1000));

      // Obtener perfil creado por el trigger
      final profile = await _getProfile(response.user!.id);
      return profile;
    } on AuthException catch (e) {
      throw Exception('Error de registro: ${e.message}');
    } catch (e) {
      throw Exception('Error al registrarse: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

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

  @override
  Stream<UserModel?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.asyncMap((data) async {
      final user = data.session?.user;
      if (user == null) return null;

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