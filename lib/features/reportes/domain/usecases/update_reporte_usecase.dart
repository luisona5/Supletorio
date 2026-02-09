import '../entities/reporte.dart';
import '../repositories/reporte_repository.dart';

/// Use Case: Actualizar Reporte
class UpdateReporteUseCase {
  final ReporteRepository repository;

  UpdateReporteUseCase(this.repository);

  Future<Reporte> call({
    required String id,
    String? titulo,
    String? descripcion,
    String? categoria,
    double? latitud,
    double? longitud,
    String? imagenPath,
  }) async {
    // Validaciones
    if (titulo != null && (titulo.trim().isEmpty || titulo.trim().length < 5)) {
      throw Exception('El título debe tener al menos 5 caracteres');
    }

    if (descripcion != null && (descripcion.trim().isEmpty || descripcion.trim().length < 10)) {
      throw Exception('La descripción debe tener al menos 10 caracteres');
    }

    return await repository.updateReporte(
      id: id,
      titulo: titulo?.trim(),
      descripcion: descripcion?.trim(),
      categoria: categoria,
      latitud: latitud,
      longitud: longitud,
      imagenPath: imagenPath,
    );
  }
}

/// Use Case: Actualizar Estado del Reporte (Admin)
class UpdateEstadoReporteUseCase {
  final ReporteRepository repository;

  UpdateEstadoReporteUseCase(this.repository);

  Future<Reporte> call({
    required String id,
    required String estado,
  }) async {
    // Validar que el estado sea válido
    final estadosValidos = ['pendiente', 'en_proceso', 'resuelto'];
    if (!estadosValidos.contains(estado)) {
      throw Exception('Estado inválido. Use: pendiente, en_proceso, o resuelto');
    }

    return await repository.updateEstado(
      id: id,
      estado: estado,
    );
  }
}