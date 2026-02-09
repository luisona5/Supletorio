import '../repositories/reporte_repository.dart';

/// Use Case: Eliminar Reporte
class DeleteReporteUseCase {
  final ReporteRepository repository;

  DeleteReporteUseCase(this.repository);

  Future<void> call(String id) async {
    if (id.isEmpty) {
      throw Exception('ID de reporte inválido');
    }

    return await repository.deleteReporte(id);
  }
}