import 'package:flutter/foundation.dart';

import '../models/task_api_model.dart';
import '../repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository repository;

  TaskProvider({required this.repository});

  List<TaskApiModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TaskApiModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await repository.getTasks();
    } catch (error) {
      _errorMessage = 'Gagal mengambil data tugas. Periksa koneksi internet.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
