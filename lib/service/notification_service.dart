import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  late FlutterLocalNotificationsPlugin _localNotificationsPlugin;
  late FirebaseMessaging _firebaseMessaging;

  NotificationService._internal() {
    _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _firebaseMessaging = FirebaseMessaging.instance;
  }

  Future<void> initialize() async {
    // Android Initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization
    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      
      // onDidReceiveLocalNotification: (id, title, body, payload) async {
      //   print("📱 iOS Local Notification Received: $title - $body");
      // },
    );

    // Platform Settings
    final InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotificationsPlugin.initialize(initializationSettings);

    // Request Permissions (iOS + Android)
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();

    // Create Notification Channel (Android)
    await _createNotificationChannel();

    // Listen for Foreground Notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 Foreground notification received: ${message.notification?.title}");

      String title = message.notification?.title ?? message.data["title"] ?? "No Title";
      String body = message.notification?.body ?? message.data["body"] ?? "No Body";

      _showLocalNotification(title: title, body: body);
    });

    // Handle Background Notifications
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  }

  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    print('📩 Background notification received: ${message.notification?.title}');
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel_id',
      'Default Notifications',
      description: 'Used for important notifications',
      importance: Importance.high,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(channel);
  }

  Future<void> _showLocalNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'Default Notifications',
      channelDescription: 'Notification channel for default alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
    );
  }

  
/// 🔹 **Retrieve Push Notification Token Based on Platform**
Future<String?> getDeviceToken({int retries = 3}) async {
  String? token;

  for (int i = 0; i < retries; i++) {
    if (Platform.isAndroid) {
      token = await _firebaseMessaging.getToken();
    } else if (Platform.isIOS) {
      token = await _firebaseMessaging.getAPNSToken();
    }

    if (token != null) {
      print("✅ Token Received: $token");
      return token;
    }

    print("⚠️ Token is null, retrying in 2 seconds...");
    await Future.delayed(const Duration(seconds: 2));
  }

  print("❌ Failed to fetch token after $retries attempts.");
  return null;
}

}
