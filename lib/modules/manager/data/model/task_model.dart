class WorkerModel {
  final int id;
  final String fullName;
  final String phone;

  WorkerModel({required this.id, required this.fullName, required this.phone});

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class CreatedByModel {
  final int id;
  final String name;

  CreatedByModel({required this.id, required this.name});

  factory CreatedByModel.fromJson(Map<String, dynamic> json) {
    return CreatedByModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class TaskMetaModel {
  final int id;
  final int taskId;
  final int staffId;
  final String metaKey;
  final String metaValue;
  final StaffMetaModel? staff;

  TaskMetaModel({
    required this.id,
    required this.taskId,
    required this.staffId,
    required this.metaKey,
    required this.metaValue,
    this.staff,
  });

  factory TaskMetaModel.fromJson(Map<String, dynamic> json) {
    return TaskMetaModel(
      id: json['id'] ?? 0,
      taskId: json['task_id'] ?? 0,
      staffId: json['staff_id'] ?? 0,
      metaKey: json['meta_key'] ?? '',
      metaValue: json['meta_value'] ?? '',
      staff: json['staff'] != null
          ? StaffMetaModel.fromJson(json['staff'])
          : null,
    );
  }
}

class StaffMetaModel {
  final int id;
  final String staffName;
  final int staffId;

  StaffMetaModel({
    required this.id,
    required this.staffName,
    required this.staffId,
  });

  factory StaffMetaModel.fromJson(Map<String, dynamic> json) {
    return StaffMetaModel(
      id: json['id'] ?? 0,
      staffName: json['staff_name'] ?? '',
      staffId: json['staff_id'] ?? 0,
    );
  }
}

class TaskDetailModel {
  final int id;
  final LocationModel location;
  final String taskName;
  final String taskType;
  final String taskDate;
  final String taskStatus;
  final CreatedByModel createdBy;
  final String? submittedAt;
  final List<WorkerModel> workers;
  final List<TaskMetaModel> taskMeta;
  final String createdAt;
  final String updatedAt;

  TaskDetailModel({
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

  factory TaskDetailModel.fromJson(Map<String, dynamic> json) {
    return TaskDetailModel(
      id: json['id'] ?? 0,
      location: LocationModel.fromJson(json['location'] ?? {}),
      taskName: json['taskName'] ?? '',
      taskType: json['taskType'] ?? '',
      taskDate: json['taskDate'] ?? '',
      taskStatus: json['taskStatus'] ?? '',
      createdBy: CreatedByModel.fromJson(json['createdBy'] ?? {}),
      submittedAt: json['submittedAt'],
      workers: (json['workers'] as List<dynamic>? ?? [])
          .map((e) => WorkerModel.fromJson(e))
          .toList(),
      taskMeta: (json['task_meta'] as List<dynamic>? ?? [])
          .map((e) => TaskMetaModel.fromJson(e))
          .toList(),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class LocationDetailModel {
  final int id;
  final String name;
  final int taskCount;
  final String createdAt;
  final String updatedAt;

  LocationDetailModel({
    required this.id,
    required this.name,
    required this.taskCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocationDetailModel.fromJson(Map<String, dynamic> json) {
    return LocationDetailModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      taskCount: json['taskCount'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class LocationTasksDetailResponse {
  final LocationDetailModel location;
  final List<TaskDetailModel> tasks;

  LocationTasksDetailResponse({required this.location, required this.tasks});

  factory LocationTasksDetailResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return LocationTasksDetailResponse(
      location: LocationDetailModel.fromJson(data['location'] ?? {}),
      tasks: (data['tasks'] as List<dynamic>? ?? [])
          .map((e) => TaskDetailModel.fromJson(e))
          .toList(),
    );
  }
}

class LocationModel {
  final int id;
  final String name;
  final int taskCount;

  LocationModel({
    required this.id,
    required this.name,
    required this.taskCount,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      taskCount: json['taskCount'] ?? 0,
    );
  }
}

class LocationListResponse {
  final List<LocationModel> locations;

  LocationListResponse({required this.locations});

  factory LocationListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    return LocationListResponse(
      locations: data.map((e) => LocationModel.fromJson(e)).toList(),
    );
  }
}

class TaskModel {
  final int id;
  final LocationModel location;

  TaskModel({required this.id, required this.location});

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      location: LocationModel.fromJson(json['location'] ?? {}),
    );
  }
}

class TaskListResponse {
  final List<TaskModel> tasks;

  TaskListResponse({required this.tasks});

  factory TaskListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    return TaskListResponse(
      tasks: data.map((e) => TaskModel.fromJson(e)).toList(),
    );
  }
}
