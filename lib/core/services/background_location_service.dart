import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

// Shared instance to track background location
StreamSubscription<Position>? _backgroundLocationSubscription;

// Helper function to start background service
Future<void> initializeBackgroundLocationService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: false, // Disable foreground mode to avoid crashes
      notificationChannelId: 'location_updates',
      initialNotificationTitle: 'Season',
      initialNotificationContent: 'Location tracking active',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(),
  );

  debugPrint('✅ Background location service initialized');
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Service runs in separate isolate - just keep it alive
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

// Start background location tracking - runs in main isolate
Future<void> startBackgroundLocationTracking(int groupId) async {
  debugPrint('📍 Starting background location tracking for group $groupId');
  
  // Store group ID
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('active_group_id', groupId);

  // Cancel existing subscription if any
  await _backgroundLocationSubscription?.cancel();

  // Get auth token
  final token = prefs.getString('auth_token');
  if (token == null) {
    debugPrint('❌ No auth token found');
    return;
  }

  // Initialize Dio client
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://seasonksa.com/api',
      headers: {'Authorization': 'Bearer $token'},
      receiveTimeout: const Duration(seconds: 10),
      connectTimeout: const Duration(seconds: 10),
    ),
  );

  Position? lastPosition;
  DateTime lastUpdateTime = DateTime.now();

  // Start position stream - works in background on Android
  _backgroundLocationSubscription = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: 10, // Update when moved 10 meters
      timeLimit: Duration(seconds: 30), // Force update every 30 seconds max
    ),
  ).listen(
    (Position position) {
      final now = DateTime.now();
      final timeSinceLastUpdate = now.difference(lastUpdateTime);

      // Send update if moved significantly or 30 seconds passed
      if (lastPosition == null ||
          timeSinceLastUpdate.inSeconds >= 30 ||
          Geolocator.distanceBetween(
                lastPosition!.latitude,
                lastPosition!.longitude,
                position.latitude,
                position.longitude,
              ) >= 10) {
        lastPosition = position;
        lastUpdateTime = now;

        // Send to API in background
        dio.post('/groups/$groupId/location', data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
        }).then((response) {
          debugPrint('✅ Background location updated: ${position.latitude}, ${position.longitude}');
        }).catchError((e) {
          debugPrint('❌ Background location update failed: $e');
        });
      }
    },
    onError: (error) {
      debugPrint('❌ Location stream error: $error');
    },
  );

  debugPrint('✅ Background location tracking started for group $groupId');
}

// Stop background location tracking
Future<void> stopBackgroundLocationTracking() async {
  debugPrint('🛑 Stopping background location tracking');
  
  // Cancel location subscription
  await _backgroundLocationSubscription?.cancel();
  _backgroundLocationSubscription = null;

  // Remove group ID
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('active_group_id');

  debugPrint('✅ Background location tracking stopped');
}

