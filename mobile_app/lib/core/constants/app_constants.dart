class AppConstants {
  // App Information
  static const String appName = 'NES Properties';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your trusted property partner in Malaysia';

  // API Configuration
  static const String baseUrl = 'http://localhost:3001/api';
  static const String apiVersion = 'v1';
  
  // Endpoints
  static const String authEndpoint = '/auth';
  static const String propertiesEndpoint = '/properties';
  static const String usersEndpoint = '/users';
  static const String chatbotEndpoint = '/chatbot';
  static const String ownersEndpoint = '/owners';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themePreferenceKey = 'theme_preference';
  static const String languagePreferenceKey = 'language_preference';
  static const String favoritesKey = 'favorites';
  static const String searchHistoryKey = 'search_history';

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Property Constants
  static const List<String> propertyTypes = [
    'Terrace',
    'Apartment',
    'Condo',
    'House',
    '1-Storey Terrace',
    '2-Storey Terrace',
    'Semi-D'
  ];

  static const List<String> genderRestrictions = [
    'none',
    'male_only',
    'female_only'
  ];

  static const List<String> amenities = [
    'Air Conditioning',
    'WiFi',
    'Parking',
    'Security',
    'Swimming Pool',
    'Gym',
    'Laundry',
    'Kitchen',
    'Furnished',
    'Utilities Included',
    'Pet Friendly',
    'Study Room',
    'Common Area',
    'Near Public Transport',
    'Shopping Mall Nearby'
  ];

  // Map Constants
  static const double defaultMapZoom = 14.0;
  static const double klLatitude = 3.139003;
  static const double klLongitude = 101.686855;

  // Firebase Constants
  static const String fcmTopicAllUsers = 'all_users';
  static const String fcmTopicPropertyUpdates = 'property_updates';

  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection';
  static const String serverErrorMessage = 'Server error. Please try again later';
  static const String unauthorizedErrorMessage = 'Please login to continue';
  static const String notFoundErrorMessage = 'Resource not found';
  static const String validationErrorMessage = 'Please check your input';

  // Success Messages
  static const String loginSuccessMessage = 'Welcome back!';
  static const String registerSuccessMessage = 'Account created successfully!';
  static const String propertyAddedMessage = 'Property added to favorites';
  static const String propertyRemovedMessage = 'Property removed from favorites';

  // Chat Constants
  static const int maxMessageLength = 1000;
  static const List<String> quickReplies = [
    'Show all properties',
    'Student accommodations',
    'Properties for women only',
    'Properties near USAS',
    'Budget friendly options',
    'View virtual tours',
    'Contact property owner',
    'Schedule viewing'
  ];

  // Image Constants
  static const String defaultPropertyImage = 'assets/images/default_property.png';
  static const String defaultUserAvatar = 'assets/images/default_avatar.png';
  static const String logoImage = 'assets/images/logo.png';
  static const String logoWithText = 'assets/images/logo_with_text.png';

  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxPropertyTitleLength = 100;
  static const int maxPropertyDescriptionLength = 1000;
  static const double minPropertyPrice = 100;
  static const double maxPropertyPrice = 10000000;
}