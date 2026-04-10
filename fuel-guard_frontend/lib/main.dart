import 'package:flutter/material.dart';

import 'features/auth/screens/auth_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF2D5C91)),
      home:AuthScreen(),
    );
  }
}