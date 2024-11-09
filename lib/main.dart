import 'constants/imports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

// Provider Classes
class MarketProvider with ChangeNotifier {
  List<Map<String, dynamic>> trendingStocks = [
    {'symbol': 'AAPL', 'change': 2.5, 'sentiment': 0.8},
    {'symbol': 'GOOGL', 'change': -1.2, 'sentiment': 0.6},
    {'symbol': 'MSFT', 'change': 1.8, 'sentiment': 0.7},
  ];

  Map<String, dynamic> marketData = {
    'marketCap': '2.8T',
    'volume': '125M',
    'gainers': 280,
    'losers': 120,
  };

  Future<void> fetchMarketData() async {
    await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
  }
}

class SentimentProvider with ChangeNotifier {
  double overallSentiment = 0.75;
  List<double> sentimentTrend = [0.6, 0.65, 0.7, 0.72, 0.75, 0.73, 0.78];
  String sentimentDescription = 'Market sentiment is strongly positive';

  List<Map<String, dynamic>> recentInsights = [
    {
      'title': 'Tech Sector Surge',
      'description': 'Technology stocks showing strong momentum',
      'type': 'positive'
    },
    {
      'title': 'Market Volatility Alert',
      'description': 'Increased market volatility detected',
      'type': 'alert'
    },
  ];

  var trendDates;

  Future<void> fetchSentimentData() async {
    // await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
  }
}

// SettingsProvider for managing app settings
class SettingsProvider with ChangeNotifier {
  bool _notificationsEnabled = true;
  double _alertThreshold = 50.0;
  String _theme = 'Light';

  bool get notificationsEnabled => _notificationsEnabled;
  double get alertThreshold => _alertThreshold;
  String get theme => _theme;

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _alertThreshold = prefs.getDouble('alertThreshold') ?? 50.0;
    _theme = prefs.getString('theme') ?? 'Light';
    notifyListeners();
  }

  Future<void> toggleNotifications(bool isEnabled) async {
    _notificationsEnabled = isEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', isEnabled);
    notifyListeners();
  }

  Future<void> setAlertThreshold(double threshold) async {
    _alertThreshold = threshold;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('alertThreshold', threshold);
    notifyListeners();
  }

  Future<void> setTheme(String theme) async {
    _theme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
    notifyListeners();
  }
}

// Firebase messaging background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => SentimentProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Sentrix',
            debugShowCheckedModeBanner: false,
            theme: settingsProvider.theme == 'Light'
                ? ThemeData(
                    useMaterial3: true,
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: const Color(0xFF2196F3),
                    ),
                    cardTheme: CardTheme(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                : ThemeData.dark().copyWith(
                    useMaterial3: true,
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: const Color(0xFF2196F3),
                      brightness: Brightness.dark,
                    ),
                    cardTheme: CardTheme(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}
