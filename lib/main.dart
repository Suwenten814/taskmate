import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/task_provider.dart';
import 'providers/supabase_task_provider.dart';
import 'repositories/task_repository.dart';
import 'screens/dashboard_screen.dart';
import 'services/task_api_service.dart';
import 'services/supabase_task_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://algzhhszwjuiddsvhtoj.supabase.co',
    publishableKey: 'sb_publishable_kX3ESXvwpzUP7tukKV1mwA_sSVrnd6u',
  );

  runApp(
    MultiProvider(
      providers: [
        // Provider untuk REST API JSONPlaceholder
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            repository: TaskRepository(apiService: TaskApiService()),
          ),
        ),

        // Provider untuk CRUD Supabase
        ChangeNotifierProvider(
          create: (_) => SupabaseTaskProvider(service: SupabaseTaskService()),
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
      home: const DashboardScreen(),
    );
  }
}
