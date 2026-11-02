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
}
