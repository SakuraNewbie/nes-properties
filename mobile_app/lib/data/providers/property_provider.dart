import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/property.dart';
import '../../core/network/api_service.dart';
import '../../core/constants/app_constants.dart';

class PropertyProvider extends ChangeNotifier {
  List<Property> _properties = [];
  List<Property> _featuredProperties = [];
  List<Property> _favorites = [];
  Property? _selectedProperty;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;
  String _searchQuery = '';
  PropertyFilters _filters = PropertyFilters();

  List<Property> get properties => _properties;
  List<Property> get featuredProperties => _featuredProperties;
  List<Property> get favorites => _favorites;
  Property? get selectedProperty => _selectedProperty;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;
  String get searchQuery => _searchQuery;
  PropertyFilters get filters => _filters;

  final ApiService _apiService = ApiService.instance;

  PropertyProvider() {
    _loadInitialData();
  }

  // Load initial data
  Future<void> _loadInitialData() async {
    await Future.wait([
      loadProperties(),
      loadFeaturedProperties(),
      loadFavorites(),
    ]);
  }

  // Load properties with pagination
  Future<void> loadProperties({
    bool refresh = false,
    String? search,
    PropertyFilters? filters,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _properties.clear();
    }

    if (!_hasMoreData && !refresh) return;

    _setLoading(refresh ? true : false);
    _setLoadingMore(refresh ? false : true);
    _clearError();

    try {
      final response = await _apiService.getProperties(
        page: _currentPage,
        search: search ?? _searchQuery,
        type: filters?.type ?? _filters.type,
        minPrice: filters?.minPrice ?? _filters.minPrice,
        maxPrice: filters?.maxPrice ?? _filters.maxPrice,
        genderRestriction: filters?.genderRestriction ?? _filters.genderRestriction,
        amenities: filters?.amenities ?? _filters.amenities,
        sortBy: filters?.sortBy ?? _filters.sortBy,
        sortOrder: filters?.sortOrder ?? _filters.sortOrder,
      );

      if (refresh) {
        _properties = response.properties;
      } else {
        _properties.addAll(response.properties);
      }

      _hasMoreData = response.hasNext;
      _currentPage++;

      // Update search query and filters
      if (search != null) _searchQuery = search;
      if (filters != null) _filters = filters;

    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
      _setLoadingMore(false);
    }
  }

  // Load featured properties
  Future<void> loadFeaturedProperties() async {
    try {
      final response = await _apiService.getFeaturedProperties();
      _featuredProperties = response.properties;
      notifyListeners();
    } catch (e) {
      // Featured properties failure shouldn't block the app
      debugPrint('Failed to load featured properties: $e');
    }
  }

  // Load property details
  Future<void> loadPropertyDetails(String propertyId) async {
    _setLoading(true);
    _clearError();

    try {
      final property = await _apiService.getProperty(propertyId);
      _selectedProperty = property;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Search properties
  Future<void> searchProperties(String query) async {
    _searchQuery = query;
    await loadProperties(refresh: true, search: query);
  }

  // Apply filters
  Future<void> applyFilters(PropertyFilters filters) async {
    _filters = filters;
    await loadProperties(refresh: true, filters: filters);
  }

  // Clear filters
  Future<void> clearFilters() async {
    _filters = PropertyFilters();
    await loadProperties(refresh: true);
  }

  // Load more properties (pagination)
  Future<void> loadMoreProperties() async {
    if (!_hasMoreData || _isLoadingMore) return;
    await loadProperties();
  }

  // ============ FAVORITES ============

  // Load user favorites
  Future<void> loadFavorites() async {
    try {
      final favorites = await _apiService.getFavorites();
      _favorites = favorites;
      notifyListeners();
    } catch (e) {
      // Favorites might require authentication
      debugPrint('Failed to load favorites: $e');
    }
  }

  // Add property to favorites
  Future<bool> addToFavorites(String propertyId) async {
    try {
      await _apiService.addToFavorites(propertyId);
      
      // Find and update the property in local lists
      _updatePropertyFavoriteStatus(propertyId, true);
      
      // Reload favorites to get updated list
      await loadFavorites();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Remove property from favorites
  Future<bool> removeFromFavorites(String propertyId) async {
    try {
      await _apiService.removeFromFavorites(propertyId);
      
      // Find and update the property in local lists
      _updatePropertyFavoriteStatus(propertyId, false);
      
      // Remove from favorites list
      _favorites.removeWhere((property) => property.id == propertyId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Check if property is in favorites
  bool isFavorite(String propertyId) {
    return _favorites.any((property) => property.id == propertyId);
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String propertyId) async {
    if (isFavorite(propertyId)) {
      return await removeFromFavorites(propertyId);
    } else {
      return await addToFavorites(propertyId);
    }
  }

  // ============ HELPER METHODS ============

  void _updatePropertyFavoriteStatus(String propertyId, bool isFavorite) {
    // Update in main properties list
    final propertyIndex = _properties.indexWhere((p) => p.id == propertyId);
    if (propertyIndex != -1) {
      // Note: Property model doesn't have favorite status, 
      // but we track it in the favorites list
    }

    // Update in featured properties list
    final featuredIndex = _featuredProperties.indexWhere((p) => p.id == propertyId);
    if (featuredIndex != -1) {
      // Same as above
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
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

  // Clear selected property
  void clearSelectedProperty() {
    _selectedProperty = null;
    notifyListeners();
  }

  // Get properties by type
  List<Property> getPropertiesByType(String type) {
    return _properties.where((property) => 
      property.type.toLowerCase() == type.toLowerCase()
    ).toList();
  }

  // Get properties in price range
  List<Property> getPropertiesInPriceRange(double minPrice, double maxPrice) {
    return _properties.where((property) => 
      property.price >= minPrice && property.price <= maxPrice
    ).toList();
  }

  // Get properties with specific amenity
  List<Property> getPropertiesWithAmenity(String amenity) {
    return _properties.where((property) => 
      property.amenities.any((a) => 
        a.toLowerCase().contains(amenity.toLowerCase()))
    ).toList();
  }

  // Sort properties
  void sortProperties(String sortBy, {bool ascending = true}) {
    switch (sortBy) {
      case 'price':
        _properties.sort((a, b) => ascending 
            ? a.price.compareTo(b.price)
            : b.price.compareTo(a.price));
        break;
      case 'distance':
        _properties.sort((a, b) => ascending 
            ? a.location.distanceToUSAS.compareTo(b.location.distanceToUSAS)
            : b.location.distanceToUSAS.compareTo(a.location.distanceToUSAS));
        break;
      case 'date':
        _properties.sort((a, b) => ascending 
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
    }
    notifyListeners();
  }

  // Filter properties locally
  List<Property> filterPropertiesLocally(PropertyFilters filters) {
    return _properties.where((property) {
      // Type filter
      if (filters.type != null && 
          property.type.toLowerCase() != filters.type!.toLowerCase()) {
        return false;
      }

      // Price range filter
      if (filters.minPrice != null && property.price < filters.minPrice!) {
        return false;
      }
      if (filters.maxPrice != null && property.price > filters.maxPrice!) {
        return false;
      }

      // Gender restriction filter
      if (filters.genderRestriction != null && 
          property.genderRestriction != filters.genderRestriction) {
        return false;
      }

      // Amenities filter
      if (filters.amenities != null && filters.amenities!.isNotEmpty) {
        final hasAllAmenities = filters.amenities!.every((amenity) =>
          property.amenities.any((a) => 
            a.toLowerCase().contains(amenity.toLowerCase()))
        );
        if (!hasAllAmenities) return false;
      }

      return true;
    }).toList();
  }
}

// Property filters model
class PropertyFilters {
  final String? type;
  final double? minPrice;
  final double? maxPrice;
  final String? genderRestriction;
  final List<String>? amenities;
  final String? sortBy;
  final String? sortOrder;

  PropertyFilters({
    this.type,
    this.minPrice,
    this.maxPrice,
    this.genderRestriction,
    this.amenities,
    this.sortBy,
    this.sortOrder,
  });

  PropertyFilters copyWith({
    String? type,
    double? minPrice,
    double? maxPrice,
    String? genderRestriction,
    List<String>? amenities,
    String? sortBy,
    String? sortOrder,
  }) {
    return PropertyFilters(
      type: type ?? this.type,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      genderRestriction: genderRestriction ?? this.genderRestriction,
      amenities: amenities ?? this.amenities,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  bool get hasFilters {
    return type != null ||
           minPrice != null ||
           maxPrice != null ||
           genderRestriction != null ||
           (amenities != null && amenities!.isNotEmpty);
  }

  @override
  String toString() {
    return 'PropertyFilters(type: $type, priceRange: $minPrice-$maxPrice, genderRestriction: $genderRestriction, amenities: $amenities)';
  }
}