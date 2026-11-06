import 'package:flutter/foundation.dart';

import '../models/task_api_model.dart';
import '../repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository repository;

  TaskProvider({required this.repository});

  List<TaskApiModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TaskApiModel> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Mengecek apakah data tugas kosong
  bool get isEmpty => _tasks.isEmpty;

  // Mengambil data tugas dari REST API
  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await repository.getTasks();

      _tasks = result;

      debugPrint('BERHASIL FETCH API: ${_tasks.length} tugas');
    } catch (error, stackTrace) {
      debugPrint('ERROR FETCH API: $error');
      debugPrint('STACK TRACE: $stackTrace');

      _errorMessage = 'Gagal mengambil data tugas. Periksa koneksi internet.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Menghapus pesan error dan mencoba mengambil data lagi
  Future<void> retryFetchTasks() async {
    await fetchTasks();
  }
}
