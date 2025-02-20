import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
final AudioPlayer audioPlayer = AudioPlayer();
Timer? emergencyTimer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeNotifications();
  runApp(const MyApp());
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );
  await notificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: handleNotificationResponse,
  );
}

void handleNotificationResponse(NotificationResponse response) async {
  switch (response.actionId) {
    case 'CANCEL':
      stopEmergencyAlert();
      break;
    case 'CALL':
      stopEmergencyAlert();
      Fluttertoast.showToast(msg: "SENT", gravity: ToastGravity.CENTER);
      break;
  }
}

Future<void> triggerEmergencyAlert() async {
  await audioPlayer.play(AssetSource('sounds/emergency_alert.mp3'));
  audioPlayer.setReleaseMode(ReleaseMode.loop);

  emergencyTimer?.cancel();
  emergencyTimer = Timer(const Duration(seconds: 15), () {
    stopEmergencyAlert();
    Fluttertoast.showToast(msg: "SENT", gravity: ToastGravity.CENTER);
  });

  await notificationsPlugin.show(
    0,
    "Emergency Alert!",
    "Accident detected! Do you need emergency assistance?",
    NotificationDetails(
      android: AndroidNotificationDetails(
        'safety_net_channel',
        'Safety Net Alerts',
        importance: Importance.max,
        priority: Priority.high,
        actions: [
          const AndroidNotificationAction('CANCEL', 'Cancel'),
          const AndroidNotificationAction('CALL', 'Call Emergency'),
        ],
      ),
    ),
  );
}

Future<void> stopEmergencyAlert() async {
  await audioPlayer.stop();
  emergencyTimer?.cancel();
  await notificationsPlugin.cancel(0);
}

Future<Position> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafetyNet',
      home: Scaffold(
        appBar: AppBar(title: const Text('Emergency Test')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: triggerEmergencyAlert,
                child: const Text('Trigger Emergency Alert'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    Position position = await getCurrentLocation();
                    Fluttertoast.showToast(
                      msg: "Lat: \${position.latitude}, Long: \${position.longitude}",
                      gravity: ToastGravity.CENTER,
                    );
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: e.toString(),
                      gravity: ToastGravity.CENTER,
                    );
                  }
                },
                child: const Text('Get Current Location'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
