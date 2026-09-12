import 'package:flutter/material.dart';
import 'theme.dart';
import 'login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SEREO',
      theme: sereoTheme(),
      home: const LoginScreen(),
    );
  }
}
