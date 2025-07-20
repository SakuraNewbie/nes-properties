import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../../core/network/api_service.dart';
import '../../core/constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  final ApiService _apiService = ApiService.instance;

  AuthProvider() {
    _checkAuthStatus();
  }

  // Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.accessTokenKey);
      final userJson = prefs.getString(AppConstants.userDataKey);

      if (token != null && userJson != null) {
        // Try to get current user from API to verify token
        final user = await _apiService.getCurrentUser();
        _setUser(user);
        _isAuthenticated = true;
      }
    } catch (e) {
      // Token might be expired, clear storage
      await _clearAuthData();
    } finally {
      _setLoading(false);
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final authResponse = await _apiService.login(email, password);
      
      // Save auth data
      await _saveAuthData(
        authResponse.token,
        authResponse.refreshToken,
        authResponse.user,
      );

      _setUser(authResponse.user);
      _isAuthenticated = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Register user
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final authResponse = await _apiService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      // Save auth data
      await _saveAuthData(
        authResponse.token,
        authResponse.refreshToken,
        authResponse.user,
      );

      _setUser(authResponse.user);
      _isAuthenticated = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    }

    await _clearAuthData();
    _user = null;
    _isAuthenticated = false;
    _setLoading(false);
  }

  // Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _apiService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      _setUser(updatedUser);
      
      // Update stored user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userDataKey, updatedUser.toString());
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Helper methods
  void _setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Save authentication data to local storage
  Future<void> _saveAuthData(String token, String refreshToken, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.accessTokenKey, token);
    await prefs.setString(AppConstants.refreshTokenKey, refreshToken);
    await prefs.setString(AppConstants.userDataKey, user.toString());
  }

  // Clear authentication data from local storage
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.accessTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.userDataKey);
  }

  // Check if user has specific role
  bool hasRole(String role) {
    return _user?.role == role;
  }

  // Check if user is admin
  bool get isAdmin => hasRole('admin');

  // Check if user is owner
  bool get isOwner => hasRole('owner');

  // Check if user is regular user
  bool get isUser => hasRole('user');

  // Get user display name
  String get displayName {
    if (_user != null) {
      return _user!.fullName;
    }
    return 'Guest';
  }

  // Get user avatar URL
  String? get avatarUrl {
    return _user?.profileImage;
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (!_isAuthenticated) return;

    try {
      final user = await _apiService.getCurrentUser();
      _setUser(user);
    } catch (e) {
      // If refresh fails, user might need to login again
      await logout();
    }
  }
}