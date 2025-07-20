import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  ThemeData get lightTheme => AppTheme.lightTheme;
  ThemeData get darkTheme => AppTheme.darkTheme;

  ThemeProvider() {
    _loadThemePreference();
  }

  // Load theme preference from storage
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(AppConstants.themePreferenceKey) ?? 0;
      
      switch (themeIndex) {
        case 0:
          _themeMode = ThemeMode.system;
          break;
        case 1:
          _themeMode = ThemeMode.light;
          break;
        case 2:
          _themeMode = ThemeMode.dark;
          break;
      }
      
      _updateDarkModeFlag();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load theme preference: $e');
    }
  }

  // Save theme preference to storage
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int themeIndex = 0;
      
      switch (_themeMode) {
        case ThemeMode.system:
          themeIndex = 0;
          break;
        case ThemeMode.light:
          themeIndex = 1;
          break;
        case ThemeMode.dark:
          themeIndex = 2;
          break;
      }
      
      await prefs.setInt(AppConstants.themePreferenceKey, themeIndex);
    } catch (e) {
      debugPrint('Failed to save theme preference: $e');
    }
  }

  // Update dark mode flag based on theme mode and system settings
  void _updateDarkModeFlag() {
    switch (_themeMode) {
      case ThemeMode.light:
        _isDarkMode = false;
        break;
      case ThemeMode.dark:
        _isDarkMode = true;
        break;
      case ThemeMode.system:
        // This will be updated by the system when brightness changes
        _isDarkMode = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
        break;
    }
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      _updateDarkModeFlag();
      await _saveThemePreference();
      notifyListeners();
    }
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.system:
        // When in system mode, toggle to the opposite of current system setting
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        await setThemeMode(brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
        break;
    }
  }

  // Set light theme
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  // Set dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  // Set system theme
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  // Update dark mode flag when system brightness changes
  void updateSystemBrightness(Brightness brightness) {
    if (_themeMode == ThemeMode.system) {
      final newDarkMode = brightness == Brightness.dark;
      if (_isDarkMode != newDarkMode) {
        _isDarkMode = newDarkMode;
        notifyListeners();
      }
    }
  }

  // Get theme mode display name
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // Get theme mode icon
  IconData get themeModeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.auto_mode;
    }
  }

  // Get current effective brightness
  Brightness get effectiveBrightness {
    switch (_themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
  }

  // Check if currently using dark theme
  bool get isUsingDarkTheme {
    return effectiveBrightness == Brightness.dark;
  }

  // Check if currently using light theme
  bool get isUsingLightTheme {
    return effectiveBrightness == Brightness.light;
  }

  // Check if following system theme
  bool get isFollowingSystem {
    return _themeMode == ThemeMode.system;
  }

  // Get all available theme modes
  List<ThemeModeOption> get availableThemeModes {
    return [
      ThemeModeOption(
        mode: ThemeMode.system,
        name: 'System',
        description: 'Follow system setting',
        icon: Icons.auto_mode,
      ),
      ThemeModeOption(
        mode: ThemeMode.light,
        name: 'Light',
        description: 'Light theme',
        icon: Icons.light_mode,
      ),
      ThemeModeOption(
        mode: ThemeMode.dark,
        name: 'Dark',
        description: 'Dark theme',
        icon: Icons.dark_mode,
      ),
    ];
  }

  // Get color scheme based on current theme
  ColorScheme getColorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }

  // Get text theme based on current theme
  TextTheme getTextTheme(BuildContext context) {
    return Theme.of(context).textTheme;
  }

  // Check if Material You dynamic colors are supported
  bool get supportsDynamicColors {
    // This would need to be implemented based on platform capabilities
    return false; // Simplified for now
  }

  // Reset to default theme
  Future<void> resetToDefault() async {
    await setThemeMode(ThemeMode.system);
  }
}

// Theme mode option model
class ThemeModeOption {
  final ThemeMode mode;
  final String name;
  final String description;
  final IconData icon;

  ThemeModeOption({
    required this.mode,
    required this.name,
    required this.description,
    required this.icon,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeModeOption && other.mode == mode;
  }

  @override
  int get hashCode => mode.hashCode;

  @override
  String toString() {
    return 'ThemeModeOption(mode: $mode, name: $name)';
  }
}