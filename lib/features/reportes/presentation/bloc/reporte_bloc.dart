import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_reporte_usecase.dart';
import '../../domain/usecases/get_reportes_usecase.dart';
import '../../domain/usecases/update_reporte_usecase.dart';
import '../../domain/usecases/delete_reporte_usecase.dart';
import 'reporte_event.dart';
import 'reporte_state.dart';

/// Bloc de Reportes
/// 
/// Maneja toda la lógica de negocio de reportes
class ReporteBloc extends Bloc<ReporteEvent, ReporteState> {
  final CreateReporteUseCase createReporteUseCase;
  final GetMyReportesUseCase getMyReportesUseCase;
  final GetAllReportesUseCase getAllReportesUseCase;
  final GetReportesByEstadoUseCase getReportesByEstadoUseCase;
  final UpdateReporteUseCase updateReporteUseCase;
  final UpdateEstadoReporteUseCase updateEstadoReporteUseCase;
  final DeleteReporteUseCase deleteReporteUseCase;

  ReporteBloc({
    required this.createReporteUseCase,
    required this.getMyReportesUseCase,
    required this.getAllReportesUseCase,
    required this.getReportesByEstadoUseCase,
    required this.updateReporteUseCase,
    required this.updateEstadoReporteUseCase,
    required this.deleteReporteUseCase,
  }) : super(const ReporteInitial()) {
    on<LoadMyReportesEvent>(_onLoadMyReportes);
    on<LoadAllReportesEvent>(_onLoadAllReportes);
    on<LoadReportesByEstadoEvent>(_onLoadReportesByEstado);
    on<CreateReporteEvent>(_onCreateReporte);
    on<UpdateReporteEvent>(_onUpdateReporte);
    on<UpdateEstadoReporteEvent>(_onUpdateEstado);
    on<DeleteReporteEvent>(_onDeleteReporte);
  }

  /// Cargar mis reportes
  Future<void> _onLoadMyReportes(
    LoadMyReportesEvent event,
    Emitter<ReporteState> emit,
  ) async {
    try {
      emit(const ReporteLoading());
      
      final reportes = await getMyReportesUseCase();
      
      emit(ReportesLoaded(reportes));
    } catch (e) {
      emit(ReporteError(e.toString()));
    }
  }

  /// Cargar todos los reportes (admin)
  Future<void> _onLoadAllReportes(
    LoadAllReportesEvent event,
    Emitter<ReporteState> emit,
  ) async {
    try {
      emit(const ReporteLoading());
      
      final reportes = await getAllReportesUseCase();
      
      emit(ReportesLoaded(reportes));
    } catch (e) {
      emit(ReporteError(e.toString()));
    }
  }

  /// Cargar reportes por estado
  Future<void> _onLoadReportesByEstado(
    LoadReportesByEstadoEvent event,
    Emitter<ReporteState> emit,
  ) async {
    try {
      emit(const ReporteLoading());
      
      final reportes = await getReportesByEstadoUseCase(event.estado);
      
      emit(ReportesLoaded(reportes));
    } catch (e) {
      emit(ReporteError(e.toString()));
    }
  }

  /// Crear reporte
  Future<void> _onCreateReporte(
    CreateReporteEvent event,
    Emitter<ReporteState> emit,
  ) async {
    try {
      emit(const ReporteLoading());
      
      final reporte = await createReporteUseCase(
        titulo: event.titulo,
        descripcion: event.descripcion,
        categoria: event.categoria,
        latitud: event.latitud,
        longitud: event.longitud,
        sensorValid: event.sensorValid,
        imagenPath: event.imagenPath,
      );
      
      emit(ReporteCreated(reporte));
      
      // Recargar la lista de reportes después de crear
      add(const LoadMyReportesEvent());
    } catch (e) {
      emit(ReporteError(e.toString()));
    }
  }

  /// Actualizar reporte
  Future<void> _onUpdateReporte(
    UpdateReporteEvent event,
    Emitter<ReporteState> emit,
  ) async {
    try {
      emit(const ReporteLoading());
      
      final reporte = await updateReporteUseCase(
        id: event.id,
        titulo: event.titulo,
        descripcion: event.descripcion,
        categoria: event.categoria,
        latitud: event.latitud,
        longitud: event.longitud,
        imagenPath: event.imagenPath,
      );
      
      emit(ReporteUpdated(reporte));
      
      // Recargar la lista de reportes
      add(const LoadMyReportesEvent());
    } catch (e) {
      emit(ReporteError(e.toString()));
    }
  }

  /// Actualizar estado (admin)
  Future<void> _onUpdateEstado(
    UpdateEstadoReporteEvent event,
    Emitter<ReporteState> emit,
  ) async {
    try {
      emit(const ReporteLoading());
      
      final reporte = await updateEstadoReporteUseCase(
        id: event.id,
        estado: event.estado,
      );
      
      emit(ReporteUpdated(reporte));
      
      // Recargar todos los reportes (admin)
      add(const LoadAllReportesEvent());
    } catch (e) {
      emit(ReporteError(e.toString()));
    }
  }

  /// Eliminar reporte
  Future<void> _onDeleteReporte(
    DeleteReporteEvent event,
    Emitter<ReporteState> emit,
  ) async {
    try {
      emit(const ReporteLoading());
      
      await deleteReporteUseCase(event.id);
      
      emit(ReporteDeleted(event.id));
      
      // Recargar la lista de reportes
      add(const LoadMyReportesEvent());
    } catch (e) {
      emit(ReporteError(e.toString()));
    }
  }
}