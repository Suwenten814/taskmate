import 'package:flutter/material.dart';

import '../models/task_item.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(title),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final TaskItem task;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Checkbox(value: task.completed, onChanged: onChanged),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Text('${task.subject} • ${task.dueDate}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
          tooltip: 'Hapus tugas',
        ),
      ),
    );
  }
}
