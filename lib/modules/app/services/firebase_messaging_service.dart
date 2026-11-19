
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._();

  static final FirebaseMessagingService instance =
      FirebaseMessagingService._();

  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint(
        'Estado del permiso FCM: '
        '${settings.authorizationStatus}',
      );
      _messaging.onRegistered.listen(
        (String installationId) {
          debugPrint(
            'ID de instalación de Firebase: $installationId',
          );
        },
        onError: (Object error) {
          debugPrint(
            'Error al registrar el dispositivo: $error',
          );
        },
      );
      await _messaging.register();

      FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) {
          debugPrint(
            'Mensaje FCM recibido en primer plano',
          );
          debugPrint('ID: ${message.messageId}');
          debugPrint(
            'Título: ${message.notification?.title}',
          );
          debugPrint(
            'Cuerpo: ${message.notification?.body}',
          );
          debugPrint('Datos: ${message.data}');
        },
        onError: (Object error) {
          debugPrint(
            'Error al recibir mensaje FCM: $error',
          );
        },
      );

      FirebaseMessaging.onMessageOpenedApp.listen(
        (RemoteMessage message) {
          debugPrint(
            'Se abrió la aplicación desde una notificación FCM',
          );
          debugPrint(
            'Título: ${message.notification?.title}',
          );
          debugPrint(
            'Datos: ${message.data}',
          );
        },
        onError: (Object error) {
          debugPrint(
            'Error al abrir la notificación: $error',
          );
        },
      );

      final initialMessage =
          await _messaging.getInitialMessage();

      if (initialMessage != null) {
        debugPrint(
          'La aplicación se abrió desde una notificación FCM',
        );
        debugPrint(
          'Título: ${initialMessage.notification?.title}',
        );
        debugPrint(
          'Cuerpo: ${initialMessage.notification?.body}',
        );
        debugPrint(
          'Datos: ${initialMessage.data}',
        );
      }

      _initialized = true;
      debugPrint(
        'Firebase Messaging inicializado correctamente.',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Error al inicializar Firebase Messaging: $e',
      );
      debugPrint('$stackTrace');
      rethrow;
    }
  }
}
