import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<List<Directory>> getVideoFolders() async {
    List<Directory> videoFolders = [];
    Directory? rootDirectory = await getExternalStorageDirectory();

    if (rootDirectory != null) {
      final dir = Directory(rootDirectory.parent.parent.parent.path); // Get root storage
      final folders = dir.listSync().whereType<Directory>();

      for (var folder in folders) {
        final videoFiles = folder
            .listSync()
            .where((file) => file.path.endsWith('.mp4') || file.path.endsWith('.mkv'));
        if (videoFiles.isNotEmpty) {
          videoFolders.add(folder);
        }
      }
    }
    return videoFolders;
  }
}
