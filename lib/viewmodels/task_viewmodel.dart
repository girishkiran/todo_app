import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

final taskRepoProvider = Provider<TaskRepository>((ref) => TaskRepository());

final taskListProvider =
    StateNotifierProvider<TaskListViewModel, AsyncValue<List<Task>>>(
      (ref) => TaskListViewModel(ref),
    );

class TaskListViewModel extends StateNotifier<AsyncValue<List<Task>>> {
  final Ref _ref;
  StreamSubscription<List<Task>>? _sub;
  String _currentUserId = '';

  TaskListViewModel(this._ref) : super(const AsyncValue.loading()) {
    _initLocalUserId();
  }

  Future<void> _initLocalUserId() async {
    final prefs = await SharedPreferences.getInstance();
    var uid = prefs.getString('local_user_id');
    if (uid == null) {
      uid = const String.fromEnvironment('LOCAL_USER_ID', defaultValue: '');
      if (uid.isEmpty) {
        uid =
            '${DateTime.now().millisecondsSinceEpoch}-${const UuidPlaceholder().v4()}';
      }
      await prefs.setString('local_user_id', uid);
    }
    startListeningForUser(uid);
  }

  void startListeningForUser(String userId) {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    _sub?.cancel();

    final repo = _ref.read(taskRepoProvider);
    _sub = repo
        .streamTasksForParticipant(userId)
        .listen(
          (tasks) => state = AsyncValue.data(tasks),
          onError: (e, st) => state = AsyncValue.error(e, st),
        );
  }

  Future<void> addTask(String title) async {
    if (_currentUserId.isEmpty) return;
    final repo = _ref.read(taskRepoProvider);
    final task = Task.create(title, creatorId: _currentUserId);
    await repo.addOrUpdateTask(task);
  }

  Future<void> editTask(
    Task task, {
    required String title,
    required String notes,
  }) async {
    final repo = _ref.read(taskRepoProvider);
    final updated = task.copyWith(
      title: title,
      notes: notes,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await repo.addOrUpdateTask(updated);
  }

  Future<void> toggleDone(Task task) async {
    final repo = _ref.read(taskRepoProvider);
    final updated = task.copyWith(
      done: !task.done,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await repo.addOrUpdateTask(updated);
  }

  Future<void> shareTaskWith(Task task, String userIdToShare) async {
    final repo = _ref.read(taskRepoProvider);
    final participants = Set<String>.from(task.participants);
    participants.add(userIdToShare);
    final updated = task.copyWith(
      participants: participants.toList(),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await repo.addOrUpdateTask(updated);
  }

  Future<void> deleteTask(String id) async {
    final repo = _ref.read(taskRepoProvider);
    await repo.deleteTask(id);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<String> acceptSharedTask(String payload) async {
    payload = payload.trim();
    String? taskId;

    try {
      final uri = Uri.tryParse(payload);

      if (uri != null &&
          (uri.scheme == 'todoapp' ||
              uri.queryParameters.containsKey('taskId'))) {
        taskId =
            uri.queryParameters['taskId'] ??
            (uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null);
      }
    } catch (_) {
      taskId = null;
    }

    taskId ??= payload;

    if (taskId == null || taskId.isEmpty) {
      return 'Invalid share payload';
    }

    final repo = _ref.read(taskRepoProvider);
    final task = await repo.getTaskById(taskId);
    if (task == null) {
      return 'Task not found';
    }

    if (_currentUserId.isEmpty) {
      return 'Local user id not initialized';
    }

    await repo.addParticipant(taskId, _currentUserId);
    return 'Joined task successfully';
  }
}

class UuidPlaceholder {
  const UuidPlaceholder();
  String v4() => DateTime.now().microsecondsSinceEpoch.toRadixString(36);
}
