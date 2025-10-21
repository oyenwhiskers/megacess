
class AnalyticsResponse {
  final UsageAnalytics usageAnalytics;
  final TaskAnalytics taskAnalytics;

  AnalyticsResponse({
    required this.usageAnalytics,
    required this.taskAnalytics,
  });

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return AnalyticsResponse(
      usageAnalytics: UsageAnalytics.fromJson(json['usage_analytics'] ?? {}),
      taskAnalytics: TaskAnalytics.fromJson(json['task_analytics'] ?? {}),
    );
  }
}

class UsageAnalytics {
  final FertilizerUsage fertilizerUsage;
  final HerbicideUsage herbicideUsage;
  final FuelUsage fuelUsage;

  UsageAnalytics({
    required this.fertilizerUsage,
    required this.herbicideUsage,
    required this.fuelUsage,
  });

  factory UsageAnalytics.fromJson(Map<String, dynamic> json) {
    return UsageAnalytics(
      fertilizerUsage: FertilizerUsage.fromJson(json['fertilizer_usage'] ?? {}),
      herbicideUsage: HerbicideUsage.fromJson(json['herbicide_usage'] ?? {}),
      fuelUsage: FuelUsage.fromJson(json['fuel_usage'] ?? {}),
    );
  }
}

class FertilizerUsage {
  final double totalAmount;
  final String unit;
  final int taskCount;

  FertilizerUsage({
    required this.totalAmount,
    required this.unit,
    required this.taskCount,
  });

  factory FertilizerUsage.fromJson(Map<String, dynamic> json) {
    return FertilizerUsage(
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      taskCount: json['task_count'] ?? 0,
    );
  }
}

class HerbicideUsage {
  final double totalAmount;
  final String unit;
  final int taskCount;

  HerbicideUsage({
    required this.totalAmount,
    required this.unit,
    required this.taskCount,
  });

  factory HerbicideUsage.fromJson(Map<String, dynamic> json) {
    return HerbicideUsage(
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      taskCount: json['task_count'] ?? 0,
    );
  }
}

class FuelUsage {
  final double totalAmount;
  final String unit;
  final int taskCount;

  FuelUsage({
    required this.totalAmount,
    required this.unit,
    required this.taskCount,
  });

  factory FuelUsage.fromJson(Map<String, dynamic> json) {
    return FuelUsage(
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      taskCount: json['task_count'] ?? 0,
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
