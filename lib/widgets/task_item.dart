import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final void Function(String userId) onShare;
  final Future<void> Function(Task task, String title, String notes) onEdit;

  const TaskItem({
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onShare,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  void _showEditDialog(BuildContext context) {
    final titleCtrl = TextEditingController(text: task.title);
    final notesCtrl = TextEditingController(text: task.notes);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes'),
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
                final newTitle = titleCtrl.text.trim();
                final newNotes = notesCtrl.text.trim();
                if (newTitle.isNotEmpty) {
                  await onEdit(task, newTitle, newNotes);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareViaIntent(BuildContext context) async {
    final shareLink = 'todoapp://share?taskId=${task.id}';
    await Share.share(shareLink);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(value: task.done, onChanged: (_) => onToggle()),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.done ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        task.notes.isNotEmpty
            ? task.notes
            : 'Updated: ${DateTime.fromMillisecondsSinceEpoch(task.updatedAt)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareViaIntent(context),
          ),
          IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
        ],
      ),
    );
  }
}
