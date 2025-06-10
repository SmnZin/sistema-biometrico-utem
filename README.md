# 🛡️ Sistema de Seguridad Biométrico UTEM

Sistema de control de acceso biométrico que integra reconocimiento facial e inteligencia artificial con autenticación biométrica nativa, desarrollado como proyecto académico para el curso de Inteligencia Artificial (AI) 2025-I - LAB 02 de la Universidad Tecnológica Metropolitana (UTEM).

## 📋 Descripción del Proyecto

Este proyecto consiste en el desarrollo de una aplicación móvil Flutter que implementa un sistema de seguridad biométrico híbrido, capaz de identificar y verificar la identidad de personas mediante dos modalidades complementarias:

- **🎭 Reconocimiento Facial**: Utilizando la cámara frontal del dispositivo con procesamiento IA en backend
- **👆 Autenticación Biométrica Nativa**: Mediante sensores biométricos nativos del dispositivo (huella dactilar, facial, etc.)
- **🔒 Autenticación Dual**: Combinación de ambos métodos para máxima seguridad

El sistema está diseñado para integrarse con modelos de inteligencia artificial desarrollados en Google Colab para el reconocimiento facial, mientras utiliza las APIs nativas del dispositivo para la autenticación biométrica, proporcionando una experiencia completa y realista de desarrollo de sistemas biométricos aplicados.

## ✨ Características Principales

### 🎯 Funcionalidades Core
- **Captura facial en tiempo real** con validación de calidad y procesamiento IA
- **Autenticación biométrica nativa** usando sensores del dispositivo
- **Detección automática de sensores** biométricos disponibles
- **Interfaz intuitiva** con guías visuales y animaciones
- **Sistema de fusión híbrido** combinando IA y hardware nativo
- **Gestión de permisos** automática y transparente
- **Navegación fluida** entre módulos

### 🎨 Experiencia de Usuario
- **Diseño institucional UTEM** con colores corporativos
- **Animaciones suaves** y feedback visual
- **Overlays personalizados** para guiar la captura facial
- **Indicadores de calidad** en tiempo real para imágenes
- **Instrucciones dinámicas** según disponibilidad de sensores
- **Responsive design** para diferentes tamaños de pantalla

### 🔧 Arquitectura Técnica Híbrida
- **Clean Architecture** con separación de responsabilidades
- **Sistema dual**: IA para facial + APIs nativas para biometría
- **Navegación declarativa** con GoRouter
- **Gestión de estado** preparada para BLoC
- **Servicios modulares** para cámara y autenticación biométrica
- **Manejo de errores** robusto con fallbacks

## 🛠️ Tecnologías Utilizadas

### Frontend (Flutter)
- **Flutter SDK** ^3.1.0
- **Dart** ^3.1.0
- **Material Design 3** para componentes UI

### Dependencias Principales
- **go_router** ^12.1.3 - Navegación declarativa
- **camera** ^0.10.5+5 - Control de cámara para captura facial
- **local_auth** ^2.1.6 - Autenticación biométrica nativa (huellas, face unlock, etc.)
- **permission_handler** ^11.0.1 - Gestión de permisos
- **google_fonts** ^6.1.0 - Tipografías personalizadas
- **http** ^1.1.0 - Cliente HTTP para API de reconocimiento facial
- **shared_preferences** ^2.2.2 - Almacenamiento local para registro de usuarios

### Backend (IA para Reconocimiento Facial)
- **Python** + **TensorFlow/PyTorch** en Google Colab
- **FastAPI** para endpoints REST
- **OpenCV** para procesamiento de imágenes faciales
- **MTCNN/FaceNet** para reconocimiento facial

### Sistema Biométrico Nativo
- **Sensores de huella dactilar** del dispositivo
- **Face ID / Face Unlock** (iOS/Android)
- **Iris scanner** (dispositivos compatibles)
- **APIs nativas** Android/iOS para autenticación

## 🚀 Instalación y Configuración

### Prerrequisitos

1. **Flutter SDK** (versión 3.1.0 o superior)
   ```bash
   # Verificar instalación
   flutter --version
   flutter doctor
   ```

2. **Git** para clonar el repositorio
   ```bash
   git --version
   ```

3. **Android Studio** o **VS Code** con extensiones de Flutter
4. **Dispositivo físico** con sensores biométricos (recomendado para testing completo)

### 📥 Clonar el Repositorio

```bash
# Clonar el proyecto
git clone https://github.com/smnzin/sistema-biometrico-utem.git

# Navegar al directorio
cd sistema-biometrico-utem
```

### 📦 Instalación de Dependencias

```bash
# Instalar dependencias de Flutter
flutter pub get

# Verificar que todo esté configurado correctamente
flutter doctor
```

### 📱 Ejecutar la Aplicación

#### En Dispositivo Físico (Recomendado)

```bash
# Conectar dispositivo por USB y habilitar depuración USB

# Verificar dispositivos conectados
flutter devices

# Ejecutar en dispositivo
flutter run
```

**Nota**: Se recomienda usar dispositivo físico para probar completamente las funciones biométricas, ya que los emuladores pueden tener limitaciones con sensores biométricos.

#### En Emulador

```bash
# Iniciar emulador desde Android Studio
flutter emulators --launch <emulator_id>

# Ejecutar en emulador
flutter run
```

**Limitaciones en emulador**: Los sensores biométricos pueden no estar disponibles o requerir configuración adicional.

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── config/                     # Configuración general
│   ├── theme.dart              # Tema y colores UTEM
│   └── routes.dart             # Navegación y rutas
├── screens/                    # Pantallas de la aplicación
│   ├── splash_screen.dart      # Pantalla de carga
│   ├── welcome_screen.dart     # Bienvenida
│   ├── method_selection_screen.dart # Selección de método
│   ├── facial_capture_screen.dart   # Captura facial
│   └── fingerprint_capture_screen.dart # Captura huella
├── widgets/                    # Componentes reutilizables
├── services/                   # Lógica de negocio
├── models/                     # Modelos de datos
└── utils/                      # Utilidades y constantes

assets/
├── images/                     # Imágenes y logos
└── fonts/                      # Fuentes personalizadas (opcional)
```

## 🎮 Cómo Usar la Aplicación

### 1. **Pantalla de Inicio**
- La app inicia con el logo UTEM y una animación de carga
- Verificación automática de sensores disponibles
- Navegación automática a la pantalla de bienvenida

### 2. **Selección de Método Biométrico**
- **Reconocimiento Facial**: Captura + procesamiento IA en backend
- **Autenticación Biométrica**: Uso de sensores nativos del dispositivo
- **Autenticación Dual**: Combina ambos métodos para máxima seguridad

### 3. **Captura Facial (con IA)**
- Coloca tu rostro dentro del marco guía
- El sistema evalúa la calidad de la imagen en tiempo real
- Captura automática cuando la calidad sea óptima
- Envío al backend para procesamiento con modelos de IA
- Resultado basado en reconocimiento facial inteligente

### 4. **Autenticación Biométrica Nativa**
- **Detección automática** de sensores disponibles en el dispositivo
- **Huella dactilar**: Usa el sensor nativo del dispositivo
- **Face ID/Unlock**: Aprovecha el reconocimiento facial nativo
- **Múltiples modalidades**: Soporte para cualquier sensor biométrico disponible
- **Proceso nativo**: La autenticación se realiza completamente en el dispositivo
- **Seguridad hardware**: Aprovecha el Secure Element del dispositivo

### 5. **Modos de Operación**

#### Modo Solo Facial (IA)
- Captura imagen facial
- Procesamiento en backend con modelos de IA
- Identificación basada en base de datos de usuarios
- Ideal para identificación de personas no registradas localmente

#### Modo Solo Biométrico (Nativo)
- Verificación contra huellas/rostros registrados en el dispositivo
- Procesamiento local ultra-rápido
- Mayor privacidad (datos no salen del dispositivo)
- Ideal para usuarios ya registrados en el sistema

#### Modo Dual (Híbrido)
- Combina ambas tecnologías para máxima seguridad
- Verificación biométrica nativa + identificación IA
- Doble factor de autenticación biométrica
- Confianza máxima del sistema

### 6. **Resultados**
- El sistema procesa según el método seleccionado
- Muestra resultado: Acceso concedido o denegado
- Incluye información de confianza, método usado y tiempo de proceso
- Registro de audit trail para seguimiento

## 🎯 Estado Actual del Desarrollo

### ✅ Implementado (Fase 1 - Frontend)
- [x] Estructura base del proyecto Flutter
- [x] Navegación completa entre pantallas
- [x] Interfaz de usuario con diseño UTEM
- [x] Captura facial con overlays y animaciones
- [x] **Autenticación biométrica nativa completa**
  - [x] Detección automática de sensores
  - [x] Integración con local_auth
  - [x] Soporte para múltiples modalidades biométricas
  - [x] Manejo de estados y errores
- [x] Gestión de permisos y cámara
- [x] Simulación de procesamiento para reconocimiento facial
- [x] Indicadores de calidad en tiempo real

### 🔄 En Desarrollo (Próximas Fases)
- [ ] **Backend IA (Solo para Reconocimiento Facial)**
  - [ ] Modelo de reconocimiento facial (FaceNet) en Google Colab
  - [ ] API endpoints para procesamiento de imágenes faciales
  - [ ] Base de datos de usuarios para identificación facial
- [ ] **Sistema de Fusión Híbrido**
  - [ ] Lógica de combinación IA + biometría nativa
  - [ ] Algoritmos de scoring y confianza combinada
  - [ ] Configuración de umbrales por modalidad
- [ ] **Funcionalidades Adicionales**
  - [ ] Registro de usuarios (facial + biométrico)
  - [ ] Dashboard administrativo
  - [ ] Analytics y reportes de uso
  - [ ] Configuraciones avanzadas del sistema

## 🧪 Testing y Desarrollo

### Ejecutar Tests

```bash
# Tests unitarios
flutter test

# Tests de integración
flutter test integration_test/

# Test específico de autenticación biométrica
flutter test test/biometric_auth_test.dart
```

### Debug y Logging

```bash
# Ejecutar con logs detallados
flutter run --verbose

# Ver logs específicos de biometría
flutter logs | grep "BiometricAuth"
```

### Testing en Dispositivos

#### Requisitos para Testing Completo
- **Android**: Dispositivo con sensor de huella dactilar o Face Unlock
- **iOS**: iPhone con Touch ID o Face ID
- **Huellas registradas**: Al menos una huella dactilar configurada en el dispositivo
- **Permisos**: Biometría habilitada para aplicaciones

#### Casos de Test
- ✅ Dispositivo con sensor biométrico + huellas registradas
- ✅ Dispositivo con sensor biométrico sin huellas registradas
- ✅ Dispositivo sin sensor biométrico (fallback)
- ✅ Autenticación exitosa vs fallida
- ✅ Cancelación por parte del usuario
- ✅ Múltiples intentos de autenticación

## 👥 Equipo de Desarrollo

**Roles actualizados para equipos de 4 estudiantes:**

- **Líder de Proyecto**: Coordinación general, documentación y sistema de fusión
- **Encargado Modelo Facial**: Desarrollo de reconocimiento facial con IA (backend)
- **Encargado Autenticación Biométrica**: Implementación de APIs nativas y servicios locales
- **Encargado Frontend e Integración**: Desarrollo UI/UX y integración de componentes

## 📊 Criterios de Evaluación Actualizados

| Criterio | Peso | Detalles |
|----------|------|----------|
| **Calidad de modelos IA** | 35% | Precisión facial (20%), sistema de fusión híbrido (15%) |
| **Implementación técnica** | 25% | Calidad código (10%), integración biométrica nativa (15%) |
| **Interfaz y experiencia** | 15% | Usabilidad, tiempo de respuesta, flujo biométrico |
| **Innovación y optimización** | 15% | Eficiencia, aprovechamiento de hardware nativo |
| **Documentación** | 10% | Calidad documentación, cumplimiento plazos |

## 🛡️ Consideraciones de Seguridad

### Reconocimiento Facial (IA)
- **Datos temporales**: Imágenes procesadas y eliminadas tras análisis
- **Comunicación cifrada**: HTTPS para transmisión al backend
- **No almacenamiento**: Imágenes no se guardan permanentemente

### Autenticación Biométrica Nativa
- **Secure Element**: Uso del hardware de seguridad del dispositivo
- **Datos locales**: La biometría nunca sale del dispositivo
- **APIs nativas**: Aprovecha la seguridad implementada por el fabricante
- **Privacidad máxima**: Sin transmisión de datos biométricos

### General
- **Permisos explícitos**: Solicitud clara de acceso a cámara y sensores
- **Audit logs**: Registro local de intentos de autenticación
- **Sin tracking**: No se rastrea comportamiento de usuarios

## 🐛 Problemas Conocidos y Soluciones

### Sensor Biométrico No Detectado
```bash
# Causa: Dispositivo sin sensor o huellas no registradas
# Solución: La app detecta automáticamente y muestra mensaje informativo
# Fallback: Redirección a método de reconocimiento facial
```

### Error "BiometricException: NotEnrolled"
```bash
# Causa: No hay huellas registradas en el dispositivo
# Solución: Instruir al usuario para registrar huella en Configuración del dispositivo
# Path Android: Configuración > Seguridad > Huella dactilar
# Path iOS: Configuración > Touch ID y código
```

### Autenticación Cancelada por Usuario
```bash
# Causa: Usuario presiona cancelar en el prompt biométrico
# Solución: Mostrar opción de reintentar o usar método alternativo
# Implementado: Manejo graceful de cancelación
```

### Error de Permisos de Cámara (Reconocimiento Facial)
```bash
# Solución: Verificar permisos en configuración del dispositivo
# Android: Configuración > Apps > [App] > Permisos > Cámara
```

## 📚 Recursos y Referencias

### Documentación Técnica
- [Flutter Documentation](https://docs.flutter.dev/)
- [Local Auth Plugin](https://pub.dev/packages/local_auth) - **Clave para biometría**
- [Camera Plugin](https://pub.dev/packages/camera) - Para reconocimiento facial
- [Biometric Authentication Best Practices](https://developer.android.com/training/sign-in/biometric-auth)

### Arquitectura del Sistema
- **Frontend**: Flutter + APIs nativas para biometría
- **Backend**: Python + IA para reconocimiento facial únicamente
- **Seguridad**: Híbrida (local + cloud) con énfasis en privacidad

### Datasets (Solo para Reconocimiento Facial)
- **Rostros**: LFW, CelebA (subconjuntos)
- **Propios**: Recolección manual del equipo (50% mínimo)
- **Nota**: No se requieren datasets de huellas (usamos APIs nativas)

### Papers de Referencia
- FaceNet: A Unified Embedding for Face Recognition
- MTCNN: Joint Face Detection and Alignment
- Mobile Biometric Authentication: A Survey

## 🔄 Decisiones de Arquitectura

### ¿Por qué Autenticación Biométrica Nativa vs IA?

#### **Ventajas del Enfoque Híbrido:**
1. **Seguridad**: Los datos biométricos nunca salen del dispositivo
2. **Velocidad**: Autenticación instantánea con hardware optimizado
3. **Privacidad**: Cumple con regulaciones de protección de datos
4. **Realismo**: Replica sistemas de producción reales
5. **Estabilidad**: APIs maduras y probadas en millones de dispositivos

#### **Scope Técnico Realista:**
- **IA especializada**: Solo para reconocimiento facial (donde aporta valor)
- **Hardware nativo**: Para biometría (donde el hardware es superior)
- **Mejor de ambos mundos**: Combina innovación IA con estabilidad nativa

## 📄 Licencia

Este proyecto es desarrollado con fines académicos para la Universidad Tecnológica Metropolitana (UTEM). 

**Nota**: El uso de datos biométricos cumple con las mejores prácticas de privacidad, utilizando APIs nativas que mantienen los datos biométricos seguros en el dispositivo.

## 🤝 Contribuciones

Este es un proyecto académico. Para contribuciones:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📞 Soporte

Para preguntas o issues relacionados con el proyecto:

- **Curso**: Inteligencia Artificial (AI) 2025-I - LAB 02
- **Institución**: Universidad Tecnológica Metropolitana (UTEM)
- **Facultad**: Ingeniería - Escuela de Informática

---

**⚡ ¡Desarrollado con Flutter, IA y APIs nativas biométricas para UTEM!**

*Sistema híbrido que combina lo mejor de la inteligencia artificial con la seguridad del hardware nativo.*