import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final String notes;
  final bool done;
  final int updatedAt;
  final List<String> participants;

  Task({
    required this.id,
    required this.title,
    this.notes = '',
    this.done = false,
    required this.updatedAt,
    required this.participants,
  });

  Task copyWith({
    String? title,
    String? notes,
    bool? done,
    List<String>? participants,
    int? updatedAt,
  }) => Task(
    id: id,
    title: title ?? this.title,
    notes: notes ?? this.notes,
    done: done ?? this.done,
    updatedAt: updatedAt ?? DateTime.now().millisecondsSinceEpoch,
    participants: participants ?? this.participants,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'notes': notes,
    'done': done,
    'updatedAt': updatedAt,
    'participants': participants,
  };

  factory Task.fromJson(Map<dynamic, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    notes: json['notes'] as String? ?? '',
    done: json['done'] as bool? ?? false,
    updatedAt: json['updatedAt'] as int? ?? 0,
    participants:
        (json['participants'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
  );

  static Task create(String title, {required String creatorId}) {
    return Task(
      id: const Uuid().v4(),
      title: title,
      notes: '',
      done: false,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      participants: [creatorId],
    );
  }
}
