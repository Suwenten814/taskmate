import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/task_provider.dart';
import 'repositories/task_repository.dart';
import 'screens/api_tasks_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/task_api_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            repository: TaskRepository(apiService: TaskApiService()),
          ),
        ),
      ],
      child: const TaskMateApp(),
    ),
  );
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

      // Layar sementara untuk menguji REST API.
      home: const DashboardScreen(),
    );
  }
}
