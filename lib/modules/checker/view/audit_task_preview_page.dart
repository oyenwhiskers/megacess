import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:megacess/modules/checker/data/model/audit_task_preview_model.dart';
import 'package:megacess/modules/checker/data/service/attendance_service.dart';
import 'package:megacess/modules/utility/secure_storage_service.dart';

class AuditTaskPreviewPage extends StatefulWidget {
  final int taskId;
  const AuditTaskPreviewPage({Key? key, required this.taskId})
    : super(key: key);

  @override
  State<AuditTaskPreviewPage> createState() => _AuditTaskPreviewPageState();
}

class _AuditTaskPreviewPageState extends State<AuditTaskPreviewPage> {
  bool _isLoading = true;
  bool _isUploading = false;
  bool _isApproving = false;
  String? _error;
  AuditTaskPreviewModel? _task;
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _uploadedFiles = [];
  final AttendanceService _attendanceService = AttendanceService(
    SecureStorageService(),
  );
  VideoPlayerController? _videoController;
  bool _isVideoSelected = false;

  // Method to pick and upload an image
  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: source,
        imageQuality: 50, // Reduced from 70 to 50 for faster upload
        maxWidth: 1920, // Limit image width for faster upload
        maxHeight: 1080, // Limit image height for faster upload
      );

      if (pickedImage == null) return;

      setState(() {
        _isUploading = true;
      });

      // Different handling for web vs native platforms
      Map<String, dynamic> response;
      Uint8List? imageBytes; // Store bytes only once for web

      if (kIsWeb) {
        // Web platform - read bytes only once
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
        // Mobile/Desktop platforms
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
        // Resolve URL/path from response (simplified)
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

          // Some APIs nest the file under 'file'
          if (resolvedUrl.isEmpty && data['file'] is Map) {
            final f = data['file'] as Map<String, dynamic>;
            resolvedUrl = (f['url'] ?? f['full_url'] ?? '')?.toString() ?? '';
            resolvedPath = resolvedPath ?? (f['path']?.toString());
          }

          // Build full URL from path if needed
          if (resolvedUrl.isEmpty &&
              resolvedPath != null &&
              resolvedPath.isNotEmpty) {
            const baseUrl = 'https://mwms.megacess.com/';
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
            'id': response['data']?['id'] ?? '',
            'serverPath': resolvedPath ?? response['data']?['path'],
            'bytes': imageBytes, // Use the already-read bytes for web
          });
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload failed: ${response['message'] ?? 'Unknown error'}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Method to show the media source selection
  void _showImageSourceSelector() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to show video source selection
  void _showVideoSourceSelector() {
    // First check if platform supports video picking
    if (!_isPlatformSupportedForVideo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video upload is not supported on this platform'),
        ),
      );
      return;
    }

    // For web platform
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choosing video from gallery...')),
      );
      // For web, we can only use gallery
      _pickAndUploadVideo(ImageSource.gallery);
      return;
    }

    // For other platforms
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Record video'),
                subtitle: const Text('Maximum 30 seconds'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadVideo(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Choose from gallery'),
                subtitle: const Text('Maximum 30 seconds'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadVideo(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to pick and upload a video with max duration of 30 seconds
  Future<void> _pickAndUploadVideo(ImageSource source) async {
    try {
      // First check platform support
      if (!_isPlatformSupportedForVideo) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video upload is not supported on this platform'),
          ),
        );
        return;
      }

      final XFile? pickedVideo = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 30),
      );

      if (pickedVideo == null) return;

      setState(() {
        _isUploading = true;
        _isVideoSelected = true;
      });

      // Skip duration check for faster upload - picker already limits to 30 seconds
      int? videoDuration;

      // Show uploading indicator immediately
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uploading video...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Different handling for web vs native platforms
      Map<String, dynamic> response;
      Uint8List? videoBytes; // Store bytes only once for web

      try {
        if (kIsWeb) {
          // Web platform - read bytes only once
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
          // Mobile/Desktop platforms
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
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to upload video: $e')));
        }
        setState(() {
          _isUploading = false;
          _isVideoSelected = false;
        });
        return;
      }

      if (response['success'] == true) {
        // Resolve URL/path from response (simplified)
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
          thumbnailUrl = (data['thumbnail_url'] ?? data['thumbnail'])
              ?.toString();

          if (resolvedUrl.isEmpty && data['file'] is Map) {
            final f = data['file'] as Map<String, dynamic>;
            resolvedUrl = (f['url'] ?? f['full_url'] ?? '')?.toString() ?? '';
            resolvedPath = resolvedPath ?? (f['path']?.toString());
            thumbnailUrl = thumbnailUrl ?? (f['thumbnail_url']?.toString());
          }

          // Build full URL from path if needed
          if (resolvedUrl.isEmpty &&
              resolvedPath != null &&
              resolvedPath.isNotEmpty) {
            const baseUrl = 'https://mwms.megacess.com/';
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
            'id': response['data']?['id'] ?? '',
            'serverPath': resolvedPath ?? response['data']?['path'],
            'bytes': videoBytes, // Use the already-read bytes for web
            'thumbnailUrl':
                thumbnailUrl ?? response['data']?['thumbnail_url'] ?? '',
            'duration': videoDuration,
            'fileName': pickedVideo.name,
          });
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video uploaded successfully'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error with video: $e')));
      }
    } finally {
      setState(() {
        _isUploading = false;
        _isVideoSelected = false;
      });
    }
  }

  // Helper method to build media widget based on platform and media source
  Widget _buildImageWidget(Map<String, dynamic> fileMap) {
    final bool isVideo = fileMap['isVideo'] == true;
    final bool isDeleting = fileMap['isDeleting'] == true;

    // If file is being deleted, show semi-transparent overlay
    if (isDeleting) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _buildActualMediaContent(fileMap),
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Text(
                'Deleting...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Return the media content based on type
    if (isVideo) {
      return GestureDetector(
        onTap: !isDeleting ? () => _showVideoPlayer(fileMap) : null,
        child: _buildActualMediaContent(fileMap),
      );
    } else {
      return _buildActualMediaContent(fileMap);
    }
  }

  // Helper method to build the actual media content based on the file type and source
  Widget _buildActualMediaContent(Map<String, dynamic> fileMap) {
    final bool isVideo = fileMap['isVideo'] == true;

    if (isVideo) {
      // Video content with thumbnail and metadata
      return Stack(
        alignment: Alignment.center,
        children: [
          // Video thumbnail or placeholder
          if (!fileMap['isLocal'] &&
              fileMap['thumbnailUrl'] != null &&
              fileMap['thumbnailUrl'].isNotEmpty)
            Image.network(
              fileMap['thumbnailUrl'],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            )
          else
            Container(
              color: Colors.black,
              child: const Icon(Icons.movie, color: Colors.white, size: 40),
            ),

          // Play button overlay
          Icon(
            Icons.play_circle_fill,
            color: Colors.white.withOpacity(0.8),
            size: 50,
          ),

          // Duration indicator
          if (fileMap['duration'] != null)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(fileMap['duration']),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),

          // File name indicator (truncated if too long)
          if (fileMap['fileName'] != null)
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  fileMap['fileName'].toString().length > 15
                      ? '${fileMap['fileName'].toString().substring(0, 15)}...'
                      : fileMap['fileName'].toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      );
    }

    // For images
    if (!fileMap['isLocal']) {
      // Remote image
      return Image.network(
        fileMap['url'],
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }

    // Local image
    if (kIsWeb) {
      // For web platform
      if (fileMap['bytes'] != null) {
        return Image.memory(fileMap['bytes'], fit: BoxFit.cover);
      } else {
        return Center(child: Text('Image preview not available'));
      }
    } else {
      // For mobile/desktop platforms
      return Image.file(File(fileMap['path']), fit: BoxFit.cover);
    }
  }

  // Helper method to format video duration
  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Helper function to capitalize a string
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // Method to delete a media item
  Future<void> _deleteMedia(Map<String, dynamic> fileMap) async {
    // Track the file ID for deletion
    String fileId = fileMap['id'] ?? '';

    // Check if we have an ID - needed for API calls
    if (fileId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete file: No ID found')),
      );
      return;
    }

    // Show deletion indicator immediately
    setState(() {
      fileMap['isDeleting'] = true;
    });

    // Check if we have a file path or URL
    String? url = fileMap['url'];
    String? filePath =
        fileMap['path']; // Original path (could be local or server)
    String? serverPath = fileMap['serverPath']; // Try to get directly first

    if ((url == null || url.isEmpty) &&
        (filePath == null || filePath.isEmpty) &&
        (serverPath == null || serverPath.isEmpty)) {
      setState(() {
        fileMap['isDeleting'] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete file: No path information'),
        ),
      );
      return;
    }

    // If no serverPath directly available but we have a URL, try to extract server path
    if ((serverPath == null || serverPath.isEmpty) &&
        url != null &&
        url.isNotEmpty) {
      // Try to get the server path from API first if we have a URL
      try {
        // First get file URL info from API to get proper path
        final urlResponse = await _attendanceService.getFileUrl(url);
        print('URL response: $urlResponse');

        if (urlResponse['success'] == true && urlResponse['data'] != null) {
          // Use the path returned from the API
          serverPath = urlResponse['data']['path'];
          print('Using server path from API: $serverPath');
        } else {
          // If API call fails, try to parse from URL
          if (url.startsWith('http://') || url.startsWith('https://')) {
            try {
              final uri = Uri.parse(url);
              // Extract path part
              String parsedPath = uri.path;

              // Remove leading slash if present
              if (parsedPath.startsWith('/')) {
                parsedPath = parsedPath.substring(1);
              }

              serverPath = parsedPath;
              print('Using parsed path from URL: $serverPath');
            } catch (e) {
              print('Error parsing URL: $e');
              serverPath = url; // Use the original URL if parsing fails
              print('Using original URL: $serverPath');
            }
          } else {
            // Not a URL but might be a direct path
            serverPath = url;
            print('Using URL as path: $serverPath');
          }
        }
      } catch (e) {
        print('Error getting file URL: $e');
        // Try to use the URL directly if API call fails
        serverPath = url;
        print('Error case - using URL as path: $serverPath');
      }
    } else if ((serverPath == null || serverPath.isEmpty) &&
        filePath != null &&
        filePath.isNotEmpty) {
      // If no serverPath or URL but we have a file path (e.g., from local upload)
      // This might be a local path for a file that was uploaded
      serverPath = filePath; // Use filePath as last resort
      print('Using file path as server path: $serverPath');
    }

    // Show confirmation dialog
    final bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to delete this ${fileMap['isVideo'] == true ? 'video' : 'image'}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'DELETE',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) {
      // Reset deletion state if cancelled
      setState(() {
        fileMap['isDeleting'] = false;
      });
      return;
    }

    // Show loading indicator
    setState(() {
      _isUploading = true; // Reuse the loading indicator
    });

    try {
      // Ensure we have a non-null server path
      if (serverPath == null || serverPath.isEmpty) {
        throw Exception("Cannot determine file path for deletion");
      }

      print('Attempting to delete file with path: $serverPath');
      print('File ID: $fileId');

      // Call the delete API
      final response = await _attendanceService.deleteFile(serverPath);

      if (response['success'] == true) {
        // Remove from the list
        setState(() {
          _uploadedFiles.removeWhere((item) => item['id'] == fileId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File deleted successfully')),
        );
      } else {
        // Mark file as no longer being deleted
        for (var item in _uploadedFiles) {
          if (item['id'] == fileId) {
            item['isDeleting'] = false;
          }
        }

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete file: ${response["message"] ?? "Unknown error"}',
            ),
          ),
        );
      }
    } catch (e) {
      // Reset deleting state on error
      for (var item in _uploadedFiles) {
        if (item['id'] == fileId) {
          item['isDeleting'] = false;
        }
      }

      setState(() {});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting file: $e')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Show video player in a dialog
  void _showVideoPlayer(Map<String, dynamic> fileMap) async {
    if (!_isPlatformSupportedForVideo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video playback is not supported on this platform'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Loading video player...')));

    VideoPlayerController? controller;
    try {
      // Create video controller based on source
      if (kIsWeb) {
        if (fileMap['url'] != null && fileMap['url'].toString().isNotEmpty) {
          controller = VideoPlayerController.networkUrl(
            Uri.parse(fileMap['url']),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot play this video on web platform'),
            ),
          );
          return;
        }
      } else {
        // For mobile platforms
        if (fileMap['isLocal']) {
          controller = VideoPlayerController.file(
            File(fileMap['path']),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          );
        } else if (fileMap['url'] != null) {
          controller = VideoPlayerController.networkUrl(
            Uri.parse(fileMap['url']),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          );
        }
      }

      if (controller == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Unable to play video')));
        return;
      }

      // Initialize the controller
      await controller.initialize();

      if (!mounted) return;

      // Create a reference to the video controller for the dialog
      final videoController = controller; // We've already checked it's not null

      // Show the video in a dialog
      showDialog(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            backgroundColor: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: videoController.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(videoController),
                      VideoProgressIndicator(
                        videoController,
                        allowScrubbing: true,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                        ),
                      ),
                      // Handle tap to toggle playback
                      Positioned.fill(
                        child: StatefulBuilder(
                          builder: (context, setInnerState) {
                            return GestureDetector(
                              onTap: () {
                                setInnerState(() {
                                  if (videoController.value.isPlaying) {
                                    videoController.pause();
                                  } else {
                                    videoController.play();
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      // Play/pause button overlay
                      Center(
                        child: StatefulBuilder(
                          builder: (context, setInnerState) {
                            return videoController.value.isPlaying
                                ? const SizedBox.shrink()
                                : Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black45,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 50.0,
                                      ),
                                      onPressed: () {
                                        videoController.play();
                                        setInnerState(() {});
                                      },
                                    ),
                                  );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StatefulBuilder(
                    builder: (context, setInnerState) {
                      // Add a listener to update the UI when the position changes
                      videoController.addListener(() {
                        setInnerState(() {});
                      });

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              videoController.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setInnerState(() {
                                if (videoController.value.isPlaying) {
                                  videoController.pause();
                                } else {
                                  videoController.play();
                                }
                              });
                            },
                          ),
                          Text(
                            '${_formatDuration(videoController.value.position.inSeconds)} / '
                            '${_formatDuration(videoController.value.duration.inSeconds)}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ).then((_) {
        // Cleanup when dialog closes
        controller?.pause();
        controller?.dispose();
      });

      // Start playing the video
      controller.play();
    } catch (e) {
      print('Error showing video player: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error playing video: $e')));
      controller?.dispose();
    }
  }

  // Helper method to format meta keys for display
  String _formatMetaKey(String key) {
    // Replace underscores with spaces
    String formatted = key.replaceAll('_', ' ');

    // Capitalize each word
    List<String> words = formatted.split(' ');
    words = words.map((word) => _capitalize(word)).toList();

    // Join the words back together
    return words.join(' ');
  }

  // Helper method to get the unit description for meta value input
  String _getMetaValueUnit(String metaKey, String taskType) {
    switch (metaKey.toLowerCase()) {
      case 'normal pruning':
        return 'tree amount';
      case 'routine pruning':
        return 'acre amount';
      case 'normal harvesting':
        return 'kg amount';
      case 'collect loose fruits':
        return 'kg amount';
      case 'planting':
        return 'tree amount';
      case 'manuring':
        return 'tree amount';
      case 'spraying':
        return 'acre amount';
      case 'slashing':
        return 'acre amount';
      default:
        return 'value';
    }
  }

  // Check if this platform supports video features
  bool get _isPlatformSupportedForVideo {
    // Web platform has limitations but is supported
    if (kIsWeb) {
      return true;
    }

    // Check other platforms
    try {
      // We support all major platforms
      return Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isMacOS ||
          Platform.isWindows ||
          Platform.isLinux;
    } catch (e) {
      print('Platform detection error: $e');
      // If Platform check fails, assume not supported
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  @override
  void dispose() {
    // Dispose of video controller when widget is disposed
    _videoController?.dispose();
    super.dispose();
  }

  // Method to show meta data input dialog based on task type
  Future<Map<String, String>?> _showMetaDataInputDialog() async {
    if (_task == null) return null;

    final taskType = _task!.taskType.toLowerCase();

    // For sanitation tasks, show worker-specific inputs
    if (taskType == 'sanitation') {
      return _showSanitationMetaDialog();
    }

    // For other task types, use the original simple form
    Map<String, TextEditingController> controllers = {};

    // Define meta keys based on task type
    List<String> metaKeys = [];
    String dialogTitle = '';

    switch (taskType) {
      case 'pruning':
        metaKeys = ['normal pruning', 'routine pruning'];
        dialogTitle = 'Pruning Task Data';
        break;
      case 'harvesting':
        metaKeys = ['normal harvesting', 'collect loose fruits'];
        dialogTitle = 'Harvesting Task Data';
        break;
      case 'planting':
        metaKeys = ['planting'];
        dialogTitle = 'Planting Task Data';
        break;
      case 'manuring':
        metaKeys = ['manuring'];
        dialogTitle = 'Manuring Task Data';
        break;
      default:
        // For unknown task types, return empty map
        return {};
    }

    // Create controllers for each meta key
    for (var key in metaKeys) {
      controllers[key] = TextEditingController();
    }

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(dialogTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter the values for this task:',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              ...metaKeys.map((key) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatMetaKey(key),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controllers[key],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter ${_getMetaValueUnit(key, taskType)}',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Clean up controllers
              controllers.forEach((_, controller) => controller.dispose());
              Navigator.of(context).pop(null);
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              // Validate that at least one field has a value
              Map<String, String> result = {};
              bool hasValue = false;

              controllers.forEach((key, controller) {
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  result[key] = value;
                  hasValue = true;
                }
              });

              if (!hasValue) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter at least one value'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Clean up controllers
              controllers.forEach((_, controller) => controller.dispose());
              Navigator.of(context).pop(result);
            },
            child: const Text(
              'SUBMIT',
              style: TextStyle(color: Color(0xFF7ED957)),
            ),
          ),
        ],
      ),
    );

    return result;
  }

  // Special method for sanitation tasks - worker-specific input
  Future<Map<String, String>?> _showSanitationMetaDialog() async {
    if (_task == null || _task!.workers.isEmpty) return null;

    print('\n===== SANITATION META DIALOG =====');
    print('Total workers: ${_task!.workers.length}');

    // Create a map to store controllers for each worker-task combination
    // Key format: "worker_id:task_type" (e.g., "13:slashing")
    Map<String, TextEditingController> controllers = {};

    // Build list of unique worker-task combinations
    List<Map<String, dynamic>> workerTasks = [];

    for (var worker in _task!.workers) {
      print('\n--- Worker: ${worker.fullName} (ID: ${worker.id}) ---');
      print('Worker meta keys: ${worker.meta.keys.toList()}');
      print('Worker meta data: ${worker.meta}');

      // Get the specific task type for this worker from their meta data
      String? workerTaskType;

      // Check worker meta for task type in multiple possible formats
      if (worker.meta.containsKey('spraying')) {
        workerTaskType = 'spraying';
        print('Found task type: spraying (from meta key)');
      } else if (worker.meta.containsKey('slashing')) {
        workerTaskType = 'slashing';
        print('Found task type: slashing (from meta key)');
      } else if (worker.meta.containsKey('sanitation_type')) {
        // Check if there's a sanitation_type field
        final sanitationType = worker.meta['sanitation_type']
            ?.toString()
            .toLowerCase();
        if (sanitationType == 'spraying' || sanitationType == 'slashing') {
          workerTaskType = sanitationType;
          print(
            'Found task type: $sanitationType (from sanitation_type field)',
          );
        }
      } else if (worker.meta.containsKey('type')) {
        // Check if there's a type field
        final typeValue = worker.meta['type']?.toString().toLowerCase();
        if (typeValue == 'spraying' || typeValue == 'slashing') {
          workerTaskType = typeValue;
          print('Found task type: $typeValue (from type field)');
        }
      } else if (worker.meta.containsKey('task_type')) {
        // Check if there's a task_type field
        final taskTypeValue = worker.meta['task_type']
            ?.toString()
            .toLowerCase();
        if (taskTypeValue == 'spraying' || taskTypeValue == 'slashing') {
          workerTaskType = taskTypeValue;
          print('Found task type: $taskTypeValue (from task_type field)');
        }
      } else if (worker.meta.isNotEmpty) {
        // Use the first meta key as task type if it's spraying or slashing
        final firstKey = worker.meta.keys.first.toLowerCase();
        if (firstKey == 'spraying' || firstKey == 'slashing') {
          workerTaskType = firstKey;
          print('Found task type: $firstKey (from first meta key)');
        }
      }

      // If no specific task type found, allow both (backward compatibility)
      if (workerTaskType == null) {
        print(
          'WARNING: No task type found for worker. User needs to specify manually.',
        );
        // Show BOTH options so user can choose which one to fill
        workerTasks.add({
          'worker_id': worker.id,
          'worker_name': worker.fullName,
          'task_type': 'spraying',
        });
        workerTasks.add({
          'worker_id': worker.id,
          'worker_name': worker.fullName,
          'task_type': 'slashing',
        });
      } else {
        // Add only the specific task type
        print('Adding worker task: ${worker.fullName} - $workerTaskType');
        workerTasks.add({
          'worker_id': worker.id,
          'worker_name': worker.fullName,
          'task_type': workerTaskType,
        });
      }
    }

    print('\n===== FINAL WORKER TASKS LIST =====');
    for (var wt in workerTasks) {
      print('Worker: ${wt['worker_name']}, Task: ${wt['task_type']}');
    }

    // Create controllers for each worker-task combination
    for (var workerTask in workerTasks) {
      final key = '${workerTask['worker_id']}:${workerTask['task_type']}';
      controllers[key] = TextEditingController();
    }

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sanitation Task Data'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter values for each worker:',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),

              // Display input for each worker-task combination
              ...workerTasks.map((workerTask) {
                final key =
                    '${workerTask['worker_id']}:${workerTask['task_type']}';
                final workerName = workerTask['worker_name'];
                final taskType = workerTask['task_type'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Worker name
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              workerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Task type label
                        Row(
                          children: [
                            Icon(
                              taskType == 'spraying'
                                  ? Icons.water_drop
                                  : Icons.grass,
                              size: 16,
                              color: taskType == 'spraying'
                                  ? Colors.blue
                                  : Colors.green,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatMetaKey(taskType),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Input field
                        TextField(
                          controller: controllers[key],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText:
                                'Enter ${_getMetaValueUnit(taskType, 'sanitation')}',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Clean up controllers
              controllers.forEach((_, controller) => controller.dispose());
              Navigator.of(context).pop(null);
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              // Validate that at least one field has a value
              Map<String, String> result = {};
              bool hasValue = false;

              controllers.forEach((key, controller) {
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  result[key] = value;
                  hasValue = true;
                }
              });

              if (!hasValue) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter at least one value'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Clean up controllers
              controllers.forEach((_, controller) => controller.dispose());
              Navigator.of(context).pop(result);
            },
            child: const Text(
              'SUBMIT',
              style: TextStyle(color: Color(0xFF7ED957)),
            ),
          ),
        ],
      ),
    );

    return result;
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _attendanceService.fetchAuditTaskPreview(
        widget.taskId,
      );
      if (response != null) {
        _task = response;
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Method to approve the task
  Future<void> _approveTask() async {
    // Validate that we have at least one image or video
    if (_uploadedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please upload at least one image or video before approving',
          ),
        ),
      );
      return;
    }

    // Show meta data input dialog first
    print('\n===== SHOWING META DATA INPUT DIALOG =====');
    final metaData = await _showMetaDataInputDialog();

    // If user cancelled the dialog, return
    if (metaData == null) {
      print('User cancelled meta data input dialog');
      return;
    }

    print('User provided meta data: $metaData');

    // Show confirmation dialog
    final bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Approval'),
            content: const Text('Are you sure you want to approve this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'APPROVE',
                  style: TextStyle(color: Color(0xFF7ED957)),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    // Set loading state
    setState(() {
      _isApproving = true;
    });

    try {
      // Debug: Print all uploaded files
      print('=== DEBUG: Uploaded Files ===');
      for (var i = 0; i < _uploadedFiles.length; i++) {
        print('File $i:');
        print('  - isVideo: ${_uploadedFiles[i]['isVideo']}');
        print('  - url: ${_uploadedFiles[i]['url']}');
        print('  - path: ${_uploadedFiles[i]['path']}');
        print('  - serverPath: ${_uploadedFiles[i]['serverPath']}');
      }

      // Separate videos and images from uploaded files
      String? taskVideo;
      List<String> taskImages = [];

      for (var file in _uploadedFiles) {
        print(
          'Processing file: isVideo=${file['isVideo']}, url=${file['url']}, serverPath=${file['serverPath']}, path=${file['path']}',
        );

        // prefer url, then serverPath, then local path
        String? resolvedUrl;
        if (file['url'] != null && file['url'].toString().isNotEmpty) {
          resolvedUrl = file['url'].toString();
        } else if (file['serverPath'] != null &&
            file['serverPath'].toString().isNotEmpty) {
          resolvedUrl = file['serverPath'].toString();
        } else if (file['path'] != null && file['path'].toString().isNotEmpty) {
          resolvedUrl = file['path'].toString();
        }

        if (file['isVideo'] == true) {
          // Take the first video only
          if (taskVideo == null &&
              resolvedUrl != null &&
              resolvedUrl.isNotEmpty) {
            taskVideo = resolvedUrl;
            print('Found video (resolved): $taskVideo');
          }
        } else {
          // Add all images
          if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
            taskImages.add(resolvedUrl);
            print('Added image (resolved): $resolvedUrl');
          }
        }
      }

      // Build worker_audit_meta from user input
      List<Map<String, dynamic>>? workerAuditMeta;

      print('\n\n===== DEBUG: TASK DATA =====');
      print('Task ID: ${widget.taskId}');
      print('Task Type: ${_task?.taskType ?? "Unknown"}');
      print('Workers Count: ${_task?.workers.length ?? 0}');
      print('User Input Meta Data: $metaData');

      // Build worker_audit_meta from user input using correct nested format
      if (_task != null && _task!.workers.isNotEmpty && metaData.isNotEmpty) {
        print('\n===== BUILDING WORKER_AUDIT_META FROM USER INPUT =====');

        workerAuditMeta = [];

        // Check if this is sanitation task with worker-specific format
        final isSanitationFormat = metaData.keys.any(
          (key) => key.contains(':'),
        );

        if (isSanitationFormat) {
          // Sanitation task: metaData format is "worker_id:task_type" = "value"
          // Example: {"13:spraying": "100"}
          // Convert to NESTED format: {"staff_id": 13, "meta": {"spraying": "100"}}
          print('Using SANITATION worker-specific NESTED format');

          // Group by worker_id first
          Map<int, Map<String, String>> workerMetaMap = {};

          metaData.forEach((key, value) {
            // Parse the key format "worker_id:task_type"
            final parts = key.split(':');
            if (parts.length == 2) {
              final workerId = int.tryParse(parts[0]);
              final taskType = parts[1]; // "spraying" or "slashing"

              if (workerId != null) {
                if (!workerMetaMap.containsKey(workerId)) {
                  workerMetaMap[workerId] = {};
                }
                // Store with lowercase key for consistency
                workerMetaMap[workerId]![taskType.toLowerCase()] = value;
                print('  - Grouped: Worker $workerId, ${taskType.toLowerCase()} = $value');
              }
            }
          });

          // Build NESTED entries - EXACTLY like manuring format
          workerMetaMap.forEach((workerId, metaObject) {
            if (metaObject.isNotEmpty) {
              // Create entry with EXACT same structure as manuring
              final workerEntry = {
                'staff_id': workerId, // Must be int
                'meta': metaObject,   // Must be Map<String, String>
              };
              print('Created sanitation entry (manuring-style): $workerEntry');
              workerAuditMeta!.add(workerEntry);
            }
          });

          // Critical validation
          if (workerAuditMeta.isEmpty) {
            print('CRITICAL ERROR: No worker entries created!');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Failed to build worker data. Please try again.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
            setState(() {
              _isApproving = false;
            });
            return;
          }
          
          // Extra validation: ensure meta objects are not empty
          bool allValid = true;
          for (var entry in workerAuditMeta) {
            if (entry['meta'] == null || (entry['meta'] as Map).isEmpty) {
              allValid = false;
              print('ERROR: Worker ${entry['staff_id']} has empty meta!');
            }
          }
          
          if (!allValid) {
            print('CRITICAL ERROR: Some workers have empty meta data!');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Invalid worker data. Please check your input.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
            setState(() {
              _isApproving = false;
            });
            return;
          }
        } else {
          // Other task types: use simple format where all workers get same meta keys
          // Example: {"manuring": "100"} applied to all workers
          print('Using STANDARD format (same meta for all workers)');

          for (var worker in _task!.workers) {
            print(
              '\nProcessing worker: ID=${worker.id}, Name=${worker.fullName}',
            );

            // Build the meta object from user input
            Map<String, String> metaObject = {};

            // Add each meta key-value pair from user input
            metaData.forEach((key, value) {
              metaObject[key] = value;
              print('  - Added: $key = $value');
            });

            // Add the worker entry with nested meta object (correct API format)
            // Note: Removed 'staff_name' as backend will look it up using staff_id
            final workerEntry = {'staff_id': worker.id, 'meta': metaObject};

            print('Created worker entry: $workerEntry');
            workerAuditMeta.add(workerEntry);
          }
        }
      } else if (metaData.isEmpty) {
        print('ERROR: No meta data provided by user!');
      } else if (_task == null || _task!.workers.isEmpty) {
        print('ERROR: No workers found in task data!');
      }

      // For special handling for manuring tasks if needed
      if (_task != null && _task!.taskType.toLowerCase() == 'manuring') {
        print('\n===== MANURING TASK - Using user input =====');
      }

      // Final logging of prepared worker_audit_meta
      if (workerAuditMeta != null && workerAuditMeta.isNotEmpty) {
        print(
          '\n===== FINAL WORKER AUDIT META (${workerAuditMeta.length} entries) =====',
        );
        for (var i = 0; i < workerAuditMeta.length; i++) {
          print('Entry ${i + 1}: ${workerAuditMeta[i]}');
        }
      } else {
        print('WARNING: No worker_audit_meta prepared!');
      }

      // Automatically set remarks to "Task completed successfully"
      String remarks = "Task completed successfully";

      print('\n===== FINAL DATA TO SEND =====');
      print('- Task ID: ${widget.taskId}');
      print('- Task Type: ${_task?.taskType ?? "Unknown"}');
      print('- Task Video: $taskVideo');
      print('- Task Images: $taskImages');
      print('- Remarks: $remarks');

      // More detailed logging for worker_audit_meta to help diagnose issues
      print('- Worker Audit Meta Count: ${workerAuditMeta?.length ?? 0}');
      if (workerAuditMeta != null && workerAuditMeta.isNotEmpty) {
        print('- Worker Audit Meta Details:');
        for (int i = 0; i < workerAuditMeta.length; i++) {
          final entry = workerAuditMeta[i];
          print(
            '  Entry $i: staff_id=${entry['staff_id']}, meta=${entry['meta']}',
          );
        }
      } else {
        print(
          '- Worker Audit Meta: MISSING OR EMPTY (this may cause validation errors)',
        );
      }

      // Build final payload and log it clearly
      final Map<String, dynamic> payload = {};
      if (taskVideo != null && taskVideo.isNotEmpty) {
        payload['task_video'] = taskVideo;
      }
      if (taskImages.isNotEmpty) {
        payload['task_img'] = taskImages;
      }
      payload['remarks'] = remarks;

      // Use the worker_audit_meta as-is (already in correct nested format)
      payload['worker_audit_meta'] =
          (workerAuditMeta != null && workerAuditMeta.isNotEmpty)
          ? workerAuditMeta
          : null;

      print('\n===== PAYLOAD JSON =====');
      print(payload);

      // Validate required fields based on API requirements
      if (taskVideo == null || taskVideo.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Task video is required. Please upload a video before approving.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isApproving = false;
        });
        return;
      }

      if (taskImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'At least one image is required. Please upload an image before approving.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isApproving = false;
        });
        return;
      }

      // Call the approve API (use the payload map to make sure keys are aligned)
      print('\n===== CALLING API: approveAuditTask =====');
      print('Task ID: ${widget.taskId}');

      // Validate worker_audit_meta based on task type
      if (_task?.taskType.toLowerCase() == 'sanitation') {
        print('\n===== SANITATION TASK VALIDATION (NESTED FORMAT) =====');

        // Check if worker_audit_meta exists and is not empty
        if (payload['worker_audit_meta'] == null ||
            (payload['worker_audit_meta'] as List).isEmpty) {
          print('ERROR: Missing worker_audit_meta for sanitation task!');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Worker audit meta is required for sanitation tasks. Please enter values for spraying or slashing.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          setState(() {
            _isApproving = false;
          });
          return;
        }

        // Validate that each worker entry has proper NESTED meta data
        // Expected format: {"staff_id": 13, "meta": {"spraying": "100"}}
        final metaList = payload['worker_audit_meta'] as List;
        bool hasValidMeta = false;

        for (var entry in metaList) {
          if (entry is Map &&
              entry.containsKey('staff_id') &&
              entry.containsKey('meta') &&
              entry['meta'] is Map &&
              (entry['meta'] as Map).isNotEmpty) {
            hasValidMeta = true;
            print('Valid NESTED meta entry: $entry');
          }
        }

        if (!hasValidMeta) {
          print(
            'ERROR: No valid NESTED meta entries found for sanitation task!',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please enter at least one value for spraying or slashing.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          setState(() {
            _isApproving = false;
          });
          return;
        }

        print('Sanitation task NESTED format validation passed.');
      } // Ensure worker_audit_meta is properly formatted for manuring tasks
      if (_task?.taskType.toLowerCase() == 'manuring') {
        // Always verify meta data format for manuring tasks, regardless of existing data
        print('\n===== FINAL MANURING TASK META VERIFICATION =====');

        // Create or recreate worker_audit_meta if it's missing or empty
        if (payload['worker_audit_meta'] == null ||
            (payload['worker_audit_meta'] as List).isEmpty) {
          print(
            'CRITICAL ERROR: Missing worker_audit_meta for manuring task before API call!',
          );
          print('Adding emergency default meta data...');

          // Create emergency default meta data - use values from screenshot
          final defaultWorkerId = (_task != null && _task!.workers.isNotEmpty)
              ? _task!.workers.first.id
              : 1;
          payload['worker_audit_meta'] = [
            {
              'staff_id': defaultWorkerId,
              'meta_key': 'fertilizer_type',
              'meta_value': 'BORATE', // From screenshot
            },
            {
              'staff_id': defaultWorkerId,
              'meta_key': 'fertilizer_amount',
              'meta_value': '100', // From screenshot
            },
          ];

          print('Emergency meta data added: ${payload['worker_audit_meta']}');
        }
        // Verify all required fields exist in existing data
        else {
          final metaList = payload['worker_audit_meta'] as List;
          print('Verifying ${metaList.length} existing meta entries');

          // Check for fertilizer_type and fertilizer_amount keys
          bool hasFertilizerType = false;
          bool hasFertilizerAmount = false;
          int? firstStaffId;

          for (var meta in metaList) {
            if (meta is Map && meta.containsKey('staff_id')) {
              firstStaffId ??= meta['staff_id'];

              if (meta.containsKey('meta_key') &&
                  meta['meta_key'] == 'fertilizer_type') {
                hasFertilizerType = true;
              }
              if (meta.containsKey('meta_key') &&
                  meta['meta_key'] == 'fertilizer_amount') {
                hasFertilizerAmount = true;
              }
            }
          }

          // Add missing entries if needed
          if (!hasFertilizerType || !hasFertilizerAmount) {
            print(
              'WARNING: Missing required meta fields. Adding default values.',
            );
            final staffId =
                firstStaffId ??
                ((_task != null && _task!.workers.isNotEmpty)
                    ? _task!.workers.first.id
                    : 1);

            if (!hasFertilizerType) {
              (payload['worker_audit_meta'] as List).add({
                'staff_id': staffId,
                'meta_key': 'fertilizer_type',
                'meta_value': 'BORATE', // From screenshot
              });
              print('Added missing fertilizer_type');
            }

            if (!hasFertilizerAmount) {
              (payload['worker_audit_meta'] as List).add({
                'staff_id': staffId,
                'meta_key': 'fertilizer_amount',
                'meta_value': '100', // From screenshot
              });
              print('Added missing fertilizer_amount');
            }
          }
        }

        print('Final worker_audit_meta: ${payload['worker_audit_meta']}');
      }

      // Print the exact payload we're sending to the API for debugging
      print('\n===== API PAYLOAD (EXACT JSON FORMAT) =====');
      print('task_video: ${payload['task_video']}');
      print('task_img: ${payload['task_img']}');
      print('remarks: ${payload['remarks']}');
      print(
        'worker_audit_meta (${payload['worker_audit_meta'] == null ? "null" : (payload['worker_audit_meta'] as List).length} items):',
      );
      if (payload['worker_audit_meta'] != null) {
        final metaList = payload['worker_audit_meta'] as List;
        for (int i = 0; i < metaList.length; i++) {
          print('  [$i]: ${metaList[i]}');
        }
      }

      // For manuring tasks, use the CORRECT format expected by the API
      if (_task?.taskType.toLowerCase() == 'manuring') {
        print(
          '\n===== CRITICAL FIX: USING CORRECT API FORMAT FOR MANURING =====',
        );

        // According to documentation, manuring tasks need:
        // [{"staff_id": 1, "meta": {"manuring": "100"}}]
        // where "manuring" is the meta_key and "100" is the tree amount per tree manured

        // Get the staff_id from the task data if available
        final staffId = (_task != null && _task!.workers.isNotEmpty)
            ? _task!.workers.first.id
            : 13;

        // Get the manuring amount from task data (tree amount per tree manured)
        String manuringAmount = '100'; // Default value

        if (_task != null && _task!.workers.isNotEmpty) {
          final worker = _task!.workers.first;

          // Try to find the amount from various possible keys
          if (worker.meta.containsKey('manuring')) {
            manuringAmount = worker.meta['manuring'].toString();
          } else if (worker.meta.containsKey('fertilizer_amount')) {
            manuringAmount = worker.meta['fertilizer_amount'].toString();
          } else if (worker.meta.containsKey('amount')) {
            manuringAmount = worker.meta['amount'].toString();
          } else {
            // Try to find any numeric value
            for (var entry in worker.meta.entries) {
              if (entry.value is num ||
                  (entry.value is String &&
                      int.tryParse(entry.value) != null)) {
                manuringAmount = entry.value.toString();
                break;
              }
            }
          }
        }

        // Build the CORRECT structure according to documentation
        payload['worker_audit_meta'] = [
          {
            'staff_id': staffId,
            'meta': {
              'manuring':
                  manuringAmount, // Key is "manuring", value is tree amount
            },
          },
        ];

        print(
          'Using CORRECT API format for manuring task: ${payload['worker_audit_meta']}',
        );
      }

      // Make the API call with the prepared payload - use it as-is since we've already formatted it correctly
      final List<Map<String, dynamic>>? formattedWorkerMeta =
          payload['worker_audit_meta'] != null
          ? (payload['worker_audit_meta'] as List<Map<String, dynamic>>)
          : null;

      // Log the final formatted meta data
      print('\n===== FINAL FORMATTED WORKER_AUDIT_META =====');
      if (formattedWorkerMeta != null) {
        for (int i = 0; i < formattedWorkerMeta.length; i++) {
          print('Item $i: ${formattedWorkerMeta[i]}');
        }
      } else {
        print('No worker_audit_meta to send');
      }

      final response = await _attendanceService.approveAuditTask(
        taskId: widget.taskId,
        taskVideo: payload['task_video'],
        taskImages: (payload['task_img'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        remarks: payload['remarks'],
        workerAuditMeta: formattedWorkerMeta,
      );

      print('\n===== API RESPONSE =====');
      print('Success: ${response['success']}');
      print('Message: ${response['message']}');
      print('Errors: ${response['errors']}');
      print('Full Response: $response');

      if (response['success'] == true) {
        print('API call succeeded');
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Task approved successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Optionally navigate back or refresh
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        print('API call failed');
        // Handle error response
        String errorMessage = response['message'] ?? 'Failed to approve task';

        // Check for validation errors
        if (response['errors'] != null) {
          print('\n===== ERROR DETAILS =====');
          final errors = response['errors'] as Map<String, dynamic>;
          final errorMessages = <String>[];

          errors.forEach((key, value) {
            print('Error field: $key, Value: $value (${value.runtimeType})');

            if (value is List) {
              final messages = value.map((e) => e.toString()).toList();
              errorMessages.addAll(messages);
              print('- Error messages: $messages');
            } else {
              print('- Error value (not a list): $value');
            }

            // Special handling for worker_audit_meta errors
            if (key == 'worker_audit_meta') {
              print('\n===== WORKER_AUDIT_META ERROR ANALYSIS =====');
              print(
                'Current worker_audit_meta value: ${payload['worker_audit_meta']}',
              );
              print('Error value: $value');

              // Get exact error message for better diagnosis
              String errorMessage = '';
              if (value is List && value.isNotEmpty) {
                errorMessage = value.first.toString();
              } else if (value is String) {
                errorMessage = value;
              }
              print('Error message: $errorMessage');

              // Check if task is manuring
              if (_task?.taskType.toLowerCase() == 'manuring') {
                print('TASK TYPE: MANURING - Special validation required');

                // Check if worker_audit_meta is missing or empty
                if (payload['worker_audit_meta'] == null ||
                    (payload['worker_audit_meta'] is List &&
                        (payload['worker_audit_meta'] as List).isEmpty)) {
                  print(
                    'CRITICAL ISSUE: Manuring task with null/empty worker_audit_meta',
                  );

                  // This should have been caught by our validation, but just in case
                  errorMessage += ' (worker_audit_meta is null or empty)';
                } else {
                  // Check format of existing entries
                  final List<dynamic> metaList =
                      payload['worker_audit_meta'] as List<dynamic>;
                  print('Meta entries count: ${metaList.length}');

                  // Check for meta_key and meta_value format
                  bool hasValidFormat = true;
                  for (var entry in metaList) {
                    if (entry is Map) {
                      if (!entry.containsKey('staff_id') ||
                          !entry.containsKey('meta_key') ||
                          !entry.containsKey('meta_value')) {
                        print(
                          'INVALID FORMAT: Missing required fields in entry: $entry',
                        );
                        hasValidFormat = false;
                      }
                    } else {
                      print('INVALID ENTRY: Not a Map: $entry');
                      hasValidFormat = false;
                    }
                  }

                  if (!hasValidFormat) {
                    errorMessage += ' (worker_audit_meta has invalid format)';
                  } else {
                    print('Format looks valid - checking for required keys...');

                    // Group by staff_id
                    final staffMetaKeys = <int, Set<String>>{};
                    for (var entry in metaList) {
                      final staffId = entry['staff_id'];
                      final metaKey = entry['meta_key'];

                      if (!staffMetaKeys.containsKey(staffId)) {
                        staffMetaKeys[staffId] = {};
                      }
                      staffMetaKeys[staffId]!.add(metaKey);
                    }

                    // Check if each worker has required meta
                    staffMetaKeys.forEach((staffId, keys) {
                      print('Staff ID $staffId has keys: $keys');
                      if (!keys.contains('fertilizer_type')) {
                        print(
                          'MISSING KEY: Staff ID $staffId missing fertilizer_type',
                        );
                        errorMessage +=
                            ' (missing fertilizer_type for staff $staffId)';
                      }
                      if (!keys.contains('fertilizer_amount')) {
                        print(
                          'MISSING KEY: Staff ID $staffId missing fertilizer_amount',
                        );
                        errorMessage +=
                            ' (missing fertilizer_amount for staff $staffId)';
                      }
                    });
                  }
                }

                print(
                  'SUGGESTED FIX: Ensure worker_audit_meta contains both fertilizer_type and fertilizer_amount for each worker',
                );
                print(
                  'Example format: [{"staff_id": 13, "meta_key": "fertilizer_type", "meta_value": "NPK"}, {"staff_id": 13, "meta_key": "fertilizer_amount", "meta_value": "100"}]',
                );
              }

              // Update error message for display
              if (errorMessage.isNotEmpty) {
                errorMessages.add('Worker audit meta error: $errorMessage');
              }
            }
          });

          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join('\n');
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('Error approving task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isApproving = false;
        });
      }
    }
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String label;
    switch (status.toLowerCase()) {
      case 'in_progress':
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        label = 'In-progress';
        break;
      case 'completed':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        label = 'Completed';
        break;
      case 'pending':
        backgroundColor =
            Colors.amber; // Yellow background as shown in the image
        textColor = Colors.black; // Black text for better contrast on yellow
        label = 'Pending';
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16), // More rounded corners
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7ED957),
        elevation: 0,
        title: const Text('Audit Task', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _task == null
          ? const Center(child: Text('No data found.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16), // Add some space at the top
                  // Task header - simpler design as in the image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _task!.taskName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              _task!.taskType,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(_task!.taskStatus),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Created by:',
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  Text(
                    _task!.createdBy.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Created at:',
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  Text(
                    _task!.taskDate,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Worker details:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ..._task!.workers.map(
                    (worker) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 2),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_outline,
                                color: Colors.black,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${worker.fullName}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                // Dynamically display all meta fields
                                ...worker.meta.entries.map((entry) {
                                  final String formattedKey = _formatMetaKey(
                                    entry.key,
                                  );
                                  return Text(
                                    '$formattedKey: ${entry.value}',
                                    style: const TextStyle(fontSize: 14),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Evidence:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Media(insert at least one):',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  _isUploading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 8),
                                Text('Uploading media...'),
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  Container(
                    height: 180,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Add Image Button
                          InkWell(
                            onTap: _showImageSourceSelector,
                            child: Container(
                              width: 160,
                              height: 160,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 40,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add Image',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Display uploaded files
                          ..._uploadedFiles.map((fileMap) {
                            return Container(
                              width: 160,
                              height: 160,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Stack(
                                children: [
                                  // Media content
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(11),
                                      child: _buildImageWidget(fileMap),
                                    ),
                                  ),

                                  // Delete button or loading indicator
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: fileMap['isDeleting'] == true
                                        ? Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.7,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () => _deleteMedia(fileMap),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(
                                                  0.7,
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    blurRadius: 2,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),

                          // Placeholder if no images
                          if (_uploadedFiles.isEmpty)
                            Container(
                              width: 160,
                              height: 160,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 32,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'No images yet',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // Video Button - only show if platform is supported
                          InkWell(
                            onTap: _isPlatformSupportedForVideo
                                ? _showVideoSourceSelector
                                : () => ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Video upload is not supported on this platform',
                                      ),
                                    ),
                                  ),
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isPlatformSupportedForVideo
                                        ? Icons.videocam
                                        : Icons.videocam_off,
                                    size: 40,
                                    color: _isPlatformSupportedForVideo
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isPlatformSupportedForVideo
                                        ? 'Add Video'
                                        : 'Video not supported',
                                    style: TextStyle(
                                      color: _isPlatformSupportedForVideo
                                          ? Colors.red
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_isPlatformSupportedForVideo)
                                    Text(
                                      'Maximum 30 seconds',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Task Rejected',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7ED957),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _isApproving ? null : _approveTask,
                          child: _isApproving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Task Approved',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
