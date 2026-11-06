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
  bool showCompletedTasks = false;

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

  // Daftar tugas
  Widget buildTaskList(List<SupabaseTask> tasks) {
    final completedCount = getCompletedCount(tasks);
    final pendingCount = tasks.length - completedCount;

    final visibleTasks = tasks
        .where((task) => showCompletedTasks ? task.completed : !task.completed)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header halaman tugas
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Tugas',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                '$pendingCount tugas menunggu diselesaikan',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),

              // Ringkasan tugas
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.assignment_turned_in_outlined,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total tugas',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${tasks.length} tugas',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Selesai'),
                        const SizedBox(height: 4),
                        Text(
                          '$completedCount/${tasks.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Filter tugas
              Row(
                children: [
                  Expanded(
                    child: _taskFilterChip(
                      label: 'Belum Selesai',
                      count: pendingCount,
                      selected: !showCompletedTasks,
                      onSelected: () {
                        setState(() {
                          showCompletedTasks = false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _taskFilterChip(
                      label: 'Selesai',
                      count: completedCount,
                      selected: showCompletedTasks,
                      onSelected: () {
                        setState(() {
                          showCompletedTasks = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Daftar kartu tugas
        Expanded(
          child: visibleTasks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          showCompletedTasks
                              ? Icons.task_alt
                              : Icons.assignment_outlined,
                          size: 64,
                          color: Colors.deepPurple.withValues(alpha: 0.45),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          showCompletedTasks
                              ? 'Belum ada tugas yang selesai'
                              : 'Semua tugas sudah beres!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          showCompletedTasks
                              ? 'Tugas yang kamu selesaikan akan muncul di sini.'
                              : 'Tambahkan tugas baru untuk mulai mengatur aktivitasmu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
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
                ),
        ),
      ],
    );
  }

  // Tombol filter tugas
  Widget _taskFilterChip({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return Material(
      color: selected ? Colors.deepPurple : Colors.grey.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.deepPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Beranda

  Widget buildHome(List<SupabaseTask> tasks) {
    final completedCount = getCompletedCount(tasks);
    final pendingCount = tasks.length - completedCount;
    final pendingTasks = tasks
        .where((task) => !task.completed)
        .take(3)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        // Header dashboard
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Halo, Mahasiswa! 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.school_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Atur tugasmu, capai targetmu.',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // Progres penyelesaian
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: tasks.isEmpty ? 0 : completedCount / tasks.length,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tasks.isEmpty
                    ? 'Belum ada tugas'
                    : '$completedCount dari ${tasks.length} tugas telah selesai',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Judul ringkasan
        Text(
          'Ringkasan Tugas',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Kartu statistik
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 460 ? 3 : 2;

            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 3 ? 0.95 : 1.25,
              children: [
                _dashboardSummaryCard(
                  title: 'Semua Tugas',
                  value: '${tasks.length}',
                  icon: Icons.assignment_outlined,
                  color: Colors.deepPurple,
                ),
                _dashboardSummaryCard(
                  title: 'Belum Selesai',
                  value: '$pendingCount',
                  icon: Icons.pending_actions_outlined,
                  color: Colors.orange,
                ),
                _dashboardSummaryCard(
                  title: 'Selesai',
                  value: '$completedCount',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 28),

        // Bagian tugas belum selesai
        Row(
          children: [
            Expanded(
              child: Text(
                'Tugas yang belum selesai',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (pendingCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$pendingCount tugas',
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        // Daftar tugas atau empty state
        if (pendingTasks.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.celebration_outlined,
                    color: Colors.green,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  tasks.isEmpty
                      ? 'Belum ada tugas'
                      : 'Semua tugas sudah selesai!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tasks.isEmpty
                      ? 'Tambahkan tugas kuliahmu agar lebih terorganisir.'
                      : 'Hebat! Kamu sudah menyelesaikan semua tugas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ...pendingTasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TaskCard(
                task: task,
                onChanged: (value) => toggleTask(task, value),
                onDelete: () => deleteTask(task),
                onEdit: () => editTask(task),
              ),
            ),
          ),

        if (pendingCount > 3)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Dan ${pendingCount - 3} tugas lainnya. '
              'Buka menu Daftar Tugas untuk melihat semuanya.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // Kartu ringkasan dashboard
  Widget _dashboardSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Progres

  Widget buildProgress(List<SupabaseTask> tasks) {
    final completedCount = getCompletedCount(tasks);
    final pendingCount = tasks.length - completedCount;
    final percentage = tasks.isEmpty
        ? 0
        : (completedCount * 100 / tasks.length).round();

    final progressValue = tasks.isEmpty ? 0.0 : completedCount / tasks.length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header
        Text(
          'Progres Tugas',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Pantau pencapaian tugas kuliahmu.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),

        const SizedBox(height: 24),

        // Kartu progres utama
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Penyelesaian Tugas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Lingkaran progres
              SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: progressValue,
                        strokeWidth: 13,
                        backgroundColor: Colors.white.withValues(alpha: 0.20),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$percentage%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Selesai',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                tasks.isEmpty
                    ? 'Belum ada tugas yang tercatat.'
                    : '$completedCount dari ${tasks.length} tugas telah selesai',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Statistik
        Text(
          'Ringkasan Tugas',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _progressStatCard(
                title: 'Total Tugas',
                count: tasks.length,
                icon: Icons.assignment_outlined,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _progressStatCard(
                title: 'Belum Selesai',
                count: pendingCount,
                icon: Icons.pending_actions_outlined,
                color: Colors.orange,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _progressStatCard(
          title: 'Tugas Selesai',
          count: completedCount,
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),

        const SizedBox(height: 24),

        // Status pencapaian
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.deepPurple.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  tasks.isNotEmpty && pendingCount == 0
                      ? Icons.emoji_events_outlined
                      : Icons.flag_outlined,
                  color: Colors.deepPurple,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tasks.isEmpty
                          ? 'Mulai perjalananmu!'
                          : pendingCount == 0
                          ? 'Luar biasa!'
                          : 'Terus semangat!',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tasks.isEmpty
                          ? 'Tambahkan tugas pertamamu.'
                          : pendingCount == 0
                          ? 'Semua tugas berhasil diselesaikan.'
                          : 'Masih ada $pendingCount tugas yang perlu diselesaikan.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Kartu statistik pada halaman progres
  Widget _progressStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
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
