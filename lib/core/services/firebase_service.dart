import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:season_app/core/services/notification_service.dart';

class FirebaseService {
  static bool _isInitialized = false;

  /// Initialize Firebase and related services
  static Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('🔥 Firebase already initialized');
      return;
    }

    try {
      debugPrint('🔥 Initializing Firebase...');

      // Initialize Firebase Core
      await Firebase.initializeApp();
      
      _isInitialized = true;
      debugPrint('✅ Firebase initialized successfully');

      // Initialize Notification Service
      await NotificationService().initialize();
      
    } catch (e) {
      debugPrint('❌ Error initializing Firebase: $e');
      rethrow;
    }
  }

  /// Check if Firebase is initialized
  static bool get isInitialized => _isInitialized;
}

