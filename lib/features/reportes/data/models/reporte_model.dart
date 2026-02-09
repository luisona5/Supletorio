import '../../../reportes/domain/entities/reporte.dart';

/// Modelo de Reporte (Data Layer)
/// 
/// Maneja la serialización/deserialización con Supabase
class ReporteModel extends Reporte {
  const ReporteModel({
    required super.id,
    required super.usuarioId,
    required super.titulo,
    required super.descripcion,
    required super.categoria,
    required super.estado,
    required super.latitud,
    required super.longitud,
    required super.sensorValid,
    super.imagenUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Desde JSON (Supabase)
  factory ReporteModel.fromJson(Map<String, dynamic> json) {
    return ReporteModel(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      categoria: CategoriaReporte.fromString(json['categoria'] as String),
      estado: EstadoReporte.fromString(json['estado'] as String),
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      sensorValid: json['sensor_valid'] as bool? ?? false,
      imagenUrl: json['imagen_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Hacia JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria.toString(),
      'estado': estado.toString(),
      'latitud': latitud,
      'longitud': longitud,
      'sensor_valid': sensorValid,
      'imagen_url': imagenUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Desde entidad del dominio
  factory ReporteModel.fromEntity(Reporte reporte) {
    return ReporteModel(
      id: reporte.id,
      usuarioId: reporte.usuarioId,
      titulo: reporte.titulo,
      descripcion: reporte.descripcion,
      categoria: reporte.categoria,
      estado: reporte.estado,
      latitud: reporte.latitud,
      longitud: reporte.longitud,
      sensorValid: reporte.sensorValid,
      imagenUrl: reporte.imagenUrl,
      createdAt: reporte.createdAt,
      updatedAt: reporte.updatedAt,
    );
  }

  /// Hacia entidad del dominio
  Reporte toEntity() {
    return Reporte(
      id: id,
      usuarioId: usuarioId,
      titulo: titulo,
      descripcion: descripcion,
      categoria: categoria,
      estado: estado,
      latitud: latitud,
      longitud: longitud,
      sensorValid: sensorValid,
      imagenUrl: imagenUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// CopyWith para inmutabilidad
  ReporteModel copyWith({
    String? id,
    String? usuarioId,
    String? titulo,
    String? descripcion,
    CategoriaReporte? categoria,
    EstadoReporte? estado,
    double? latitud,
    double? longitud,
    bool? sensorValid,
    String? imagenUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReporteModel(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      estado: estado ?? this.estado,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      sensorValid: sensorValid ?? this.sensorValid,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}