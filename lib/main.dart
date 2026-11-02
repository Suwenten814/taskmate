import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';

void main() {
  runApp(const TaskMateApp());
}

class TaskMateApp extends StatelessWidget {
  const TaskMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: false),
      ),
      home: const DashboardScreen(),
    );
  }
}
