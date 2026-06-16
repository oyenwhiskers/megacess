class AuditTaskPreviewWorker {
  final int id;
  final String fullName;
  final String phone;
  final Map<String, dynamic> meta;
  AuditTaskPreviewWorker({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.meta,
  });
  factory AuditTaskPreviewWorker.fromJson(Map<String, dynamic> json) =>
      AuditTaskPreviewWorker(
        id: json['id'] ?? 0,
        fullName: json['fullName'] ?? '',
        phone: json['phone'] ?? '',
        meta: json['meta'] ?? {},
      );
}

class AuditTaskPreviewLocation {
  final int id;
  final String name;
  AuditTaskPreviewLocation({required this.id, required this.name});
  factory AuditTaskPreviewLocation.fromJson(Map<String, dynamic> json) =>
      AuditTaskPreviewLocation(id: json['id'] ?? 0, name: json['name'] ?? '');
}

class AuditTaskPreviewCreatedBy {
  final int id;
  final String name;
  AuditTaskPreviewCreatedBy({required this.id, required this.name});
  factory AuditTaskPreviewCreatedBy.fromJson(Map<String, dynamic> json) =>
      AuditTaskPreviewCreatedBy(id: json['id'] ?? 0, name: json['name'] ?? '');
}

class AuditTaskPreviewModel {
  final int id;
  final AuditTaskPreviewLocation location;
  final String taskName;
  final String taskType;
  final String taskDate;
  final String taskStatus;
  final AuditTaskPreviewCreatedBy createdBy;
  final String? submittedAt;
  final Map<String, dynamic> meta;
  final List<AuditTaskPreviewWorker> workers;
  final String createdAt;
  final String updatedAt;
  AuditTaskPreviewModel({
    required this.id,
    required this.location,
    required this.taskName,
    required this.taskType,
    required this.taskDate,
    required this.taskStatus,
    required this.createdBy,
    required this.submittedAt,
    required this.meta,
    required this.workers,
    required this.createdAt,
    required this.updatedAt,
  });
  factory AuditTaskPreviewModel.fromJson(Map<String, dynamic> json) =>
      AuditTaskPreviewModel(
        id: json['id'] ?? 0,
        location: AuditTaskPreviewLocation.fromJson(json['location'] ?? {}),
        taskName: json['taskName'] ?? '',
        taskType: json['taskType'] ?? '',
        taskDate: json['taskDate'] ?? '',
        taskStatus: json['taskStatus'] ?? '',
        createdBy: AuditTaskPreviewCreatedBy.fromJson(json['createdBy'] ?? {}),
        submittedAt: json['submittedAt'],
        meta: json['meta'] ?? {},
        workers: (json['workers'] as List<dynamic>? ?? [])
            .map((e) => AuditTaskPreviewWorker.fromJson(e))
            .toList(),
        createdAt: json['createdAt'] ?? '',
        updatedAt: json['updatedAt'] ?? '',
      );
}
