import 'dart:convert';

import 'package:gwealth/models/user_profile_store.dart';
import 'package:gwealth/services/in_app_notification_service.dart';
import 'package:gwealth/services/notification_navigation_service.dart';
import 'package:gwealth/services/notification_service.dart';
import 'package:gwealth/shared/notification_settings_store.dart';
import 'package:gwealth/shared/notification_store.dart';
import 'package:gwealth/splash.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (message.notification != null) return;

  await NotificationService.initForBackground();
  await NotificationSettingsStore.instance.load();

  if (!NotificationSettingsStore.instance.shouldNotify(message.data)) return;

  final settings = NotificationSettingsStore.instance;
  final title = message.data['title']?.toString() ?? 'แจ้งเตือน';
  final body = message.data['body']?.toString() ?? '';
  if (title.isEmpty && body.isEmpty) return;

  await NotificationService.showSystemNotification(
    title: title,
    body: body,
    payload: jsonEncode(message.data),
    sound: settings.shouldPlaySound,
    vibration: settings.shouldVibrate,
  );
}

String _readTitle(RemoteMessage message) =>
    message.notification?.title ??
    message.data['title']?.toString() ??
    'แจ้งเตือน';

String _readBody(RemoteMessage message) =>
    message.notification?.body ?? message.data['body']?.toString() ?? '';

void _handleNotificationPayload(Map<String, dynamic> data) {
  NotificationNavigationService.handlePayload(data);
}

void _handleNotificationNavigation(RemoteMessage message) {
  _handleNotificationPayload(message.data);
}

void _handleLocalNotificationTap(String? payload) {
  if (payload == null || payload.isEmpty) return;
  try {
    final data = jsonDecode(payload);
    if (data is Map) {
      _handleNotificationPayload(Map<String, dynamic>.from(data));
    }
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );

    await NotificationService.init(onTap: _handleLocalNotificationTap);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (!NotificationSettingsStore.instance.shouldNotify(message.data)) {
        if (UserProfileStore.instance.isLoggedIn) {
          NotificationStore.instance.refresh();
        }
        return;
      }

      InAppNotificationService.show(
        title: _readTitle(message),
        body: _readBody(message),
        data: message.data,
        onTap: () => _handleNotificationNavigation(message),
      );

      if (UserProfileStore.instance.isLoggedIn) {
        NotificationStore.instance.refresh();
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationNavigation);

    LineSDK.instance.setup('2009412792').then((_) {
      debugPrint('LineSDK Prepared');
    });
  }

  await initializeDateFormatting('th', null);
  await NotificationSettingsStore.instance.load();
  final startLocale = await _loadSavedLocale();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('th'),
        Locale('en'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('th'),
      startLocale: startLocale,
      saveLocale: true,
      useOnlyLangCode: true,
      child: const _AppView(),
    ),
  );

  if (!kIsWeb) {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationNavigation(initialMessage);
    }
  }
}

final _secureStorage = FlutterSecureStorage();

Future<Locale> _loadSavedLocale() async {
  final localeCode = await _secureStorage.read(key: 'appLanguage');
  if (localeCode != null && localeCode.isNotEmpty) {
    return Locale(localeCode);
  }
  return const Locale('th');
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      title: 'G-Wealth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE84090),
          primary: const Color(0xFFE84090),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.promptTextTheme(),
        fontFamily: GoogleFonts.prompt().fontFamily,
      ),
      home: const SplashPage(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      title: 'G-Wealth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE84090),
          primary: const Color(0xFFE84090),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.promptTextTheme(),
        fontFamily: GoogleFonts.prompt().fontFamily,
      ),
      home: const SplashPage(),
    );
  }
}
