import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Constantes globales de la aplicación ElVeciReporta
class AppConstants {
  // ========== SUPABASE CONFIGURATION ==========
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // ========== SUPABASE TABLES ==========
  static const String profilesTable = 'profiles';
  static const String reportesTable = 'reportes';

  // ========== STORAGE BUCKETS ==========
  static const String reporteImagesBucket = 'reporte_images';

  // ========== USER TYPES ==========
  static const String userTypeCiudadano = 'ciudadano';
  static const String userTypeAdministrador = 'administrador';

  // ========== ESTADOS DE REPORTE ==========
  static const String estadoPendiente = 'pendiente';
  static const String estadoEnProceso = 'en_proceso';
  static const String estadoResuelto = 'resuelto';

  // ========== CATEGORÍAS DE REPORTE ==========
  static const String categoriaBaches = 'baches';
  static const String categoriaLuminarias = 'luminarias';
  static const String categoriaBasura = 'basura';
  static const String categoriaOtro = 'otro';

  // ========== VALIDACIÓN ==========
  static const int minPasswordLength = 6;
  static const double sensorMovementThreshold = 10.5; // m/s² para acelerómetro
}

/// Strings de la UI
class AppStrings {
  // Auth
  static const String appName = 'VeciAvisa';
  static const String welcome = 'Bienvenido';
  static const String loginToContinue = 'Inicia sesión para continuar';
  static const String email = 'EMAIL';
  static const String password = 'CONTRASEÑA';
  static const String fullName = 'NOMBRE COMPLETO';
  static const String login = 'Iniciar Sesión';
  static const String register = 'Registrarse';
  static const String noAccount = '¿No tienes cuenta?';
  static const String haveAccount = '¿Ya tienes cuenta?';
  
  // User Type
  static const String selectUserType = 'Selecciona tu tipo de cuenta';
  static const String ciudadano = 'Ciudadano';
  static const String ciudadanoDesc = 'Reportar problemas en mi comunidad';
  static const String administrador = 'Administrador';
  static const String administradorDesc = 'Gestionar reportes del municipio';
  
  // Reportes
  static const String myReportes = 'Mis Reportes';
  static const String allReportes = 'Todos los Reportes';
  static const String createReporte = 'Crear Reporte';
  static const String title = 'Título';
  static const String description = 'Descripción';
  static const String category = 'Categoría';
  static const String estado = 'Estado';
  static const String location = 'Ubicación';
  
  // Estados
  static const String pendiente = 'Pendiente';
  static const String enProceso = 'En Proceso';
  static const String resuelto = 'Resuelto';
  
  // Categorías
  static const String baches = 'Baches';
  static const String luminarias = 'Luminarias';
  static const String basura = 'Basura';
  static const String otro = 'Otro';
  
  // Sensor
  static const String moveDeviceToEnableCamera = 
      'Mueve el dispositivo para habilitar la cámara';
  static const String cameraEnabled = 'Cámara habilitada';
  
  // Mapa
  static const String generalMap = 'Mapa General';
  static const String selectLocation = 'Selecciona la ubicación';
  
  // Perfil
  static const String profile = 'Perfil';
  static const String logout = 'Cerrar Sesión';
}