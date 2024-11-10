import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sentrix/screens/login.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _notificationsEnabled = true;
  double _alertThreshold = 50;

  Future<void> _handleLogout() async {
    try {
      await _auth.signOut();
      if (mounted) {
        // Navigate to login page and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error logging out. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: currentUser?.photoURL != null
                            ? ClipCircle(
                                child: CachedNetworkImage(
                                  imageUrl: currentUser!.photoURL!,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.person, size: 50),
                                ),
                              )
                            : const Icon(Icons.person,
                                size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 16),

                      // User Name
                      Text(
                        currentUser?.displayName ?? 'User',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),

                      // User Email
                      Text(
                        currentUser?.email ?? 'No email',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Settings Section
              Card(
                elevation: 4,
                child: Column(
                  children: [
                    // Notifications Toggle
                    ListTile(
                      title: const Text('Enable Notifications'),
                      subtitle: const Text('Receive alerts and updates'),
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                    ),
                    const Divider(),

                    // Alert Threshold Slider
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alert Threshold: ${_alertThreshold.toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Slider(
                            value: _alertThreshold,
                            min: 0,
                            max: 100,
                            divisions: 20,
                            label: '${_alertThreshold.toStringAsFixed(0)}%',
                            onChanged: (value) {
                              setState(() {
                                _alertThreshold = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Separate ClipCircle widget
class ClipCircle extends StatelessWidget {
  final Widget child;

  const ClipCircle({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox.fromSize(
        size: const Size.fromRadius(50), // Matches the CircleAvatar radius
        child: child,
      ),
    );
  }
}
