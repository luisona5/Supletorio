import 'package:equatable/equatable.dart';

/// Categorías de reporte
enum CategoriaReporte {
  baches,
  luminarias,
  basura,
  otro;

  String get displayName {
    switch (this) {
      case CategoriaReporte.baches:
        return 'Baches';
      case CategoriaReporte.luminarias:
        return 'Luminarias';
      case CategoriaReporte.basura:
        return 'Basura';
      case CategoriaReporte.otro:
        return 'Otro';
    }
  }

  static CategoriaReporte fromString(String value) {
    switch (value) {
      case 'baches':
        return CategoriaReporte.baches;
      case 'luminarias':
        return CategoriaReporte.luminarias;
      case 'basura':
        return CategoriaReporte.basura;
      case 'otro':
        return CategoriaReporte.otro;
      default:
        return CategoriaReporte.otro;
    }
  }

  @override
  String toString() {
    switch (this) {
      case CategoriaReporte.baches:
        return 'baches';
      case CategoriaReporte.luminarias:
        return 'luminarias';
      case CategoriaReporte.basura:
        return 'basura';
      case CategoriaReporte.otro:
        return 'otro';
    }
  }
}

/// Estados de reporte
enum EstadoReporte {
  pendiente,
  enProceso,
  resuelto;

  String get displayName {
    switch (this) {
      case EstadoReporte.pendiente:
        return 'Pendiente';
      case EstadoReporte.enProceso:
        return 'En Proceso';
      case EstadoReporte.resuelto:
        return 'Resuelto';
    }
  }

  static EstadoReporte fromString(String value) {
    switch (value) {
      case 'pendiente':
        return EstadoReporte.pendiente;
      case 'en_proceso':
        return EstadoReporte.enProceso;
      case 'resuelto':
        return EstadoReporte.resuelto;
      default:
        return EstadoReporte.pendiente;
    }
  }

  @override
  String toString() {
    switch (this) {
      case EstadoReporte.pendiente:
        return 'pendiente';
      case EstadoReporte.enProceso:
        return 'en_proceso';
      case EstadoReporte.resuelto:
        return 'resuelto';
    }
  }
}

/// Entidad de Reporte (Domain Layer)
class Reporte extends Equatable {
  final String id;
  final String usuarioId;
  final String titulo;
  final String descripcion;
  final CategoriaReporte categoria;
  final EstadoReporte estado;
  final double latitud;
  final double longitud;
  final bool sensorValid;
  final String? imagenUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reporte({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.estado,
    required this.latitud,
    required this.longitud,
    required this.sensorValid,
    this.imagenUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ¿Está pendiente?
  bool get isPendiente => estado == EstadoReporte.pendiente;

  /// ¿Está en proceso?
  bool get isEnProceso => estado == EstadoReporte.enProceso;

  /// ¿Está resuelto?
  bool get isResuelto => estado == EstadoReporte.resuelto;

  /// ¿Tiene imagen?
  bool get hasImage => imagenUrl != null && imagenUrl!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        usuarioId,
        titulo,
        descripcion,
        categoria,
        estado,
        latitud,
        longitud,
        sensorValid,
        imagenUrl,
        createdAt,
        updatedAt,
      ];
}