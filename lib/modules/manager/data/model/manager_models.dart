class ManagerStats {
  final int totalInProgress;
  final int totalCompleted;
  final int totalPending;

  ManagerStats({
    required this.totalInProgress,
    required this.totalCompleted,
    required this.totalPending,
  });

  factory ManagerStats.fromJson(Map<String, dynamic> json) {
    return ManagerStats(
      totalInProgress: json['total_in_progress'] ?? 0,
      totalCompleted: json['total_completed'] ?? 0,
      totalPending: json['total_pending'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_in_progress': totalInProgress,
      'total_completed': totalCompleted,
      'total_pending': totalPending,
    };
  }
}

class TaskItem {
  final int id;
  final String title;
  final String description;
  final String status; // 'in_progress', 'completed', 'pending'
  final DateTime createdAt;
  final DateTime? completedAt;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}

class LocationItem {
  final int id;
  final String name;
  final int taskCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  LocationItem({
    required this.id,
    required this.name,
    required this.taskCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocationItem.fromJson(Map<String, dynamic> json) {
    return LocationItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      taskCount: json['taskCount'] ?? json['task_count'] ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] ?? json['updated_at'] ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'taskCount': taskCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Task Detail Models for Manage Tasks functionality
class TaskLocation {
  final int id;
  final String name;

  TaskLocation({required this.id, required this.name});

  factory TaskLocation.fromJson(Map<String, dynamic> json) {
    return TaskLocation(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class TaskCreator {
  final int id;
  final String name;

  TaskCreator({required this.id, required this.name});

  factory TaskCreator.fromJson(Map<String, dynamic> json) {
    return TaskCreator(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class TaskWorker {
  final int id;
  final String fullName;
  final String phone;

  TaskWorker({required this.id, required this.fullName, required this.phone});

  factory TaskWorker.fromJson(Map<String, dynamic> json) {
    return TaskWorker(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class TaskStaff {
  final int id;
  final String staffName;
  final int staffId;

  TaskStaff({required this.id, required this.staffName, required this.staffId});

  factory TaskStaff.fromJson(Map<String, dynamic> json) {
    return TaskStaff(
      id: json['id'] ?? 0,
      staffName: json['staff_name'] ?? '',
      staffId: json['staff_id'] ?? 0,
    );
  }
}

class TaskMeta {
  final int id;
  final int taskId;
  final int staffId;
  final String metaKey;
  final String metaValue;
  final TaskStaff staff;

  TaskMeta({
    required this.id,
    required this.taskId,
    required this.staffId,
    required this.metaKey,
    required this.metaValue,
    required this.staff,
  });

  factory TaskMeta.fromJson(Map<String, dynamic> json) {
    return TaskMeta(
      id: json['id'] ?? 0,
      taskId: json['task_id'] ?? 0,
      staffId: json['staff_id'] ?? 0,
      metaKey: json['meta_key'] ?? '',
      metaValue: json['meta_value'] ?? '',
      staff: TaskStaff.fromJson(json['staff'] ?? {}),
    );
  }
}

class TaskDetail {
  final int id;
  final TaskLocation location;
  final String taskName;
  final String taskType;
  final String taskDate;
  final String taskStatus;
  final TaskCreator createdBy;
  final String? submittedAt;
  final List<TaskWorker> workers;
  final List<TaskMeta> taskMeta;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskDetail({
    required this.id,
    required this.location,
    required this.taskName,
    required this.taskType,
    required this.taskDate,
    required this.taskStatus,
    required this.createdBy,
    this.submittedAt,
    required this.workers,
    required this.taskMeta,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskDetail.fromJson(Map<String, dynamic> json) {
    return TaskDetail(
      id: json['id'] ?? 0,
      location: TaskLocation.fromJson(json['location'] ?? {}),
      taskName: json['taskName'] ?? json['task_name'] ?? '',
      taskType: json['taskType'] ?? json['task_type'] ?? '',
      taskDate: json['taskDate'] ?? json['task_date'] ?? '',
      taskStatus: json['taskStatus'] ?? json['task_status'] ?? '',
      createdBy: TaskCreator.fromJson(
        json['createdBy'] ?? json['created_by'] ?? {},
      ),
      submittedAt: json['submittedAt'] ?? json['submitted_at'],
      workers: (json['workers'] as List<dynamic>? ?? [])
          .map((w) => TaskWorker.fromJson(w))
          .toList(),
      taskMeta: (json['task_meta'] as List<dynamic>? ?? [])
          .map((tm) => TaskMeta.fromJson(tm))
          .toList(),
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] ?? json['updated_at'] ?? '') ??
          DateTime.now(),
    );
  }
}

class LocationTasksResponse {
  final LocationItem location;
  final List<TaskDetail> tasks;

  LocationTasksResponse({required this.location, required this.tasks});

  factory LocationTasksResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return LocationTasksResponse(
      location: LocationItem.fromJson(data['location'] ?? {}),
      tasks: (data['tasks'] as List<dynamic>? ?? [])
          .map((t) => TaskDetail.fromJson(t))
          .toList(),
    );
  }
}

// Analytics Models
class UsageItem {
  final double totalAmount;
  final String unit;
  final int taskCount;

  UsageItem({
    required this.totalAmount,
    required this.unit,
    required this.taskCount,
  });

  factory UsageItem.fromJson(Map<String, dynamic> json) {
    return UsageItem(
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      taskCount: json['task_count'] ?? 0,
    );
  }
}

class UsageAnalytics {
  final UsageItem fertilizerUsage;
  final UsageItem herbicideUsage;
  final UsageItem fuelUsage;

  UsageAnalytics({
    required this.fertilizerUsage,
    required this.herbicideUsage,
    required this.fuelUsage,
  });

  factory UsageAnalytics.fromJson(Map<String, dynamic> json) {
    return UsageAnalytics(
      fertilizerUsage: UsageItem.fromJson(json['fertilizer_usage'] ?? {}),
      herbicideUsage: UsageItem.fromJson(json['herbicide_usage'] ?? {}),
      fuelUsage: UsageItem.fromJson(json['fuel_usage'] ?? {}),
    );
  }
}

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

class ManagerAnalytics {
  final UsageAnalytics usageAnalytics;
  final TaskAnalytics taskAnalytics;

  ManagerAnalytics({required this.usageAnalytics, required this.taskAnalytics});

  factory ManagerAnalytics.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return ManagerAnalytics(
      usageAnalytics: UsageAnalytics.fromJson(data['usage_analytics'] ?? {}),
      taskAnalytics: TaskAnalytics.fromJson(data['task_analytics'] ?? {}),
    );
  }
}

class AbsentWorker {
  final int staffId;
  final String staffName;
  final List<String> absentDates;
  final int totalAbsentDays;

  AbsentWorker({
    required this.staffId,
    required this.staffName,
    required this.absentDates,
    required this.totalAbsentDays,
  });

  factory AbsentWorker.fromJson(Map<String, dynamic> json) {
    return AbsentWorker(
      staffId: json['staff_id'] ?? 0,
      staffName: json['staff_name'] ?? '',
      absentDates: List<String>.from(json['absent_dates'] ?? []),
      totalAbsentDays: json['total_absent_days'] ?? 0,
    );
  }
}

class AbsentWorkersResponse {
  final String period;
  final List<AbsentWorker> records;

  AbsentWorkersResponse({required this.period, required this.records});

  factory AbsentWorkersResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return AbsentWorkersResponse(
      period: data['period'] ?? '',
      records: (data['records'] as List<dynamic>? ?? [])
          .map((r) => AbsentWorker.fromJson(r))
          .toList(),
    );
  }
}

class CheckerAnalytics {
  final int pendingTaskCount;
  final int completeTaskCount;
  final int absentPeopleCount;
  final String payrollDate;
  final int timeUntilPayroll;

  CheckerAnalytics({
    required this.pendingTaskCount,
    required this.completeTaskCount,
    required this.absentPeopleCount,
    required this.payrollDate,
    required this.timeUntilPayroll,
  });

  factory CheckerAnalytics.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return CheckerAnalytics(
      pendingTaskCount: data['pending_task_count'] ?? 0,
      completeTaskCount: data['complete_task_count'] ?? 0,
      absentPeopleCount: data['absent_people_count'] ?? 0,
      payrollDate: data['payroll_date'] ?? '',
      timeUntilPayroll: data['time_until_payroll'] ?? 0,
    );
  }
}

class ManagerProfile {
  final int id;
  final String userNickname;
  final String userFullname;
  final String userRole;
  final String? userImg;
  final String userPhone;
  final String userIc;
  final String userGender;
  final String userDob;
  final String userBankName;
  final String userBankNumber;
  final String userKwspNumber;
  final int attendanceCountMonth;

  ManagerProfile({
    required this.id,
    required this.userNickname,
    required this.userFullname,
    required this.userRole,
    this.userImg,
    required this.userPhone,
    required this.userIc,
    required this.userGender,
    required this.userDob,
    required this.userBankName,
    required this.userBankNumber,
    required this.userKwspNumber,
    required this.attendanceCountMonth,
  });

  factory ManagerProfile.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return ManagerProfile(
      id: data['id'] ?? 0,
      userNickname: data['user_nickname'] ?? '',
      userFullname: data['user_fullname'] ?? '',
      userRole: data['user_role'] ?? '',
      userImg: data['user_img'],
      userPhone: data['user_phone'] ?? '',
      userIc: data['user_ic'] ?? '',
      userGender: data['user_gender'] ?? '',
      userDob: data['user_dob'] ?? '',
      userBankName: data['user_bank_name'] ?? '',
      userBankNumber: data['user_bank_number'] ?? '',
      userKwspNumber: data['user_kwsp_number'] ?? '',
      attendanceCountMonth: data['attendance_count_month'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_nickname': userNickname,
      'user_fullname': userFullname,
      'user_role': userRole,
      'user_img': userImg,
      'user_phone': userPhone,
      'user_ic': userIc,
      'user_gender': userGender,
      'user_dob': userDob,
      'user_bank_name': userBankName,
      'user_bank_number': userBankNumber,
      'user_kwsp_number': userKwspNumber,
      'attendance_count_month': attendanceCountMonth,
    };
  }
}
