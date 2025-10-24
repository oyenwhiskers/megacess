class AuditTaskWorker {
  final int id;
  final String fullName;
  final String phone;
  AuditTaskWorker({
    required this.id,
    required this.fullName,
    required this.phone,
  });
  factory AuditTaskWorker.fromJson(Map<String, dynamic> json) =>
      AuditTaskWorker(
        id: json['id'] ?? 0,
        fullName: json['fullName'] ?? '',
        phone: json['phone'] ?? '',
      );
}

class AuditTaskMeta {
  final int id;
  final int taskId;
  final int staffId;
  final String metaKey;
  final String metaValue;
  final AuditTaskMetaStaff? staff;
  AuditTaskMeta({
    required this.id,
    required this.taskId,
    required this.staffId,
    required this.metaKey,
    required this.metaValue,
    this.staff,
  });
  factory AuditTaskMeta.fromJson(Map<String, dynamic> json) => AuditTaskMeta(
    id: json['id'] ?? 0,
    taskId: json['task_id'] ?? 0,
    staffId: json['staff_id'] ?? 0,
    metaKey: json['meta_key'] ?? '',
    metaValue: json['meta_value'] ?? '',
    staff: json['staff'] != null
        ? AuditTaskMetaStaff.fromJson(json['staff'])
        : null,
  );
}

class AuditTaskMetaStaff {
  final int id;
  final String staffName;
  final int staffId;
  AuditTaskMetaStaff({
    required this.id,
    required this.staffName,
    required this.staffId,
  });
  factory AuditTaskMetaStaff.fromJson(Map<String, dynamic> json) =>
      AuditTaskMetaStaff(
        id: json['id'] ?? 0,
        staffName: json['staff_name'] ?? '',
        staffId: json['staff_id'] ?? 0,
      );
}

class AuditTaskCreatedBy {
  final int id;
  final String name;
  AuditTaskCreatedBy({required this.id, required this.name});
  factory AuditTaskCreatedBy.fromJson(Map<String, dynamic> json) =>
      AuditTaskCreatedBy(id: json['id'] ?? 0, name: json['name'] ?? '');
}

class AuditTaskLocation {
  final int id;
  final String name;
  AuditTaskLocation({required this.id, required this.name});
  factory AuditTaskLocation.fromJson(Map<String, dynamic> json) =>
      AuditTaskLocation(id: json['id'] ?? 0, name: json['name'] ?? '');
}

class AuditTaskModel {
  final int id;
  final AuditTaskLocation location;
  final String taskName;
  final String taskType;
  final String taskDate;
  final String taskStatus;
  final AuditTaskCreatedBy createdBy;
  final String submittedAt;
  final List<AuditTaskWorker> workers;
  final List<AuditTaskMeta> taskMeta;
  final String createdAt;
  final String updatedAt;
  AuditTaskModel({
    required this.id,
    required this.location,
    required this.taskName,
    required this.taskType,
    required this.taskDate,
    required this.taskStatus,
    required this.createdBy,
    required this.submittedAt,
    required this.workers,
    required this.taskMeta,
    required this.createdAt,
    required this.updatedAt,
  });
  factory AuditTaskModel.fromJson(Map<String, dynamic> json) => AuditTaskModel(
    id: json['id'] ?? 0,
    location: AuditTaskLocation.fromJson(json['location'] ?? {}),
    taskName: json['taskName'] ?? '',
    taskType: json['taskType'] ?? '',
    taskDate: json['taskDate'] ?? '',
    taskStatus: json['taskStatus'] ?? '',
    createdBy: AuditTaskCreatedBy.fromJson(json['createdBy'] ?? {}),
    submittedAt: json['submittedAt'] ?? '',
    workers: (json['workers'] as List<dynamic>? ?? [])
        .map((e) => AuditTaskWorker.fromJson(e))
        .toList(),
    taskMeta: (json['task_meta'] as List<dynamic>? ?? [])
        .map((e) => AuditTaskMeta.fromJson(e))
        .toList(),
    createdAt: json['createdAt'] ?? '',
    updatedAt: json['updatedAt'] ?? '',
  );
}

class AuditTaskLocationDetail {
  final int id;
  final String name;
  final int taskCount;
  final String createdAt;
  final String updatedAt;
  AuditTaskLocationDetail({
    required this.id,
    required this.name,
    required this.taskCount,
    required this.createdAt,
    required this.updatedAt,
  });
  factory AuditTaskLocationDetail.fromJson(Map<String, dynamic> json) =>
      AuditTaskLocationDetail(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        taskCount: json['taskCount'] ?? 0,
        createdAt: json['createdAt'] ?? '',
        updatedAt: json['updatedAt'] ?? '',
      );
}

class AuditTaskLocationTasksResponse {
  final AuditTaskLocationDetail location;
  final List<AuditTaskModel> tasks;
  AuditTaskLocationTasksResponse({required this.location, required this.tasks});
  factory AuditTaskLocationTasksResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return AuditTaskLocationTasksResponse(
      location: AuditTaskLocationDetail.fromJson(data['location'] ?? {}),
      tasks: (data['tasks'] as List<dynamic>? ?? [])
          .map((e) => AuditTaskModel.fromJson(e))
          .toList(),
    );
  }
}
