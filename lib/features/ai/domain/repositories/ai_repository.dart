import 'dart:async';

enum TaskState {
  pending,
  running,
  completed,
  failed,
}

class AiTaskEvent {
  final String taskId;
  final String title;
  final TaskState state;
  final String? error;
  final DateTime timestamp;

  const AiTaskEvent({
    required this.taskId,
    required this.title,
    required this.state,
    this.error,
    required this.timestamp,
  });

  AiTaskEvent copyWith({
    TaskState? state,
    String? error,
  }) {
    return AiTaskEvent(
      taskId: taskId,
      title: title,
      state: state ?? this.state,
      error: error ?? this.error,
      timestamp: DateTime.now(),
    );
  }
}

abstract class AIRepository {
  Future<String> chat(String message);
  Stream<String> chatStream(String message);
  Future<void> clearHistory();
  Stream<List<AiTaskEvent>> get taskEvents;
}
