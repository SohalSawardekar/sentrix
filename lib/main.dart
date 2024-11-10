import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:sentrix/providers/MarketDataProvider.dart';
import 'package:sentrix/providers/sentiment_provider.dart';
import 'package:sentrix/screens/login.dart';
import 'package:sentrix/screens/dashboard_screen.dart';
import 'package:sentrix/firebase_options.dart';
import 'package:sentrix/constants/material_theme_ui.dart';

// Firebase messaging background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup Firebase Messaging
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Local Notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: DarwinInitializationSettings(),
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MarketDataProvider()),
        ChangeNotifierProvider(create: (_) => SentimentDataProvider()),
        ChangeNotifierProvider(
            create: (_) => ThemeNotifier()), // ThemeNotifier provider
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, theme, child) {
          // Define light and dark theme color schemes
          ColorScheme lightColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          );
          ColorScheme darkColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          );

          return MaterialApp(
            title: 'Sentrix',
            debugShowCheckedModeBanner: false,
            themeMode: theme.currentTheme, // Current theme mode (light or dark)
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lightColorScheme,
              appBarTheme: AppBarTheme(
                backgroundColor: lightColorScheme.primary,
                foregroundColor: Colors.white,
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.black),
                bodyMedium: TextStyle(color: Colors.black),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: darkColorScheme.background,
              colorScheme: darkColorScheme,
              appBarTheme: AppBarTheme(
                color: darkColorScheme.primary,
                titleTextStyle: TextStyle(color: darkColorScheme.onPrimary),
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white),
              ),
            ),
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data != null) {
                  // User is logged in
                  return const DashboardScreen();
                }

                // User is not logged in
                return const LoginPage();
              },
            ),
          );
        },
      ),
    );
  }
}
