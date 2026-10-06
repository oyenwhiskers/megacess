import 'package:flutter/material.dart';
import 'package:megacess/modules/checker/data/model/location_model.dart';
import 'package:megacess/modules/checker/data/service/attendance_service.dart';
import 'package:megacess/modules/utility/secure_storage_service.dart';
import 'package:megacess/modules/checker/view/manage_audit_task_page.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/mega_app_header.dart';

class AuditTasksPage extends StatefulWidget {
  const AuditTasksPage({super.key});

  @override
  State<AuditTasksPage> createState() => _AuditTasksPageState();
}

class _AuditTasksPageState extends State<AuditTasksPage> {
  late Future<LocationListResponse> _locationsFuture;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  void _loadLocations() {
    _locationsFuture = AttendanceService(
      SecureStorageService(),
    ).fetchLocationList();
  }

  void _refreshLocations() {
    setState(() {
      _loadLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mcBgApp,
      appBar: MegaAppHeader(
        title: 'Audit Tasks',
        subtitle: 'Field inspection & verification by block',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshLocations(),
        color: AppColors.frond6,
        backgroundColor: AppColors.mcBgSurface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estate Inspection Blocks',
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<LocationListResponse>(
                  future: _locationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.frond6),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 44,
                              color: AppColors.mcStatusDanger,
                            ),
                            const SizedBox(height: 12),
                            Text('Failed to load locations', style: AppTypography.titleMedium),
                            const SizedBox(height: 6),
                            Text(
                              snapshot.error.toString(),
                              style: AppTypography.captionMuted,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refreshLocations,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.locations.isEmpty) {
                      return Center(
                        child: Text(
                          'No locations available for audit.',
                          style: AppTypography.caption,
                        ),
                      );
                    }

                    final locations = snapshot.data!.locations;
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.15,
                      ),
                      itemCount: locations.length,
                      itemBuilder: (context, i) {
                        final loc = locations[i];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ManageAuditTaskPage(
                                    locationId: loc.id,
                                    locationName: loc.name,
                                  ),
                                ),
                              );
                              if (result == true) {
                                _refreshLocations();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.mcBgSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.mcBorder, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: AppColors.frond0,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.fact_check_outlined,
                                          size: 18,
                                          color: AppColors.frond6,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        size: 18,
                                        color: AppColors.mcTextDisabled,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loc.name,
                                        style: AppTypography.titleMedium.copyWith(fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '${loc.taskCount}',
                                            style: AppTypography.heroNumber.copyWith(
                                              color: AppColors.frond6,
                                              fontSize: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'audits',
                                            style: AppTypography.captionMuted,
                                          ),
                                        ],
                                      ),
                                    ],
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
      ),
    );
  }
}
