import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Maneja todo lo relacionado con GPS y permisos de ubicación
abstract class LocationDataSource {
  Future<Position?> getCurrentLocation();
  Future<bool> requestLocationPermissions();
  Future<bool> isLocationServiceEnabled();
  Stream<Position> get locationStream;
}

class LocationDataSourceImpl implements LocationDataSource {
  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<bool> requestLocationPermissions() async {
    try {
      // Verificar si el servicio está habilitado
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Servicio de ubicación deshabilitado');
        return false;
      }

      // Verificar permisos actuales
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Permisos de ubicación denegados');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Permisos de ubicación permanentemente denegados');
        // Abrir configuración de la app
        await openAppSettings();
        return false;
      }

      print('✅ Permisos de ubicación concedidos');
      return true;
    } catch (e) {
      print('❌ Error solicitando permisos de ubicación: $e');
      return false;
    }
  }

  @override
  Future<Position?> getCurrentLocation() async {
    try {
      // Verificar permisos
      final hasPermission = await requestLocationPermissions();
      if (!hasPermission) {
        return null;
      }

      // Obtener ubicación actual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print('📍 Ubicación obtenida: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error obteniendo ubicación: $e');
      return null;
    }
  }

  @override
  Stream<Position> get locationStream {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Actualizar cada 10 metros
      ),
    );
  }

  /// Calcular distancia entre dos puntos en metros
  static double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
  }

  /// Formatear distancia legible
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }
}