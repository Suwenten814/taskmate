class SupabaseTask {
  final int id;
  final String title;
  final String subject;
  final String dueDate;
  final bool completed;

  SupabaseTask({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.completed,
  });

  factory SupabaseTask.fromJson(Map<String, dynamic> json) {
    return SupabaseTask(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      dueDate: json['due_date'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'due_date': dueDate,
      'completed': completed,
    };
  }
}
