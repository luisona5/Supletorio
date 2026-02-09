import '../entities/reporte.dart';
import '../repositories/reporte_repository.dart';

/// Use Case: Obtener Mis Reportes
class GetMyReportesUseCase {
  final ReporteRepository repository;

  GetMyReportesUseCase(this.repository);

  Future<List<Reporte>> call() async {
    return await repository.getMyReportes();
  }
}

/// Use Case: Obtener Todos los Reportes (Admin)
class GetAllReportesUseCase {
  final ReporteRepository repository;

  GetAllReportesUseCase(this.repository);

  Future<List<Reporte>> call() async {
    return await repository.getAllReportes();
  }
}

/// Use Case: Obtener Reportes por Estado
class GetReportesByEstadoUseCase {
  final ReporteRepository repository;

  GetReportesByEstadoUseCase(this.repository);

  Future<List<Reporte>> call(String estado) async {
    return await repository.getReportesByEstado(estado);
  }
}

/// Use Case: Obtener Reporte por ID
class GetReporteByIdUseCase {
  final ReporteRepository repository;

  GetReporteByIdUseCase(this.repository);

  Future<Reporte> call(String id) async {
    return await repository.getReporteById(id);
  }
}