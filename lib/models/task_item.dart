import 'dart:convert';

class TaskItem {
  final String title;
  final String subject;
  final String dueDate;
  bool completed;

  TaskItem({
    required this.title,
    required this.subject,
    required this.dueDate,
    this.completed = false,
  });

  // Mengubah objek TaskItem menjadi Map
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subject': subject,
      'dueDate': dueDate,
      'completed': completed,
    };
  }

  // Membuat TaskItem dari Map
  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      dueDate: json['dueDate'] ?? '',
      completed: json['completed'] ?? false,
    );
  }

  // Mengubah objek menjadi teks JSON
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Membuat objek dari teks JSON
  factory TaskItem.fromJsonString(String jsonString) {
    return TaskItem.fromJson(jsonDecode(jsonString));
  }
}
