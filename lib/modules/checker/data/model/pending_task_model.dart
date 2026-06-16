class PendingTask {
  final int id;
  final String taskName;
  final String taskDescription;
  final String taskStatus;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  PendingTask({
    required this.id,
    required this.taskName,
    required this.taskDescription,
    required this.taskStatus,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PendingTask.fromJson(Map<String, dynamic> json) {
    return PendingTask(
      id: json['id'] ?? 0,
      taskName: json['task_name'] ?? '',
      taskDescription: json['task_description'] ?? '',
      taskStatus: json['task_status'] ?? '',
      createdBy: json['created_by'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class PendingTaskListResponse {
  final List<PendingTask> tasks;

  PendingTaskListResponse({required this.tasks});

  factory PendingTaskListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    return PendingTaskListResponse(
      tasks: data.map((e) => PendingTask.fromJson(e)).toList(),
    );
  }
}
