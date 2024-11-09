import 'constants/imports.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        // Handle auth state
        if (snapshot.hasData) {
          // User is logged in
          return const Homepage();
        } else {
          // User is not logged in
          return const LoginPage();
        }
      },
    );
  }
}

// Loading screen widget
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// Example usage with routes in main.dart:
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Add your theme customization
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const Homepage(),
        // Add more routes as needed
      },
    );
  }
}

// Initialize Firebase and run app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // Make sure to configure this
  );

  // Optional: Handle Firebase initialization errors
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Failed to initialize Firebase: $e');
  }

  runApp(const MyApp());
}

// Optional: Auth service class for centralized auth logic
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user ID
  String? get userId => _auth.currentUser?.uid;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;
}
