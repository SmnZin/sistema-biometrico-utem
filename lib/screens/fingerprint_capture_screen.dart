import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import '../config/routes.dart';
import '../config/theme.dart';
import 'access_granted_screen.dart';
import 'access_denied_screen.dart';

class FingerprintCaptureScreen extends StatefulWidget {
  final bool isRegistration;

  const FingerprintCaptureScreen({
    super.key,
    required this.isRegistration,
  });

  @override
  State<FingerprintCaptureScreen> createState() => _FingerprintCaptureScreenState();
}

class _FingerprintCaptureScreenState extends State<FingerprintCaptureScreen>
    with TickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Estados posibles de la pantalla
  FingerprintState _currentState = FingerprintState.initial;
  String _statusMessage = '';
  String _errorMessage = '';
  
  // Controladores de animaci�n
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometricSupport();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  // Verificar si el dispositivo soporta biometr�a y tiene huellas registradas
  Future<void> _checkBiometricSupport() async {
  try {
    // DIAGNÓSTICO: mostrar sensores detectados y disponibilidad
    final biometrics = await _localAuth.getAvailableBiometrics();
    final canCheck = await _localAuth.canCheckBiometrics;

    print('Biométricos disponibles: $biometrics');
    print('¿Puede verificar biometría?: $canCheck');

    setState(() {
      _statusMessage = 'Sensores disponibles: $biometrics | Puede verificar: $canCheck';
    });

    // Verificar si el dispositivo soporta biometría
    final bool isAvailable = canCheck;

    if (!isAvailable) {
      setState(() {
        _currentState = FingerprintState.error;
        _errorMessage = 'Este dispositivo no soporta autenticación biométrica';
        _statusMessage = 'Biometría no disponible';
      });
      return;
    }

    // Verificar si hay biométricos disponibles
    if (biometrics.isEmpty) {
      setState(() {
        _currentState = FingerprintState.error;
        _errorMessage = 'No hay métodos biométricos configurados en este dispositivo';
        _statusMessage = 'Sin biométricos configurados';
      });
      return;
    }

    // Verificar si hay huella dactilar específicamente
    final bool hasFingerprintSupport = biometrics.contains(BiometricType.strong);

    if (!hasFingerprintSupport) {
      setState(() {
        _currentState = FingerprintState.error;
        _errorMessage = 'El sensor de huella dactilar no está disponible';
        _statusMessage = 'Sensor de huella no disponible';
      });
      return;
    }

    // Todo OK
    setState(() {
      _currentState = FingerprintState.initial;
      _statusMessage = 'Sensor de huella dactilar disponible';
      _errorMessage = '';
    });
  } catch (e) {
    setState(() {
      _currentState = FingerprintState.error;
      _errorMessage = 'Error al verificar el sensor biométrico: $e';
      _statusMessage = 'Error de verificación';
    });
  }
}


  // Iniciar el proceso de autenticaci�n biom�trica
  Future<void> _startFingerprintAuthentication() async {
    setState(() {
      _currentState = FingerprintState.scanning;
      _statusMessage = 'Coloca tu dedo en el sensor';
      _errorMessage = '';
    });

    // Iniciar animaciones de escaneo
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();

    try {
      // Solicitar autenticaci�n biom�trica
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Por favor, verifica tu identidad con tu huella dactilar',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      // Detener animaciones
      _pulseController.stop();
      _rotationController.stop();

      if (didAuthenticate) {
        // Autenticaci�n exitosa
        _handleAuthenticationSuccess();
      } else {
        // Autenticaci�n fallida (usuario cancel�)
        _handleAuthenticationFailure('Autenticación cancelada por el usuario');
      }

    } on PlatformException catch (e) {
      // Detener animaciones en caso de error
      _pulseController.stop();
      _rotationController.stop();

      // Manejar diferentes tipos de errores espec�ficos
      String errorMessage = _getErrorMessage(e);
      _handleAuthenticationFailure(errorMessage);
    } catch (e) {
      // Error general
      _pulseController.stop();
      _rotationController.stop();
      _handleAuthenticationFailure('Error inesperado durante la autenticación');
    }
  }

  // Obtener mensaje de error espec�fico basado en el c�digo de error
  String _getErrorMessage(PlatformException e) {
    switch (e.code) {
      case auth_error.notAvailable:
        return 'La autenticacion biometrica no está disponible';
      case auth_error.notEnrolled:
        return 'No hay huellas dactilares registradas en este dispositivo';
      case auth_error.lockedOut:
        return 'Demasiados intentos fallidos. Intenta m�s tarde';
      case auth_error.permanentlyLockedOut:
        return 'La biometría está bloqueada permanentemente';
      case auth_error.biometricOnlyNotSupported:
        return 'Este dispositivo no soporta autenticación solo biométrica';
      default:
        return 'Error de autenticación: ${e.message ?? 'Desconocido'}';
    }
  }

  // Manejar autenticaci�n exitosa
  void _handleAuthenticationSuccess() {
    setState(() {
      _currentState = FingerprintState.success;
      _statusMessage = 'Autenticación exitosa';
    });

    // Navegar a la pantalla de acceso concedido
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AccessGrantedScreen(
            userName: 'Usuario Verificado',
            method: 'Huella Dactilar',
            confidence: 98.5,
          ),
        ),
      );
    });
  }

  // Manejar autenticaci�n fallida
  void _handleAuthenticationFailure(String reason) {
    setState(() {
      _currentState = FingerprintState.failed;
      _statusMessage = 'Autenticación fallida';
      _errorMessage = reason;
    });

    // Navegar a la pantalla de acceso denegado despu�s de mostrar el error
    Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AccessDeniedScreen(
            reason: reason,
            method: 'Huella Dactilar',
          ),
        ),
      );
    });
  }

  // Reintentar la autenticaci�n
  void _retryAuthentication() {
    _checkBiometricSupport();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.goToMethodSelection(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          widget.isRegistration ? 'Registrar Huella' : 'Verificar Huella',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Indicador de progreso/estado
              _buildProgressIndicator(),
              
              const SizedBox(height: 40),
              
              // �rea principal con �cono de huella
              Expanded(
                child: _buildMainContent(),
              ),
              
              // Mensaje de estado
              _buildStatusMessage(),
              
              const SizedBox(height: 32),
              
              // Botones de acci�n
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: _getStateColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStateColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getStateIcon(),
            color: _getStateColor(),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _getStateTitle(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _getStateColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // �cono de huella dactilar con animaciones
          _buildFingerprintIcon(),
          
          const SizedBox(height: 32),
          
          // T�tulo
          Text(
            _getMainTitle(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Subt�tulo/instrucciones
          Text(
            _getMainSubtitle(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textColor.withOpacity(0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFingerprintIcon() {
    Widget icon = Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getStateColor().withOpacity(0.1),
        border: Border.all(
          color: _getStateColor().withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.fingerprint,
        size: 60,
        color: _getStateColor(),
      ),
    );

    // Aplicar animaciones seg�n el estado
    switch (_currentState) {
      case FingerprintState.scanning:
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value * 2 * 3.14159,
                    child: icon,
                  );
                },
              ),
            );
          },
        );
      
      case FingerprintState.success:
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.successColor.withOpacity(0.1),
            border: Border.all(
              color: AppTheme.successColor,
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.check,
            size: 60,
            color: AppTheme.successColor,
          ),
        );
      
      case FingerprintState.failed:
        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.errorColor.withOpacity(0.1),
                  border: Border.all(
                    color: AppTheme.errorColor,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.close,
                  size: 60,
                  color: AppTheme.errorColor,
                ),
              ),
            );
          },
        );
      
      default:
        return icon;
    }
  }

  Widget _buildStatusMessage() {
    return Column(
      children: [
        if (_statusMessage.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.borderColor,
                width: 1,
              ),
            ),
            child: Text(
              _statusMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        
        if (_errorMessage.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.errorColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppTheme.errorColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.errorColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    switch (_currentState) {
      case FingerprintState.initial:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startFingerprintAuthentication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.fingerprint),
                label: const Text(
                  'Iniciar Escaneo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.goToMethodSelection(),
              child: const Text('Cancelar'),
            ),
          ],
        );

      case FingerprintState.scanning:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Cancelar la autenticaci�n en curso
                  _pulseController.stop();
                  _rotationController.stop();
                  setState(() {
                    _currentState = FingerprintState.initial;
                    _statusMessage = 'Escaneo cancelado';
                    _errorMessage = '';
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancelar Escaneo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );

      case FingerprintState.error:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _retryAuthentication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Reintentar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.goToMethodSelection(),
              child: const Text('Volver'),
            ),
          ],
        );

      case FingerprintState.failed:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startFingerprintAuthentication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Intentar Nuevamente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.goToMethodSelection(),
              child: const Text('Cambiar Método'),
            ),
          ],
        );

      case FingerprintState.success:
      default:
        return const SizedBox.shrink();
    }
  }

  // M�todos helper para obtener datos seg�n el estado
  Color _getStateColor() {
    switch (_currentState) {
      case FingerprintState.initial:
        return AppTheme.primaryColor;
      case FingerprintState.scanning:
        return AppTheme.warningColor;
      case FingerprintState.success:
        return AppTheme.successColor;
      case FingerprintState.failed:
      case FingerprintState.error:
        return AppTheme.errorColor;
    }
  }

  IconData _getStateIcon() {
    switch (_currentState) {
      case FingerprintState.initial:
        return Icons.fingerprint;
      case FingerprintState.scanning:
        return Icons.fingerprint;
      case FingerprintState.success:
        return Icons.check_circle;
      case FingerprintState.failed:
      case FingerprintState.error:
        return Icons.error;
    }
  }

  String _getStateTitle() {
    switch (_currentState) {
      case FingerprintState.initial:
        return 'Listo para escanear';
      case FingerprintState.scanning:
        return 'Escaneando...';
      case FingerprintState.success:
        return 'Éxito';
      case FingerprintState.failed:
        return 'Fallo';
      case FingerprintState.error:
        return 'Error';
    }
  }

  String _getMainTitle() {
    switch (_currentState) {
      case FingerprintState.initial:
        return widget.isRegistration 
            ? 'Registrar Huella Dactilar' 
            : 'Verificar Identidad';
      case FingerprintState.scanning:
        return 'Escaneando Huella...';
      case FingerprintState.success:
        return 'Verificación Exitosa';
      case FingerprintState.failed:
        return 'Verificación Fallida';
      case FingerprintState.error:
        return 'Error del Sensor';
    }
  }

  String _getMainSubtitle() {
    switch (_currentState) {
      case FingerprintState.initial:
        return 'Coloca tu dedo en el sensor de huella dactilar cuando esté listo';
      case FingerprintState.scanning:
        return 'Mantén tu dedo en el sensor hasta que se complete el escaneo';
      case FingerprintState.success:
        return 'Tu identidad ha sido verificada correctamente';
      case FingerprintState.failed:
        return 'No se pudo verificar tu identidad. Inténtalo nuevamente';
      case FingerprintState.error:
        return 'Hay un problema con el sensor biometrico. Verifica la configuración de tu dispositivo';
    }
  }
}

// Enum para definir los estados de la pantalla
enum FingerprintState {
  initial,    // Estado inicial, listo para comenzar
  scanning,   // Escaneando huella dactilar
  success,    // Autenticaci�n exitosa
  failed,     // Autenticaci�n fallida
  error,      // Error con el sensor o configuraci�n
}