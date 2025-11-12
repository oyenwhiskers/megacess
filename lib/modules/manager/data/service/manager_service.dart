import '../model/manager_models.dart';
import '../../../utility/dio_client.dart';
import '../../../utility/secure_storage_service.dart';
import 'package:dio/dio.dart';

class ManagerService {
  // Singleton pattern for demo purposes
  static final ManagerService _instance = ManagerService._internal();
  factory ManagerService() => _instance;
  ManagerService._internal();
  
  // Demo data - in real app this would come from API
  List<TaskItem> _tasks = [
    TaskItem(
      id: 1,
      title: 'Complete Project A',
      description: 'Finish the implementation of Project A features',
      status: 'in_progress',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TaskItem(
      id: 2,
      title: 'Review Code',
      description: 'Review team member code submissions',
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TaskItem(
      id: 3,
      title: 'Plan Sprint',
      description: 'Plan next sprint activities and assignments',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
  
  // Get manager statistics
  Future<ManagerStats> getManagerStats() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final inProgress = _tasks.where((task) => task.status == 'in_progress').length;
    final completed = _tasks.where((task) => task.status == 'completed').length;
    final pending = _tasks.where((task) => task.status == 'pending').length;
    
    return ManagerStats(
      totalInProgress: inProgress,
      totalCompleted: completed,
      totalPending: pending,
    );
  }
  
  // Get all tasks
  Future<List<TaskItem>> getAllTasks() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_tasks);
  }
  
  // Get tasks by status
  Future<List<TaskItem>> getTasksByStatus(String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _tasks.where((task) => task.status == status).toList();
  }
  
  // Add new task (demo)
  Future<bool> addTask(TaskItem task) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _tasks.add(task);
    return true;
  }
  
  // Update task status (demo)
  Future<bool> updateTaskStatus(int taskId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final updatedTask = TaskItem(
        id: task.id,
        title: task.title,
        description: task.description,
        status: newStatus,
        createdAt: task.createdAt,
        completedAt: newStatus == 'completed' ? DateTime.now() : null,
      );
      _tasks[taskIndex] = updatedTask;
      return true;
    }
    return false;
  }
  
  // Delete task (demo)
  Future<bool> deleteTask(int taskId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _tasks.removeWhere((task) => task.id == taskId);
    return true;
  }

  // Fetch locations from API
  final String _baseUrl = 'https://mwms.megacess.com/api/';
  final SecureStorageService _storageService = SecureStorageService();
  late final DioClient _dioClient = DioClient(
    baseUrl: _baseUrl,
    storageService: _storageService,
  );

  /// GET v1/locations
  Future<List<LocationItem>> fetchLocations() async {
    try {
      final response = await _dioClient.get('v1/locations');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['success'] == true && data['data'] is List) {
          final list = (data['data'] as List)
              .map((e) => LocationItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          return list;
        }
      }
    } catch (e) {
      // ignore - will fallback to demo data below
      // print('fetchLocations error: $e');
    }

    // Fallback/demo data if network fails
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      LocationItem(id: 1, name: 'A01', taskCount: 4, createdAt: DateTime.now(), updatedAt: DateTime.now()),
      LocationItem(id: 2, name: 'A02', taskCount: 4, createdAt: DateTime.now(), updatedAt: DateTime.now()),
      LocationItem(id: 3, name: 'B01', taskCount: 4, createdAt: DateTime.now(), updatedAt: DateTime.now()),
      LocationItem(id: 4, name: 'B02', taskCount: 4, createdAt: DateTime.now(), updatedAt: DateTime.now()),
      LocationItem(id: 5, name: 'C01', taskCount: 4, createdAt: DateTime.now(), updatedAt: DateTime.now()),
      LocationItem(id: 6, name: 'C02', taskCount: 4, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    ];
  }

  /// GET v1/locations/{location_id}/tasks
  Future<LocationTasksResponse> fetchLocationTasks(int locationId) async {
    try {
      final response = await _dioClient.get('v1/locations/$locationId/tasks');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['success'] == true) {
          return LocationTasksResponse.fromJson(data);
        }
      }
    } catch (e) {
      // ignore - will fallback to demo data below
      // print('fetchLocationTasks error: $e');
    }

    // Fallback/demo data if network fails
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find the location name for demo
    final locations = await fetchLocations();
    final location = locations.firstWhere(
      (loc) => loc.id == locationId,
      orElse: () => LocationItem(
        id: locationId, 
        name: 'A01', 
        taskCount: 5, 
        createdAt: DateTime.now(), 
        updatedAt: DateTime.now()
      ),
    );
    
    // Demo tasks data
    final demoTasks = [
      TaskDetail(
        id: 1,
        location: TaskLocation(id: locationId, name: location.name),
        taskName: 'Manuring1',
        taskType: 'Manuring',
        taskDate: '2025-01-15',
        taskStatus: 'in_progress',
        createdBy: TaskCreator(id: 1, name: 'Manager2'),
        submittedAt: null,
        workers: [
          TaskWorker(id: 1, fullName: 'Worker One', phone: '019-1234567'),
        ],
        taskMeta: [],
        createdAt: DateTime.parse('2025-01-01 00:00:00'),
        updatedAt: DateTime.parse('2025-01-01 00:00:00'),
      ),
      TaskDetail(
        id: 2,
        location: TaskLocation(id: locationId, name: location.name),
        taskName: 'Pruning1',
        taskType: 'Pruning',
        taskDate: '2025-01-16',
        taskStatus: 'in_progress',
        createdBy: TaskCreator(id: 1, name: 'Manager2'),
        submittedAt: null,
        workers: [
          TaskWorker(id: 2, fullName: 'Worker Two', phone: '019-2345678'),
        ],
        taskMeta: [],
        createdAt: DateTime.parse('2025-01-02 00:00:00'),
        updatedAt: DateTime.parse('2025-01-02 00:00:00'),
      ),
      TaskDetail(
        id: 3,
        location: TaskLocation(id: locationId, name: location.name),
        taskName: 'Sanitation1',
        taskType: 'Sanitation',
        taskDate: '2025-01-17',
        taskStatus: 'in_progress',
        createdBy: TaskCreator(id: 1, name: 'Manager2'),
        submittedAt: null,
        workers: [
          TaskWorker(id: 3, fullName: 'Worker Three', phone: '019-3456789'),
        ],
        taskMeta: [],
        createdAt: DateTime.parse('2025-01-03 00:00:00'),
        updatedAt: DateTime.parse('2025-01-03 00:00:00'),
      ),
      TaskDetail(
        id: 4,
        location: TaskLocation(id: locationId, name: location.name),
        taskName: 'Harvesting1',
        taskType: 'Harvesting',
        taskDate: '2025-01-18',
        taskStatus: 'in_progress',
        createdBy: TaskCreator(id: 1, name: 'Manager2'),
        submittedAt: null,
        workers: [
          TaskWorker(id: 4, fullName: 'Worker Four', phone: '019-4567890'),
        ],
        taskMeta: [],
        createdAt: DateTime.parse('2025-01-04 00:00:00'),
        updatedAt: DateTime.parse('2025-01-04 00:00:00'),
      ),
      TaskDetail(
        id: 5,
        location: TaskLocation(id: locationId, name: location.name),
        taskName: 'Planting1',
        taskType: 'Planting',
        taskDate: '2025-01-19',
        taskStatus: 'in_progress',
        createdBy: TaskCreator(id: 1, name: 'Manager2'),
        submittedAt: null,
        workers: [
          TaskWorker(id: 5, fullName: 'Worker Five', phone: '019-5678901'),
        ],
        taskMeta: [],
        createdAt: DateTime.parse('2025-01-05 00:00:00'),
        updatedAt: DateTime.parse('2025-01-05 00:00:00'),
      ),
    ];
    
    return LocationTasksResponse(
      location: location,
      tasks: demoTasks,
    );
  }

  /// GET v1/analytics/manager
  Future<ManagerAnalytics> fetchManagerAnalytics() async {
    try {
      final response = await _dioClient.get('v1/analytics/manager');
      print('DEBUG: Manager Analytics API Response: ${response.statusCode}');
      print('DEBUG: Manager Analytics API Data: ${response.data}');
      
      if (response.statusCode == 200 && response.data is Map && response.data['success'] == true) {
        print('DEBUG: Successfully parsed Manager Analytics from real API');
        return ManagerAnalytics.fromJson(response.data);
      } else {
        throw Exception(
          response.data?['message'] ?? 'Failed to fetch manager analytics',
        );
      }
    } on DioException catch (e) {
      print('DEBUG: Manager Analytics API failed with DioException: ${e.message}');
      if (e.response != null && e.response?.data != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch manager analytics',
        );
      }
      throw Exception('Network error while fetching manager analytics');
    } catch (e) {
      print('DEBUG: Manager Analytics API failed: $e');
      throw Exception('Failed to fetch manager analytics: $e');
    }
  }

  /// GET v1/analytics/absent-workers
  Future<AbsentWorkersResponse> fetchAbsentWorkers() async {
    try {
      final response = await _dioClient.get('v1/analytics/absent-workers');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['success'] == true) {
          return AbsentWorkersResponse.fromJson(data);
        }
      }
    } catch (e) {
      // ignore - will fallback to demo data below
      // print('fetchAbsentWorkers error: $e');
    }

    // Fallback/demo data if network fails
    await Future.delayed(const Duration(milliseconds: 300));
    
    final demoData = {
      'success': true,
      'data': {
        'period': 'November 2025',
        'filter': {
          'type': 'month',
          'year': 2025,
          'month': 11
        },
        'records': [
          {
            'staff_id': 1,
            'staff_name': 'Ali bin Abu',
            'absent_dates': [
              '2025-11-05',
              '2025-11-12'
            ],
            'total_absent_days': 2
          }
        ]
      }
    };
    
    return AbsentWorkersResponse.fromJson(demoData);
  }

  /// GET v1/profile
  Future<ManagerProfile> fetchProfile() async {
    try {
      final response = await _dioClient.get('v1/profile');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['success'] == true) {
          return ManagerProfile.fromJson(data);
        }
      }
      throw Exception('Failed to fetch profile');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized');
      }
      throw Exception('Network error while fetching profile');
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  /// PUT v1/profile (for updating profile)
  Future<ManagerProfile> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _dioClient.put('v1/profile', data: profileData);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['success'] == true) {
          return ManagerProfile.fromJson(data);
        }
      }
      throw Exception('Failed to update profile');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized');
      } else if (e.response?.statusCode == 422) {
        final data = e.response?.data;
        if (data != null && data['errors'] is Map) {
          final errors = data['errors'] as Map<String, dynamic>;
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessages.add(value.first.toString());
            }
          });
          throw Exception(errorMessages.join(', '));
        }
        throw Exception('Validation error');
      }
      throw Exception('Network error while updating profile');
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}