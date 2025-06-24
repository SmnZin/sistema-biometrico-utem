// lib/services/fingerprint_recognition_service.dart

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'dart:convert';

/// Servicio especializado para reconocimiento de huellas dactilares
/// Compatible con el servidor de Google Colab que creamos
class FingerprintRecognitionService {
  // URL de tu servidor ngrok - ACTUALIZA ESTA URL
  static const String baseUrl = 'url_de_tu_ngrok'; // Cambia esto por tu URL real
  static const String fingerprintEndpoint = '/upload-fingerprint';
  static const String healthEndpoint = '/health';
  static const String statsEndpoint = '/stats';
  
  /// Reconoce una huella dactilar enviándola al servidor
  /// 
  /// [capturedImage] - Imagen capturada por la cámara
  /// [isRegistration] - Si es registro o reconocimiento
  /// 
  /// Retorna [FingerprintResult] con el resultado
  static Future<FingerprintResult> recognizeFingerprint({
    required XFile capturedImage,
    bool isRegistration = false,
  }) async {
    final uploadStopwatch = Stopwatch()..start();
    
    try {
      print('🔍 Iniciando reconocimiento de huella dactilar...');
      
      // 1. Verificar que el archivo existe y tiene contenido
      final fileSize = await capturedImage.length();
      if (fileSize == 0) {
        throw Exception('Archivo de imagen vacío');
      }
      
      print('📏 Tamaño de archivo: ${_formatFileSize(fileSize)}');
      
      // 2. Crear petición multipart
      final uri = Uri.parse('$baseUrl$fingerprintEndpoint');
      final request = http.MultipartRequest('POST', uri);
      
      // 3. Agregar headers necesarios para ngrok
      request.headers.addAll({
        'User-Agent': 'UTEM-Biometric-App/1.0',
        'ngrok-skip-browser-warning': 'true',
        'Accept': 'application/json',
      });
      
      // 4. Agregar archivo de imagen
      final multipartFile = await http.MultipartFile.fromPath(
        'image', // Nombre del campo que espera el servidor
        capturedImage.path,
        filename: 'fingerprint_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(multipartFile);
      
      // 5. Agregar campos adicionales que espera el servidor
      request.fields['operation'] = isRegistration ? 'register' : 'recognize';
      request.fields['timestamp'] = DateTime.now().toIso8601String();
      request.fields['device'] = Platform.operatingSystem;
      request.fields['image_type'] = 'huella';
      
      // 6. Enviar petición
      print('📤 Enviando imagen al servidor: $uri');
      
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: El servidor no respondió en 30 segundos');
        },
      );
      
      // 7. Convertir respuesta
      final response = await http.Response.fromStream(streamedResponse);
      uploadStopwatch.stop();
      
      // 8. Procesar respuesta del servidor
      return _parseServerResponse(
        response, 
        uploadStopwatch.elapsedMilliseconds,
        fileSize,
      );
      
    } on SocketException {
      uploadStopwatch.stop();
      return FingerprintResult.error(
        'Sin conexión a internet. Verifica tu conectividad.',
        uploadStopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      uploadStopwatch.stop();
      return FingerprintResult.error(
        'Error al procesar huella dactilar: $e',
        uploadStopwatch.elapsedMilliseconds,
      );
    }
  }
  
  /// Procesa la respuesta JSON del servidor de huellas
  static FingerprintResult _parseServerResponse(
    http.Response response,
    int uploadTimeMs,
    int fileSize,
  ) {
    try {
      print('📥 Respuesta del servidor: ${response.statusCode}');
      print('📝 Body: ${response.body}');
      
      if (response.statusCode == 200) {
        // Parsear respuesta JSON del servidor
        final jsonData = jsonDecode(response.body);
        
        // El servidor devuelve un JSON con esta estructura:
        // {
        //   "success": true,
        //   "recognized": true/false,
        //   "person": "nombre_persona" o null,
        //   "confidence": 85.2,
        //   "distance": 0.147,
        //   "message": "mensaje descriptivo",
        //   "timestamp": "ISO_timestamp"
        // }
        
        if (jsonData['success'] == true) {
          return FingerprintResult.success(
            recognized: jsonData['recognized'] ?? false,
            personName: jsonData['person'],
            confidence: (jsonData['confidence'] ?? 0.0).toDouble(),
            distance: (jsonData['distance'] ?? 1.0).toDouble(),
            message: jsonData['message'] ?? 'Procesamiento completado',
            uploadTimeMs: uploadTimeMs,
            fileSizeBytes: fileSize,
            serverTimestamp: jsonData['timestamp'],
            details: jsonData['details'],
          );
        } else {
          return FingerprintResult.error(
            jsonData['message'] ?? 'Error desconocido del servidor',
            uploadTimeMs,
          );
        }
      } else {
        return FingerprintResult.error(
          'Error del servidor: ${response.statusCode} - ${response.body}',
          uploadTimeMs,
        );
      }
    } catch (e) {
      return FingerprintResult.error(
        'Error al procesar respuesta del servidor: $e',
        uploadTimeMs,
      );
    }
  }
  
  /// Verifica si el servidor de huellas está disponible
  static Future<bool> isServerAvailable() async {
    try {
      print('🔍 Verificando disponibilidad del servidor...');
      
      final response = await http.get(
        Uri.parse('$baseUrl$healthEndpoint'),
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'UTEM-Biometric-App/1.0',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final isHealthy = jsonData['status'] == 'healthy';
        
        print(isHealthy ? '✅ Servidor disponible' : '⚠️ Servidor con problemas');
        return isHealthy;
      } else {
        print('❌ Servidor responde con error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Servidor no accesible: $e');
      return false;
    }
  }
  
  /// Obtiene estadísticas del servidor
  static Future<ServerStats?> getServerStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$statsEndpoint'),
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'UTEM-Biometric-App/1.0',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ServerStats.fromJson(jsonData);
      }
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
    }
    return null;
  }
  
  /// Formatea el tamaño de archivo para mostrar
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

// ==================== MODELOS DE DATOS ====================

/// Resultado del reconocimiento de huella dactilar
class FingerprintResult {
  final bool success;
  final bool recognized;
  final String? personName;
  final double confidence;
  final double distance;
  final String message;
  final int uploadTimeMs;
  final int? fileSizeBytes;
  final String? serverTimestamp;
  final Map<String, dynamic>? details;
  final String? errorDetails;

  FingerprintResult._({
    required this.success,
    required this.recognized,
    this.personName,
    required this.confidence,
    required this.distance,
    required this.message,
    required this.uploadTimeMs,
    this.fileSizeBytes,
    this.serverTimestamp,
    this.details,
    this.errorDetails,
  });

  factory FingerprintResult.success({
    required bool recognized,
    String? personName,
    required double confidence,
    required double distance,
    required String message,
    required int uploadTimeMs,
    required int fileSizeBytes,
    String? serverTimestamp,
    Map<String, dynamic>? details,
  }) {
    return FingerprintResult._(
      success: true,
      recognized: recognized,
      personName: personName,
      confidence: confidence,
      distance: distance,
      message: message,
      uploadTimeMs: uploadTimeMs,
      fileSizeBytes: fileSizeBytes,
      serverTimestamp: serverTimestamp,
      details: details,
    );
  }

  factory FingerprintResult.error(
    String errorMessage,
    int uploadTimeMs,
  ) {
    return FingerprintResult._(
      success: false,
      recognized: false,
      confidence: 0.0,
      distance: 1.0,
      message: errorMessage,
      uploadTimeMs: uploadTimeMs,
      errorDetails: errorMessage,
    );
  }

  /// Información de rendimiento para debugging
  String get performanceInfo {
    final fileSize = fileSizeBytes != null
        ? FingerprintRecognitionService._formatFileSize(fileSizeBytes!)
        : 'N/A';
    return 'Tiempo: ${uploadTimeMs}ms | Tamaño: $fileSize | Confianza: ${confidence.toStringAsFixed(1)}%';
  }
  
  /// Determina si el acceso debe ser autorizado
  bool get shouldGrantAccess => success && recognized && confidence > 50.0;
  
  /// Mensaje para mostrar al usuario
  String get userMessage {
    if (!success) {
      return 'Error en el sistema. Inténtalo de nuevo.';
    }
    
    if (recognized && personName != null) {
      return '✅ Bienvenido/a, $personName';
    } else {
      return '❌ Huella no reconocida. Acceso denegado.';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'recognized': recognized,
      'person_name': personName,
      'confidence': confidence,
      'distance': distance,
      'message': message,
      'upload_time_ms': uploadTimeMs,
      'file_size_bytes': fileSizeBytes,
      'server_timestamp': serverTimestamp,
      'details': details,
      'error_details': errorDetails,
    };
  }
}

/// Estadísticas del servidor
class ServerStats {
  final int totalRequests;
  final int successfulVerifications;
  final int failedVerifications;
  final String? lastRequestTime;
  final int totalPersons;
  final List<String> registeredPersons;

  ServerStats({
    required this.totalRequests,
    required this.successfulVerifications,
    required this.failedVerifications,
    this.lastRequestTime,
    required this.totalPersons,
    required this.registeredPersons,
  });

  factory ServerStats.fromJson(Map<String, dynamic> json) {
    final stats = json['statistics'] ?? {};
    final gallery = json['gallery_info'] ?? {};
    
    return ServerStats(
      totalRequests: stats['total_requests'] ?? 0,
      successfulVerifications: stats['successful_verifications'] ?? 0,
      failedVerifications: stats['failed_verifications'] ?? 0,
      lastRequestTime: stats['last_request_time'],
      totalPersons: gallery['total_persons'] ?? 0,
      registeredPersons: List<String>.from(gallery['registered_persons'] ?? []),
    );
  }

  double get successRate {
    if (totalRequests == 0) return 0.0;
    return (successfulVerifications / totalRequests) * 100;
  }
}