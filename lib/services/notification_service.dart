import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to handle local notification functionality
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _initialized = false;
  bool _permissionGranted = false;
  String? _fcmToken;
  final Set<String> _shownNotifications = {};

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize local notifications
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Check notification permission status
      await _checkNotificationPermission();

      // Initialize FCM
      await _initializeFCM();

      // Load persistent notifications
      await _loadShownNotifications();

      _initialized = true;
      debugPrint('✅ NotificationService initialized');
    } catch (e) {
      debugPrint('❌ NotificationService initialization error: $e');
    }
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFCM() async {
    try {
      // Request FCM permission
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ FCM permission granted');

        // Get FCM token
        _fcmToken = await _fcm.getToken();
        debugPrint('✅ FCM Token: $_fcmToken');

        // Save token to Firestore will be handled by auth service
        // We'll provide a method to save it

        // Listen to token refresh
        _fcm.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          debugPrint('🔄 FCM Token refreshed: $newToken');
          // Update token in Firestore
          _saveTokenToFirestore(newToken);
        });

        // Setup FCM message handlers
        _setupFCMHandlers();
      } else {
        debugPrint('❌ FCM permission denied');
      }
    } catch (e) {
      debugPrint('❌ FCM initialization error: $e');
    }
  }

  /// Setup FCM message handlers
  void _setupFCMHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📨 Foreground message received');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');

      // Show local notification when app is in foreground
      if (message.notification != null) {
        showLocalNotification(
          title: message.notification!.title ?? 'New Notification',
          body: message.notification!.body ?? '',
          payload: message.data['type'] ?? '',
        );
      }
    });

    // Handle background messages (when app is in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📨 Background message opened');
      _handleNotificationTap(message.data);
    });

    // Check if app was opened from a terminated state
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('📨 App opened from terminated state');
        _handleNotificationTap(message.data);
      }
    });
  }

  /// Handle notification tap navigation
  void _handleNotificationTap(Map<String, dynamic> data) {
    // You can add navigation logic here based on notification type
    debugPrint('Notification tapped with data: $data');
  }

  /// Save FCM token to Firestore for the current user
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      // This will be called from auth service after user logs in
      // Keeping it here for token refresh
      debugPrint('Token saved to Firestore: $token');
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  /// Load persistent shown notification IDs
  Future<void> _loadShownNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIds = prefs.getStringList('shown_notifications') ?? [];
      _shownNotifications.addAll(savedIds);
      debugPrint('📝 Loaded ${_shownNotifications.length} persistent notification IDs');
    } catch (e) {
      debugPrint('❌ Error loading persistent notifications: $e');
    }
  }

  /// Save persistent shown notification IDs
  Future<void> _saveShownNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('shown_notifications', _shownNotifications.toList());
    } catch (e) {
      debugPrint('❌ Error saving persistent notifications: $e');
    }
  }

  /// Listen for broadcast notifications from Firestore
  void listenToBroadcastNotifications(String userRole) {
    try {
      debugPrint('🔔 Starting broadcast notification listener for role: $userRole');
      
      _firestore
          .collection('broadcast_notifications')
          .where('sentTo', arrayContains: userRole)
          .snapshots()
          .listen(
        (snapshot) {
          try {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                final data = change.doc.data();
                if (data != null) {
                  final title = data['title'] as String? ?? 'Notification';
                  final body = data['body'] as String? ?? '';
                  final type = data['type'] as String? ?? '';

                  // Check if we haven't shown this notification yet
                  final docId = change.doc.id;
                  _showBroadcastNotification(docId, title, body, type);
                } else {
                  debugPrint('⚠️ Broadcast notification document has null data');
                }
              }
            }
          } catch (e) {
            debugPrint('❌ Error processing broadcast notification: $e');
            // Continue listening despite errors
          }
        },
        onError: (error) {
          debugPrint('❌ Broadcast notification stream error: $error');
          // Stream will automatically retry
        },
      );
    } catch (e) {
      debugPrint('❌ Error setting up broadcast notification listener: $e');
    }
  }



  Future<void> _showBroadcastNotification(
    String id,
    String title,
    String body,
    String type,
  ) async {
    // Prevent duplicate notifications
    if (_shownNotifications.contains(id)) {
      debugPrint('🚫 Skipping duplicate notification: $id');
      return;
    }

    _shownNotifications.add(id);
    await _saveShownNotifications();

    // Show the notification
    await showLocalNotification(
      title: title,
      body: body,
      payload: type,
    );

    // Increment badge
    if (type == 'admin_announcement') {
      await incrementBadge('admin_announcements');
    } else if (type == 'student_message') {
      await incrementBadge('student_messages');
    }
  }

  /// Check and request notification permissions
  Future<void> _checkNotificationPermission() async {
    try {
      var status = await Permission.notification.status;
      _permissionGranted = status.isGranted;

      // If permission is denied, request it
      if (!_permissionGranted &&
          (status.isDenied || status.isPermanentlyDenied)) {
        var result = await Permission.notification.request();
        _permissionGranted = result.isGranted;
      }

      // Save permission status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _permissionGranted);

      debugPrint('📱 Notification permission: $_permissionGranted');
    } catch (e) {
      debugPrint('❌ Error checking notification permission: $e');
      // Fallback to true for older Android versions
      _permissionGranted = true;
    }
  }

  /// Request notification permissions with popup dialog
  Future<bool> requestPermissionWithPopup(BuildContext context) async {
    try {
      var status = await Permission.notification.status;

      // If already granted, return true
      if (status.isGranted) {
        _permissionGranted = true;
        return true;
      }

      // If permanently denied, open app settings
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }

      // Show explanation dialog and then request permission
      bool shouldRequest = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.blue),
                SizedBox(width: 10),
                Text('Enable Notifications'),
              ],
            ),
            content: const Text(
              'Stay updated with important announcements and reminders. '
              'Allow notifications to receive timely updates from your school.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Not Now'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Allow'),
              ),
            ],
          );
        },
      );

      if (shouldRequest) {
        var result = await Permission.notification.request();
        _permissionGranted = result.isGranted;

        // Save permission status
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('notifications_enabled', _permissionGranted);

        return _permissionGranted;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');
      return false;
    }
  }

  /// Request notification permissions (for iOS mainly)
  Future<bool> requestPermission() async {
    try {
      var status = await Permission.notification.status;

      // If not granted, request permission
      if (!status.isGranted) {
        var result = await Permission.notification.request();
        _permissionGranted = result.isGranted;
      } else {
        _permissionGranted = true;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _permissionGranted);

      debugPrint('📱 Notification permission: $_permissionGranted');
      return _permissionGranted;
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');
      return false;
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      // Refresh permission status
      await _checkNotificationPermission();
      return _permissionGranted;
    } catch (e) {
      return false;
    }
  }

  /// Show local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Refresh permission status before showing notification
    await _checkNotificationPermission();

    if (!_permissionGranted) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'announcements_channel',
        'Announcements',
        channelDescription: 'Notifications for school announcements',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('❌ Error showing local notification: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  /// Increment badge count
  Future<void> incrementBadge(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt('badge_$key') ?? 0;
      await prefs.setInt('badge_$key', currentCount + 1);
    } catch (e) {
      debugPrint('❌ Error incrementing badge: $e');
    }
  }

  /// Decrement badge count
  Future<void> decrementBadge(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt('badge_$key') ?? 0;
      if (currentCount > 0) {
        await prefs.setInt('badge_$key', currentCount - 1);
      }
    } catch (e) {
      debugPrint('❌ Error decrementing badge: $e');
    }
  }

  /// Get badge count
  Future<int> getBadgeCount(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('badge_$key') ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Clear badge count
  Future<void> clearBadge(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('badge_$key', 0);
    } catch (e) {
      debugPrint('❌ Error clearing badge: $e');
    }
  }
}
