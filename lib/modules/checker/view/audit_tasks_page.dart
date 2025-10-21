import 'package:flutter/material.dart';
import 'package:megacess/modules/checker/data/model/location_model.dart';
import 'package:megacess/modules/checker/data/service/attendance_service.dart';
import 'package:megacess/modules/utility/secure_storage_service.dart';
import 'package:megacess/modules/checker/view/manage_audit_task_page.dart';

class AuditTasksPage extends StatelessWidget {
  const AuditTasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      // Custom header to match design
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 18),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF43C463), Color(0xFFB2F7EF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              const Text(
                'Hello, checker_name',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.person, color: Colors.black54, size: 26),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Location (Total Tasks)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<LocationListResponse>(
                future: AttendanceService(SecureStorageService()).fetchLocationList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load locations.'));
                  } else if (!snapshot.hasData || snapshot.data!.locations.isEmpty) {
                    return const Center(child: Text('No locations found.'));
                  }
                  final locations = snapshot.data!.locations;
                  return GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: locations.length,
                    itemBuilder: (context, i) {
                      final loc = locations[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ManageAuditTaskPage(
                                locationId: loc.id,
                                locationName: loc.name,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB2F7EF), Color(0xFF43C463)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  loc.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Color(0xFF222B45),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  loc.taskCount.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    color: Color(0xFF222B45),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
