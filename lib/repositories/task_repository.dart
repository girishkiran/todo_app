import 'package:firebase_database/firebase_database.dart';
import '../models/task.dart';

class TaskRepository {
  final DatabaseReference _rootRef = FirebaseDatabase.instance.ref();

  DatabaseReference tasksRef() => _rootRef.child('tasks');

  Stream<List<Task>> streamTasksForParticipant(String userId) {
    return tasksRef().onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final list = <Task>[];
      data.forEach((k, v) {
        final t = Task.fromJson(v);
        if (t.participants.contains(userId)) list.add(t);
      });
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    });
  }

  Future<void> addOrUpdateTask(Task task) async {
    await tasksRef().child(task.id).set(task.toJson());
  }

  Future<void> deleteTask(String id) async {
    await tasksRef().child(id).remove();
  }

  Future<Task?> getTaskById(String taskId) async {
    final snap = await tasksRef().child(taskId).get();
    if (!snap.exists) return null;
    final data = snap.value as Map<dynamic, dynamic>;
    return Task.fromJson(data);
  }

  Future<void> addParticipant(String taskId, String userId) async {
    final ref = tasksRef().child(taskId);
    final snap = await ref.child('participants').get();
    final current =
        (snap.value as List<dynamic>?)?.map((e) => e as String).toList() ?? [];

    if (!current.contains(userId)) {
      current.add(userId);
      await ref.update({
        'participants': current,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }
}
