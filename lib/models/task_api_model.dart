class TaskApiModel {
  final int id;
  final int userId;
  final String title;
  final bool completed;

  TaskApiModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
  });

  factory TaskApiModel.fromJson(Map<String, dynamic> json) {
    return TaskApiModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      completed: json['completed'] as bool,
    );
  }
}
