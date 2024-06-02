import 'package:flutter/material.dart';
import 'package:task_manager/screen/onboarding/login.dart';
import 'package:task_manager/screen/onboarding/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      initialRoute: '/',
      routes: {
        '/':(context)=>Splashscreen(),
        '/login':(context)=>Login(),
      },

    );
  }
}

