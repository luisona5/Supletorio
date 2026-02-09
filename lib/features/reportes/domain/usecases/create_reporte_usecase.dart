import '../entities/reporte.dart';
import '../repositories/reporte_repository.dart';

/// Use Case: Crear Reporte
class CreateReporteUseCase {
  final ReporteRepository repository;

  CreateReporteUseCase(this.repository);

  Future<Reporte> call({
    required String titulo,
    required String descripcion,
    required String categoria,
    required double latitud,
    required double longitud,
    required bool sensorValid,
    String? imagenPath,
  }) async {
    // Validaciones
    if (titulo.trim().isEmpty || titulo.trim().length < 5) {
      throw Exception('El título debe tener al menos 5 caracteres');
    }

    if (descripcion.trim().isEmpty || descripcion.trim().length < 10) {
      throw Exception('La descripción debe tener al menos 10 caracteres');
    }

    if (!sensorValid) {
      throw Exception('Debe validar el sensor antes de crear el reporte');
    }

    // Crear reporte
    return await repository.createReporte(
      titulo: titulo.trim(),
      descripcion: descripcion.trim(),
      categoria: categoria,
      latitud: latitud,
      longitud: longitud,
      sensorValid: sensorValid,
      imagenPath: imagenPath,
    );
  }
}