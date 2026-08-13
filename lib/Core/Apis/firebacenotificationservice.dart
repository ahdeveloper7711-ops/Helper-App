import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Request notification permission
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Initialize local notification
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings,

      onDidReceiveNotificationResponse: (response) {
        print("🔔 Notification clicked: ${response.payload}");
      },
    );

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',

      'High Importance Notifications',

      description: 'Used for important notifications',

      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("📩 Foreground notification: ${message.messageId}");

      RemoteNotification? notification = message.notification;

      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        await _localNotifications.show(
          notification.hashCode,

          notification.title,

          notification.body,

          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',

              'High Importance Notifications',

              channelDescription: 'Used for important notifications',

              importance: Importance.high,

              priority: Priority.high,
            ),
          ),

          payload: message.data.toString(),
        );
      }
    });

    // When app opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🔔 Opened from notification: ${message.data}");
    });

    // Get FCM token

    String? token = await _messaging.getToken();

    print("📱 FCM TOKEN: $token");
  }
}
