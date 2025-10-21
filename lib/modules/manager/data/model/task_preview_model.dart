class TaskPreviewModel {
  final int id;
  final LocationPreviewModel location;
  final String taskName;
  final String taskType;
  final String taskDate;
  final String taskStatus;
  final CreatedByPreviewModel createdBy;
  final String? submittedAt;
  final Map<String, dynamic> meta;
  final List<TaskWorkerModel> workers;
  final String createdAt;
  final String updatedAt;

  TaskPreviewModel({
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

  factory TaskPreviewModel.fromJson(Map<String, dynamic> json) {
    return TaskPreviewModel(
      id: json['id'],
      location: LocationPreviewModel.fromJson(json['location']),
      taskName: json['taskName'],
      taskType: json['taskType'],
      taskDate: json['taskDate'],
      taskStatus: json['taskStatus'],
      createdBy: CreatedByPreviewModel.fromJson(json['createdBy']),
      submittedAt: json['submittedAt'],
      meta: json['meta'] ?? {},
      workers: (json['workers'] as List<dynamic>? ?? []).map((w) => TaskWorkerModel.fromJson(w)).toList(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class LocationPreviewModel {
  final int id;
  final String name;
  LocationPreviewModel({required this.id, required this.name});
  factory LocationPreviewModel.fromJson(Map<String, dynamic> json) {
    return LocationPreviewModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

class CreatedByPreviewModel {
  final int id;
  final String name;
  CreatedByPreviewModel({required this.id, required this.name});
  factory CreatedByPreviewModel.fromJson(Map<String, dynamic> json) {
    return CreatedByPreviewModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

class TaskWorkerModel {
  final int id;
  final String fullName;
  final String phone;
  final Map<String, dynamic> meta;
  TaskWorkerModel({required this.id, required this.fullName, required this.phone, required this.meta});
  factory TaskWorkerModel.fromJson(Map<String, dynamic> json) {
    return TaskWorkerModel(
      id: json['id'],
      fullName: json['fullName'],
      phone: json['phone'],
      meta: json['meta'] ?? {},
    );
  }
}
