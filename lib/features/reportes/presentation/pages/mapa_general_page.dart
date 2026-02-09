import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/reporte.dart';
import '../widgets/mapa_general_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../bloc/reporte_bloc.dart';
import '../bloc/reporte_event.dart';
import '../bloc/reporte_state.dart';

/// Página del Mapa General
/// 
/// Muestra todos los reportes del sistema en un mapa interactivo
class MapaGeneralPage extends StatefulWidget {
  const MapaGeneralPage({super.key});

  @override
  State<MapaGeneralPage> createState() => _MapaGeneralPageState();
}

class _MapaGeneralPageState extends State<MapaGeneralPage> {
  @override
  void initState() {
    super.initState();
    // Cargar todos los reportes al iniciar
    context.read<ReporteBloc>().add(const LoadAllReportesEvent());
  }

  /// Manejar tap en marcador
  void _onMarkerTap(Reporte reporte) {
    // Aquí se podría navegar a la página de detalle
    print('📍 Marcador seleccionado: ${reporte.titulo}');
    
    // Mostrar snackbar temporal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(reporte.titulo),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  /// Filtrar reportes por estado
  void _showFilterDialog() {
    final bloc = context.read<ReporteBloc>();
    
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<ReporteBloc, ReporteState>(
        builder: (context, state) {
          final reportes = state is ReportesLoaded ? state.reportes : <Reporte>[];
          
          return AlertDialog(
            title: const Text('Filtrar Reportes'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FilterOption(
                  label: 'Todos',
                  count: reportes.length,
                  onTap: () {
                    Navigator.pop(context);
                    bloc.add(const LoadAllReportesEvent());
                  },
                ),
                _FilterOption(
                  label: 'Pendientes',
                  count: reportes.where((r) => r.isPendiente).length,
                  color: AppTheme.pendiente,
                  onTap: () {
                    Navigator.pop(context);
                    bloc.add(const LoadReportesByEstadoEvent('pendiente'));
                  },
                ),
                _FilterOption(
                  label: 'En Proceso',
                  count: reportes.where((r) => r.isEnProceso).length,
                  color: AppTheme.enProceso,
                  onTap: () {
                    Navigator.pop(context);
                    bloc.add(const LoadReportesByEstadoEvent('en_proceso'));
                  },
                ),
                _FilterOption(
                  label: 'Resueltos',
                  count: reportes.where((r) => r.isResuelto).length,
                  color: AppTheme.resuelto,
                  onTap: () {
                    Navigator.pop(context);
                    bloc.add(const LoadReportesByEstadoEvent('resuelto'));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Reportes'),
        backgroundColor: AppTheme.primary,
        actions: [
          // Botón de filtro
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrar',
          ),
          // Botón de refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ReporteBloc>().add(const LoadAllReportesEvent());
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: BlocBuilder<ReporteBloc, ReporteState>(
        builder: (context, state) {
          if (state is ReporteLoading) {
            return const LoadingWidget(message: 'Cargando mapa...');
          }

          if (state is ReporteError) {
            return _buildError(state.message);
          }

          if (state is ReportesLoaded) {
            if (state.reportes.isEmpty) {
              return _buildEmpty();
            }
            return MapaGeneralWidget(
              reportes: state.reportes,
              onMarkerTap: _onMarkerTap,
            );
          }

          return const LoadingWidget(message: 'Cargando mapa...');
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textGrey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ReporteBloc>().add(const LoadAllReportesEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: AppTheme.textGrey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay reportes para mostrar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Los reportes aparecerán aquí cuando se creen',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de opción de filtro
class _FilterOption extends StatelessWidget {
  final String label;
  final int count;
  final Color? color;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    required this.count,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: color != null
          ? Icon(Icons.circle, color: color, size: 16)
          : const Icon(Icons.all_inclusive, size: 16),
      title: Text(label),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (color ?? AppTheme.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          count.toString(),
          style: TextStyle(
            color: color ?? AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}