class TaskAnalytics {
  final int totalTasks;
  final int inProgress;
  final int pending;
  final int rejected;
  final int completed;

  TaskAnalytics({
    required this.totalTasks,
    required this.inProgress,
    required this.pending,
    required this.rejected,
    required this.completed,
  });

  factory TaskAnalytics.fromJson(Map<String, dynamic> json) {
    return TaskAnalytics(
      totalTasks: json['total_tasks'] ?? 0,
      inProgress: json['in_progress'] ?? 0,
      pending: json['pending'] ?? 0,
      rejected: json['rejected'] ?? 0,
      completed: json['completed'] ?? 0,
    );
  }
}
