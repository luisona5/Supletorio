import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// DataSource del Acelerómetro
/// 
/// Detecta movimiento del dispositivo para validar que el usuario
/// está físicamente presente tomando la foto
abstract class SensorDataSource {
  Stream<bool> get validationStream;
  bool get isMovementDetected;
  void startListening();
  void stopListening();
  void reset();
  Future<bool> requestPermissions();
}

class SensorDataSourceImpl implements SensorDataSource {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final StreamController<bool> _validationController = 
      StreamController<bool>.broadcast();
  
  bool _isMovementDetected = false;
  double _lastMagnitude = 9.8; // Gravedad estándar
  int _movementCount = 0;
  static const int _requiredMovements = 3; // Necesita 3 movimientos para validar
  static const double _movementThreshold = 10.5; // m/s²
  static const double _stillThreshold = 9.5; // m/s²

  @override
  Stream<bool> get validationStream => _validationController.stream;

  @override
  bool get isMovementDetected => _isMovementDetected;

  @override
  Future<bool> requestPermissions() async {
    try {
      // En Android 13+ se requiere permiso de sensores corporales
      final status = await Permission.sensors.request();
      
      if (status.isGranted) {
        print('✅ Permisos de sensores concedidos');
        return true;
      } else if (status.isPermanentlyDenied) {
        print('❌ Permisos de sensores permanentemente denegados');
        await openAppSettings();
        return false;
      } else {
        print('⚠️ Permisos de sensores denegados');
        return false;
      }
    } catch (e) {
      print('❌ Error solicitando permisos: $e');
      // En versiones antiguas de Android no se necesita permiso
      return true;
    }
  }

  @override
  void startListening() {
    print('🎯 Iniciando escucha del acelerómetro...');
    
    _accelerometerSubscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.normalInterval, // ~200ms
    ).listen(
      _processAccelerometerEvent,
      onError: (error) {
        print('❌ Error en acelerómetro: $error');
      },
    );
  }

  @override
  void stopListening() {
    print('🛑 Deteniendo escucha del acelerómetro');
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }

  @override
  void reset() {
    print('🔄 Reiniciando validación de sensor');
    _isMovementDetected = false;
    _movementCount = 0;
    _validationController.add(false);
  }

  /// Procesar evento del acelerómetro
  void _processAccelerometerEvent(AccelerometerEvent event) {
    // Calcular magnitud del vector de aceleración
    final magnitude = sqrt(
      event.x * event.x + 
      event.y * event.y + 
      event.z * event.z
    );

    // Detectar cambio significativo (movimiento o inclinación)
    final isMoving = magnitude > _movementThreshold || magnitude < _stillThreshold;
    
    if (isMoving && !_isMovementDetected) {
      _movementCount++;
      
      print('📱 Movimiento detectado $_movementCount/$_requiredMovements - Magnitud: ${magnitude.toStringAsFixed(2)} m/s²');
      
      // Validar después de detectar suficientes movimientos
      if (_movementCount >= _requiredMovements) {
        _isMovementDetected = true;
        _validationController.add(true);
        print('✅ Sensor validado - Cámara habilitada');
      }
    }

    _lastMagnitude = magnitude;
  }

  /// Cerrar recursos
  void dispose() {
    stopListening();
    _validationController.close();
  }
}