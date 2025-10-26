import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 Background Message: ${message.messageId}');
  debugPrint('📩 Title: ${message.notification?.title}');
  debugPrint('📩 Body: ${message.notification?.body}');
  debugPrint('📩 Data: ${message.data}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  bool _isInitialized = false;

  // Getters
  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase Messaging and Local Notifications
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('🔔 Notification Service already initialized');
      return;
    }

    try {
      debugPrint('🔔 Initializing Notification Service...');

      // Request notification permissions
      await _requestPermissions();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      await _getFCMToken();

      // Setup message handlers
      _setupMessageHandlers();

      // Listen to token refresh
      _setupTokenRefreshListener();

      _isInitialized = true;
      debugPrint('✅ Notification Service initialized successfully');
      debugPrint('🔑 FCM Token: $_fcmToken');
    } catch (e) {
      debugPrint('❌ Error initializing Notification Service: $e');
      rethrow;
    }
  }

  /// Request notification permissions (iOS & Android 13+)
  Future<NotificationSettings> _requestPermissions() async {
    debugPrint('🔔 Requesting notification permissions...');

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('🔔 Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('⚠️ User granted provisional notification permission');
    } else {
      debugPrint('❌ User declined or has not accepted notification permission');
    }

    return settings;
  }

  /// Initialize Flutter Local Notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    debugPrint('🔔 Initializing local notifications...');

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize with callback for when notification is tapped
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }

    debugPrint('✅ Local notifications initialized');
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'season_app_channel', // id
      'Season App Notifications', // name
      description: 'Notifications from Season App',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    debugPrint('✅ Android notification channel created');
  }

  /// Get FCM token
  Future<String?> _getFCMToken() async {
    try {
      debugPrint('🔔 Getting FCM token...');
      
      if (Platform.isIOS) {
        // For iOS, get APNs token first
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        debugPrint('📱 APNs Token: $apnsToken');
        
        if (apnsToken == null) {
          debugPrint('⚠️ APNs token not available yet, will retry...');
          // Wait a bit and retry
          await Future.delayed(const Duration(seconds: 2));
          apnsToken = await _firebaseMessaging.getAPNSToken();
        }
      }

      _fcmToken = await _firebaseMessaging.getToken();
      
      if (_fcmToken != null) {
        debugPrint('✅ FCM Token: $_fcmToken');
        await _saveFCMToken(_fcmToken!);
      } else {
        debugPrint('⚠️ FCM Token is null');
      }

      return _fcmToken;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Save FCM token to local storage
  Future<void> _saveFCMToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      debugPrint('💾 FCM Token saved to local storage');
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  /// Get saved FCM token from local storage
  Future<String?> getSavedFCMToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('fcm_token');
      debugPrint('📖 Retrieved FCM Token from storage: $token');
      return token;
    } catch (e) {
      debugPrint('❌ Error retrieving FCM token: $e');
      return null;
    }
  }

  /// Setup message handlers for foreground, background, and terminated states
  void _setupMessageHandlers() {
    debugPrint('🔔 Setting up message handlers...');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message tap (when app is in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

    // Handle notification tap when app was terminated
    _handleTerminatedMessageTap();

    debugPrint('✅ Message handlers configured');
  }

  /// Handle foreground messages (when app is open)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📩 Foreground Message Received');
    debugPrint('📩 Message ID: ${message.messageId}');
    debugPrint('📩 Title: ${message.notification?.title}');
    debugPrint('📩 Body: ${message.notification?.body}');
    debugPrint('📩 Data: ${message.data}');

    // Show local notification when app is in foreground
    if (message.notification != null) {
      await _showLocalNotification(
        title: message.notification!.title ?? 'New Notification',
        body: message.notification!.body ?? '',
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Handle background message tap (when app is in background and user taps notification)
  void _handleBackgroundMessageTap(RemoteMessage message) {
    debugPrint('📩 Background Message Tapped');
    debugPrint('📩 Message ID: ${message.messageId}');
    debugPrint('📩 Data: ${message.data}');

    // Navigate or perform action based on notification data
    _handleNotificationAction(message.data);
  }

  /// Handle terminated message tap (when app was closed and user taps notification)
  Future<void> _handleTerminatedMessageTap() async {
    // Get initial message if app was opened from terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('📩 App opened from terminated state via notification');
      debugPrint('📩 Message ID: ${initialMessage.messageId}');
      debugPrint('📩 Data: ${initialMessage.data}');

      // Handle the notification action
      _handleNotificationAction(initialMessage.data);
    }
  }

  /// Handle notification action based on data
  void _handleNotificationAction(Map<String, dynamic> data) {
    debugPrint('🎯 Handling notification action with data: $data');

    // TODO: Implement navigation or actions based on notification data
    // Example:
    // if (data.containsKey('type')) {
    //   switch (data['type']) {
    //     case 'message':
    //       // Navigate to messages screen
    //       break;
    //     case 'order':
    //       // Navigate to order details
    //       break;
    //   }
    // }
  }

  /// Show local notification (for foreground messages)
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'season_app_channel',
        'Season App Notifications',
        channelDescription: 'Notifications from Season App',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecond, // notification id
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      debugPrint('✅ Local notification shown: $title');
    } catch (e) {
      debugPrint('❌ Error showing local notification: $e');
    }
  }

  /// Callback when local notification is tapped
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🎯 Notification tapped: ${response.payload}');

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _handleNotificationAction(data);
      } catch (e) {
        debugPrint('❌ Error parsing notification payload: $e');
      }
    }
  }

  /// Setup token refresh listener
  void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 FCM Token refreshed: $newToken');
      _fcmToken = newToken;
      _saveFCMToken(newToken);
      
      // TODO: Send updated token to your backend
      // _sendTokenToBackend(newToken);
    });
  }

  /// Delete FCM token (useful for logout)
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
      
      debugPrint('✅ FCM Token deleted');
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Get notification permission status
  Future<bool> isNotificationEnabled() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Request permission again (useful for settings screen)
  Future<bool> requestPermissionAgain() async {
    final settings = await _requestPermissions();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Subscribe to "all_users" topic for broadcast messages
  Future<void> subscribeToAllUsers() async {
    await subscribeToTopic('all_users');
    debugPrint('📢 Subscribed to broadcast notifications');
  }

  /// Subscribe to user-specific topic (e.g., for personal notifications)
  Future<void> subscribeToUserTopic(String userId) async {
    await subscribeToTopic('user_$userId');
    debugPrint('👤 Subscribed to user notifications: $userId');
  }

  /// Unsubscribe from user-specific topic (useful on logout)
  Future<void> unsubscribeFromUserTopic(String userId) async {
    await unsubscribeFromTopic('user_$userId');
    debugPrint('👤 Unsubscribed from user notifications: $userId');
  }
}

