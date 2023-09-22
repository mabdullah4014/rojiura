import 'dart:convert';
import 'dart:io';

import 'package:app/controller/user_controller.dart';
import 'package:app/repo/settings_repository.dart' as settingRepo;
import 'package:app/route_generator.dart';
import 'package:app/utils/app_utils.dart';
import 'package:app/utils/notification_handler.dart';
import 'package:app/utils/pref_util.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:app/utils/extensions.dart';

import 'generated/l10n.dart';
import 'model/setting_object.dart';
import 'model/user.dart';

FirebaseApp app;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

const MethodChannel platform =
    MethodChannel('rojiura/flutter_local_notifications_example');

class ReceivedNotification {
  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("configurations");
  WidgetsFlutterBinding.ensureInitialized();
  app = await Firebase.initializeApp(
      name: 'rojiura-82c91',
      options: Platform.isIOS || Platform.isMacOS
          ? FirebaseOptions(
              appId: '1:659818956340:ios:86a2965c65a3f1a088ac61',
              apiKey: 'AIzaSyBNASL0ICG195w4YDrz_EJS62v8LSHeTUQ',
              projectId: 'rojiura-82c91',
              messagingSenderId: '659818956340',
              databaseURL: 'https://rojiura-82c91-default-rtdb.firebaseio.com/',
            )
          : FirebaseOptions(
              appId: '1:659818956340:android:8c64eda2703ac3fd88ac61',
              apiKey: 'AIzaSyCxuYiXrf7ZQjE7AoVAQsB13RfSDEDNB-c',
              messagingSenderId: '659818956340',
              projectId: 'rojiura-82c91',
              databaseURL: 'https://rojiura-82c91-default-rtdb.firebaseio.com/',
            ));

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          onDidReceiveLocalNotification:
              (int id, String title, String body, String payload) async {
            didReceiveLocalNotificationSubject.add(ReceivedNotification(
                id: id, title: title, body: body, payload: payload));
          });
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  PreferenceUtils.init().then((value) {
    String userString = PreferenceUtils.getString('user', "");
    if (userString.isNotEmpty)
      currentUser.value = User.fromJson(json.decode(userString));
    runApp(MyApp());
  });
}

class MyApp extends AppMVC {
  FirebaseMessaging _firebaseMessaging;

  @override
  void initApp() {
    super.initApp();
    _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.getToken().then((String _deviceToken) {
      print('Push token: $_deviceToken');
      PreferenceUtils.setString("push_token", _deviceToken);
      currentUser.value.push_token = _deviceToken;
    });

    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          const AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails('your channel id', 'your channel name',
                  'your channel description',
                  importance: Importance.max,
                  priority: Priority.high,
                  ticker: 'ticker');
          const NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);
          await flutterLocalNotificationsPlugin.show(
              0,
              message["notification"]["title"],
              message["notification"]["body"],
              platformChannelSpecifics,
              payload: message["data"]["notification"]);
        },
        onBackgroundMessage: myBackgroundMessageHandler,
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
          selectNotificationSubject.add(json.encode(message));
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
          selectNotificationSubject.add(json.encode(message));
        });
  }

  @override
  Widget build(BuildContext buildContext) {
    return DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) {
          if (brightness == Brightness.light) {
            return ThemeData(
                primaryColor: AppUtils.getColorFromHash(AppUtils.darkGreyColor),
                brightness: brightness,
                accentColor:
                    AppUtils.getColorFromHash(AppUtils.lightGreyColor));
          } else {
            return ThemeData(
                primaryColor: AppUtils.getColorFromHash(AppUtils.darkGreyColor),
                brightness: brightness,
                accentColor:
                    AppUtils.getColorFromHash(AppUtils.lightGreyColor));
          }
        },
        themedWidgetBuilder: (context, theme) {
          return ValueListenableBuilder(
              valueListenable: settingRepo.setting,
              builder: (context, Setting _setting, _) {
                return MaterialApp(
                    initialRoute: currentUser.value.uuid.isNullOrEmpty()
                        ? RouteGenerator.LANDING
                        : RouteGenerator.HOME,
                    onGenerateRoute: RouteGenerator.generateRoute,
                    debugShowCheckedModeBanner: true,
                    locale: _setting.mobileLanguage.value,
                    localizationsDelegates: [
                      S.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate
                    ],
                    supportedLocales: S.delegate.supportedLocales,
                    theme: theme);
              });
        });
  }
}
