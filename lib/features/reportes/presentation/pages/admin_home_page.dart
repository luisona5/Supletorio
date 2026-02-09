import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/pages/profile_page.dart';
import '../../../../core/theme/app_theme.dart';
import '../pages/mapa_general_page.dart';
import '../pages/reporte_detail_page.dart';
import '../bloc/reporte_bloc.dart';
import '../bloc/reporte_event.dart';
import '../bloc/reporte_state.dart';
import '../../domain/entities/reporte.dart';

/// Home del Administrador
/// 
/// Muestra todos los reportes del sistema
/// y permite cambiar estados
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String _filtroEstado = 'todos';

  @override
  void initState() {
    super.initState();
    // Cargar todos los reportes al iniciar
    context.read<ReporteBloc>().add(const LoadAllReportesEvent());
  }

  void _aplicarFiltro(String estado) {
    setState(() => _filtroEstado = estado);
    
    if (estado == 'todos') {
      context.read<ReporteBloc>().add(const LoadAllReportesEvent());
    } else {
      context.read<ReporteBloc>().add(LoadReportesByEstadoEvent(estado));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrativo'),
        backgroundColor: AppTheme.primary,
        actions: [
          // Botón de perfil
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
            tooltip: 'Perfil',
          ),
          // Botón de mapa
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapaGeneralPage(),
                ),
              );
            },
            tooltip: 'Ver mapa',
          ),
          // Botón de logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Column(
        children: [
          // Estadísticas
          BlocBuilder<ReporteBloc, ReporteState>(
            builder: (context, state) {
              if (state is ReportesLoaded) {
                return _buildStats(state.reportes);
              }
              return const SizedBox.shrink();
            },
          ),

          // Filtros
          _buildFilters(),

          // Lista de reportes
          Expanded(
            child: BlocBuilder<ReporteBloc, ReporteState>(
              builder: (context, state) {
                if (state is ReporteLoading) {
                  return const LoadingWidget(message: 'Cargando reportes...');
                }

                if (state is ReporteError) {
                  return _buildError(state.message);
                }

                if (state is ReportesLoaded) {
                  if (state.reportes.isEmpty) {
                    return _buildEmpty();
                  }
                  return _buildReportesList(state.reportes);
                }

                return _buildEmpty();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Estadísticas
  Widget _buildStats(List<Reporte> reportes) {
    final pendientes = reportes.where((r) => r.isPendiente).length;
    final enProceso = reportes.where((r) => r.isEnProceso).length;
    final resueltos = reportes.where((r) => r.isResuelto).length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.pending_actions,
              label: 'Pendientes',
              count: pendientes.toString(),
              color: AppTheme.pendiente,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.hourglass_empty,
              label: 'En Proceso',
              count: enProceso.toString(),
              color: AppTheme.enProceso,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle,
              label: 'Resueltos',
              count: resueltos.toString(),
              color: AppTheme.resuelto,
            ),
          ),
        ],
      ),
    );
  }

  /// Filtros
  Widget _buildFilters() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'Todos',
            isSelected: _filtroEstado == 'todos',
            onTap: () => _aplicarFiltro('todos'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Pendientes',
            isSelected: _filtroEstado == 'pendiente',
            color: AppTheme.pendiente,
            onTap: () => _aplicarFiltro('pendiente'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'En Proceso',
            isSelected: _filtroEstado == 'en_proceso',
            color: AppTheme.enProceso,
            onTap: () => _aplicarFiltro('en_proceso'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Resueltos',
            isSelected: _filtroEstado == 'resuelto',
            color: AppTheme.resuelto,
            onTap: () => _aplicarFiltro('resuelto'),
          ),
        ],
      ),
    );
  }

  /// Vista de error
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
            const Text(
              'Error cargando reportes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
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

  /// Vista vacía
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppTheme.textGrey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay reportes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _filtroEstado == 'todos'
                  ? 'Aún no se han creado reportes'
                  : 'No hay reportes con este filtro',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Lista de reportes
  Widget _buildReportesList(List<Reporte> reportes) {
    return RefreshIndicator(
      onRefresh: () async {
        if (_filtroEstado == 'todos') {
          context.read<ReporteBloc>().add(const LoadAllReportesEvent());
        } else {
          context.read<ReporteBloc>().add(LoadReportesByEstadoEvent(_filtroEstado));
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reportes.length,
        itemBuilder: (context, index) {
          final reporte = reportes[index];
          return _ReporteCard(reporte: reporte);
        },
      ),
    );
  }
}

/// Card de estadística
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 6),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Chip de filtro
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.primary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: chipColor.withOpacity(0.2),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? chipColor : AppTheme.textGrey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? chipColor : Colors.grey[300]!,
      ),
    );
  }
}

/// Card de Reporte
class _ReporteCard extends StatelessWidget {
  final Reporte reporte;

  const _ReporteCard({required this.reporte});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReporteDetailPage(reporte: reporte),
            ),
          );
          // Recargar lista al volver
          if (context.mounted) {
            context.read<ReporteBloc>().add(const LoadAllReportesEvent());
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icono de categoría
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getEstadoColor(reporte.estado).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoriaIcon(reporte.categoria),
                  color: _getEstadoColor(reporte.estado),
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reporte.titulo,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reporte.descripcion,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(reporte.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getEstadoColor(reporte.estado).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getEstadoColor(reporte.estado).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  reporte.estado.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    color: _getEstadoColor(reporte.estado),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getEstadoColor(EstadoReporte estado) {
    switch (estado) {
      case EstadoReporte.pendiente:
        return AppTheme.pendiente;
      case EstadoReporte.enProceso:
        return AppTheme.enProceso;
      case EstadoReporte.resuelto:
        return AppTheme.resuelto;
    }
  }

  IconData _getCategoriaIcon(CategoriaReporte categoria) {
    switch (categoria) {
      case CategoriaReporte.baches:
        return Icons.construction;
      case CategoriaReporte.luminarias:
        return Icons.lightbulb;
      case CategoriaReporte.basura:
        return Icons.delete;
      case CategoriaReporte.otro:
        return Icons.warning;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Hace ${difference.inMinutes} min';
      }
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}