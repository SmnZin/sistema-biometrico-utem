// lib/services/simple_image_upload_service.dart

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'dart:convert';

/// Servicio simple para subir imágenes al servidor de Colab actual
/// Compatible con el endpoint /upload-image que creaste
class SimpleImageUploadService {
  // URL de tu servidor ngrok
  static const String baseUrl = 'url_de_tu_ngrok'; // Cambia esto por tu URL real
  static const String uploadEndpoint = '/upload-image';
  
  /// Sube imagen al servidor usando multipart/form-data
  /// 
  /// [capturedImage] - Imagen capturada por la cámara
  /// [isRegistration] - Si es registro o reconocimiento (para logging)
  /// 
  /// Retorna [ImageUploadResult] con el resultado
  static Future<ImageUploadResult> uploadImage({
    required XFile capturedImage,
    bool isRegistration = false,
  }) async {
    final uploadStopwatch = Stopwatch()..start();
    
    try {
      // 1. Verificar que el archivo existe y tiene contenido
      final fileSize = await capturedImage.length();
      if (fileSize == 0) {
        throw Exception('Archivo de imagen vacío');
      }
      
      // 2. Crear petición multipart
      final uri = Uri.parse('$baseUrl$uploadEndpoint');
      final request = http.MultipartRequest('POST', uri);
      
      // 3. Agregar headers necesarios para ngrok
      request.headers.addAll({
        'User-Agent': 'UTEM-Biometric-App/1.0',
        'ngrok-skip-browser-warning': 'true', // Para evitar página de advertencia de ngrok
      });
      
      // 4. Agregar archivo de imagen
      final multipartFile = await http.MultipartFile.fromPath(
        'image', // Nombre del campo que espera tu servidor
        capturedImage.path,
        filename: 'facial_capture_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(multipartFile);
      
      // 5. Agregar campos adicionales (opcional)
      request.fields['operation'] = isRegistration ? 'register' : 'recognize';
      request.fields['timestamp'] = DateTime.now().toIso8601String();
      request.fields['device'] = Platform.operatingSystem;
      
      // 6. Enviar petición
      print('📤 Enviando imagen al servidor: $uri');
      print('📏 Tamaño de archivo: ${_formatFileSize(fileSize)}');
      
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: El servidor no respondió en 30 segundos');
        },
      );
      
      // 7. Convertir respuesta
      final response = await http.Response.fromStream(streamedResponse);
      uploadStopwatch.stop();
      
      // 8. Procesar respuesta
      return _parseUploadResponse(
        response, 
        uploadStopwatch.elapsedMilliseconds,
        fileSize,
      );
      
    } on SocketException {
      uploadStopwatch.stop();
      return ImageUploadResult.error(
        'Sin conexión a internet. Verifica tu conectividad.',
        uploadStopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      uploadStopwatch.stop();
      return ImageUploadResult.error(
        'Error al subir imagen: $e',
        uploadStopwatch.elapsedMilliseconds,
      );
    }
  }
  
  /// Procesa la respuesta del servidor
  static ImageUploadResult _parseUploadResponse(
    http.Response response,
    int uploadTimeMs,
    int fileSize,
  ) {
    try {
      print('📥 Respuesta del servidor: ${response.statusCode}');
      print('📝 Body: ${response.body}');
      
      if (response.statusCode == 200) {
        // Parsear respuesta JSON
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['status'] == 'success') {
          return ImageUploadResult.success(
            message: jsonData['message'] ?? 'Imagen subida exitosamente',
            serverPath: jsonData['saved_path'],
            filename: jsonData['filename'],
            uploadTimeMs: uploadTimeMs,
            fileSizeBytes: fileSize,
          );
        } else {
          return ImageUploadResult.error(
            jsonData['message'] ?? 'Error desconocido del servidor',
            uploadTimeMs,
          );
        }
      } else {
        return ImageUploadResult.error(
          'Error del servidor: ${response.statusCode}',
          uploadTimeMs,
        );
      }
    } catch (e) {
      return ImageUploadResult.error(
        'Error al procesar respuesta: $e',
        uploadTimeMs,
      );
    }
  }
  
  /// Verifica si el servidor está disponible
  static Future<bool> isServerAvailable() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'ngrok-skip-browser-warning': 'true'},
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Servidor no disponible: $e');
      return false;
    }
  }
  
  /// Formatea el tamaño de archivo para mostrar
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

// ==================== MODELO DE RESULTADO ====================

/// Resultado de la subida de imagen
class ImageUploadResult {
  final bool success;
  final String message;
  final String? serverPath;
  final String? filename;
  final int uploadTimeMs;
  final int? fileSizeBytes;
  final String? errorDetails;

  ImageUploadResult._({
    required this.success,
    required this.message,
    this.serverPath,
    this.filename,
    required this.uploadTimeMs,
    this.fileSizeBytes,
    this.errorDetails,
  });

  /// Constructor para casos exitosos
  factory ImageUploadResult.success({
    required String message,
    String? serverPath,
    String? filename,
    required int uploadTimeMs,
    required int fileSizeBytes,
  }) {
    return ImageUploadResult._(
      success: true,
      message: message,
      serverPath: serverPath,
      filename: filename,
      uploadTimeMs: uploadTimeMs,
      fileSizeBytes: fileSizeBytes,
    );
  }

  /// Constructor para errores
  factory ImageUploadResult.error(
    String errorMessage,
    int uploadTimeMs,
  ) {
    return ImageUploadResult._(
      success: false,
      message: errorMessage,
      uploadTimeMs: uploadTimeMs,
      errorDetails: errorMessage,
    );
  }

  /// Información de rendimiento para mostrar al usuario
  String get performanceInfo {
    final fileSize = fileSizeBytes != null 
        ? SimpleImageUploadService._formatFileSize(fileSizeBytes!)
        : 'N/A';
    return 'Tiempo: ${uploadTimeMs}ms | Tamaño: $fileSize';
  }

  /// Para logging y debugging
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'server_path': serverPath,
      'filename': filename,
      'upload_time_ms': uploadTimeMs,
      'file_size_bytes': fileSizeBytes,
      'error_details': errorDetails,
    };
  }
}