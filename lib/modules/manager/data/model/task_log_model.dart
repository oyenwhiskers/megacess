class TaskLogModel {
  final int id;
  final int taskId;
  final int userId;
  final String taskStatus;
  final String remarks;
  final TaskLogUser user;
  final String createdAt;
  final String updatedAt;

  TaskLogModel({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.taskStatus,
    required this.remarks,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskLogModel.fromJson(Map<String, dynamic> json) {
    return TaskLogModel(
      id: json['id'],
      taskId: json['task_id'],
      userId: json['user_id'],
      taskStatus: json['task_status'],
      remarks: json['remarks'] ?? '',
      user: TaskLogUser.fromJson(json['user']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class TaskLogUser {
  final int id;
  final String userFullname;
  TaskLogUser({required this.id, required this.userFullname});
  factory TaskLogUser.fromJson(Map<String, dynamic> json) {
    return TaskLogUser(
      id: json['id'],
      userFullname: json['user_fullname'],
    );
  }
}
