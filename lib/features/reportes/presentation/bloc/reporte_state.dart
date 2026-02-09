import 'package:equatable/equatable.dart';
import '../../domain/entities/reporte.dart';

/// Estados del Bloc de Reportes
abstract class ReporteState extends Equatable {
  const ReporteState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ReporteInitial extends ReporteState {
  const ReporteInitial();
}

/// Cargando
class ReporteLoading extends ReporteState {
  const ReporteLoading();
}

/// Reportes cargados
class ReportesLoaded extends ReporteState {
  final List<Reporte> reportes;

  const ReportesLoaded(this.reportes);

  @override
  List<Object?> get props => [reportes];
}

/// Reporte creado exitosamente
class ReporteCreated extends ReporteState {
  final Reporte reporte;

  const ReporteCreated(this.reporte);

  @override
  List<Object?> get props => [reporte];
}

/// Reporte actualizado exitosamente
class ReporteUpdated extends ReporteState {
  final Reporte reporte;

  const ReporteUpdated(this.reporte);

  @override
  List<Object?> get props => [reporte];
}

/// Reporte eliminado exitosamente
class ReporteDeleted extends ReporteState {
  final String id;

  const ReporteDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

/// Error
class ReporteError extends ReporteState {
  final String message;

  const ReporteError(this.message);

  @override
  List<Object?> get props => [message];
}