import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:megacess/core/theme/app_colors.dart';

/// Shows a video player dialog given a media map
void showAuditVideoPlayerDialog(
  BuildContext context,
  Map<String, dynamic> fileMap,
) async {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Loading video player...'),
      duration: Duration(seconds: 1),
    ),
  );

  VideoPlayerController? controller;
  try {
    if (kIsWeb) {
      final url = fileMap['url']?.toString();
      if (url != null && url.isNotEmpty) {
        controller = VideoPlayerController.networkUrl(
          Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      }
    } else {
      if (fileMap['isLocal'] == true && fileMap['path'] != null) {
        controller = VideoPlayerController.file(
          File(fileMap['path'].toString()),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      } else if (fileMap['url'] != null && fileMap['url'].toString().isNotEmpty) {
        controller = VideoPlayerController.networkUrl(
          Uri.parse(fileMap['url'].toString()),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      }
    }

    if (controller == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to play video on this platform')),
        );
      }
      return;
    }

    await controller.initialize();
    if (!context.mounted) {
      controller.dispose();
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogCtx) {
        return _VideoPlayerModal(controller: controller!);
      },
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing video: $e')),
      );
    }
  }
}

class _VideoPlayerModal extends StatefulWidget {
  final VideoPlayerController controller;
  const _VideoPlayerModal({required this.controller});

  @override
  State<_VideoPlayerModal> createState() => _VideoPlayerModalState();
}

class _VideoPlayerModalState extends State<_VideoPlayerModal> {
  @override
  void initState() {
    super.initState();
    widget.controller.play();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: Colors.black,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Bar
              Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.videocam, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Video Evidence',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Player
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (widget.controller.value.isPlaying) {
                      widget.controller.pause();
                    } else {
                      widget.controller.play();
                    }
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: widget.controller.value.aspectRatio,
                      child: VideoPlayer(widget.controller),
                    ),
                    if (!widget.controller.value.isPlaying)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                  ],
                ),
              ),

              // Controls
              Container(
                color: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    VideoProgressIndicator(
                      widget.controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppColors.frond500,
                        bufferedColor: Colors.white24,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows a photo viewer dialog given a media map
void showAuditPhotoViewerDialog(
  BuildContext context,
  Map<String, dynamic> fileMap,
) {
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (dialogCtx) {
      Widget imageWidget;
      if (kIsWeb && fileMap['bytes'] != null) {
        imageWidget = Image.memory(fileMap['bytes'], fit: BoxFit.contain);
      } else if (fileMap['isLocal'] == true && fileMap['path'] != null) {
        imageWidget = Image.file(
          File(fileMap['path'].toString()),
          fit: BoxFit.contain,
        );
      } else if (fileMap['url'] != null && fileMap['url'].toString().isNotEmpty) {
        imageWidget = Image.network(
          fileMap['url'].toString(),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
          ),
        );
      } else {
        imageWidget = const Center(
          child: Icon(Icons.image_not_supported, color: Colors.white54, size: 48),
        );
      }

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.photo_outlined, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Image Evidence',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                InteractiveViewer(
                  maxScale: 4.0,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 500),
                    alignment: Alignment.center,
                    child: imageWidget,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
