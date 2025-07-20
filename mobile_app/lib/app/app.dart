import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/properties/screens/properties_screen.dart';
import '../features/properties/screens/property_details_screen.dart';
import '../features/properties/screens/map_view_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/favorites_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/virtual_tour/screens/virtual_tour_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Authentication Routes
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Main App Routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/properties',
        builder: (context, state) => const PropertiesScreen(),
      ),
      GoRoute(
        path: '/property/:id',
        builder: (context, state) {
          final propertyId = state.pathParameters['id']!;
          return PropertyDetailsScreen(propertyId: propertyId);
        },
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapViewScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/virtual-tour/:propertyId',
        builder: (context, state) {
          final propertyId = state.pathParameters['propertyId']!;
          return VirtualTourScreen(propertyId: propertyId);
        },
      ),
    ],
  );
}