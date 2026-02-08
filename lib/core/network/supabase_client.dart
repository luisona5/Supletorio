import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Maneja la inicialización y acceso global a Supabase
class SupabaseClientManager {
  static SupabaseClientManager? _instance;
  
  SupabaseClientManager._();
  
  static SupabaseClientManager get instance {
    _instance ??= SupabaseClientManager._();
    return _instance!;
  }
  
  /// Inicializar Supabase al inicio de la app
  static Future<void> initialize() async {
    // Cargar variables de entorno
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    
    // Validar que las variables estén configuradas
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'SUPABASE_URL y SUPABASE_ANON_KEY deben estar configurados en .env'
      );
    }
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    
    print('✅ Supabase inicializado correctamente');
  }
  
  // ========== GETTERS ==========
  
  /// Cliente de Supabase
  SupabaseClient get client => Supabase.instance.client;
  
  /// Usuario actual
  User? get currentUser => client.auth.currentUser;
  
  /// ID del usuario actual
  String? get userId => currentUser?.id;
  
  /// ¿Está autenticado?
  bool get isAuthenticated => currentUser != null;
  
  // ========== HELPERS DE BASE DE DATOS ==========
  
  /// Acceso directo a tablas
  PostgrestQueryBuilder from(String table) => client.from(table);
  
  /// Acceso directo a Storage
  SupabaseStorageClient get storage => client.storage;
  
  /// Stream de cambios de autenticación
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}