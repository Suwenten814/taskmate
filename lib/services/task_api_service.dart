import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/task_api_model.dart';

class TaskApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com/todos';

  Future<List<TaskApiModel>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl?_limit=10'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((json) => TaskApiModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal mengambil data tugas: ${response.statusCode}');
    }
  }
}
