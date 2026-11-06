import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/supabase_task.dart';
import '../providers/supabase_task_provider.dart';
import '../widgets/task_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SupabaseTaskProvider>().fetchTasks();
    });
  }

  int getCompletedCount(List<SupabaseTask> tasks) {
    return tasks.where((task) => task.completed).length;
  }

  String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String?> chooseDate(
    BuildContext dialogContext,
    String? currentDate,
  ) async {
    final initialDate = DateTime.tryParse(currentDate ?? '') ?? DateTime.now();

    final selectedDate = await showDatePicker(
      context: dialogContext,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (selectedDate == null) return null;

    return formatDate(selectedDate);
  }

  Widget dateField({
    required BuildContext dialogContext,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: const InputDecoration(
        labelText: 'Tanggal tenggat',
        hintText: 'Pilih tanggal',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_month),
      ),
    );
  }

  // Tambah tugas
  Future<void> addTask() async {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    final dateController = TextEditingController();

    String? validationMessage;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
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
                    const SizedBox(height: 12),
                    dateField(
                      dialogContext: dialogContext,
                      controller: dateController,
                      onTap: () async {
                        final date = await chooseDate(
                          dialogContext,
                          dateController.text,
                        );

                        if (date != null) {
                          setDialogState(() {
                            dateController.text = date;
                          });
                        }
                      },
                    ),
                    if (validationMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        validationMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
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
                        subjectController.text.trim().isEmpty ||
                        dateController.text.trim().isEmpty) {
                      setDialogState(() {
                        validationMessage = 'Semua kolom wajib diisi.';
                      });
                      return;
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      final success = await context.read<SupabaseTaskProvider>().addTask(
        title: titleController.text.trim(),
        subject: subjectController.text.trim(),
        dueDate: dateController.text.trim(),
      );

      showMessage(
        success ? 'Tugas berhasil ditambahkan.' : 'Gagal menambahkan tugas.',
      );
    }

    titleController.dispose();
    subjectController.dispose();
    dateController.dispose();
  }

  // Edit tugas
  Future<void> editTask(SupabaseTask task) async {
    final titleController = TextEditingController(text: task.title);
    final subjectController = TextEditingController(text: task.subject);
    final dateController = TextEditingController(text: task.dueDate);

    String? validationMessage;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Tugas'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
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
                    const SizedBox(height: 12),
                    dateField(
                      dialogContext: dialogContext,
                      controller: dateController,
                      onTap: () async {
                        final date = await chooseDate(
                          dialogContext,
                          dateController.text,
                        );

                        if (date != null) {
                          setDialogState(() {
                            dateController.text = date;
                          });
                        }
                      },
                    ),
                    if (validationMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        validationMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
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
                        subjectController.text.trim().isEmpty ||
                        dateController.text.trim().isEmpty) {
                      setDialogState(() {
                        validationMessage = 'Semua kolom wajib diisi.';
                      });
                      return;
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      final success = await context.read<SupabaseTaskProvider>().updateTask(
        id: task.id,
        title: titleController.text.trim(),
        subject: subjectController.text.trim(),
        dueDate: dateController.text.trim(),
        completed: task.completed,
      );

      showMessage(
        success ? 'Tugas berhasil diperbarui.' : 'Gagal memperbarui tugas.',
      );
    }

    titleController.dispose();
    subjectController.dispose();
    dateController.dispose();
  }

  // Hapus tugas
  Future<void> deleteTask(SupabaseTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
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
        );
      },
    );

    if (confirmed == true && mounted) {
      final success = await context.read<SupabaseTaskProvider>().deleteTask(
        task.id,
      );

      showMessage(
        success ? 'Tugas berhasil dihapus.' : 'Gagal menghapus tugas.',
      );
    }
  }

  // Checklist selesai
  Future<void> toggleTask(SupabaseTask task, bool? value) async {
    final success = await context.read<SupabaseTaskProvider>().updateTask(
      id: task.id,
      title: task.title,
      subject: task.subject,
      dueDate: task.dueDate,
      completed: value ?? false,
    );

    showMessage(
      success
          ? (value == true
                ? 'Tugas ditandai selesai.'
                : 'Tugas ditandai belum selesai.')
          : 'Gagal mengubah status tugas.',
    );
  }

  // Daftar tugas
  Widget buildTaskList(List<SupabaseTask> tasks, {bool showCompleted = false}) {
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
          onChanged: (value) => toggleTask(task, value),
          onDelete: () => deleteTask(task),
          onEdit: () => editTask(task),
        );
      },
    );
  }

  // Beranda
  Widget buildHome(List<SupabaseTask> tasks) {
    final completedCount = getCompletedCount(tasks);
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

            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.35,
              children: [
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
              ],
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
                onChanged: (value) => toggleTask(task, value),
                onDelete: () => deleteTask(task),
                onEdit: () => editTask(task),
              ),
            ),
        if (pendingCount == 0) const Text('Semua tugas sudah selesai. Hebat!'),
      ],
    );
  }

  // Progres
  Widget buildProgress(List<SupabaseTask> tasks) {
    final completedCount = getCompletedCount(tasks);

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

  // Profil
  // Profil
  Widget buildProfile(List<SupabaseTask> tasks) {
    final completedCount = getCompletedCount(tasks);
    final pendingCount = tasks.length - completedCount;

    final percentage = tasks.isEmpty
        ? 0
        : (completedCount * 100 / tasks.length).round();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),

        // Header Profil
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple.withValues(alpha: (0.12)),
                ),
                child: const CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.person, size: 56, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mahasiswa TaskMate',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Aplikasi pengelola tugas kuliah',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Statistik Tugas
        Text(
          'Statistik Tugas',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: profileStatCard(
                title: 'Total Tugas',
                value: '${tasks.length}',
                icon: Icons.assignment_outlined,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: profileStatCard(
                title: 'Selesai',
                value: '$completedCount',
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: profileStatCard(
                title: 'Pending',
                value: '$pendingCount',
                icon: Icons.pending_actions,
                color: Colors.orange,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Progres Penyelesaian
        Card(
          elevation: 0,
          color: Colors.deepPurple.withOpacity(0.06),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.insights, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Progres Penyelesaian',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: tasks.isEmpty ? 0 : completedCount / tasks.length,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: Colors.deepPurple.withOpacity(0.12),
                  color: Colors.deepPurple,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Informasi Aplikasi
        Text(
          'Informasi',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Card(
          elevation: 0,
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.info_outline, color: Colors.deepPurple),
                title: Text('Tentang TaskMate'),
                subtitle: Text(
                  'Aplikasi untuk membantu mahasiswa mengelola tugas kuliah.',
                ),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.school_outlined, color: Colors.deepPurple),
                title: Text('Versi Aplikasi'),
                subtitle: Text('TaskMate v1.0.0'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: Text(
            'Dibuat untuk membantu tugas kuliahmu.',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Colors.grey[600]),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget profileStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupabaseTaskProvider>(
      builder: (context, provider, child) {
        final tasks = provider.tasks;

        final pages = [
          buildHome(tasks),
          buildTaskList(tasks),
          buildProgress(tasks),
          buildProfile(tasks),
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text('TaskMate'),
            actions: [
              IconButton(
                onPressed: provider.isLoading
                    ? null
                    : () => provider.fetchTasks(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Muat ulang tugas',
              ),
              if (selectedIndex == 0 || selectedIndex == 1)
                IconButton(
                  onPressed: provider.isLoading ? null : addTask,
                  icon: const Icon(Icons.add),
                  tooltip: 'Tambah tugas',
                ),
            ],
          ),
          body: SafeArea(
            child: provider.isLoading && tasks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.errorMessage != null && tasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => provider.fetchTasks(),
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : IndexedStack(index: selectedIndex, children: pages),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.checklist),
                label: 'Tugas',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights),
                label: 'Progres',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }
}
