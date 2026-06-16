import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import '../models/video_model.dart';

class VideoUploadService {
  static final VideoUploadService _instance = VideoUploadService._internal();

  factory VideoUploadService() {
    return _instance;
  }

  VideoUploadService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  final VideoCompress _videoCompress = VideoCompress();

  /// Pick video from device
  Future<File?> pickVideo() async {
    try {
      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking video: $e');
      return null;
    }
  }

  /// Compress video to reduce file size
  Future<File?> compressVideo(String videoPath) async {
    try {
      final compressedVideo = await _videoCompress.compressVideo(
        videoPath,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        onStatisticsUpdated: (Statistics stats) {
          print('Compression progress: ${stats.progress}%');
        },
      );

      if (compressedVideo != null) {
        return File(compressedVideo.path);
      }
      return null;
    } catch (e) {
      print('Error compressing video: $e');
      return File(videoPath); // Return original if compression fails
    }
  }

  /// Get video thumbnail (base64 encoded)
  Future<String?> generateThumbnail(String videoPath) async {
    try {
      final uint8list = await _videoCompress.getByteThumbnail(videoPath);
      if (uint8list != null) {
        // For now, we'll just indicate that thumbnail exists
        // In production, you'd encode this as base64 or upload to server
        return 'thumbnail_generated';
      }
      return null;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  /// Validate video file
  bool isValidVideoFile(File file) {
    final allowedExtensions = ['mp4', 'mov', 'avi', 'mkv', 'flv'];
    final fileExtension = file.path.split('.').last.toLowerCase();
    return allowedExtensions.contains(fileExtension);
  }

  /// Get video file size in MB
  double getFileSizeInMB(File file) {
    return file.lengthSync() / (1024 * 1024);
  }

  /// Create Video object from file
  Future<Video?> createVideoFromFile({
    required File videoFile,
    required String creatorId,
    required String creatorPhone,
    required String title,
    required String description,
  }) async {
    try {
      // Validate video
      if (!isValidVideoFile(videoFile)) {
        throw Exception('ልክ ያልሆነ ቪዲዮ ፍርቅ። MP4, MOV, AVI, MKV, ወይም FLV ይጠቀሙ።');
      }

      final fileSizeMB = getFileSizeInMB(videoFile);
      if (fileSizeMB > 500) {
        throw Exception('ቪዲዮ ትንሽ ነው። 500MB ከበለጠ ሊሆን አይችልም።');
      }

      // For now, store as local file path
      // In production, this would upload to a server and return the URL
      final video = Video(
        id: 'video_${DateTime.now().millisecondsSinceEpoch}',
        creatorId: creatorId,
        creatorPhone: creatorPhone,
        title: title,
        description: description,
        videoUrl: videoFile.path, // Local path for now
        createdAt: DateTime.now(),
      );

      return video;
    } catch (e) {
      print('Error creating video: $e');
      rethrow;
    }
  }

  /// Cancel video compression
  Future<void> cancelCompression() async {
    await _videoCompress.cancelCompression();
  }
}
