import '../constants/app_constants.dart';

/// Validadores de formularios
class Validators {
  /// Validar email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    
    return null;
  }
  
  /// Validar contraseña
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
    }
    
    return null;
  }
  
  /// Validar nombre completo
  static String? fullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    
    if (value.trim().split(' ').length < 2) {
      return 'Ingresa tu nombre completo';
    }
    
    return null;
  }
  
  /// Validar campo requerido
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    return null;
  }
  
  /// Validar longitud mínima
  static String? minLength(String? value, int min, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    
    if (value.length < min) {
      return '${fieldName ?? 'Este campo'} debe tener al menos $min caracteres';
    }
    
    return null;
  }
  
  /// Validar título de reporte
  static String? reportTitle(String? value) {
    return minLength(value, 5, 'El título');
  }
  
  /// Validar descripción de reporte
  static String? reportDescription(String? value) {
    return minLength(value, 10, 'La descripción');
  }
}