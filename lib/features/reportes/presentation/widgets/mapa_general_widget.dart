import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/reporte.dart';

/// Widget de Mapa General
/// 
/// Muestra un mapa con todos los reportes como marcadores
class MapaGeneralWidget extends StatefulWidget {
  final List<Reporte> reportes;
  final LatLng? centerPosition;
  final double initialZoom;
  final Function(Reporte)? onMarkerTap;

  const MapaGeneralWidget({
    super.key,
    required this.reportes,
    this.centerPosition,
    this.initialZoom = 13.0,
    this.onMarkerTap,
  });

  @override
  State<MapaGeneralWidget> createState() => _MapaGeneralWidgetState();
}

class _MapaGeneralWidgetState extends State<MapaGeneralWidget> {
  final MapController _mapController = MapController();
  Reporte? _selectedReporte;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Obtener centro del mapa
  LatLng get _center {
    if (widget.centerPosition != null) {
      return widget.centerPosition!;
    }

    // Si hay reportes, centrar en el primero
    if (widget.reportes.isNotEmpty) {
      final first = widget.reportes.first;
      return LatLng(first.latitud, first.longitud);
    }

    // Por defecto: Centro de Quito
    return const LatLng(-0.1807, -78.4678);
  }

  /// Construir marcadores
  List<Marker> get _markers {
    return widget.reportes.map((reporte) {
      return Marker(
        point: LatLng(reporte.latitud, reporte.longitud),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () {
            setState(() => _selectedReporte = reporte);
            widget.onMarkerTap?.call(reporte);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Círculo de fondo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getEstadoColor(reporte.estado).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getEstadoColor(reporte.estado),
                    width: 3,
                  ),
                ),
              ),
              // Icono
              Icon(
                _getCategoriaIcon(reporte.categoria),
                color: _getEstadoColor(reporte.estado),
                size: 24,
              ),
              // Badge de estado
              if (_selectedReporte?.id == reporte.id)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Mapa
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _center,
            initialZoom: widget.initialZoom,
            minZoom: 10.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(
              enableMultiFingerGestureRace: true,
            ),
          ),
          children: [
            // Capa de tiles (OpenStreetMap)
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.quito.elveci_reporta',
              maxNativeZoom: 19,
              maxZoom: 19,
            ),

            // Capa de marcadores
            MarkerLayer(markers: _markers),
          ],
        ),

        // Leyenda de estados
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Estados',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _LegendItem(
                  color: AppTheme.pendiente,
                  label: 'Pendiente',
                ),
                _LegendItem(
                  color: AppTheme.enProceso,
                  label: 'En Proceso',
                ),
                _LegendItem(
                  color: AppTheme.resuelto,
                  label: 'Resuelto',
                ),
              ],
            ),
          ),
        ),

        // Contador de reportes
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${widget.reportes.length} reportes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Popup de información
        if (_selectedReporte != null)
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: _ReportePopup(
              reporte: _selectedReporte!,
              onClose: () => setState(() => _selectedReporte = null),
            ),
          ),
      ],
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

/// Item de leyenda
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// Popup de información del reporte
class _ReportePopup extends StatelessWidget {
  final Reporte reporte;
  final VoidCallback onClose;

  const _ReportePopup({
    required this.reporte,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  _getCategoriaIcon(reporte.categoria),
                  color: _getEstadoColor(reporte.estado),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reporte.titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Descripción
            Text(
              reporte.descripcion,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textGrey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Chips de info
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.category,
                  label: reporte.categoria.displayName,
                  color: AppTheme.getColorForCategoria(
                    reporte.categoria.toString(),
                  ),
                ),
                _InfoChip(
                  icon: Icons.flag,
                  label: reporte.estado.displayName,
                  color: _getEstadoColor(reporte.estado),
                ),
                if (reporte.sensorValid)
                  const _InfoChip(
                    icon: Icons.verified,
                    label: 'Verificado',
                    color: AppTheme.success,
                  ),
              ],
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}