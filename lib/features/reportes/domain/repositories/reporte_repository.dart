import '../entities/reporte.dart';

/// Repositorio de Reportes (Domain Layer)
/// 
/// Define el contrato para las operaciones CRUD de reportes
abstract class ReporteRepository {
  /// Crear un nuevo reporte
  Future<Reporte> createReporte({
    required String titulo,
    required String descripcion,
    required String categoria,
    required double latitud,
    required double longitud,
    required bool sensorValid,
    String? imagenPath,
  });

  /// Obtener todos los reportes del usuario actual
  Future<List<Reporte>> getMyReportes();

  /// Obtener todos los reportes (solo para admin)
  Future<List<Reporte>> getAllReportes();

  /// Obtener reportes filtrados por estado
  Future<List<Reporte>> getReportesByEstado(String estado);

  /// Obtener un reporte por ID
  Future<Reporte> getReporteById(String id);

  /// Actualizar un reporte
  Future<Reporte> updateReporte({
    required String id,
    String? titulo,
    String? descripcion,
    String? categoria,
    double? latitud,
    double? longitud,
    String? imagenPath,
  });

  /// Cambiar estado de un reporte (solo admin)
  Future<Reporte> updateEstado({
    required String id,
    required String estado,
  });

  /// Eliminar un reporte
  Future<void> deleteReporte(String id);

  /// Subir imagen al storage
  Future<String> uploadImage(String imagePath);
}