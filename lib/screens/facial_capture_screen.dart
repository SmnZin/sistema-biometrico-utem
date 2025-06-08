import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import '../config/routes.dart';

class FacialCaptureScreen extends StatefulWidget {
  final bool isRegistration;
  
  const FacialCaptureScreen({
    super.key,
    this.isRegistration = false,
  });

  @override
  State<FacialCaptureScreen> createState() => _FacialCaptureScreenState();
}

class _FacialCaptureScreenState extends State<FacialCaptureScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  bool _faceDetected = false;
  double _imageQuality = 0.0;
  String _instructions = "Coloca tu rostro dentro del marco";
  
  // Animaciones
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCamera();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _scanController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    ));
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

      // Buscar cámara frontal
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        _startFaceDetectionSimulation();
      }
    } catch (e) {
      _showErrorDialog('Error al inicializar la cámara: $e');
    }
  }

  void _startFaceDetectionSimulation() {
    // Simulación de detección facial
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _faceDetected = true;
          _imageQuality = 0.75;
          _instructions = "Rostro detectado - Mantente quieto";
        });
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _imageQuality = 0.85;
          _instructions = "Buena calidad - Listo para capturar";
        });
      }
    });
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
      final image = await _cameraController!.takePicture();
      
      // Simulación de procesamiento
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        
        final isSuccess = false;
        
        if (isSuccess) {
          context.goToAccessGranted(
            userName: widget.isRegistration ? 'Usuario Registrado' : 'Juan Pérez',
            method: 'Facial',
            confidence: _imageQuality * 100,
          );
        } else {
          context.goToAccessDenied(
            reason: 'Rostro no reconocido',
            method: 'Facial',
          );
        }
      }
    } catch (e) {
      setState(() {
        _isCapturing = false;
        _instructions = "Error en la captura. Inténtalo de nuevo";
      });
      _showErrorDialog('Error al capturar imagen: $e');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permiso Requerido'),
        content: const Text(
          'La aplicación necesita acceso a la cámara para el reconocimiento facial.',
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
    _pulseController.dispose();
    _scanController.dispose();
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
          widget.isRegistration ? 'Registro Facial' : 'Reconocimiento Facial',
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
          child: _buildFaceDetectionOverlay(),
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

  Widget _buildFaceDetectionOverlay() {
    return CustomPaint(
      painter: FaceDetectionPainter(
        faceDetected: _faceDetected,
        scanProgress: _scanAnimation.value,
        pulseScale: _pulseAnimation.value,
      ),
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
          // Indicador de calidad
          _buildQualityIndicator(),
          
          const SizedBox(height: 16),
          
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

  Widget _buildQualityIndicator() {
    Color qualityColor;
    String qualityText;
    
    if (_imageQuality >= 0.8) {
      qualityColor = Colors.green;
      qualityText = 'Excelente';
    } else if (_imageQuality >= 0.6) {
      qualityColor = Colors.orange;
      qualityText = 'Buena';
    } else if (_imageQuality >= 0.4) {
      qualityColor = Colors.yellow;
      qualityText = 'Regular';
    } else {
      qualityColor = Colors.red;
      qualityText = 'Insuficiente';
    }

    return Column(
      children: [
        Text(
          'Calidad de imagen: $qualityText',
          style: TextStyle(
            color: qualityColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _imageQuality,
          backgroundColor: Colors.white.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(qualityColor),
        ),
      ],
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _isCapturing || _imageQuality < 0.6 ? null : _captureImage,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _faceDetected ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isCapturing 
                    ? Colors.grey 
                    : (_imageQuality >= 0.6 ? Colors.green : Colors.grey),
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
        },
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
            Text('• Mantén el rostro centrado en el marco'),
            Text('• Evita movimientos bruscos'),
            Text('• Retira lentes si es posible'),
            Text('• Mira directamente a la cámara'),
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

// Custom Painter para el overlay de detección facial
class FaceDetectionPainter extends CustomPainter {
  final bool faceDetected;
  final double scanProgress;
  final double pulseScale;

  FaceDetectionPainter({
    required this.faceDetected,
    required this.scanProgress,
    required this.pulseScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2 - 50;
    final radius = 120.0;

    // Marco de detección facial
    final framePaint = Paint()
      ..color = faceDetected ? Colors.green : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Dibujar marco ovalado
    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: radius * 2 * (faceDetected ? pulseScale : 1.0),
      height: radius * 2.5 * (faceDetected ? pulseScale : 1.0),
    );
    
    canvas.drawOval(rect, framePaint);

    // Esquinas del marco
    final cornerPaint = Paint()
      ..color = faceDetected ? Colors.green : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final cornerLength = 20.0;
    
    // Esquina superior izquierda
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      cornerPaint,
    );

    // Esquina superior derecha
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      cornerPaint,
    );

    // Esquina inferior izquierda
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      cornerPaint,
    );

    // Esquina inferior derecha
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom - cornerLength),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );

    // Línea de escaneo
    if (faceDetected) {
      final scanPaint = Paint()
        ..color = Colors.green.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final scanY = rect.top + (rect.height * scanProgress);
      canvas.drawLine(
        Offset(rect.left + 10, scanY),
        Offset(rect.right - 10, scanY),
        scanPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}