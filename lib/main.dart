import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/auth_gate.dart';
import 'app_theme.dart';
import 'firebase_options.dart';

import 'modules/app/providers/auth_provider.dart' as app_auth;

import 'modules/radio/helpers/providers/app_provider.dart' as radio_app;
import 'modules/radio/helpers/providers/audio_provider.dart';
import 'modules/radio/services/audio_service.dart' as radio_audio;
import 'modules/news/services/notification_service.dart';

import 'modules/news/providers/app_provider.dart' as news_theme;
import 'modules/news/providers/auth_provider.dart' as news_auth;
import 'modules/news/providers/news_provider.dart';
import 'modules/news/providers/bookmark_provider.dart';
import 'modules/news/providers/notification_provider.dart';
import 'modules/app/services/firebase_radio_favorites_repository.dart'
    as app_favorites;
import 'modules/radio/helpers/providers/radio_favorites_provider.dart';
import 'modules/radio/services/radio_favorites_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final radio_audio.RadioAudioHandler audioHandler = await AudioService.init(
    builder: () => radio_audio.RadioAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.appmodular.audio',
      androidNotificationChannelName: 'App Modular Radio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(AppModular(audioHandler: audioHandler));
}

class AppModular extends StatelessWidget {
  final radio_audio.RadioAudioHandler audioHandler;

  const AppModular({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<app_auth.AuthProvider>(
          create: (_) => app_auth.AuthProvider(),
        ),

        ChangeNotifierProvider<radio_app.AppProvider>(
          create: (_) => radio_app.AppProvider()..loadData(),
        ),

        ChangeNotifierProvider<AudioProvider>(
          create: (_) => AudioProvider(audioHandler: audioHandler),
        ),

        ChangeNotifierProvider<news_auth.AuthProvider>(
          create: (context) => news_auth.AuthProvider(
            appAuthProvider: context.read<app_auth.AuthProvider>(),
          ),
        ),

        ChangeNotifierProvider<news_theme.AppProvider>(
          create: (_) => news_theme.AppProvider()..loadTheme(),
        ),

        ChangeNotifierProvider<NewsProvider>(
          create: (_) => NewsProvider()..initialize(),
        ),

        ChangeNotifierProxyProvider<news_auth.AuthProvider, BookmarkProvider>(
          create: (_) => BookmarkProvider(),
          update: (_, authProvider, bookmarkProvider) {
            final provider = bookmarkProvider ?? BookmarkProvider();
            provider.setUserId(authProvider.userId);
            return provider;
          },
        ),

        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider()..initialize(),
        ),

        Provider<RadioFavoritesRepository>(
          create: (_) => app_favorites.FirebaseRadioFavoritesRepository(),
        ),

        ChangeNotifierProvider<RadioFavoritesProvider>(
          create: (context) => RadioFavoritesProvider(
            repository: context.read<RadioFavoritesRepository>(),
            currentUserId: () =>
                context.read<app_auth.AuthProvider>().currentUser?.uid,
          ),
        ),
      ],
      child: const AppModularView(),
    );
  }
}

class AppModularView extends StatelessWidget {
  const AppModularView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<news_theme.AppProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'App Modular',
          theme: AppTheme.appTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AuthGate(),
        );
      },
    );
  }
}
