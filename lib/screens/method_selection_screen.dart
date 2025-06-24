import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/routes.dart';

class MethodSelectionScreen extends StatelessWidget {
  const MethodSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Método de Autenticación'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.welcome),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.security,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Selecciona el método\nde autenticación',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Elige cómo deseas verificar tu identidad',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Opciones de método - SOLUCIÓN: Usando Flexible y SingleChildScrollView
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Reconocimiento facial
                      _buildMethodCard(
                        context,
                        icon: Icons.face,
                        title: 'Reconocimiento Facial',
                        description: 'Utiliza la cámara frontal para\nidentificarte mediante tu rostro',
                        color: const Color(0xFF4CAF50),
                        onTap: () {
                          context.goToFacialCapture(isRegistration: false);
                        },
                      ),
                      
                      const SizedBox(height: 16), // Reducido de 20 a 16
                      
                      // Huella dactilar
                      _buildMethodCard(
                        context,
                        icon: Icons.fingerprint,
                        title: 'Huella Dactilar (nativo)',
                        description: 'Utiliza el sensor biométrico nativo para\nverificar tu huella dactilar',
                        color: const Color(0xFF2196F3),
                        onTap: () {
                          context.goToFingerprintCapture(isRegistration: false);
                        },
                      ),
                      
                      const SizedBox(height: 16), // Reducido de 20 a 16
                      
                      // Captura de imagen de huella dactilar
                      _buildMethodCard(
                        context,
                        icon: Icons.fingerprint,
                        title: 'Huella Dactilar (imagen)',
                        description: 'Utiliza la cámara para capturar\nuna imagen de tu huella dactilar',
                        color: const Color(0xFF6A1B9A),
                        onTap: () {
                          context.goToFingerprintImageCapture(isRegistration: false);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Footer con opción de registro - SOLUCIÓN: Removido Expanded y usando tamaño fijo
            
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icono
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Flecha
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Icon(
            Icons.construction,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Próximamente'),
          content: Text(
            'La funcionalidad de $feature estará disponible en la próxima actualización.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }
}