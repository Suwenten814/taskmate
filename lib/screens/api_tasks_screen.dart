import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';

class ApiTasksScreen extends StatefulWidget {
  const ApiTasksScreen({super.key});

  @override
  State<ApiTasksScreen> createState() => _ApiTasksScreenState();
}

class _ApiTasksScreenState extends State<ApiTasksScreen> {
  @override
  void initState() {
    super.initState();

    // Memanggil REST API saat layar pertama kali dibuka.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<TaskProvider>().fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas dari REST API'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TaskProvider>().fetchTasks();
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          // 1. Loading awal
          if (provider.isLoading && provider.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error ketika belum ada data
          if (provider.errorMessage != null && provider.tasks.isEmpty) {
            return _buildErrorState(
              message: provider.errorMessage!,
              onRetry: provider.retryFetchTasks,
            );
          }

          // 3. Empty state
          if (provider.tasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Belum ada tugas dari API.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // 4. Data tersedia
          return Column(
            children: [
              // Indikator refresh ketika data lama masih tampil
              if (provider.isLoading) const LinearProgressIndicator(),

              // Pesan jika refresh gagal tetapi data lama tersedia
              if (provider.errorMessage != null)
                Material(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline),
                        const SizedBox(width: 8),
                        Expanded(child: Text(provider.errorMessage!)),
                        TextButton(
                          onPressed: provider.retryFetchTasks,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.fetchTasks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = provider.tasks[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${task.id}')),
                          title: Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text('User ID: ${task.userId}'),
                          trailing: Icon(
                            task.completed
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: task.completed ? Colors.green : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget untuk tampilan error dengan tombol coba lagi
  Widget _buildErrorState({
    required String message,
    required Future<void> Function() onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 56, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
