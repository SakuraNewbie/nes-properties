# NES Properties Mobile App

A comprehensive Flutter mobile application for the NES Properties real estate platform with modern Material 3 UI design and enhanced mobile-first features.

## Features

### 🏡 Property Management
- Advanced property browsing with grid and list views
- Interactive map integration with property markers
- Powerful filtering by price, location, type, and amenities
- Favorites functionality with local storage
- Property details with image galleries and virtual tours

### 🤖 AI-Powered Chatbot
- Mobile-optimized chat interface
- Voice-to-text integration using speech recognition
- Text-to-speech for chatbot responses
- Quick reply suggestions for common queries
- Property recommendations within chat conversations

### 🌟 Virtual Tours
- 360° panoramic virtual tours
- Gyroscope support for immersive experience
- Fullscreen mode with intuitive controls
- Integration with existing Three.js virtual tours via WebView
- Virtual tour thumbnails and navigation

### 🔐 Authentication & Security
- Email/password authentication
- Google Sign-In integration
- Biometric authentication (fingerprint/face ID)
- Guest mode for property browsing
- Secure token-based API authentication

### 🎨 Modern UI/UX
- Material 3 (Material You) design system
- Dynamic color theming with system integration
- Adaptive layouts for different screen sizes
- Smooth animations and micro-interactions
- Dark/Light theme support with system preference

### 📱 Mobile-First Features
- Push notifications for new properties and updates
- Offline support for cached properties
- Share properties via social media or messaging
- Camera integration for profile pictures
- Location services for nearby properties
- Multi-language support (English/Malay)

### 👤 User Features
- User dashboard with viewing history
- Favorite properties management
- Search history and saved searches
- Viewing appointment scheduling
- Contact preferences and profile management

### 🏢 Owner Features (for property owners)
- Property listing management
- Image and virtual tour content upload
- Property analytics and insights
- Inquiry management system
- Performance tracking

## Technology Stack

### Framework & Language
- **Flutter 3.24+** - Cross-platform mobile development
- **Dart 3.0+** - Programming language

### State Management
- **Provider** - State management solution
- **SharedPreferences** - Local data persistence

### UI & Design
- **Material 3** - Modern design system
- **Dynamic theming** - Adaptive color schemes
- **Custom animations** - Smooth user interactions

### Network & API
- **HTTP/Dio** - REST API communication
- **JSON serialization** - Data parsing

### Storage & Caching
- **SQLite** - Local database
- **SharedPreferences** - Settings storage
- **Cached Network Image** - Image caching

### Maps & Location
- **Google Maps Flutter** - Interactive maps
- **Geolocator** - Location services
- **Location** - Permission handling

### Authentication
- **Google Sign In** - OAuth integration
- **Local Auth** - Biometric authentication
- **JWT** - Token-based authentication

### Media & Communication
- **Speech to Text** - Voice input
- **Flutter TTS** - Text-to-speech
- **Image Picker** - Camera integration
- **WebView** - Web content display

### Virtual Tours & AR
- **Panorama** - 360° image viewing
- **WebView Flutter** - Three.js integration
- **Gyroscope** - Motion-based navigation

### Firebase Integration
- **Firebase Core** - Base configuration
- **Firebase Messaging** - Push notifications
- **Firebase Analytics** - User behavior tracking

### Utilities
- **URL Launcher** - External link handling
- **Share Plus** - Content sharing
- **Connectivity Plus** - Network status
- **Permission Handler** - Runtime permissions
- **Package Info Plus** - App information

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app/
│   ├── app.dart             # Router configuration
│   └── theme/
│       └── app_theme.dart   # Material 3 theme definitions
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── network/
│   │   └── api_service.dart # REST API client
│   └── utils/
├── features/               # Feature-based architecture
│   ├── auth/
│   │   └── screens/        # Authentication screens
│   ├── home/
│   │   └── screens/        # Home and dashboard
│   ├── properties/
│   │   └── screens/        # Property browsing
│   ├── chat/
│   │   └── screens/        # AI chatbot interface
│   ├── virtual_tour/
│   │   └── screens/        # 360° tours
│   ├── profile/
│   │   └── screens/        # User profile
│   └── dashboard/
│       └── screens/        # Owner dashboard
├── shared/
│   ├── widgets/            # Reusable UI components
│   └── services/           # Shared services
└── data/
    ├── models/             # Data models
    ├── repositories/       # Data repositories
    └── providers/          # State management
```

## Getting Started

### Prerequisites
- Flutter SDK 3.24 or higher
- Dart SDK 3.0 or higher
- Android SDK (for Android development)
- Xcode (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/nes-properties.git
   cd nes-properties/mobile_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoints**
   - Update `lib/core/constants/app_constants.dart`
   - Set your backend API URL

4. **Set up Google Maps**
   - Get Google Maps API key
   - Add to `android/app/src/main/AndroidManifest.xml`
   - Add to `ios/Runner/AppDelegate.swift`

5. **Configure Firebase**
   - Create Firebase project
   - Add `google-services.json` (Android)
   - Add `GoogleService-Info.plist` (iOS)

6. **Run the app**
   ```bash
   flutter run
   ```

## API Integration

The app integrates with the existing NES Properties backend API:

- **Base URL**: `http://localhost:3001/api`
- **Authentication**: JWT token-based
- **Endpoints**: Properties, Users, Chat, Owners

### Key API Endpoints
- `GET /properties` - Property listings with filters
- `GET /properties/:id` - Property details
- `POST /auth/login` - User authentication
- `POST /chatbot/message` - AI chatbot interaction
- `GET /users/favorites` - User favorites

## Build & Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Performance Optimization

- **Lazy loading** for property lists
- **Image caching** and optimization
- **Pagination** for large datasets
- **Efficient state management**
- **Code splitting** for reduced app size

## Testing

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new features
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@nesproperties.app or create an issue in the repository.

---

Built with ❤️ using Flutter and Material 3 design principles.