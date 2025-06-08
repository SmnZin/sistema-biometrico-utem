# 🛡️ Sistema de Seguridad Biométrico UTEM

Sistema de control de acceso biométrico que integra reconocimiento facial y de huella dactilar, desarrollado como proyecto académico para el curso de Inteligencia Artificial (AI) 2025-I - LAB 02 de la Universidad Tecnológica Metropolitana (UTEM).

## 📋 Descripción del Proyecto

Este proyecto consiste en el desarrollo de una aplicación móvil Flutter que implementa un sistema de seguridad biométrico integral, capaz de identificar y verificar la identidad de personas mediante dos modalidades complementarias:

- **🎭 Reconocimiento Facial**: Utilizando la cámara frontal del dispositivo
- **👆 Huella Dactilar**: Mediante sensor nativo o captura por cámara trasera
- **🔒 Autenticación Dual**: Combinación de ambos métodos para mayor seguridad

El sistema está diseñado para integrarse con modelos de inteligencia artificial desarrollados en Google Colab, proporcionando una experiencia completa de desarrollo de sistemas biométricos aplicados.

## ✨ Características Principales

### 🎯 Funcionalidades Core
- **Captura biométrica en tiempo real** con validación de calidad
- **Detección automática de sensores** biométricos del dispositivo
- **Interfaz intuitiva** con guías visuales y animaciones
- **Simulación de procesamiento** con modelos de IA
- **Gestión de permisos** automática y transparente
- **Navegación fluida** entre módulos

### 🎨 Experiencia de Usuario
- **Diseño institucional UTEM** con colores corporativos
- **Animaciones suaves** y feedback visual
- **Overlays personalizados** para guiar la captura
- **Indicadores de calidad** en tiempo real
- **Instrucciones dinámicas** según el contexto
- **Responsive design** para diferentes tamaños de pantalla

### 🔧 Arquitectura Técnica
- **Clean Architecture** con separación de responsabilidades
- **Navegación declarativa** con GoRouter
- **Gestión de estado** preparada para BLoC
- **Servicios modulares** para cámara y biometría
- **Manejo de errores** robusto

## 🛠️ Tecnologías Utilizadas

### Frontend (Flutter)
- **Flutter SDK** ^3.1.0
- **Dart** ^3.1.0
- **Material Design 3** para componentes UI

### Dependencias Principales
- **go_router** ^12.1.3 - Navegación declarativa
- **camera** ^0.10.5+5 - Control de cámara
- **local_auth** ^2.1.6 - Autenticación biométrica nativa
- **permission_handler** ^11.0.1 - Gestión de permisos
- **google_fonts** ^6.1.0 - Tipografías personalizadas
- **http** ^1.1.0 - Cliente HTTP para API
- **shared_preferences** ^2.2.2 - Almacenamiento local

### Backend (Futuro)
- **Python** + **TensorFlow/PyTorch** en Google Colab
- **FastAPI** para endpoints REST
- **OpenCV** para procesamiento de imágenes
- **MTCNN/FaceNet** para reconocimiento facial

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
4. **Dispositivo físico** o emulador Android/iOS

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

#### En Dispositivo Físico (Recomendado para cámara)

```bash
# Conectar dispositivo por USB y habilitar depuración USB

# Verificar dispositivos conectados
flutter devices

# Ejecutar en dispositivo
flutter run
```

#### En Emulador

```bash
# Iniciar emulador desde Android Studio o usar comandos
flutter emulators --launch <emulator_id>

# Ejecutar en emulador
flutter run
```

#### Modo Debug con Hot Reload

```bash
# Ejecutar en modo debug (recomendado para desarrollo)
flutter run --debug

# En la terminal aparecerán comandos disponibles:
# r: Hot reload
# R: Hot restart
# q: Quit
```

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
- Navegación automática a la pantalla de bienvenida

### 2. **Selección de Método Biométrico**
- **Reconocimiento Facial**: Usa la cámara frontal
- **Huella Dactilar**: Sensor nativo o cámara trasera
- **Autenticación Dual**: Combina ambos métodos (próximamente)

### 3. **Captura Facial**
- Coloca tu rostro dentro del marco guía
- Espera la detección automática
- El sistema indica la calidad de la imagen
- Captura cuando la calidad sea óptima

### 4. **Captura de Huella**
- **Sensor Nativo**: Usa el lector de huellas de tu dispositivo
- **Cámara**: Coloca el dedo sobre la cámara trasera
- Sigue las instrucciones en pantalla
- Mantén el dedo inmóvil durante el escaneo

### 5. **Resultados**
- El sistema procesa los datos biométricos
- Muestra el resultado: Acceso concedido o denegado
- Incluye información de confianza y método usado

## 🎯 Estado Actual del Desarrollo

### ✅ Implementado (Fase 1 - Frontend)
- [x] Estructura base del proyecto Flutter
- [x] Navegación completa entre pantallas
- [x] Interfaz de usuario con diseño UTEM
- [x] Captura facial con overlays y animaciones
- [x] Captura de huella (sensor nativo + cámara)
- [x] Gestión de permisos y cámara
- [x] Simulación de procesamiento biométrico
- [x] Indicadores de calidad en tiempo real

### 🔄 En Desarrollo (Próximas Fases)
- [ ] Modelos de IA en Google Colab
  - [ ] Modelo de reconocimiento facial (FaceNet)
  - [ ] Modelo de procesamiento de huellas
  - [ ] Sistema de fusión biométrica
- [ ] API Backend
  - [ ] Endpoints para procesamiento
  - [ ] Base de datos de usuarios
  - [ ] Logs de acceso
- [ ] Pantallas adicionales
  - [ ] Registro de usuarios
  - [ ] Dashboard administrativo
  - [ ] Configuraciones del sistema

## 🧪 Testing y Desarrollo

### Ejecutar Tests

```bash
# Tests unitarios
flutter test

# Tests de integración
flutter test integration_test/
```

### Debug y Logging

```bash
# Ejecutar con logs detallados
flutter run --verbose

# Ver logs en tiempo real
flutter logs
```

### Build para Producción

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (solo en macOS)
flutter build ios --release
```

## 👥 Equipo de Desarrollo

**Roles sugeridos para equipos de 4 estudiantes:**

- **Líder de Proyecto**: Coordinación general y documentación
- **Encargado Modelo Facial**: Desarrollo de reconocimiento facial
- **Encargado Modelo Huella**: Desarrollo de procesamiento de huellas
- **Encargado Frontend**: Desarrollo de la aplicación móvil e integración

## 📊 Criterios de Evaluación

| Criterio | Peso | Detalles |
|----------|------|----------|
| **Calidad de modelos IA** | 35% | Precisión facial (12%), huella (12%), integración (11%) |
| **Implementación técnica** | 25% | Calidad código (10%), integración componentes (15%) |
| **Interfaz y experiencia** | 15% | Usabilidad, tiempo de respuesta |
| **Optimización** | 15% | Eficiencia computacional, escalabilidad |
| **Documentación** | 10% | Calidad documentación, cumplimiento plazos |

## 🛡️ Consideraciones de Seguridad

- **Datos biométricos**: Procesamiento local, no almacenamiento permanente
- **Permisos**: Solicitud explícita de acceso a cámara y sensores
- **Comunicación**: Preparado para protocolos HTTPS con backend
- **Privacidad**: Sin tracking de usuarios en la aplicación

## 🐛 Problemas Conocidos y Soluciones

### Error de Permisos de Cámara
```bash
# Solución: Verificar permisos en configuración del dispositivo
# Android: Configuración > Apps > [App] > Permisos > Cámara
```

### Overflow en Pantallas Pequeñas
```bash
# Solución: Ya implementado con SingleChildScrollView
# Las pantallas se adaptan automáticamente
```

### Sensor Biométrico No Detectado
```bash
# Solución: La app detecta automáticamente y ofrece alternativas
# Fallback a captura por cámara siempre disponible
```

## 📚 Recursos y Referencias

### Documentación Técnica
- [Flutter Documentation](https://docs.flutter.dev/)
- [Camera Plugin](https://pub.dev/packages/camera)
- [Local Auth Plugin](https://pub.dev/packages/local_auth)
- [Go Router](https://pub.dev/packages/go_router)

### Datasets Sugeridos (Próxima Fase)
- **Rostros**: LFW, CelebA (subconjuntos)
- **Huellas**: SOCOFing (subconjuntos)
- **Propios**: Recolección manual del equipo (50% mínimo)

### Papers de Referencia
- FaceNet: A Unified Embedding for Face Recognition
- MTCNN: Joint Face Detection and Alignment
- Handbook of Fingerprint Recognition

## 📄 Licencia

Este proyecto es desarrollado con fines académicos para la Universidad Tecnológica Metropolitana (UTEM). 

**Nota**: El uso de datos biométricos debe cumplir con regulaciones locales de privacidad y protección de datos.

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

**⚡ ¡Desarrollado con Flutter y ❤️ para UTEM!**