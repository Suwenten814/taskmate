import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_item.dart';

class TaskStorage {
  static const String _storageKey = 'taskmate_tasks';

  // Menyimpan semua tugas
  static Future<void> saveTasks(List<TaskItem> tasks) async {
    final prefs = await SharedPreferences.getInstance();

    final taskList = tasks.map((task) => task.toJson()).toList();

    await prefs.setString(_storageKey, jsonEncode(taskList));
  }

  // Mengambil semua tugas yang tersimpan
  static Future<List<TaskItem>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = prefs.getString(_storageKey);

    if (savedData == null || savedData.isEmpty) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(savedData);

    return decodedData.map((item) {
      return TaskItem.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  // Menghapus data tugas yang tersimpan
  static Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
