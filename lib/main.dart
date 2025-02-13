import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:SafetyNet/screens/login.dart';
import 'package:SafetyNet/screens/on_boarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
  bool? isFirstTime = prefs.getBool("isFirstTime") ?? true;

  runApp(MyApp(isLoggedIn: isLoggedIn, isFirstTime: isFirstTime));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn, isFirstTime;

  const MyApp({super.key, required this.isLoggedIn, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafetyNet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: isFirstTime ? const OnboardingScreen() : (isLoggedIn ? AccidentDetectionScreen() : const Login()),
    );
  }
}

class AccidentDetectionScreen extends StatefulWidget {
  @override
  _AccidentDetectionScreenState createState() => _AccidentDetectionScreenState();
}

class _AccidentDetectionScreenState extends State<AccidentDetectionScreen> {
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;

  bool isAccidentDetected = false;
  int lastMovementTime = 0;

  static const int inactivityThreshold = 10000;
  static const double accelerationThreshold = 50.0;
  static const double rotationThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      _onAccelerometerDataChanged(event);
    });
    _gyroscopeSubscription = gyroscopeEvents.listen((event) {
      _onGyroscopeDataChanged(event);
    });
  }

  void _onAccelerometerDataChanged(AccelerometerEvent event) {
    double acceleration = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

    if (acceleration > accelerationThreshold) {
      _detectAccident();
    }

    int currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - lastMovementTime > inactivityThreshold) {
      if (!isAccidentDetected) {
        _sendEmergencyAlert();
      }
    }
  }

  void _onGyroscopeDataChanged(GyroscopeEvent event) {
    if (event.x.abs() > rotationThreshold) {
      _detectAccident();
    }
  }

  void _detectAccident() {
    if (!isAccidentDetected) {
      setState(() {
        isAccidentDetected = true;
      });
      _showAlert("Accident Detected! Are you okay?");
      _startResponseTimer();
    }
  }

  void _startResponseTimer() {
    Timer(Duration(seconds: 10), () {
      if (isAccidentDetected) {
        _sendEmergencyAlert();
      }
    });
  }

  void _showAlert(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _sendEmergencyAlert() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Emergency alert sent!")));
  }

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    _gyroscopeSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Accident Detection')),
      body: Center(
        child: Text(
          isAccidentDetected ? "Accident Detected! Please Respond!" : "Monitoring Sensors for Accidents...",
          style: TextStyle(fontSize: 20, color: isAccidentDetected ? Colors.red : Colors.black),
        ),
      ),
    );
  }
}
