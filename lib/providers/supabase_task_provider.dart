import 'package:flutter/foundation.dart';

import '../models/supabase_task.dart';
import '../services/supabase_task_service.dart';

class SupabaseTaskProvider extends ChangeNotifier {
  final SupabaseTaskService service;

  SupabaseTaskProvider({required this.service});

  List<SupabaseTask> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SupabaseTask> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await service.fetchTasks();

      _tasks = data.map((json) => SupabaseTask.fromJson(json)).toList();

      debugPrint('BERHASIL FETCH SUPABASE: ${_tasks.length} tugas');

      if (_tasks.isEmpty) {
        debugPrint('Data tugas masih kosong.');
      }
    } catch (error, stackTrace) {
      debugPrint('ERROR FETCH SUPABASE: $error');
      debugPrint('STACK TRACE: $stackTrace');

      _errorMessage = 'Gagal mengambil tugas: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTask({
    required String title,
    required String subject,
    required String dueDate,
  }) async {
    try {
      await service.addTask(title: title, subject: subject, dueDate: dueDate);

      await fetchTasks();
      return _errorMessage == null;
    } catch (error, stackTrace) {
      debugPrint('ERROR ADD SUPABASE: $error');
      debugPrint('STACK TRACE: $stackTrace');

      _errorMessage = 'Gagal menambahkan tugas: $error';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask({
    required int id,
    required String title,
    required String subject,
    required String dueDate,
    required bool completed,
  }) async {
    try {
      await service.updateTask(
        id: id,
        title: title,
        subject: subject,
        dueDate: dueDate,
        completed: completed,
      );

      await fetchTasks();
      return _errorMessage == null;
    } catch (error, stackTrace) {
      debugPrint('ERROR UPDATE SUPABASE: $error');
      debugPrint('STACK TRACE: $stackTrace');

      _errorMessage = 'Gagal memperbarui tugas: $error';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      await service.deleteTask(id);

      await fetchTasks();
      return _errorMessage == null;
    } catch (error, stackTrace) {
      debugPrint('ERROR DELETE SUPABASE: $error');
      debugPrint('STACK TRACE: $stackTrace');

      _errorMessage = 'Gagal menghapus tugas: $error';
      notifyListeners();
      return false;
    }
  }
}
