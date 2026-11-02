import '../models/task_api_model.dart';
import '../services/task_api_service.dart';

class TaskRepository {
  final TaskApiService apiService;

  TaskRepository({required this.apiService});

  Future<List<TaskApiModel>> getTasks() {
    return apiService.fetchTasks();
  }
}
