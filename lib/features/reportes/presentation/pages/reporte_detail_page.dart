import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/reporte.dart';
import '../bloc/reporte_bloc.dart';
import '../bloc/reporte_event.dart';
import '../bloc/reporte_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'edit_reporte_page.dart';

/// Página de Detalle de Reporte
/// 
/// Muestra toda la información del reporte
/// Permite al admin cambiar estados
class ReporteDetailPage extends StatelessWidget {
  final Reporte reporte;

  const ReporteDetailPage({
    super.key,
    required this.reporte,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReporteBloc, ReporteState>(
      listener: (context, state) {
        if (state is ReporteUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Reporte actualizado'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is ReporteDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Reporte eliminado'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is ReporteError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle del Reporte'),
          backgroundColor: AppTheme.primary,
          actions: [
            // Botón editar (solo si es el dueño)
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  final isOwner = authState.user.id == reporte.usuarioId;
                  final isAdmin = authState.user.isAdministrador;

                  if (isOwner && !isAdmin) {
                    return IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditReportePage(reporte: reporte),
                          ),
                        );
                      },
                      tooltip: 'Editar',
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),

            // Menú de opciones
            _buildPopupMenu(context),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen
              if (reporte.hasImage)
                _buildImage()
              else
                _buildPlaceholderImage(),

              // Contenido
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      reporte.titulo,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Chips de información
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.flag,
                          label: reporte.estado.displayName,
                          color: _getEstadoColor(reporte.estado),
                        ),
                        _InfoChip(
                          icon: _getCategoriaIcon(reporte.categoria),
                          label: reporte.categoria.displayName,
                          color: AppTheme.getColorForCategoria(
                            reporte.categoria.toString(),
                          ),
                        ),
                        if (reporte.sensorValid)
                          const _InfoChip(
                            icon: Icons.verified,
                            label: 'Verificado',
                            color: AppTheme.success,
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Descripción
                    _buildSection(
                      'Descripción',
                      Icons.description,
                      reporte.descripcion,
                    ),

                    const SizedBox(height: 20),

                    // Ubicación
                    _buildSection(
                      'Ubicación',
                      Icons.location_on,
                      '${reporte.latitud.toStringAsFixed(6)}, ${reporte.longitud.toStringAsFixed(6)}',
                    ),

                    const SizedBox(height: 20),

                    // Fechas
                    _buildDateInfo(),

                    const SizedBox(height: 24),

                    // Botones de acción (Admin)
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        if (authState is AuthAuthenticated &&
                            authState.user.isAdministrador) {
                          return _buildAdminActions(context);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Imagen del reporte
  Widget _buildImage() {
    return Hero(
      tag: 'reporte-${reporte.id}',
      child: CachedNetworkImage(
        imageUrl: reporte.imagenUrl!,
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 300,
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 300,
          color: Colors.grey[300],
          child: const Icon(Icons.error, size: 50),
        ),
      ),
    );
  }

  /// Placeholder de imagen
  Widget _buildPlaceholderImage() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.getColorForCategoria(reporte.categoria.toString())
                .withOpacity(0.3),
            AppTheme.getColorForCategoria(reporte.categoria.toString())
                .withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _getCategoriaIcon(reporte.categoria),
          size: 80,
          color: AppTheme.getColorForCategoria(reporte.categoria.toString()),
        ),
      ),
    );
  }

  /// Sección de información
  Widget _buildSection(String title, IconData icon, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            color: AppTheme.textDark,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// Información de fechas
  Widget _buildDateInfo() {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: AppTheme.textGrey),
              const SizedBox(width: 8),
              const Text(
                'Creado:',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                dateFormat.format(reporte.createdAt),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.update, size: 16, color: AppTheme.textGrey),
              const SizedBox(width: 8),
              const Text(
                'Actualizado:',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                dateFormat.format(reporte.updatedAt),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Acciones del admin
  Widget _buildAdminActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 32),
        
        const Text(
          'Acciones de Administrador',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Cambiar a Pendiente
        if (!reporte.isPendiente)
          _ActionButton(
            icon: Icons.pending_actions,
            label: 'Marcar como Pendiente',
            color: AppTheme.pendiente,
            onPressed: () => _changeEstado(context, 'pendiente'),
          ),
        
        // Cambiar a En Proceso
        if (!reporte.isEnProceso)
          _ActionButton(
            icon: Icons.hourglass_empty,
            label: 'Marcar como En Proceso',
            color: AppTheme.enProceso,
            onPressed: () => _changeEstado(context, 'en_proceso'),
          ),
        
        // Cambiar a Resuelto
        if (!reporte.isResuelto)
          _ActionButton(
            icon: Icons.check_circle,
            label: 'Marcar como Resuelto',
            color: AppTheme.success,
            onPressed: () => _changeEstado(context, 'resuelto'),
          ),
      ],
    );
  }

  /// Menú popup
  Widget _buildPopupMenu(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }

        final isOwner = authState.user.id == reporte.usuarioId;
        final isAdmin = authState.user.isAdministrador;

        if (!isOwner && !isAdmin) {
          return const SizedBox.shrink();
        }

        return PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'delete':
                _confirmDelete(context);
                break;
            }
          },
          itemBuilder: (context) => [
            if (isOwner)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppTheme.error),
                    SizedBox(width: 8),
                    Text('Eliminar'),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  /// Cambiar estado
  void _changeEstado(BuildContext context, String estado) {
    context.read<ReporteBloc>().add(
          UpdateEstadoReporteEvent(
            id: reporte.id,
            estado: estado,
          ),
        );
  }

  /// Confirmar eliminación
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Reporte'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este reporte? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ReporteBloc>().add(DeleteReporteEvent(reporte.id));
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
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
}

/// Chip de información
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón de acción
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}