import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:storage_analyzer/models/file_category_model.dart';

class StoragePresenter {
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) return true;

      final images = await Permission.photos.request();
      final videos = await Permission.videos.request();
      final audio = await Permission.audio.request();

      return images.isGranted || videos.isGranted || audio.isGranted;
    }
    return true;
  }

  Future<List<FileCategoryModel>> analyzeStorage() async {
    final List<Directory> targetDirs = [
      Directory('/storage/emulated/0/DCIM'),
      Directory('/storage/emulated/0/Pictures'),
      Directory('/storage/emulated/0/Movies'),
      Directory('/storage/emulated/0/Music'),
      Directory('/storage/emulated/0/Download'),
    ];

    Map<String, List<File>> categorizedFiles = {
      'Images': [],
      'Videos': [],
      'Audio': [],
      'Documents': [],
      'Others': [],
    };

    for (final dir in targetDirs) {
      if (await dir.exists()) {
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            final path = entity.path.toLowerCase();
            if (_isImage(path)) {
              categorizedFiles['Images']!.add(entity);
            } else if (_isVideo(path)) {
              categorizedFiles['Videos']!.add(entity);
            } else if (_isAudio(path)) {
              categorizedFiles['Audio']!.add(entity);
            } else if (_isDocument(path)) {
              categorizedFiles['Documents']!.add(entity);
            } else {
              categorizedFiles['Others']!.add(entity);
            }
          }
        }
      }
    }

    List<FileCategoryModel> result = [];

    categorizedFiles.forEach((category, files) {
      int count = files.length;
      int totalBytes = files.fold(0, (sum, f) => sum + f.statSync().size);

      // For documents, we can’t access them due to Android 13 restrictions
      if (category == 'Documents') {
        result.add(FileCategoryModel(name: 'Documents (Restricted)', count: 0, size: 0));
      } else {
        result.add(FileCategoryModel(name: category, count: count, size: totalBytes));
      }
    });

    return result;
  }

  bool _isImage(String path) =>
      path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png') || path.endsWith('.gif');

  bool _isVideo(String path) =>
      path.endsWith('.mp4') || path.endsWith('.mkv') || path.endsWith('.mov') || path.endsWith('.avi');

  bool _isAudio(String path) =>
      path.endsWith('.mp3') || path.endsWith('.wav') || path.endsWith('.aac');

  bool _isDocument(String path) =>
      path.endsWith('.pdf') || path.endsWith('.doc') || path.endsWith('.docx') || path.endsWith('.txt');
}
