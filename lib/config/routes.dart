import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Importaciones de pantallas
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/method_selection_screen.dart';
import '../screens/facial_capture_screen.dart';
import '../screens/fingerprint_capture_screen.dart';
import '../screens/access_granted_screen.dart';
import '../screens/access_denied_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    // Ruta inicial
    initialLocation: AppRoutes.splash,
    
    // Definición de rutas
    routes: [
      // Ruta de splash
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SplashScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      
      // Ruta de bienvenida
      GoRoute(
        path: AppRoutes.welcome,
        name: AppRoutes.welcomeName,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const WelcomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
                ),
                child: child,
              );
            },
          );
        },
      ),
      
      // Ruta de selección de método
      GoRoute(
        path: AppRoutes.methodSelection,
        name: AppRoutes.methodSelectionName,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const MethodSelectionScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
                ),
                child: child,
              );
            },
          );
        },
      ),
      
      // // Ruta de captura facial
      GoRoute(
        path: AppRoutes.facialCapture,
        name: AppRoutes.facialCaptureName,
        builder: (context, state) {
          final isRegistration = state.uri.queryParameters['registration'] == 'true';
          return FacialCaptureScreen(isRegistration: isRegistration);
        },
      ),
      
      // Ruta de captura de huella dactilar
      GoRoute(
        path: AppRoutes.fingerprintCapture,
        name: AppRoutes.fingerprintCaptureName,
        builder: (context, state) {
          final isRegistration = state.uri.queryParameters['registration'] == 'true';
          return FingerprintCaptureScreen(isRegistration: isRegistration);
        },
      ), 
      
      // Ruta de acceso concedido
      GoRoute(
        path: AppRoutes.accessGranted,
        name: AppRoutes.accessGrantedName,
        builder: (context, state) {
          final userName = state.uri.queryParameters['userName'] ?? 'Usuario';
          final method = state.uri.queryParameters['method'] ?? 'facial';
          final confidence = state.uri.queryParameters['confidence'] ?? '95';
          return AccessGrantedScreen(
            userName: userName,
            method: method,
            confidence: double.parse(confidence),
          );
        },
      ),
      
      // Ruta de acceso denegado
      GoRoute(
        path: AppRoutes.accessDenied,
        name: AppRoutes.accessDeniedName,
        builder: (context, state) {
          final reason = state.uri.queryParameters['reason'] ?? 'Usuario no reconocido';
          final method = state.uri.queryParameters['method'] ?? 'facial';
          return AccessDeniedScreen(
            reason: reason,
            method: method,
          );
        },
      ),
    ],
    
    // Manejo de errores de navegación
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Ruta: ${state.uri.toString()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.welcome),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Clase con todas las rutas de la aplicación
class AppRoutes {
  // Rutas principales
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String methodSelection = '/method-selection';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
  
  // Rutas de captura biométrica
  static const String facialCapture = '/facial-capture';
  static const String fingerprintCapture = '/fingerprint-capture';
  static const String processing = '/processing';
  
  // Rutas de resultados
  static const String accessGranted = '/access-granted';
  static const String accessDenied = '/access-denied';
  
  // Nombres de rutas (para navegación programática)
  static const String splashName = 'splash';
  static const String welcomeName = 'welcome';
  static const String methodSelectionName = 'methodSelection';
  static const String registerName = 'register';
  static const String dashboardName = 'dashboard';
  static const String settingsName = 'settings';
  static const String facialCaptureName = 'facialCapture';
  static const String fingerprintCaptureName = 'fingerprintCapture';
  static const String processingName = 'processing';
  static const String accessGrantedName = 'accessGranted';
  static const String accessDeniedName = 'accessDenied';
}

// Extensión para facilitar la navegación
extension AppRouterExtension on BuildContext {
  // Navegación simple
  void goToWelcome() => go(AppRoutes.welcome);
  void goToMethodSelection() => go(AppRoutes.methodSelection);
  void goToRegister() => go(AppRoutes.register);
  void goToDashboard() => go(AppRoutes.dashboard);
  void goToSettings() => go(AppRoutes.settings);
  
  // Navegación con parámetros
  void goToFacialCapture({bool isRegistration = false}) {
    go('${AppRoutes.facialCapture}?registration=$isRegistration');
  }
  
  void goToFingerprintCapture({bool isRegistration = false}) {
    go('${AppRoutes.fingerprintCapture}?registration=$isRegistration');
  }
  
  void goToProcessing({
    required String method,
    bool isRegistration = false,
  }) {
    go('${AppRoutes.processing}?method=$method&registration=$isRegistration');
  }
  
  void goToAccessGranted({
    required String userName,
    required String method,
    required double confidence,
  }) {
    go('${AppRoutes.accessGranted}?userName=$userName&method=$method&confidence=$confidence');
  }
  
  void goToAccessDenied({
    required String reason,
    required String method,
  }) {
    go('${AppRoutes.accessDenied}?reason=$reason&method=$method');
  }
  
  // Navegación hacia atrás
  void goBack() {
    if (canPop()) {
      pop();
    } else {
      goToMethodSelection();
    }
  }
}