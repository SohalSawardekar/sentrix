import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Toggle
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: settingsProvider.notificationsEnabled,
              onChanged: (value) {
                settingsProvider.toggleNotifications(value);
              },
              activeColor: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 20),

            // Alert Threshold Slider
            Text(
              'Alert Threshold: ${settingsProvider.alertThreshold.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Slider(
              value: settingsProvider.alertThreshold,
              min: 0,
              max: 100,
              divisions: 20,
              label: '${settingsProvider.alertThreshold.toStringAsFixed(0)}%',
              onChanged: (value) {
                settingsProvider.setAlertThreshold(value);
              },
              activeColor: Theme.of(context).colorScheme.primary,
              inactiveColor: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
