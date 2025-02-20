import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:rxdart/rxdart.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
final BehaviorSubject<String?> selectNotificationSubject = BehaviorSubject<String?>();
final FlutterBackgroundService backgroundService = FlutterBackgroundService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeNotifications();
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings settings = InitializationSettings(
    android: androidSettings,
    iOS: DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    ),
  );

  await notificationsPlugin.initialize(settings, onDidReceiveNotificationResponse: (response) {
    if (response.payload != null) {
      selectNotificationSubject.add(response.payload);
    }
  });
}

Future<void> initializeService() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'safety_net_channel', 'Safety Net',
    description: 'Used for monitoring accidents',
    importance: Importance.high,
  );

  await notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  await backgroundService.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'safety_net_channel',
      initialNotificationTitle: 'SafetyNet',
      initialNotificationContent: 'Monitoring for accidents',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(autoStart: true, onForeground: onStart),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
  if (!isLoggedIn) return;

  service.on('stopService').listen((_) => service.stopSelf());
  Timer.periodic(const Duration(milliseconds: 500), (timer) async {
    if (!isLoggedIn) {
      timer.cancel();
      return;
    }

    AccelerometerEvent? accelEvent = await accelerometerEvents.first;
    double acceleration = sqrt(accelEvent.x * accelEvent.x + accelEvent.y * accelEvent.y + accelEvent.z * accelEvent.z);

    if (acceleration > 25.0) {
      await prefs.setBool("isAccidentDetected", true);
      _sendEmergencyAlert(service);
    }
  });
}

Future<void> _sendEmergencyAlert(ServiceInstance service) async {
  await notificationsPlugin.show(
    0,
    "Emergency Alert Sent!",
    "Your emergency contacts have been notified.",
    const NotificationDetails(
      android: AndroidNotificationDetails('safety_net_channel', 'Emergency Alerts'),
    ),
  );
  service.invoke('emergencyAlert', {'message': "Emergency alert sent!"});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafetyNet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const MainScreen(), // Directs to MainScreen
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SafetyNet Monitoring')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text("Monitoring Accidents...", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool("isLoggedIn", false);
                backgroundService.invoke('stopService');
              },
              child: const Text("Stop Monitoring"),
            ),
          ],
        ),
      ),
    );
  }
}
