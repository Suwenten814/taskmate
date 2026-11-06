import 'package:flutter/material.dart';

import '../models/supabase_task.dart';

class TaskDetailScreen extends StatelessWidget {
  final SupabaseTask task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tugas')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    size: 48,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nama Tugas',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Mata Kuliah',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.subject,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Tanggal Tenggat',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.dueDate,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Status',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Chip(
                    avatar: Icon(
                      task.completed
                          ? Icons.check_circle
                          : Icons.pending_actions,
                      color: task.completed ? Colors.green : Colors.orange,
                    ),
                    label: Text(task.completed ? 'Selesai' : 'Belum selesai'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
