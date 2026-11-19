# App Modular

Aplicación móvil desarrollada con **Flutter y Firebase**, organizada en módulos independientes que integran distintas funcionalidades en una sola aplicación.

## Módulos principales

- **App:** gestión de usuarios, notas, eventos y recordatorios.
- **Radio:** reproducción de estaciones, controles de audio y favoritos.
- **News:** consulta de noticias, detalle de publicaciones, marcadores y perfil.

La aplicación incorpora navegación entre secciones, animaciones, estados de carga y personalización visual.

## Tecnologías utilizadas

- Flutter y Dart.
- Firebase Authentication.
- Cloud Firestore.
- Firebase Cloud Messaging.
- Provider para la gestión del estado.
- `audio_service` y `just_audio` para la reproducción de audio.

## Requisitos previos

- Flutter SDK.
- Android Studio o Visual Studio Code.
- Android SDK.
- Un emulador o dispositivo Android.
- Un proyecto de Firebase configurado.

## Instalación

Clona el repositorio:

```bash
git clone https://github.com/yenifermtnezhdez-ops/app_modular.git
```

Entra en la carpeta:

```bash
cd app_modular
```

Instala las dependencias:

```bash
flutter pub get
```

Comprueba la instalación:

```bash
flutter doctor
```

## Configuración de Firebase

La aplicación utiliza Firebase para autenticación, almacenamiento de información y notificaciones.

Para configurar el proyecto en otro equipo:

1. Crea o selecciona un proyecto en Firebase.
2. Registra la aplicación Android con el identificador de paquete correspondiente.
3. Configura FlutterFire y genera `firebase_options.dart`.
4. Coloca el archivo `google-services.json` correspondiente en `android/app/`.
5. Configura Firestore y sus reglas de seguridad.
6. Habilita los servicios de Firebase utilizados por la aplicación.

**Importante:** utiliza las credenciales de tu propio proyecto de Firebase. No compartas claves privadas ni credenciales sensibles.

## Ejecutar la aplicación

Conecta un dispositivo Android o inicia un emulador:

```bash
flutter run
```

## Análisis y pruebas

Analiza el código:

```bash
flutter analyze
```

Ejecuta las pruebas:

```bash
flutter test
```

## Generar APK

Para crear una versión instalable:

```bash
flutter build apk --release
```

El archivo se genera en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Organización del proyecto

```text
lib/
├── app/
│   ├── auth_gate.dart
│   ├── module_hub_screen.dart
│   ├── animated_page_route.dart
│   └── loading_state.dart
├── modules/
│   ├── app/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── services/
│   ├── radio/
│   │   ├── helpers/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   └── news/
│       ├── components/
│       ├── models/
│       ├── providers/
│       ├── screens/
│       └── services/
├── app_theme.dart
└── main.dart

test/
```

## Desarrollo

La arquitectura modular facilita el mantenimiento y permite organizar las pantallas, modelos, proveedores y servicios de cada sección de forma independiente.

## Licencia

Proyecto desarrollado con fines educativos y de aprendizaje.