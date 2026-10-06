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
    // Accepts either root-level keys or nested under 'data'
    final data = json['data'] ?? json;
    return CheckerAnalytics(
      pendingTaskCount: data['pending_task_count'] ?? 0,
      completeTaskCount: data['complete_task_count'] ?? 0,
      absentPeopleCount: data['absent_people_count'] ?? 0,
      payrollDate: data['payroll_date'] ?? '',
      timeUntilPayroll: data['time_until_payroll'] ?? 0,
    );
  }
}
