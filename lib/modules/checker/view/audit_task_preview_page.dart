import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:megacess/core/config/flavor_config.dart';
import 'package:megacess/core/theme/app_colors.dart';
import 'package:megacess/core/theme/app_typography.dart';
import 'package:megacess/core/widgets/mega_app_header.dart';
import 'package:megacess/modules/checker/data/model/audit_task_preview_model.dart';
import 'package:megacess/modules/checker/data/service/attendance_service.dart';
import 'package:megacess/modules/checker/view/audit/audit_metadata_dialogs.dart';
import 'package:megacess/modules/checker/view/audit/tabs/audit_evidence_tab.dart';
import 'package:megacess/modules/checker/view/audit/tabs/audit_overview_tab.dart';
import 'package:megacess/modules/checker/view/audit/tabs/audit_workers_tab.dart';
import 'package:megacess/modules/utility/secure_storage_service.dart';

class AuditTaskPreviewPage extends StatefulWidget {
  final int taskId;
  const AuditTaskPreviewPage({super.key, required this.taskId});

  @override
  State<AuditTaskPreviewPage> createState() => _AuditTaskPreviewPageState();
}

class _AuditTaskPreviewPageState extends State<AuditTaskPreviewPage> {
  bool _isLoading = true;
  bool _isUploading = false;
  bool _isApproving = false;
  bool _isRejecting = false;
  String? _error;
  AuditTaskPreviewModel? _task;

  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _uploadedFiles = [];
  final AttendanceService _attendanceService = AttendanceService(
    SecureStorageService(),
  );

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  @override
  void dispose() {
    _uploadedFiles.clear();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final response = await _attendanceService.fetchAuditTaskPreview(
        widget.taskId,
      );
      if (response != null && mounted) {
        setState(() {
          _task = response;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Task details could not be found';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================
  // MEDIA CAPTURE & UPLOAD
  // ==========================================

  void _showImageSourceSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: AppColors.mcForestGreen),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.of(bottomSheetCtx).pop();
                    Future.delayed(const Duration(milliseconds: 250), () {
                      if (mounted) _pickAndUploadImage(ImageSource.camera);
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: AppColors.mcForestGreen),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.of(bottomSheetCtx).pop();
                    Future.delayed(const Duration(milliseconds: 250), () {
                      if (mounted) _pickAndUploadImage(ImageSource.gallery);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showVideoSourceSelector() {
    if (kIsWeb) {
      _pickAndUploadVideo(ImageSource.gallery);
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.videocam, color: Colors.orange),
                  title: const Text('Record video'),
                  subtitle: const Text('Maximum 30 seconds'),
                  onTap: () {
                    Navigator.of(bottomSheetCtx).pop();
                    Future.delayed(const Duration(milliseconds: 250), () {
                      if (mounted) _pickAndUploadVideo(ImageSource.camera);
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_library, color: Colors.orange),
                  title: const Text('Choose from gallery'),
                  subtitle: const Text('Maximum 30 seconds'),
                  onTap: () {
                    Navigator.of(bottomSheetCtx).pop();
                    Future.delayed(const Duration(milliseconds: 250), () {
                      if (mounted) _pickAndUploadVideo(ImageSource.gallery);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedImage == null) return;

      if (mounted) setState(() => _isUploading = true);

      Map<String, dynamic> response;
      Uint8List? imageBytes;

      if (kIsWeb) {
        imageBytes = await pickedImage.readAsBytes();
        final String mimeType = pickedImage.mimeType ?? 'image/jpeg';
        response = await _attendanceService
            .uploadAuditTaskEvidence(
              taskId: widget.taskId,
              filePath: pickedImage.name,
              description: 'Evidence for task ${widget.taskId}',
              bytes: imageBytes,
              mimeType: mimeType,
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () => {
                'success': false,
                'message': 'Upload timeout - please try again',
              },
            );
      } else {
        response = await _attendanceService
            .uploadAuditTaskEvidence(
              taskId: widget.taskId,
              filePath: pickedImage.path,
              description: 'Evidence for task ${widget.taskId}',
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () => {
                'success': false,
                'message': 'Upload timeout - please try again',
              },
            );
      }

      if (response['success'] == true) {
        final Map<String, dynamic>? data =
            response['data'] as Map<String, dynamic>?;
        String resolvedUrl = '';
        String? resolvedPath;

        if (data != null) {
          resolvedUrl =
              (data['url'] ?? data['file_url'] ?? data['full_url'] ?? '')
                  ?.toString() ??
              '';
          resolvedPath = (data['path'] ?? data['file_path'])?.toString();

          if (resolvedUrl.isEmpty && data['file'] is Map) {
            final f = data['file'] as Map<String, dynamic>;
            resolvedUrl = (f['url'] ?? f['full_url'] ?? '')?.toString() ?? '';
            resolvedPath = resolvedPath ?? (f['path']?.toString());
          }

          if (resolvedUrl.isEmpty &&
              resolvedPath != null &&
              resolvedPath.isNotEmpty) {
            final baseUrl = '${FlavorConfig.instance.baseDomain}/';
            final cleanPath = resolvedPath.startsWith('/')
                ? resolvedPath.substring(1)
                : resolvedPath;
            resolvedUrl = '$baseUrl$cleanPath';
          }
        }

        setState(() {
          _uploadedFiles.add({
            'path': kIsWeb ? pickedImage.name : pickedImage.path,
            'isLocal': true,
            'url': resolvedUrl,
            'id': response['data']?['id']?.toString() ??
                '${DateTime.now().millisecondsSinceEpoch}_${_uploadedFiles.length}',
            'serverPath': resolvedPath ?? response['data']?['path'],
            'bytes': imageBytes,
          });
        });

        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Upload failed: ${response['message'] ?? 'Unknown error'}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickAndUploadVideo(ImageSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final XFile? pickedVideo = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 30),
      );

      if (pickedVideo == null) return;

      if (mounted) setState(() => _isUploading = true);

      Map<String, dynamic> response;
      Uint8List? videoBytes;

      if (kIsWeb) {
        videoBytes = await pickedVideo.readAsBytes();
        final String mimeType = pickedVideo.mimeType ?? 'video/mp4';
        response = await _attendanceService
            .uploadAuditTaskEvidence(
              taskId: widget.taskId,
              filePath: pickedVideo.name,
              description: 'Video evidence for task ${widget.taskId}',
              bytes: videoBytes,
              mimeType: mimeType,
              isVideo: true,
            )
            .timeout(
              const Duration(seconds: 60),
              onTimeout: () => {
                'success': false,
                'message': 'Upload timeout - please try again',
              },
            );
      } else {
        response = await _attendanceService
            .uploadAuditTaskEvidence(
              taskId: widget.taskId,
              filePath: pickedVideo.path,
              description: 'Video evidence for task ${widget.taskId}',
              isVideo: true,
            )
            .timeout(
              const Duration(seconds: 60),
              onTimeout: () => {
                'success': false,
                'message': 'Upload timeout - please try again',
              },
            );
      }

      if (response['success'] == true) {
        final Map<String, dynamic>? data =
            response['data'] as Map<String, dynamic>?;
        String resolvedUrl = '';
        String? resolvedPath;
        String? thumbnailUrl;

        if (data != null) {
          resolvedUrl =
              (data['url'] ?? data['file_url'] ?? data['full_url'] ?? '')
                  ?.toString() ??
              '';
          resolvedPath = (data['path'] ?? data['file_path'])?.toString();
          thumbnailUrl =
              (data['thumbnail_url'] ?? data['thumbnail'])?.toString();

          if (resolvedUrl.isEmpty && data['file'] is Map) {
            final f = data['file'] as Map<String, dynamic>;
            resolvedUrl = (f['url'] ?? f['full_url'] ?? '')?.toString() ?? '';
            resolvedPath = resolvedPath ?? (f['path']?.toString());
            thumbnailUrl = thumbnailUrl ?? (f['thumbnail_url']?.toString());
          }

          if (resolvedUrl.isEmpty &&
              resolvedPath != null &&
              resolvedPath.isNotEmpty) {
            final baseUrl = '${FlavorConfig.instance.baseDomain}/';
            final cleanPath = resolvedPath.startsWith('/')
                ? resolvedPath.substring(1)
                : resolvedPath;
            resolvedUrl = '$baseUrl$cleanPath';
          }
        }

        setState(() {
          _uploadedFiles.add({
            'path': kIsWeb ? pickedVideo.name : pickedVideo.path,
            'isLocal': true,
            'isVideo': true,
            'url': resolvedUrl,
            'id': response['data']?['id']?.toString() ??
                '${DateTime.now().millisecondsSinceEpoch}_${_uploadedFiles.length}',
            'serverPath': resolvedPath ?? response['data']?['path'],
            'bytes': videoBytes,
            'thumbnailUrl':
                thumbnailUrl ?? response['data']?['thumbnail_url'] ?? '',
            'fileName': pickedVideo.name,
          });
        });

        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Video uploaded successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Upload failed: ${response['message'] ?? 'Unknown error'}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Error uploading video: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteMedia(Map<String, dynamic> fileMap) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Evidence'),
        content: const Text('Are you sure you want to remove this evidence file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusRejectedText,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final fileId = fileMap['id']?.toString() ?? '';
    final serverPath = fileMap['serverPath']?.toString();

    setState(() {
      fileMap['isDeleting'] = true;
    });

    try {
      if (serverPath != null && serverPath.isNotEmpty) {
        await _attendanceService.deleteFile(serverPath);
      }
      setState(() {
        _uploadedFiles.removeWhere((item) => item['id'] == fileId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evidence deleted'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      setState(() {
        fileMap['isDeleting'] = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete file: $e')),
        );
      }
    }
  }

  // ==========================================
  // APPROVE & REJECT ACTIONS
  // ==========================================

  Future<void> _approveTask() async {
    if (_task == null) return;

    // 1. Validate required media
    String? taskVideo;
    List<String> taskImages = [];

    for (var file in _uploadedFiles) {
      String resolved = '';
      if (file['url'] != null && file['url'].toString().isNotEmpty) {
        resolved = file['url'].toString();
      } else if (file['serverPath'] != null &&
          file['serverPath'].toString().isNotEmpty) {
        resolved = file['serverPath'].toString();
      } else if (file['path'] != null && file['path'].toString().isNotEmpty) {
        resolved = file['path'].toString();
      }

      if (resolved.isNotEmpty) {
        if (file['isVideo'] == true) {
          taskVideo ??= resolved;
        } else {
          taskImages.add(resolved);
        }
      }
    }

    if (taskVideo == null || taskImages.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text('Evidence Required'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'To approve this task, the following evidence is mandatory:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    taskVideo == null ? Icons.close : Icons.check,
                    color: taskVideo == null ? Colors.red : Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '1 Video Clip (${taskVideo == null ? 'Missing' : 'Uploaded'})',
                    style: TextStyle(
                      color: taskVideo == null ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    taskImages.isEmpty ? Icons.close : Icons.check,
                    color: taskImages.isEmpty ? Colors.red : Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'At least 1 Photo (${taskImages.isEmpty ? 'Missing' : '${taskImages.length} Uploaded'})',
                    style: TextStyle(
                      color: taskImages.isEmpty ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Switch to the "Evidence" tab to record or select media.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mcForestGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Understood'),
            ),
          ],
        ),
      );
      return;
    }

    // 2. Open Metadata Dialog
    final metaData = await showAuditMetadataDialog(
      context: context,
      task: _task!,
    );

    if (metaData == null) return; // User cancelled

    if (!mounted) return;
    setState(() => _isApproving = true);

    try {
      // 3. Build nested worker_audit_meta
      List<Map<String, dynamic>>? workerAuditMeta;

      if (_task!.workers.isNotEmpty && metaData.isNotEmpty) {
        final isWorkerSpecific = metaData.keys.any((k) => k.contains(':'));
        if (isWorkerSpecific) {
          final Map<int, Map<String, String>> workerMetaMap = {};
          metaData.forEach((key, value) {
            final parts = key.split(':');
            if (parts.length == 2) {
              final wId = int.tryParse(parts[0]);
              final tType = parts[1].toLowerCase();
              if (wId != null) {
                workerMetaMap.putIfAbsent(wId, () => {})[tType] = value;
              }
            }
          });

          workerAuditMeta = workerMetaMap.entries
              .where((e) => e.value.isNotEmpty)
              .map((e) => {'staff_id': e.key, 'meta': e.value})
              .toList();
        } else {
          workerAuditMeta = _task!.workers
              .map((w) => {'staff_id': w.id, 'meta': metaData})
              .toList();
        }
      }

      // 4. API Call
      final response = await _attendanceService.approveAuditTask(
        taskId: widget.taskId,
        taskVideo: taskVideo,
        taskImages: taskImages,
        remarks: 'Task completed successfully',
        workerAuditMeta: workerAuditMeta,
      );

      if (response['success'] == true) {
        if (!mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.statusCompletedBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.statusCompletedText,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Audit Task Approved',
                    style: AppTypography.headingH3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Task verification has been saved and completed.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mcForestGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      Navigator.of(context).pop(true); // Return success to parent
                    },
                    child: const Text('Back to Tasks'),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Approval failed: ${response['message'] ?? 'Unknown error'}',
              ),
              backgroundColor: AppColors.statusRejectedText,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Approval error: $e'),
            backgroundColor: AppColors.statusRejectedText,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isApproving = false);
    }
  }

  Future<void> _rejectTask() async {
    final remarksController = TextEditingController();

    final remarks = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.statusRejectedBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.cancel_outlined,
                color: AppColors.statusRejectedText,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Reject Audit Task',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide clear feedback explaining why this task is being rejected:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: remarksController,
              maxLines: 3,
              style: AppTypography.bodyRegular,
              decoration: InputDecoration(
                hintText: 'Enter reason for rejection...',
                hintStyle: AppTypography.quietLabel,
                filled: true,
                fillColor: AppColors.mcBgApp,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.mcBorder),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.mcBorder),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusRejectedText,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final text = remarksController.text.trim();
              if (text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter rejection remarks')),
                );
                return;
              }
              Navigator.of(dialogCtx).pop(text);
            },
            child: const Text('Confirm Rejection'),
          ),
        ],
      ),
    );

    remarksController.dispose();

    if (remarks == null || remarks.isEmpty) return;

    if (!mounted) return;
    setState(() => _isRejecting = true);

    try {
      final response = await _attendanceService.rejectAuditTask(
        taskId: widget.taskId,
        remarks: remarks,
      );

      if (response['success'] == true) {
        if (!mounted) return;
        Navigator.of(context).pop(true); // Return success to parent
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Rejection failed: ${response['message'] ?? 'Unknown error'}',
              ),
              backgroundColor: AppColors.statusRejectedText,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rejection error: $e'),
            backgroundColor: AppColors.statusRejectedText,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRejecting = false);
    }
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.mcBgApp,
        appBar: MegaAppHeader(
          title: 'Audit Task #${widget.taskId}',
          showBackButton: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.mcForestGreen),
          ),
        ),
      );
    }

    if (_error != null || _task == null) {
      return Scaffold(
        backgroundColor: AppColors.mcBgApp,
        appBar: MegaAppHeader(
          title: 'Audit Task #${widget.taskId}',
          showBackButton: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.statusRejectedText,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  _error ?? 'Task details could not be loaded',
                  textAlign: TextAlign.center,
                  style: AppTypography.headingH4,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mcForestGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _fetchDetail,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final videoCount =
        _uploadedFiles.where((f) => f['isVideo'] == true).length;
    final imageCount =
        _uploadedFiles.where((f) => f['isVideo'] != true).length;
    final isReadyToApprove = videoCount > 0 && imageCount > 0;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.mcBgApp,
        appBar: MegaAppHeader(
          title: 'Audit Task #${widget.taskId}',
          showBackButton: true,
          bottom: TabBar(
            indicatorColor: AppColors.frond500,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            unselectedLabelStyle: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            tabs: [
              const Tab(
                icon: Icon(Icons.dashboard_outlined, size: 18),
                text: 'Overview',
              ),
              Tab(
                icon: const Icon(Icons.people_outline, size: 18),
                text: 'Workers (${_task!.workers.length})',
              ),
              Tab(
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                text: 'Evidence (${_uploadedFiles.length})',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AuditOverviewTab(
              task: _task!,
              videoCount: videoCount,
              imageCount: imageCount,
            ),
            AuditWorkersTab(
              workers: _task!.workers,
              taskType: _task!.taskType,
            ),
            AuditEvidenceTab(
              uploadedFiles: _uploadedFiles,
              isUploading: _isUploading,
              onAddImage: _showImageSourceSelector,
              onAddVideo: _showVideoSourceSelector,
              onDeleteMedia: _deleteMedia,
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: AppColors.mcBorder)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Evidence status cue
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isReadyToApprove
                              ? Icons.check_circle
                              : Icons.info_outline,
                          size: 14,
                          color: isReadyToApprove
                              ? AppColors.statusCompletedText
                              : AppColors.statusPendingText,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isReadyToApprove
                              ? 'Media evidence verified'
                              : 'Video & photo evidence required',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isReadyToApprove
                                ? AppColors.statusCompletedText
                                : AppColors.statusPendingText,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_task!.taskStatus.toUpperCase()} TASK',
                      style: AppTypography.metaLabel.copyWith(fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Reject Button
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.statusRejectedText,
                          side: const BorderSide(
                            color: AppColors.statusRejectedBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: (_isRejecting || _isApproving)
                            ? null
                            : _rejectTask,
                        child: _isRejecting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.statusRejectedText,
                                  ),
                                ),
                              )
                            : const Text(
                                'Reject',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Approve Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mcForestGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: (_isApproving || _isRejecting)
                            ? null
                            : _approveTask,
                        child: _isApproving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Approve Task',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
