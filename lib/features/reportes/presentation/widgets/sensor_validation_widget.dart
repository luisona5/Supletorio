import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/theme/app_theme.dart';
import '../../data/datasources/sensor_datasource.dart';

/// Widget de validación por sensor
/// 
/// Muestra el estado del acelerómetro y habilita la cámara
/// cuando detecta movimiento del dispositivo
class SensorValidationWidget extends StatefulWidget {
  final VoidCallback onCameraEnabled;
  final bool enabled;

  const SensorValidationWidget({
    super.key,
    required this.onCameraEnabled,
    this.enabled = true,
  });

  @override
  State<SensorValidationWidget> createState() => _SensorValidationWidgetState();
}

class _SensorValidationWidgetState extends State<SensorValidationWidget>
    with SingleTickerProviderStateMixin {
  final SensorDataSource _sensorDataSource = SensorDataSourceImpl();
  StreamSubscription<bool>? _subscription;
  bool _isValidated = false;
  bool _isListening = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    if (widget.enabled) {
      _startSensorValidation();
    }
  }

  void _setupAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _sensorDataSource.stopListening();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startSensorValidation() async {
    if (_isListening) return;

    // Solicitar permisos
    final hasPermission = await _sensorDataSource.requestPermissions();
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permisos de sensores denegados'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    // Iniciar escucha
    _sensorDataSource.startListening();
    setState(() => _isListening = true);

    // Suscribirse al stream de validación
    _subscription = _sensorDataSource.validationStream.listen((isValid) {
      if (isValid && !_isValidated) {
        setState(() => _isValidated = true);
        _pulseController.stop();
        widget.onCameraEnabled();

        // Vibración de feedback (opcional)
        // HapticFeedback.mediumImpact();
      }
    });
  }

  void _resetValidation() {
    _sensorDataSource.reset();
    setState(() {
      _isValidated = false;
    });
    _pulseController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isValidated
            ? AppTheme.success.withOpacity(0.1)
            : AppTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isValidated
              ? AppTheme.success
              : AppTheme.warning,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icono animado
              if (!_isValidated)
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: const Icon(
                    Icons.smartphone,
                    color: AppTheme.warning,
                    size: 32,
                  ),
                )
              else
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.success,
                  size: 32,
                ),

              const SizedBox(width: 12),

              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isValidated
                          ? '✓ Sensor Validado'
                          : 'Validación por Sensor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isValidated
                            ? AppTheme.success
                            : AppTheme.warning,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isValidated
                          ? 'Cámara habilitada - Puedes tomar la foto'
                          : 'Mueve el dispositivo para habilitar la cámara',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),

              // Botón reset
              if (_isValidated)
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _resetValidation,
                  tooltip: 'Reiniciar validación',
                  color: AppTheme.textGrey,
                ),
            ],
          ),

          // Indicador de progreso
          if (!_isValidated) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                backgroundColor: AppTheme.warning.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.warning,
                ),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}