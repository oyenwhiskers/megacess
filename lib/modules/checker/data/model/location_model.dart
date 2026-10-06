class Location {
  final int id;
  final String name;
  final int taskCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Location({
    required this.id,
    required this.name,
    required this.taskCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      taskCount: json['taskCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class LocationListResponse {
  final List<Location> locations;
  LocationListResponse({required this.locations});

  factory LocationListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    return LocationListResponse(
      locations: data.map((e) => Location.fromJson(e)).toList(),
    );
  }
}
