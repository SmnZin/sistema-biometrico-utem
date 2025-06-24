import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../config/routes.dart';
import '../services/simple_image_upload_service.dart';

class FingerprintImageCaptureScreen extends StatefulWidget {
  final bool isRegistration;
  
  const FingerprintImageCaptureScreen({
    super.key,
    this.isRegistration = false,
  });

  @override
  State<FingerprintImageCaptureScreen> createState() => _FingerprintImageCaptureScreenState();
}

class _FingerprintImageCaptureScreenState extends State<FingerprintImageCaptureScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  String _instructions = "Coloca una imagen de tu huella dactilar en el centro del círculo";
  

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }


  Future<void> _initializeCamera() async {
    // Solicitar permisos
    final cameraPermission = await Permission.camera.request();
    if (cameraPermission != PermissionStatus.granted) {
      _showPermissionDialog();
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        _showErrorDialog('No se encontraron cámaras disponibles');
        return;
      }

      // Usar cámara trasera para mejor calidad de captura
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      _showErrorDialog('Error al inicializar la cámara: $e');
    }
  }


  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isCapturing = true;
      _instructions = "Capturando imagen...";
    });

    try {
      // 1. Capturar imagen
      final image = await _cameraController!.takePicture();
      
      setState(() {
        _instructions = "Verificando servidor...";
      });
      
      // 2. Verificar que el servidor esté disponible
      final serverAvailable = await SimpleImageUploadService.isServerAvailable();
      if (!serverAvailable) {
        throw Exception('Servidor de Colab no disponible. Verifica la URL: ${SimpleImageUploadService.baseUrl}');
      }
      
      setState(() {
        _instructions = "Enviando imagen al servidor...";
      });
      
      // 3. Subir imagen al servidor
      final uploadResult = await SimpleImageUploadService.uploadImage(
        capturedImage: image,
        imageType: 'huella',
        isRegistration: widget.isRegistration,
      );
      
      // 4. Procesar resultado
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
        
        if (uploadResult.success) {
          // ✅ Imagen subida exitosamente
          _showSuccessDialog(uploadResult);
          
          // Simular reconocimiento exitoso (hasta que tengas el modelo de IA)
          context.goToAccessGranted(
            userName: widget.isRegistration ? 'Usuario Registrado' : 'Usuario Reconocido',
            method: 'Huella Dactilar (Servidor Colab)',
            confidence: 92.0, // Simulado por ahora
          );
        } else {
          // ❌ Error al subir imagen
          _showErrorDialog(uploadResult.message);
        }
      }
      
    } catch (e) {
      setState(() {
        _isCapturing = false;
        _instructions = "Error. Inténtalo de nuevo";
      });
      
      _showErrorDialog('Error: ${e.toString()}');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permiso Requerido'),
        content: const Text(
          'La aplicación necesita acceso a la cámara para capturar la huella dactilar.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.goBack();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Configuración'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(ImageUploadResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Imagen Enviada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ ${result.message}'),
            const SizedBox(height: 8),
            if (result.filename != null) 
              Text('📁 Archivo: ${result.filename}', 
                   style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('⏱️ ${result.performanceInfo}', 
                 style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.goBack();
            },
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          widget.isRegistration ? 'Registro de Huella' : 'Captura de Huella',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goBack(),
        ),
      ),
      body: _isCameraInitialized ? _buildCameraView() : _buildLoadingView(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Inicializando cámara...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        // Vista de la cámara
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),
        
        // Overlay con marco de detección
        Positioned.fill(
          child: _buildFingerprintDetectionOverlay(),
        ),
        
        // Panel inferior con controles
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildControlPanel(),
        ),
      ],
    );
  }

  Widget _buildFingerprintDetectionOverlay() {
    return CustomPaint(
      painter: FingerprintDetectionPainter(),
      child: Container(),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Instrucciones
          Text(
            _instructions,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Botones de control
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón cancelar
              _buildControlButton(
                icon: Icons.close,
                label: 'Cancelar',
                onTap: () => context.goBack(),
                color: Colors.red,
              ),
              
              // Botón capturar
              _buildCaptureButton(),
              
              // Botón información
              _buildControlButton(
                icon: Icons.info_outline,
                label: 'Ayuda',
                onTap: _showHelpDialog,
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _isCapturing ? null : _captureImage,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isCapturing 
              ? Colors.grey 
              : Colors.green,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: _isCapturing
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              )
            : const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 32,
              ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Consejos para mejor captura'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Asegúrate de tener buena iluminación'),
            Text('• Coloca el dedo completamente sobre el círculo'),
            Text('• Mantén el dedo quieto durante la captura'),
            Text('• Usa el dedo índice para mejores resultados'),
            Text('• Limpia el dedo si está húmedo o sucio'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

// Custom Painter para el overlay de guía de huella
class FingerprintDetectionPainter extends CustomPainter {
  FingerprintDetectionPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2 - 50;
    final radius = 80.0;

    // Marco circular para el dedo
    final framePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Dibujar círculo principal
    canvas.drawCircle(
      Offset(centerX, centerY),
      radius,
      framePaint,
    );

    // Círculo interior más pequeño
    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      Offset(centerX, centerY),
      radius * 0.7,
      innerPaint,
    );

    // Marcadores en el círculo
    final markerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Dibujar 8 marcadores alrededor del círculo
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180);
      final startRadius = radius + 10;
      final endRadius = radius + 25;
      
      final startX = centerX + startRadius * math.cos(angle);
      final startY = centerY + startRadius * math.sin(angle);
      final endX = centerX + endRadius * math.cos(angle);
      final endY = centerY + endRadius * math.sin(angle);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        markerPaint,
      );
    }

    // Icono de huella en el centro
    final iconPaint = Paint()
      ..color = Colors.white.withOpacity(0.6);
    
    _drawFingerprintIcon(canvas, Offset(centerX, centerY), 30, iconPaint);
  }

  void _drawFingerprintIcon(Canvas canvas, Offset center, double size, Paint paint) {
    // Dibujar líneas de huella dactilar simplificadas
    final linePaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Líneas curvas que simulan una huella
    for (int i = 0; i < 5; i++) {
      final radius = (size / 2) - (i * 4);
      if (radius > 0) {
        final path = Path();
        path.addArc(
          Rect.fromCenter(center: center, width: radius * 2, height: radius * 1.5),
          -math.pi / 2,
          math.pi,
        );
        canvas.drawPath(path, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}