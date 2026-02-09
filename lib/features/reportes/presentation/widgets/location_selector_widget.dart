import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';

/// Widget Selector de Ubicación
/// 
/// Permite al usuario seleccionar una ubicación en el mapa
class LocationSelectorWidget extends StatefulWidget {
  final LatLng? initialPosition;
  final Function(LatLng) onLocationSelected;

  const LocationSelectorWidget({
    super.key,
    this.initialPosition,
    required this.onLocationSelected,
  });

  @override
  State<LocationSelectorWidget> createState() => _LocationSelectorWidgetState();
}

class _LocationSelectorWidgetState extends State<LocationSelectorWidget> {
  final MapController _mapController = MapController();
  late LatLng _selectedPosition;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition ?? 
        const LatLng(-0.1807, -78.4678); // Centro de Quito por defecto
    
    if (widget.initialPosition == null) {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Obtener ubicación actual
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        throw Exception('Permisos de ubicación denegados');
      }

      // Obtener posición
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _selectedPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Centrar el mapa
      _mapController.move(_selectedPosition, 15.0);
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error obteniendo ubicación: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  /// Actualizar posición seleccionada
  void _onMapTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
  }

  /// Confirmar selección
  void _confirmLocation() {
    widget.onLocationSelected(_selectedPosition);
    Navigator.of(context).pop(_selectedPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        backgroundColor: AppTheme.primary,
        actions: [
          // Botón de ubicación actual
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _isLoading ? null : _getCurrentLocation,
            tooltip: 'Mi ubicación',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mapa
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPosition,
              initialZoom: 15.0,
              minZoom: 10.0,
              maxZoom: 18.0,
              onTap: _onMapTap,
            ),
            children: [
              // Capa de tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.quito.elveci_reporta',
                maxNativeZoom: 19,
                maxZoom: 19,
              ),

              // Marcador de ubicación seleccionada
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPosition,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_on,
                      color: AppTheme.error,
                      size: 50,
                    ),
                  ),
                ],
              ),

              // Círculo de precisión
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _selectedPosition,
                    radius: 50, // 50 metros de radio
                    color: AppTheme.primary.withOpacity(0.1),
                    borderColor: AppTheme.primary,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
            ],
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),

          // Instrucciones
          Positioned(
            top: 16,
            left: 16,
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
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Toca en el mapa para seleccionar la ubicación exacta',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Panel de información
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Coordenadas
                  Row(
                    children: [
                      Icon(Icons.pin_drop, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ubicación seleccionada',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textGrey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_selectedPosition.latitude.toStringAsFixed(6)}, ${_selectedPosition.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Botón confirmar
                  CustomButton(
                    onPressed: _confirmLocation,
                    text: 'Confirmar Ubicación',
                    icon: Icons.check_circle,
                    backgroundColor: AppTheme.success,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}