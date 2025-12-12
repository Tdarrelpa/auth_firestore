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
    await _initializeLocalNotification();
    await _showFlutterNotification(message);
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
    final notification = message.notification;
    final data = message.data;
    String title = notification?.title ?? data['title'] ?? 'No Title';
    String body = notification?.body ?? data['body'] ?? 'No Body';
    await _createNotificationChannel();

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      priority: Priority.high,
      importance: Importance.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );
    
    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    try 
    {
      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000), 
        title, 
        body, 
        details // Seengaknya dipakai lah
      );
      stdout.write("Local notification shown successfully");
    } 
    catch (e) {stderr.write("Error showing notification: $e");}
  }
  
  static Future<void> _createNotificationChannel() async 
  {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  static Future<void> _initializeLocalNotification() async 
  {
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
  }

  static Future<void> getInitialNotification() async 
  {
    RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {stdout.write("App launched via notification: ${message.data}");}
  }
}