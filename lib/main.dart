
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SmartLogisticsApp());
}

class SmartLogisticsApp extends StatelessWidget {
  const SmartLogisticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Logistics Routing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
