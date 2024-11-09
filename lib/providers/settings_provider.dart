import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
