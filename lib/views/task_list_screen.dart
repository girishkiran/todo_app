import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/viewmodels/task_viewmodel.dart';
import '../widgets/task_item.dart';
import '../widgets/task_input.dart';
import '../utils/responsive.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared TODOs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_link_outlined),
            tooltip: 'Accept shared task',
            onPressed: () => _showAcceptSharedDialog(),
          ),
        ],
      ),
      body: ResponsiveLayout(
        builder: (context, constraints) {
          return Column(
            children: [
              TaskInput(
                onSubmit: (text) =>
                    ref.read(taskListProvider.notifier).addTask(text),
              ),
              Expanded(
                child: tasksAsync.when(
                  data: (tasks) {
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: tasks.length,
                      itemBuilder: (context, i) => TaskItem(
                        task: tasks[i],
                        onToggle: () => ref
                            .read(taskListProvider.notifier)
                            .toggleDone(tasks[i]),
                        onDelete: () => ref
                            .read(taskListProvider.notifier)
                            .deleteTask(tasks[i].id),
                        onShare: (email) => ref
                            .read(taskListProvider.notifier)
                            .shareTaskWith(tasks[i], email),
                        onEdit: (task, title, notes) async {
                          await ref
                              .read(taskListProvider.notifier)
                              .editTask(task, title: title, notes: notes);
                        },
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, st) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAcceptSharedDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Accept shared task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Paste the share link or task id you received (e.g. todoapp://share?taskId=...)',
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(hintText: 'paste link or id'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final payload = ctrl.text.trim();
                if (payload.isEmpty) return;
                Navigator.pop(ctx);
                final result = await ref
                    .read(taskListProvider.notifier)
                    .acceptSharedTask(payload);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(result)));
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }
}
