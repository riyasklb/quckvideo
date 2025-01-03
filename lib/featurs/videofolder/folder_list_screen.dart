import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quckvideo/featurs/videofolder/video_list.dart';

class FolderListScreen extends StatefulWidget {
  @override
  _FolderListScreenState createState() => _FolderListScreenState();
}

class _FolderListScreenState extends State<FolderListScreen> {
  List<Directory> videoFolders = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFolders();
  }

  /// Request necessary permissions for accessing external storage
  Future<void> _requestPermissions() async {
    if (await Permission.storage.isGranted) return;
    if (await Permission.manageExternalStorage.request().isGranted) return;

    throw Exception("Storage permissions are required to proceed.");
  }

  /// Fetch video folders from external storage
  Future<void> _fetchFolders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Request permissions
      await _requestPermissions();

      // Scan the entire storage for video folders
      List<Directory> folders = [];
      await _scanForVideoFolders(Directory('/storage/emulated/0/'), folders);

      setState(() {
        videoFolders = folders;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error during folder fetching: $e');
      setState(() {
        errorMessage = 'Failed to fetch folders: $e';
        isLoading = false;
      });
    }
  }

  /// Recursively scan for video folders in the given directory
  Future<void> _scanForVideoFolders(Directory rootDir, List<Directory> folders) async {
    if (!await rootDir.exists()) return;

    try {
      final entities = rootDir.listSync(recursive: false, followLinks: false);
      for (var entity in entities) {
        if (entity is Directory) {
          // Skip restricted directories early
          if (_isRestrictedDirectory(entity.path)) {
            debugPrint('Skipping restricted directory: ${entity.path}');
            continue;
          }

          // Check if the directory contains video files
          final containsVideo = await _containsVideoFiles(entity);
          if (containsVideo) {
            debugPrint('Video folder found: ${entity.path}');
            folders.add(entity);
          }

          // Recursively scan the subdirectories
          await _scanForVideoFolders(entity, folders);
        }
      }
    } catch (e) {
      debugPrint('Error accessing directory: $e');
    }
  }

  /// Check if a directory contains video files
  Future<bool> _containsVideoFiles(Directory dir) async {
    try {
      final files = dir.listSync();
      for (var file in files) {
        if (file is File && _isVideoFile(file.path)) {
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error checking video files in ${dir.path}: $e');
    }
    return false;
  }

  /// Check if a file is a video file based on its extension
  bool _isVideoFile(String filePath) {
    final videoExtensions = ['mp4', 'mkv', 'avi', 'mov', 'flv', 'wmv'];
    final extension = filePath.split('.').last.toLowerCase();
    return videoExtensions.contains(extension);
  }

  /// Check if a directory path is restricted
  bool _isRestrictedDirectory(String path) {
    final restrictedPaths = [
      '/Android/data',
      '/Android/obb',
    ];
    return restrictedPaths.any((restrictedPath) => path.contains(restrictedPath));
  }

  /// Handle dynamic icons based on folder names
  Icon _getFolderIcon(String folderName) {
    if (folderName.toLowerCase().contains('movies')) return Icon(Icons.movie, color: Colors.red);
    if (folderName.toLowerCase().contains('music')) return Icon(Icons.music_note, color: Colors.blue);
    return Icon(Icons.folder, color: Colors.orange);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Folders"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : videoFolders.isEmpty
                  ? Center(child: Text("No folders found"))
                  : ListView.builder(
                      itemCount: videoFolders.length,
                      itemBuilder: (context, index) {
                        final folder = videoFolders[index];
                        return ListTile(
                          leading: _getFolderIcon(folder.path.split('/').last),
                          title: Text(
                            folder.path.split('/').last.length > 20
                                ? '${folder.path.split('/').last.substring(0, 20)}...'
                                : folder.path.split('/').last,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VideoListScreen(folderPath: folder.path),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
