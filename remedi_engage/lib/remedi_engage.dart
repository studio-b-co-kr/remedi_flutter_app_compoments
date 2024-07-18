library remedi_engage;

import 'dart:developer' as dev;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

export 'package:firebase_messaging/firebase_messaging.dart';
export 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class FcmManager {
  static String? fcmToken;

  static Future Function(RemoteMessage message)? onBackgroundMessage;

  static init(
      {required Future Function(RemoteMessage message) onBackgroundMessage,
      required AndroidNotificationChannelWrapperList channels,
      String androidDefaultIcon = 'mipmap/ic_launcher'}) async {
    fcmToken = await FirebaseMessaging.instance.getToken();
    dev.log("$fcmToken", name: "FirebaseMessaging.token");

    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            androidDefaultIcon); // <- default icon name is @mipmap/ic_launcher
    DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FcmManager.onBackgroundMessage = onBackgroundMessage;

    if (channels.channels == null || channels.channels!.isEmpty) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(AndroidNotificationChannel(
            channels.defaultChannelId, // id
            channels.defaultChannelTitle, // title
            importance: Importance.high,
          ));
    } else {
      await Future.forEach<AndroidNotificationChannelWrapper>(
          channels.channels!, (channel) async {
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel.channel);
      });
    }

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static requestIOSPermission() async {
    // NotificationSettings settings =
    //     await FirebaseMessaging.instance.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //   provisional: false,
    //   sound: true,
    // );
  }

  static handleInitialMessage(
      {required Function(RemoteMessage message)? handler}) {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null && handler != null) {
        handler(message);
      }
    });
  }

  static handleOnMessage(
      {required AndroidNotificationChannelWrapperList channels}) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      AppleNotification? apple = message.notification?.apple;
      // Android
      if (android != null) {
        if (notification != null) {
          if (channels.channels != null) {
            Future.forEach(channels.channels!,
                (AndroidNotificationChannelWrapper channel) async {
              if (channel.channel.id == android.channelId) {
                _flutterLocalNotificationsPlugin.show(
                    notification.hashCode,
                    notification.title,
                    notification.body,
                    NotificationDetails(
                      android: AndroidNotificationDetails(
                        channel.id,
                        channel.name,
                        icon: channel.icon,
                      ),
                    ));
                return;
              }
            });
          }

          _flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channels.defaultChannelId,
                  channels.defaultChannelTitle,
                  icon: channels.defaultIcon,
                ),
              ));
        }
        return;
      }

      // apple (iphone, ipad)
      if (apple != null) {
        _flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification?.title,
            notification?.body,
            NotificationDetails(iOS: DarwinNotificationDetails()));
        return;
      }
    });
  }

  static handleOnMessageOpenedApp(
      {required Function(RemoteMessage message) handler}) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      handler(message);
    });
  }

  static Future<String?> getFcmToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}

class AndroidNotificationChannelWrapperList {
  final String defaultChannelId;
  final String defaultChannelTitle;
  final String defaultChannelBody;
  final String? defaultIcon;

  final List<AndroidNotificationChannelWrapper>? channels;

  const AndroidNotificationChannelWrapperList(
      {required this.defaultChannelId,
      required this.defaultChannelTitle,
      required this.defaultChannelBody,
      this.defaultIcon,
      this.channels});
}

class AndroidNotificationChannelWrapper {
  final AndroidNotificationChannel channel;
  final String? icon;

  const AndroidNotificationChannelWrapper({required this.channel, this.icon});

  String get id => channel.id;

  String get name => channel.name;
}

class BranchIoManager {}
