import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

class NotificationService 
{
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String channelId = "high_importance_channel";
  static const String channelName = "High Importance Notifications";
  static const String channelDescription = "This channel is used for important notifications";

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async 
  {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // await _initializeLocalNotification();
    // await _showFlutterNotification(message);
    stdout.write("Handling a background message: ${message.messageId}");
  }

  static Future<void> initializeLocalNotification() async 
  {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    stdout.write("User granted permission: ${settings.authorizationStatus}");

    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {stdout.write("User tapped notification: ${response.payload}");},
    );

    await _createNotificationChannel();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) 
    {
      stdout.write("Got a message whilst in the foreground!");
      stdout.write("Message data: ${message.data}");

      if (message.notification != null) 
      {
        stdout.write("Message also contained a notification: ${message.notification}");
        _showFlutterNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) 
    {
      stdout.write("Got a message whilst in the foreground!");
      stdout.write("Message data: ${message.data}");

      if (message.notification != null) 
      {
        stdout.write("Message also contained a notification: ${message.notification}");
        _showFlutterNotification(message);
      }
    });

    await getFCMToken();
  }

  static Future<void> getFCMToken() async 
  {
    String? token = await _firebaseMessaging.getToken();
    stdout.write("FCM TOKEN : $token");

    if (token == null) {return;}

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) 
    {
      stdout.write("User not logged in, skipping token save to Firestore.");
      return;
    }

    try 
    {
      // Store token associated with the user's UID
      await _firestore.collection('fcmTokens').doc(user.uid).set({
        'token': token,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      stdout.write("FCM Token saved to Firestore for user ${user.uid}");
    } 
    catch (e) {stderr.write("Error saving FCM token to Firestore: $e");}
  }

  static void getNotification() 
  {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) =>_showFlutterNotification(message));
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) => _showFlutterNotification(message));
  }
  
  static Future<void> _showFlutterNotification(RemoteMessage message) async 
  {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) 
    {
      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  static Future<void> _createNotificationChannel() async 
  {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max, // Max importance for heads-up display
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> getInitialNotification() async 
  {
    // RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
    // if (message != null) {stdout.write("App launched via notification: ${message.data}");}
    RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {stdout.write("App launched via notification: ${message.data}");}
  }
}