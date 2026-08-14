// ignore_for_file: prefer_const_constructors
import 'package:akhbar/constants/app_constants.dart';
import 'package:akhbar/screens/article_screen.dart';

import 'package:akhbar/screens/onboarding_screen_1.dart';
import 'package:akhbar/screens/profile_screen.dart';
import 'package:akhbar/screens/main_navigation_screen.dart';
import 'package:akhbar/screens/signin_screen.dart';
import 'package:akhbar/screens/signup_screen.dart';
import 'package:akhbar/screens/signup_verification_screen.dart';
import 'package:akhbar/screens/create_password_screen.dart';
import 'package:akhbar/screens/forgot_password_email_screen.dart';
import 'package:akhbar/screens/forgot_password_otp_screen.dart';
import 'package:akhbar/screens/forgot_password_create_password_screen.dart';

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';

// Show Guidelines in App (Flutter Inspector)
void showLayoutGuidelines() {
  debugPaintSizeEnabled = true;
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  await setupFlutterNotifications();
  showFlutterNotification(message);

  print("Handling a background message: ${message.messageId}");
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;
/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'article_event_channel', // id
    'Article publish event channel', // title
    description:
    'This channel is used for notifying new published articles.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
  );
  
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: 'launch_background',
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    // Firebase messaging is not supported on desktop platforms. Skip initialization.
  } else {
    // Run messaging setup in the background so it doesn't block the splash screen
    _setupMessaging();
  }

  runApp(const MyApp());
}

Future<void> _setupMessaging() async {
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    final fcmToken = await FirebaseMessaging.instance.getToken();
    await FirebaseMessaging.instance.subscribeToTopic(AppConstants.ARTICLE_PUBLISH_FCM_TOPIC);

    await setupFlutterNotifications();
    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        showFlutterNotification(message);
      }
    });
  } catch (e) {
    print("Firebase messaging error: $e");
  }
}

screenRightToLeftTransition(BuildContext context, GoRouterState state, Widget screen) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: screen,
    transitionDuration: const Duration(milliseconds: 150),
    reverseTransitionDuration: const Duration(milliseconds: 150),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end);
      final offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
        GoRoute(
          path: "/top_stories",
          name: "top_stories",
          pageBuilder: (BuildContext context, GoRouterState state) {
            return screenRightToLeftTransition(context, state, const MainNavigationScreen(initialIndex: 2));
          },
        ),
    GoRoute(
      path: "/",
      name: "welcome",
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen1(title: "Welcome");
      },
    ),

    GoRoute(
      path: "/signup",
      name: "signup",
      pageBuilder: (BuildContext context, GoRouterState state) {
        return screenRightToLeftTransition(context, state, const SignupScreen(title: "Sign-up"));
      },

      routes: <RouteBase>[
        GoRoute(
          path: "signin",
          name: "signin",
          pageBuilder: (BuildContext context, GoRouterState state) {
            return screenRightToLeftTransition(context, state, const SigninScreen(title: "Sign-in"));
          },
        ),

        GoRoute(
          path: "signup-verification",
          name: "signup-verification",
          pageBuilder: (BuildContext context, GoRouterState state) {
            return screenRightToLeftTransition(context, state, SignupVerificationScreen(
              title: "Signup verification",
              email: state.uri.queryParameters["email"] ?? "",
            ));
          },
        ),
        GoRoute(
          path: "create-password",
          name: "create-password",
          pageBuilder: (BuildContext context, GoRouterState state) {
            return screenRightToLeftTransition(context, state, CreatePasswordScreen(
              title: "Create Password",
              phone: state.uri.queryParameters["phone"] ?? "",
              firstName: state.uri.queryParameters["first_name"] ?? "",
            ));
          },
        ),
        GoRoute(
          path: "forgot-password",
          name: "forgot-password",
          pageBuilder: (BuildContext context, GoRouterState state) {
            return screenRightToLeftTransition(context, state, const ForgotPasswordEmailScreen(title: "Forgot Password"));
          },
        ),
        GoRoute(
          path: "forgot-password-otp",
          name: "forgot-password-otp",
          pageBuilder: (BuildContext context, GoRouterState state) {
            return screenRightToLeftTransition(context, state, ForgotPasswordOtpScreen(
              title: "Verify OTP",
              email: state.uri.queryParameters["email"] ?? "",
            ));
          },
        ),
        GoRoute(
          path: "forgot-password-create-password",
          name: "forgot-password-create-password",
          pageBuilder: (BuildContext context, GoRouterState state) {
            return screenRightToLeftTransition(context, state, ForgotPasswordCreatePasswordScreen(
              title: "Create New Password",
              email: state.uri.queryParameters["email"] ?? "",
              otp: state.uri.queryParameters["otp"] ?? "",
            ));
          },
        ),
      ],
    ),


    GoRoute(
      path: "/my_feed",
      name: "my_feed",
      pageBuilder: (BuildContext context, GoRouterState state) {
        return screenRightToLeftTransition(context, state, const MainNavigationScreen(initialIndex: 1));
      },
    ),

    GoRoute(
      path: "/home",
      name: "home",
      pageBuilder: (BuildContext context, GoRouterState state) {
        return screenRightToLeftTransition(context, state, const MainNavigationScreen(initialIndex: 0));
      },
      routes: <RouteBase>[
        GoRoute(
          path: "article",
          name: "article",
          pageBuilder: (BuildContext context, GoRouterState state) {
            return screenRightToLeftTransition(context, state, ArticleScreen(title: "Article",));
          },
        ),
        GoRoute(
          path: "epaper",
          name: "epaper",
          pageBuilder: (BuildContext context, GoRouterState state) {
            return screenRightToLeftTransition(context, state, const MainNavigationScreen(initialIndex: 4));
          },
        ),
        GoRoute(
          path: "trending_videos",
          name: "trending_videos",
          pageBuilder: (BuildContext context, GoRouterState state) {
            return screenRightToLeftTransition(context, state, const MainNavigationScreen(initialIndex: 3));
          },
        ),
        GoRoute(
          path: "profile",
          name: "profile",
          pageBuilder: (BuildContext context, GoRouterState state) {
            return screenRightToLeftTransition(context, state, const ProfileScreen(title: "Profile"));
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Akhbar',
      routerConfig: _router,
    );
  }
}
