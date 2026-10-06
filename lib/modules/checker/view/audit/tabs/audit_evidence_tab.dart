import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:megacess/core/theme/app_colors.dart';
import 'package:megacess/core/theme/app_typography.dart';
import 'package:megacess/modules/checker/view/audit/audit_media_dialog.dart';

class AuditEvidenceTab extends StatelessWidget {
  final List<Map<String, dynamic>> uploadedFiles;
  final bool isUploading;
  final VoidCallback onAddImage;
  final VoidCallback onAddVideo;
  final Function(Map<String, dynamic>) onDeleteMedia;

  const AuditEvidenceTab({
    super.key,
    required this.uploadedFiles,
    required this.isUploading,
    required this.onAddImage,
    required this.onAddVideo,
    required this.onDeleteMedia,
  });

  @override
  Widget build(BuildContext context) {
    final videoFiles = uploadedFiles.where((f) => f['isVideo'] == true).toList();
    final photoFiles = uploadedFiles.where((f) => f['isVideo'] != true).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Capture Action Cards Grid
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.camera_alt_outlined,
                  title: 'Add Photo',
                  subtitle: '${photoFiles.length} attached',
                  accentColor: AppColors.mcForestGreen,
                  badgeText: photoFiles.isEmpty ? 'Required' : 'Ready',
                  badgeColor: photoFiles.isEmpty
                      ? AppColors.statusPendingText
                      : AppColors.statusCompletedText,
                  badgeBg: photoFiles.isEmpty
                      ? AppColors.statusPendingBg
                      : AppColors.statusCompletedBg,
                  onTap: isUploading ? null : onAddImage,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.videocam_outlined,
                  title: 'Add Video',
                  subtitle: '${videoFiles.length} attached (max 30s)',
                  accentColor: const Color(0xFFC05621), // Amber/Orange
                  badgeText: videoFiles.isEmpty ? 'Required' : 'Ready',
                  badgeColor: videoFiles.isEmpty
                      ? AppColors.statusPendingText
                      : AppColors.statusCompletedText,
                  badgeBg: videoFiles.isEmpty
                      ? AppColors.statusPendingBg
                      : AppColors.statusCompletedBg,
                  onTap: isUploading ? null : onAddVideo,
                ),
              ),
            ],
          ),

          // Uploading banner
          if (isUploading) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.frond50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.frond200),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.mcForestGreen,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Compressing and uploading media evidence...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mcForestGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'UPLOADED EVIDENCE (${uploadedFiles.length})',
                style: AppTypography.metaLabel.copyWith(
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Tap to inspect',
                style: AppTypography.quietLabel.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Empty state or Media Grid
          if (uploadedFiles.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.mcBorder,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.mcBgApp,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      size: 36,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No Evidence Uploaded',
                    style: AppTypography.headingH4.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Both 1 video clip and at least 1 image are mandatory before this task can be approved.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: uploadedFiles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final fileMap = uploadedFiles[index];
                final isVideo = fileMap['isVideo'] == true;
                final isDeleting = fileMap['isDeleting'] == true;

                return GestureDetector(
                  onTap: isDeleting
                      ? null
                      : () {
                          if (isVideo) {
                            showAuditVideoPlayerDialog(context, fileMap);
                          } else {
                            showAuditPhotoViewerDialog(context, fileMap);
                          }
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.mcBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Media Preview Thumbnail
                          _buildThumbnail(fileMap),

                          // Gradient Overlay for readability
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.6),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Video Center Play Icon
                          if (isVideo)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),

                          // Type Badge (Top Left)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isVideo
                                    ? Colors.orange.withValues(alpha: 0.85)
                                    : AppColors.mcForestGreen.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isVideo ? Icons.videocam : Icons.photo,
                                    color: Colors.white,
                                    size: 11,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    isVideo ? 'VIDEO' : 'PHOTO',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Delete Action (Top Right)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: isDeleting
                                ? Container(
                                    width: 26,
                                    height: 26,
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () => onDeleteMedia(fileMap),
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 0.85),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(Map<String, dynamic> fileMap) {
    if (kIsWeb && fileMap['bytes'] != null) {
      return Image.memory(fileMap['bytes'], fit: BoxFit.cover);
    }

    if (fileMap['isLocal'] == true && fileMap['path'] != null) {
      final path = fileMap['path'].toString();
      if (fileMap['isVideo'] != true) {
        return Image.file(File(path), fit: BoxFit.cover);
      }
    }

    final thumbUrl = fileMap['thumbnailUrl']?.toString();
    if (thumbUrl != null && thumbUrl.isNotEmpty) {
      return Image.network(
        thumbUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackThumb(fileMap),
      );
    }

    final url = fileMap['url']?.toString();
    if (url != null && url.isNotEmpty && fileMap['isVideo'] != true) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackThumb(fileMap),
      );
    }

    return _fallbackThumb(fileMap);
  }

  Widget _fallbackThumb(Map<String, dynamic> fileMap) {
    final isVideo = fileMap['isVideo'] == true;
    return Container(
      color: const Color(0xFF1E293B),
      child: Center(
        child: Icon(
          isVideo ? Icons.videocam : Icons.image,
          color: Colors.white54,
          size: 32,
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final String badgeText;
  final Color badgeColor;
  final Color badgeBg;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.mcBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: accentColor),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.headingH4.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.quietLabel.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
