import 'package:flutter/material.dart';

void main() {
  runApp(const TaskMateApp());
}

const Color primaryColor = Color(0xFF6558D3);
const Color backgroundColor = Color(0xFFF7F7FC);

class TaskMateApp extends StatelessWidget {
  const TaskMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskMate',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class TaskItem {
  final String title;
  final String subject;
  final String deadline;
  final Color color;
  bool isCompleted;

  TaskItem({
    required this.title,
    required this.subject,
    required this.deadline,
    required this.color,
    this.isCompleted = false,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedTab = 0;

  final List<TaskItem> tasks = [
    TaskItem(
      title: 'Membuat UI aplikasi',
      subject: 'Pemrograman Mobile',
      deadline: 'Hari ini',
      color: const Color(0xFFEAE7FF),
    ),
    TaskItem(
      title: 'Laporan praktikum',
      subject: 'Basis Data',
      deadline: 'Besok',
      color: const Color(0xFFFFEBD9),
    ),
    TaskItem(
      title: 'Mengerjakan makalah',
      subject: 'Interaksi Manusia Komputer',
      deadline: '30 Okt',
      color: const Color(0xFFDDF5E8),
      isCompleted: true,
    ),
  ];

  int get completedCount => tasks.where((task) => task.isCompleted).length;

  Future<void> addTask() async {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah tugas'),
        content: Column(
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
          ],
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
                ScaffoldMessenger.of(context).showSnackBar(
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

    if (!mounted) return;

    if (result == true) {
      setState(() {
        tasks.insert(
          0,
          TaskItem(
            title: titleController.text.trim(),
            subject: subjectController.text.trim(),
            deadline: 'Belum ditentukan',
            color: const Color(0xFFEAE7FF),
          ),
        );
        selectedTab = 1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas berhasil ditambahkan.')),
      );
    }

    titleController.dispose();
    subjectController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildDashboard(),
      buildTaskList(),
      buildProgress(),
      buildProfile(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: primaryColor, size: 30),
            SizedBox(width: 8),
            Text('TaskMate', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SafeArea(
        child: IndexedStack(index: selectedTab, children: pages),
      ),
      floatingActionButton: selectedTab < 2
          ? FloatingActionButton(
              onPressed: addTask,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() => selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Tugas',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Progres',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget buildDashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 600;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Halo, Mahasiswa! 👋',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Siap menyelesaikan tugas hari ini?',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryColor, Color(0xFF9286F5)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PROGRES TUGASMU',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${tasks.isEmpty ? 0 : (completedCount / tasks.length * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: tasks.isEmpty
                            ? 0
                            : completedCount / tasks.length,
                        minHeight: 9,
                        backgroundColor: Colors.white30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$completedCount dari ${tasks.length} tugas selesai',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: wide ? 3 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: wide ? 2.0 : 1.35,
                children: [
                  SummaryCard(
                    title: 'Total Tugas',
                    value: '${tasks.length}',
                    icon: Icons.assignment_outlined,
                    color: primaryColor,
                  ),
                  SummaryCard(
                    title: 'Belum Selesai',
                    value: '${tasks.length - completedCount}',
                    icon: Icons.schedule_rounded,
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tugas Terbaru',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => setState(() => selectedTab = 1),
                    child: const Text('Lihat semua'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...tasks
                  .take(3)
                  .map(
                    (task) => TaskCard(
                      task: task,
                      onToggle: () => toggleTask(task),
                      onDelete: () => deleteTask(task),
                    ),
                  ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget buildTaskList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Daftar Tugas',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Kelola tugas kuliahmu di sini.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        if (tasks.isEmpty)
          const Center(child: Text('Belum ada tugas. Tekan + untuk menambah.')),
        ...tasks.map(
          (task) => TaskCard(
            task: task,
            onToggle: () => toggleTask(task),
            onDelete: () => deleteTask(task),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget buildProgress() {
    final percent = tasks.isEmpty
        ? 0
        : (completedCount / tasks.length * 100).round();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insights_rounded, size: 64, color: primaryColor),
            const SizedBox(height: 16),
            const Text(
              'Progres Belajarmu',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '$percent% tugas telah selesai',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: percent / 100,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
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
          CircleAvatar(
            radius: 42,
            backgroundColor: Color(0xFFEAE7FF),
            child: Icon(Icons.person, size: 48, color: primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'Mahasiswa TaskMate',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Teman mengatur tugas kuliahmu'),
        ],
      ),
    );
  }

  void toggleTask(TaskItem task) {
    setState(() => task.isCompleted = !task.isCompleted);
  }

  Future<void> deleteTask(TaskItem task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus tugas?'),
        content: Text('Hapus "${task.title}" dari daftar tugas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => tasks.remove(task));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Tugas dihapus.')));
    }
  }
}

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 27),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: task.color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.assignment_outlined, color: primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.subject,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: primaryColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          task.deadline,
                          style: const TextStyle(
                            fontSize: 12,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Checkbox(
              value: task.isCompleted,
              onChanged: (_) => onToggle(),
              activeColor: primaryColor,
            ),
            IconButton(
              tooltip: 'Hapus tugas',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}
