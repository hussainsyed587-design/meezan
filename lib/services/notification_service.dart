import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _isInitialized = false;
  bool _notificationsEnabled = true;
  
  // Notification channels
  static const String _prayerChannelId = 'prayer_notifications';
  static const String _reminderChannelId = 'reminder_notifications';
  static const String _generalChannelId = 'general_notifications';

  // Getters
  bool get isInitialized => _isInitialized;
  bool get notificationsEnabled => _notificationsEnabled;

  // Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    // Android initialization settings
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@drawable/ic_notification');

    // iOS initialization settings  
    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
      macOS: iosInitializationSettings,
    );

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
    
    // Request permissions
    await requestPermissions();
    
    // Load settings
    await _loadSettings();
    
    _isInitialized = true;
    notifyListeners();
  }

  // Create notification channels (Android)
  Future<void> _createNotificationChannels() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Prayer notifications channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _prayerChannelId,
          'Prayer Notifications',
          description: 'Notifications for prayer times and Athan calls',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      // Reminder notifications channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _reminderChannelId,
          'Islamic Reminders',
          description: 'Daily Islamic content and reminders',
          importance: Importance.defaultImportance,
          playSound: true,
          enableVibration: false,
        ),
      );

      // General notifications channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _generalChannelId,
          'General Notifications',
          description: 'App updates and general information',
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
        ),
      );
    }
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    bool granted = false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Request notification permission for Android 13+
      final status = await Permission.notification.request();
      granted = status.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Request permissions for iOS
      granted = await _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    }

    _notificationsEnabled = granted;
    await _saveSettings();
    notifyListeners();
    return granted;
  }

  // Schedule prayer notification - simplified
  Future<void> schedulePrayerNotification({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
    String? customMessage,
    bool enableAzan = true,
  }) async {
    if (!_isInitialized || !_notificationsEnabled) return;

    final title = 'Prayer Time - $prayerName';
    final body = customMessage ?? 'It\'s time for $prayerName prayer';

    // For now, show immediate notification as placeholder
    await showNotification(
      id: id,
      title: title,
      body: body,
    );
  }

  // Schedule daily reminder - simplified
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String message,
    required int hour,
    required int minute,
  }) async {
    if (!_isInitialized || !_notificationsEnabled) return;

    // For now, just show immediate notification as placeholder
    await showNotification(
      id: id,
      title: title,
      body: message,
    );
  }

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized || !_notificationsEnabled) return;

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general_notifications',
          'General Notifications',
          channelDescription: 'App updates and general information',
          importance: Importance.defaultImportance,
          playSound: true,
          enableVibration: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Enable/disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled && !_notificationsEnabled) {
      // Request permissions if enabling
      final granted = await requestPermissions();
      if (!granted) return;
    }

    _notificationsEnabled = enabled;
    await _saveSettings();
    notifyListeners();

    if (!enabled) {
      // Cancel all notifications when disabled
      await cancelAllNotifications();
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      try {
        final data = jsonDecode(payload);
        _handleNotificationAction(data);
      } catch (e) {
        debugPrint('Error handling notification payload: $e');
      }
    }
  }

  // Handle notification actions based on type
  void _handleNotificationAction(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    
    switch (type) {
      case 'prayer':
        // Handle prayer notification tap
        // Navigate to prayer screen or show prayer details
        break;
      case 'reminder':
        // Handle reminder notification tap
        // Navigate to relevant content
        break;
      default:
        // Handle general notification tap
        break;
    }
  }

  // Load notification settings
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  // Save notification settings
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }
}