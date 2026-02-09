import 'package:equatable/equatable.dart';

/// Eventos del Bloc de Reportes
abstract class ReporteEvent extends Equatable {
  const ReporteEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar mis reportes
class LoadMyReportesEvent extends ReporteEvent {
  const LoadMyReportesEvent();
}

/// Cargar todos los reportes (admin)
class LoadAllReportesEvent extends ReporteEvent {
  const LoadAllReportesEvent();
}

/// Cargar reportes por estado
class LoadReportesByEstadoEvent extends ReporteEvent {
  final String estado;

  const LoadReportesByEstadoEvent(this.estado);

  @override
  List<Object?> get props => [estado];
}

/// Crear reporte
class CreateReporteEvent extends ReporteEvent {
  final String titulo;
  final String descripcion;
  final String categoria;
  final double latitud;
  final double longitud;
  final bool sensorValid;
  final String? imagenPath;

  const CreateReporteEvent({
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.latitud,
    required this.longitud,
    required this.sensorValid,
    this.imagenPath,
  });

  @override
  List<Object?> get props => [
        titulo,
        descripcion,
        categoria,
        latitud,
        longitud,
        sensorValid,
        imagenPath,
      ];
}

/// Actualizar reporte
class UpdateReporteEvent extends ReporteEvent {
  final String id;
  final String? titulo;
  final String? descripcion;
  final String? categoria;
  final double? latitud;
  final double? longitud;
  final String? imagenPath;

  const UpdateReporteEvent({
    required this.id,
    this.titulo,
    this.descripcion,
    this.categoria,
    this.latitud,
    this.longitud,
    this.imagenPath,
  });

  @override
  List<Object?> get props => [
        id,
        titulo,
        descripcion,
        categoria,
        latitud,
        longitud,
        imagenPath,
      ];
}

/// Cambiar estado (admin)
class UpdateEstadoReporteEvent extends ReporteEvent {
  final String id;
  final String estado;

  const UpdateEstadoReporteEvent({
    required this.id,
    required this.estado,
  });

  @override
  List<Object?> get props => [id, estado];
}

/// Eliminar reporte
class DeleteReporteEvent extends ReporteEvent {
  final String id;

  const DeleteReporteEvent(this.id);

  @override
  List<Object?> get props => [id];
}