import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'views/home_screen.dart';

void main() {
  runApp(const CrewMatchApp());
}

class CrewMatchApp extends StatelessWidget {
  const CrewMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CrewMatch AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
