import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../widgets/sensor_validation_widget.dart';
import '../widgets/location_selector_widget.dart';
import '../../domain/entities/reporte.dart';
import '../bloc/reporte_bloc.dart';
import '../bloc/reporte_event.dart';
import '../bloc/reporte_state.dart';

/// Página para crear un nuevo reporte
/// 
/// Requiere validación por sensor antes de permitir tomar foto
class CreateReportePage extends StatefulWidget {
  const CreateReportePage({super.key});

  @override
  State<CreateReportePage> createState() => _CreateReportePageState();
}

class _CreateReportePageState extends State<CreateReportePage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  CategoriaReporte _selectedCategoria = CategoriaReporte.baches;
  File? _imageFile;
  Position? _currentPosition;
  bool _isCameraEnabled = false;
  bool _isLoadingLocation = false;
  bool _sensorValidated = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  /// Obtener ubicación actual
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permisos de ubicación permanentemente denegados');
      }

      // Obtener posición
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      print('📍 Ubicación obtenida: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      
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

  /// Abrir selector de ubicación en el mapa
  Future<void> _openLocationSelector() async {
    final selectedLocation = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSelectorWidget(
          initialPosition: _currentPosition != null
              ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
              : null,
          onLocationSelected: (location) {
            // La ubicación se actualiza cuando se cierra el selector
          },
        ),
      ),
    );

    if (selectedLocation != null) {
      // Crear un objeto Position desde LatLng
      setState(() {
        _currentPosition = Position(
          latitude: selectedLocation.latitude,
          longitude: selectedLocation.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Ubicación seleccionada en el mapa'),
          backgroundColor: AppTheme.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Callback cuando el sensor valida el movimiento
  void _onSensorValidated() {
    setState(() {
      _isCameraEnabled = true;
      _sensorValidated = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Sensor validado - Cámara habilitada'),
        backgroundColor: AppTheme.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Tomar foto con la cámara
  Future<void> _takePhoto() async {
    if (!_isCameraEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero debes validar el sensor moviendo el dispositivo'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });
        
        print('📸 Foto capturada: ${photo.path}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar foto: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  /// Validar y crear reporte
  Future<void> _createReporte() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esperando ubicación GPS...'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes tomar una foto del reporte'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    if (!_sensorValidated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes validar el sensor antes de crear el reporte'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    // Crear reporte usando el Bloc
    context.read<ReporteBloc>().add(
          CreateReporteEvent(
            titulo: _tituloController.text.trim(),
            descripcion: _descripcionController.text.trim(),
            categoria: _selectedCategoria.toString(),
            latitud: _currentPosition!.latitude,
            longitud: _currentPosition!.longitude,
            sensorValid: _sensorValidated,
            imagenPath: _imageFile!.path,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReporteBloc, ReporteState>(
      listener: (context, state) {
        if (state is ReporteCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Reporte creado exitosamente'),
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
          title: const Text('Crear Reporte'),
          backgroundColor: AppTheme.primary,
        ),
        body: BlocBuilder<ReporteBloc, ReporteState>(
          builder: (context, state) {
            final isLoading = state is ReporteLoading;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
              // Validación por sensor
              SensorValidationWidget(
                onCameraEnabled: _onSensorValidated,
                enabled: true,
              ),

              const SizedBox(height: 24),

              // Título
              CustomTextField(
                controller: _tituloController,
                label: 'Título del reporte',
                hintText: 'Ej: Bache en Av. Principal',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El título es requerido';
                  }
                  if (value.trim().length < 5) {
                    return 'El título debe tener al menos 5 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Descripción
              CustomTextField(
                controller: _descripcionController,
                label: 'Descripción',
                hintText: 'Describe el problema en detalle',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La descripción es requerida';
                  }
                  if (value.trim().length < 10) {
                    return 'La descripción debe tener al menos 10 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Categoría
              DropdownButtonFormField<CategoriaReporte>(
                value: _selectedCategoria,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: CategoriaReporte.values.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Row(
                      children: [
                        Icon(
                          _getCategoriaIcon(categoria),
                          color: AppTheme.getColorForCategoria(categoria.toString()),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(categoria.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategoria = value);
                  }
                },
              ),

              const SizedBox(height: 24),

              // Ubicación GPS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isLoadingLocation
                              ? Icons.location_searching
                              : Icons.location_on,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ubicación GPS',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isLoadingLocation
                                    ? 'Obteniendo ubicación...'
                                    : _currentPosition != null
                                        ? '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}'
                                        : 'Ubicación no disponible',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!_isLoadingLocation && _currentPosition == null)
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _getCurrentLocation,
                            color: Colors.blue[700],
                          ),
                      ],
                    ),
                    
                    // Botón para seleccionar en mapa
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openLocationSelector,
                        icon: Icon(Icons.map, size: 18, color: Colors.blue[700]),
                        label: Text(
                          'Seleccionar en Mapa',
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue[300]!),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botón de cámara
              CustomButton(
                onPressed: _isCameraEnabled ? _takePhoto : null,
                text: _imageFile == null ? 'Tomar Foto' : 'Cambiar Foto',
                icon: Icons.camera_alt,
                backgroundColor: _isCameraEnabled
                    ? AppTheme.primary
                    : Colors.grey[400]!,
              ),

              if (!_isCameraEnabled) ...[
                const SizedBox(height: 8),
                Text(
                  '⚠️ Mueve el dispositivo para habilitar la cámara',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.warning,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Preview de la imagen
              if (_imageFile != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _imageFile!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Botón crear reporte
              CustomButton(
                onPressed: isLoading ? null : _createReporte,
                text: 'Crear Reporte',
                icon: Icons.send,
                backgroundColor: AppTheme.success,
              ),
            ],
          ),
        ),
      ),

                // Loading overlay
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
              ],
            );
          },
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
        return Icons.more_horiz;
    }
  }
}