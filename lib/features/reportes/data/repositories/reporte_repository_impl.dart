import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/reporte.dart';
import '../../domain/repositories/reporte_repository.dart';
import '../datasources/reporte_datasource.dart';
import '../../../../core/network/supabase_client.dart';

/// Implementación del Repositorio de Reportes
class ReporteRepositoryImpl implements ReporteRepository {
  final ReporteDataSource dataSource;
  late final SupabaseClient _supabase;

  ReporteRepositoryImpl(this.dataSource) {
    _supabase = SupabaseClientManager.instance.client;
  }

  @override
  Future<Reporte> createReporte({
    required String titulo,
    required String descripcion,
    required String categoria,
    required double latitud,
    required double longitud,
    required bool sensorValid,
    String? imagenPath,
  }) async {
    try {
      // Si hay imagen, subirla primero
      String? imagenUrl;
      if (imagenPath != null && imagenPath.isNotEmpty) {
        imagenUrl = await dataSource.uploadImage(imagenPath);
      }

      // Preparar datos
      final data = {
        'titulo': titulo,
        'descripcion': descripcion,
        'categoria': categoria,
        'latitud': latitud,
        'longitud': longitud,
        'sensor_valid': sensorValid,
        'imagen_url': imagenUrl,
      };

      // Crear reporte
      final reporteModel = await dataSource.createReporte(data);
      return reporteModel.toEntity();
    } catch (e) {
      throw Exception('Error en repositorio: $e');
    }
  }

  @override
  Future<List<Reporte>> getMyReportes() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final reportesModel = await dataSource.getReportesByUserId(currentUser.id);
      return reportesModel.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error obteniendo reportes: $e');
    }
  }

  @override
  Future<List<Reporte>> getAllReportes() async {
    try {
      final reportesModel = await dataSource.getAllReportes();
      return reportesModel.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error obteniendo todos los reportes: $e');
    }
  }

  @override
  Future<List<Reporte>> getReportesByEstado(String estado) async {
    try {
      final reportesModel = await dataSource.getReportesByEstado(estado);
      return reportesModel.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error obteniendo reportes por estado: $e');
    }
  }

  @override
  Future<Reporte> getReporteById(String id) async {
    try {
      final reporteModel = await dataSource.getReporteById(id);
      return reporteModel.toEntity();
    } catch (e) {
      throw Exception('Error obteniendo reporte: $e');
    }
  }

  @override
  Future<Reporte> updateReporte({
    required String id,
    String? titulo,
    String? descripcion,
    String? categoria,
    double? latitud,
    double? longitud,
    String? imagenPath,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (titulo != null) data['titulo'] = titulo;
      if (descripcion != null) data['descripcion'] = descripcion;
      if (categoria != null) data['categoria'] = categoria;
      if (latitud != null) data['latitud'] = latitud;
      if (longitud != null) data['longitud'] = longitud;

      // Si hay nueva imagen, subirla
      if (imagenPath != null && imagenPath.isNotEmpty) {
        final imagenUrl = await dataSource.uploadImage(imagenPath);
        data['imagen_url'] = imagenUrl;
      }

      final reporteModel = await dataSource.updateReporte(id, data);
      return reporteModel.toEntity();
    } catch (e) {
      throw Exception('Error actualizando reporte: $e');
    }
  }

  @override
  Future<Reporte> updateEstado({
    required String id,
    required String estado,
  }) async {
    try {
      final data = {'estado': estado};
      final reporteModel = await dataSource.updateReporte(id, data);
      return reporteModel.toEntity();
    } catch (e) {
      throw Exception('Error actualizando estado: $e');
    }
  }

  @override
  Future<void> deleteReporte(String id) async {
    try {
      await dataSource.deleteReporte(id);
    } catch (e) {
      throw Exception('Error eliminando reporte: $e');
    }
  }

  @override
  Future<String> uploadImage(String imagePath) async {
    try {
      return await dataSource.uploadImage(imagePath);
    } catch (e) {
      throw Exception('Error subiendo imagen: $e');
    }
  }
}