import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/reporte_model.dart';

/// DataSource de Reportes
/// 
/// Maneja todas las operaciones con Supabase (BD y Storage)
abstract class ReporteDataSource {
  Future<ReporteModel> createReporte(Map<String, dynamic> data);
  Future<List<ReporteModel>> getReportesByUserId(String userId);
  Future<List<ReporteModel>> getAllReportes();
  Future<List<ReporteModel>> getReportesByEstado(String estado);
  Future<ReporteModel> getReporteById(String id);
  Future<ReporteModel> updateReporte(String id, Map<String, dynamic> data);
  Future<void> deleteReporte(String id);
  Future<String> uploadImage(String imagePath);
}

class ReporteDataSourceImpl implements ReporteDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<ReporteModel> createReporte(Map<String, dynamic> data) async {
    try {
      print('🔵 Creando reporte en Supabase...');
      
      // Agregar usuario_id del usuario actual
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      data['usuario_id'] = currentUser.id;
      data['estado'] = 'pendiente'; // Estado inicial
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      // Insertar en la base de datos
      final response = await _supabase
          .from('reportes')
          .insert(data)
          .select()
          .single();

      print('✅ Reporte creado: ${response['id']}');
      return ReporteModel.fromJson(response);
    } catch (e) {
      print('❌ Error creando reporte: $e');
      throw Exception('Error creando reporte: $e');
    }
  }

  @override
  Future<List<ReporteModel>> getReportesByUserId(String userId) async {
    try {
      print('🔵 Obteniendo reportes del usuario: $userId');
      
      final response = await _supabase
          .from('reportes')
          .select()
          .eq('usuario_id', userId)
          .order('created_at', ascending: false);

      print('✅ Reportes obtenidos: ${response.length}');
      
      return (response as List)
          .map((json) => ReporteModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error obteniendo reportes: $e');
      throw Exception('Error obteniendo reportes: $e');
    }
  }

  @override
  Future<List<ReporteModel>> getAllReportes() async {
    try {
      print('🔵 Obteniendo todos los reportes...');
      
      final response = await _supabase
          .from('reportes')
          .select()
          .order('created_at', ascending: false);

      print('✅ Total reportes: ${response.length}');
      
      return (response as List)
          .map((json) => ReporteModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error obteniendo reportes: $e');
      throw Exception('Error obteniendo reportes: $e');
    }
  }

  @override
  Future<List<ReporteModel>> getReportesByEstado(String estado) async {
    try {
      print('🔵 Obteniendo reportes con estado: $estado');
      
      final response = await _supabase
          .from('reportes')
          .select()
          .eq('estado', estado)
          .order('created_at', ascending: false);

      print('✅ Reportes encontrados: ${response.length}');
      
      return (response as List)
          .map((json) => ReporteModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error obteniendo reportes por estado: $e');
      throw Exception('Error obteniendo reportes por estado: $e');
    }
  }

  @override
  Future<ReporteModel> getReporteById(String id) async {
    try {
      print('🔵 Obteniendo reporte: $id');
      
      final response = await _supabase
          .from('reportes')
          .select()
          .eq('id', id)
          .single();

      print('✅ Reporte obtenido');
      return ReporteModel.fromJson(response);
    } catch (e) {
      print('❌ Error obteniendo reporte: $e');
      throw Exception('Error obteniendo reporte: $e');
    }
  }

  @override
  Future<ReporteModel> updateReporte(String id, Map<String, dynamic> data) async {
    try {
      print('🔵 Actualizando reporte: $id');
      
      // Agregar timestamp de actualización
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('reportes')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      print('✅ Reporte actualizado');
      return ReporteModel.fromJson(response);
    } catch (e) {
      print('❌ Error actualizando reporte: $e');
      throw Exception('Error actualizando reporte: $e');
    }
  }

  @override
  Future<void> deleteReporte(String id) async {
    try {
      print('🔵 Eliminando reporte: $id');
      
      await _supabase
          .from('reportes')
          .delete()
          .eq('id', id);

      print('✅ Reporte eliminado');
    } catch (e) {
      print('❌ Error eliminando reporte: $e');
      throw Exception('Error eliminando reporte: $e');
    }
  }

  @override
  Future<String> uploadImage(String imagePath) async {
    try {
      print('🔵 Subiendo imagen: $imagePath');
      
      final file = File(imagePath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      
      // Subir a Supabase Storage
      final response = await _supabase.storage
          .from('reporte_images')
          .upload(fileName, file);

      // Obtener URL pública
      final imageUrl = _supabase.storage
          .from('reporte_images')
          .getPublicUrl(fileName);

      print('✅ Imagen subida: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('❌ Error subiendo imagen: $e');
      throw Exception('Error subiendo imagen: $e');
    }
  }
}