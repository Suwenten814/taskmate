import 'package:flutter/material.dart';

import '../models/task_item.dart';
import '../widgets/task_widgets.dart';
import '../services/task_storage.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  final List<TaskItem> tasks = [
    TaskItem(
      title: 'Membuat UI aplikasi',
      subject: 'Pemrograman Mobile',
      dueDate: 'Besok',
    ),
    TaskItem(
      title: 'Mengerjakan laporan',
      subject: 'Rekayasa Perangkat Lunak',
      dueDate: '30 Okt',
    ),
    TaskItem(
      title: 'Belajar Dart',
      subject: 'Pemrograman Mobile',
      dueDate: '1 Nov',
      completed: true,
    ),
  ];

  int get completedCount => tasks.where((task) => task.completed).length;

  Future<void> addTask() async {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Tugas'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nama tugas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Mata kuliah',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty ||
                  subjectController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Nama tugas dan mata kuliah wajib diisi.'),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext, true);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      setState(() {
        tasks.insert(
          0,
          TaskItem(
            title: titleController.text.trim(),
            subject: subjectController.text.trim(),
            dueDate: 'Belum ditentukan',
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas berhasil ditambahkan.')),
      );
    }

    titleController.dispose();
    subjectController.dispose();
  }

  Future<void> deleteTask(TaskItem task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus tugas?'),
        content: Text('Tugas "${task.title}" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => tasks.remove(task));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tugas berhasil dihapus.')));
    }
  }

  Future<void> editTask(TaskItem task) async {
    final titleController = TextEditingController(text: task.title);
    final subjectController = TextEditingController(text: task.subject);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Tugas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Nama Tugas'),
              ),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Mata Pelajaran'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final index = tasks.indexOf(task);

      if (index != -1) {
        setState(() {
          tasks[index] = TaskItem(
            title: titleController.text.trim(),
            subject: subjectController.text.trim(),
            dueDate: task.dueDate,
            completed: task.completed,
          );
        });
      }
    }
    titleController.dispose();
    subjectController.dispose();
  }

  Widget buildTaskList({bool showCompleted = false}) {
    final visibleTasks = tasks
        .where((task) => showCompleted ? task.completed : !task.completed)
        .toList();

    if (visibleTasks.isEmpty) {
      return const Center(child: Text('Belum ada tugas di sini.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visibleTasks.length,
      itemBuilder: (context, index) {
        final task = visibleTasks[index];

        return TaskCard(
          task: task,
          onChanged: (value) {
            setState(() => task.completed = value ?? false);
          },
          onDelete: () => deleteTask(task),
          onEdit: () => editTask(task),
        );
      },
    );
  }

  Widget buildHome() {
    final pendingCount = tasks.length - completedCount;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Halo, Mahasiswa!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        const Text('Atur tugasmu, capai targetmu.'),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 600 ? 3 : 2;
            final cards = [
              SummaryCard(
                title: 'Semua Tugas',
                value: '${tasks.length}',
                icon: Icons.assignment_outlined,
                color: Colors.deepPurple,
              ),
              SummaryCard(
                title: 'Belum Selesai',
                value: '$pendingCount',
                icon: Icons.pending_actions,
                color: Colors.orange,
              ),
              SummaryCard(
                title: 'Selesai',
                value: '$completedCount',
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
            ];

            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.35,
              children: cards,
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          'Tugas yang belum selesai',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...tasks
            .where((task) => !task.completed)
            .take(3)
            .map(
              (task) => TaskCard(
                task: task,
                onChanged: (value) {
                  setState(() => task.completed = value ?? false);
                },
                onDelete: () => deleteTask(task),
                onEdit: () => editTask(task),
              ),
            ),
        if (pendingCount == 0) const Text('Semua tugas sudah selesai. Hebat!'),
      ],
    );
  }

  Widget buildProgress() {
    final percentage = tasks.isEmpty
        ? 0
        : (completedCount * 100 / tasks.length).round();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insights, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 16),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const Text('Progres penyelesaian tugas'),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: tasks.isEmpty ? 0 : completedCount / tasks.length,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfile() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 36, child: Icon(Icons.person, size: 40)),
          SizedBox(height: 12),
          Text(
            'Mahasiswa TaskMate',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text('Aplikasi pengelola tugas kuliah'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHome(),
      buildTaskList(),
      buildProgress(),
      buildProfile(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskMate'),
        actions: [
          if (selectedIndex == 0 || selectedIndex == 1)
            IconButton(
              onPressed: addTask,
              icon: const Icon(Icons.add),
              tooltip: 'Tambah tugas',
            ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: selectedIndex, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Tugas'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Progres'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
