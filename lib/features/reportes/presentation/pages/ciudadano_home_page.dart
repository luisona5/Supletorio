import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/pages/profile_page.dart';
import '../../../../core/theme/app_theme.dart';
import '../pages/create_reporte_page.dart';
import '../pages/mapa_general_page.dart';
import '../pages/reporte_detail_page.dart';
import '../bloc/reporte_bloc.dart';
import '../bloc/reporte_event.dart';
import '../bloc/reporte_state.dart';
import '../../domain/entities/reporte.dart';

/// Home del Ciudadano
/// 
/// Muestra los reportes creados por el usuario
/// y permite crear nuevos reportes
class CiudadanoHomePage extends StatefulWidget {
  const CiudadanoHomePage({super.key});

  @override
  State<CiudadanoHomePage> createState() => _CiudadanoHomePageState();
}

class _CiudadanoHomePageState extends State<CiudadanoHomePage> {
  @override
  void initState() {
    super.initState();
    // Cargar mis reportes al iniciar
    context.read<ReporteBloc>().add(const LoadMyReportesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reportes'),
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
      body: BlocBuilder<ReporteBloc, ReporteState>(
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
      
      // FAB para crear reporte
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateReportePage(),
            ),
          );
          // Recargar reportes al volver
          if (mounted) {
            context.read<ReporteBloc>().add(const LoadMyReportesEvent());
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Reporte'),
        backgroundColor: AppTheme.primary,
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
            Text(
              'Error cargando reportes',
              style: const TextStyle(
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
                context.read<ReporteBloc>().add(const LoadMyReportesEvent());
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.report_problem_outlined,
              size: 100,
              color: AppTheme.primary.withOpacity(0.5),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Aún no tienes reportes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Crea tu primer reporte para comenzar',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            CustomButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateReportePage(),
                  ),
                );
                if (mounted) {
                  context.read<ReporteBloc>().add(const LoadMyReportesEvent());
                }
              },
              text: 'Crear Nuevo Reporte',
              icon: Icons.add_circle_outline,
              backgroundColor: AppTheme.success,
            ),

            const SizedBox(height: 16),

            CustomButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapaGeneralPage(),
                  ),
                );
              },
              text: 'Ver Mapa de Reportes',
              icon: Icons.map,
              backgroundColor: AppTheme.primary,
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
        context.read<ReporteBloc>().add(const LoadMyReportesEvent());
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

/// Card de Reporte
class _ReporteCard extends StatelessWidget {
  final Reporte reporte;

  const _ReporteCard({required this.reporte});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
            context.read<ReporteBloc>().add(const LoadMyReportesEvent());
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Icono de categoría
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.getColorForCategoria(reporte.categoria.toString())
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoriaIcon(reporte.categoria),
                      color: AppTheme.getColorForCategoria(reporte.categoria.toString()),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Título y fecha
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reporte.titulo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(reporte.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Estado
                  _EstadoChip(estado: reporte.estado),
                ],
              ),

              const SizedBox(height: 12),

              // Descripción
              Text(
                reporte.descripcion,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textGrey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Footer con badges
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoBadge(
                    icon: Icons.category,
                    label: reporte.categoria.displayName,
                  ),
                  if (reporte.sensorValid)
                    const _InfoBadge(
                      icon: Icons.verified,
                      label: 'Verificado',
                      color: AppTheme.success,
                    ),
                  if (reporte.hasImage)
                    const _InfoBadge(
                      icon: Icons.image,
                      label: 'Con foto',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

/// Chip de estado
class _EstadoChip extends StatelessWidget {
  final EstadoReporte estado;

  const _EstadoChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        estado.displayName,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (estado) {
      case EstadoReporte.pendiente:
        return AppTheme.pendiente;
      case EstadoReporte.enProceso:
        return AppTheme.enProceso;
      case EstadoReporte.resuelto:
        return AppTheme.resuelto;
    }
  }
}

/// Badge de información
class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoBadge({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppTheme.textGrey;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}