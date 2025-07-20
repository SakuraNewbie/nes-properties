import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../../data/models/user.dart';
import '../../data/models/property.dart';
import '../../data/models/chat_message.dart';

class ApiService {
  static const String _baseUrl = AppConstants.baseUrl;
  static ApiService? _instance;
  
  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }
  
  ApiService._internal();

  // Get auth token from storage
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.accessTokenKey);
  }

  // Get headers with auth token
  Future<Map<String, String>> _getHeaders({bool needsAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (needsAuth) {
      final token = await _getAuthToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _getErrorMessage(response),
      );
    }
  }

  String _getErrorMessage(http.Response response) {
    try {
      final body = json.decode(response.body);
      return body['message'] ?? body['error'] ?? 'Unknown error occurred';
    } catch (e) {
      return 'Server error: ${response.statusCode}';
    }
  }

  // ============ AUTH ENDPOINTS ============

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: await _getHeaders(needsAuth: false),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = _handleResponse(response);
      return AuthResponse.fromJson(data);
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: await _getHeaders(needsAuth: false),
        body: json.encode({
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
        }),
      );

      final data = _handleResponse(response);
      return AuthResponse.fromJson(data);
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/auth/logout'),
        headers: await _getHeaders(),
      );
    } catch (e) {
      // Continue with logout even if API call fails
    }
    
    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.accessTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.userDataKey);
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      return User.fromJson(data['user']);
    } catch (e) {
      throw _handleException(e);
    }
  }

  // ============ PROPERTY ENDPOINTS ============

  Future<PropertyListResponse> getProperties({
    int page = 1,
    int limit = 20,
    String? search,
    String? type,
    double? minPrice,
    double? maxPrice,
    String? genderRestriction,
    List<String>? amenities,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null) queryParams['search'] = search;
      if (type != null) queryParams['type'] = type;
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (genderRestriction != null) queryParams['genderRestriction'] = genderRestriction;
      if (amenities != null && amenities.isNotEmpty) {
        queryParams['amenities'] = amenities.join(',');
      }
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final uri = Uri.parse('$_baseUrl/properties').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await _getHeaders(needsAuth: false));

      final data = _handleResponse(response);
      return PropertyListResponse.fromJson(data);
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<Property> getProperty(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/properties/$id'),
        headers: await _getHeaders(needsAuth: false),
      );

      final data = _handleResponse(response);
      return Property.fromJson(data);
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<PropertyListResponse> getFeaturedProperties() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/properties/featured'),
        headers: await _getHeaders(needsAuth: false),
      );

      final data = _handleResponse(response);
      return PropertyListResponse.fromJson(data);
    } catch (e) {
      throw _handleException(e);
    }
  }

  // ============ CHAT ENDPOINTS ============

  Future<ChatResponse> sendChatMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chatbot/message'),
        headers: await _getHeaders(needsAuth: false),
        body: json.encode({
          'message': message,
        }),
      );

      final data = _handleResponse(response);
      return ChatResponse.fromJson(data);
    } catch (e) {
      throw _handleException(e);
    }
  }

  // ============ USER ENDPOINTS ============

  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (firstName != null) body['firstName'] = firstName;
      if (lastName != null) body['lastName'] = lastName;
      if (phoneNumber != null) body['phoneNumber'] = phoneNumber;

      final response = await http.put(
        Uri.parse('$_baseUrl/users/profile'),
        headers: await _getHeaders(),
        body: json.encode(body),
      );

      final data = _handleResponse(response);
      return User.fromJson(data['user']);
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/change-password'),
        headers: await _getHeaders(),
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      _handleResponse(response);
    } catch (e) {
      throw _handleException(e);
    }
  }

  // ============ FAVORITES ENDPOINTS ============

  Future<List<Property>> getFavorites() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/favorites'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      final List<dynamic> favorites = data['favorites'] ?? [];
      return favorites.map((item) => Property.fromJson(item)).toList();
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<void> addToFavorites(String propertyId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/favorites/$propertyId'),
        headers: await _getHeaders(),
      );

      _handleResponse(response);
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<void> removeFromFavorites(String propertyId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/users/favorites/$propertyId'),
        headers: await _getHeaders(),
      );

      _handleResponse(response);
    } catch (e) {
      throw _handleException(e);
    }
  }

  // ============ HELPER METHODS ============

  Exception _handleException(dynamic error) {
    if (error is ApiException) {
      return error;
    } else if (error is SocketException) {
      return ApiException(
        statusCode: 0,
        message: AppConstants.networkErrorMessage,
      );
    } else {
      return ApiException(
        statusCode: 500,
        message: error.toString(),
      );
    }
  }
}

// ============ RESPONSE MODELS ============

class AuthResponse {
  final String token;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      user: User.fromJson(json['user']),
    );
  }
}

class PropertyListResponse {
  final List<Property> properties;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  PropertyListResponse({
    required this.properties,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PropertyListResponse.fromJson(Map<String, dynamic> json) {
    return PropertyListResponse(
      properties: (json['properties'] as List<dynamic>?)
          ?.map((item) => Property.fromJson(item))
          .toList() ?? [],
      totalCount: json['totalCount'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      hasNext: json['hasNext'] ?? false,
      hasPrevious: json['hasPrevious'] ?? false,
    );
  }
}

class ChatResponse {
  final String response;
  final List<Property>? properties;
  final List<String>? suggestions;

  ChatResponse({
    required this.response,
    this.properties,
    this.suggestions,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      response: json['response'] ?? '',
      properties: json['properties'] != null
          ? (json['properties'] as List)
              .map((item) => Property.fromJson(item))
              .toList()
          : null,
      suggestions: json['suggestions'] != null
          ? List<String>.from(json['suggestions'])
          : null,
    );
  }
}

// ============ EXCEPTION MODEL ============

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}

