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

      // Fetch video folders
      final List<Directory> folders =
          await _findVideoFolders(Directory('/storage/emulated/0/'));

      setState(() {
        videoFolders = folders;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch folders: $e';
        isLoading = false;
      });
    }
  }

  /// Recursively find video folders in the given directory
  Future<List<Directory>> _findVideoFolders(Directory rootDir) async {
    List<Directory> result = [];
    if (!await rootDir.exists()) {
      throw Exception('Root directory does not exist.');
    }

    final entities = rootDir.listSync(recursive: false, followLinks: false);

    for (var entity in entities) {
      if (entity is Directory) {
        // Skip restricted directories
        if (entity.path.contains('/Android/data') ||
            entity.path.contains('/Android/obb')) {
          continue;
        }

        final containsVideo = await _containsVideoFiles(entity);
        if (containsVideo) {
          result.add(entity);
        }
      }
    }

    return result;
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
      // Handle restricted access errors gracefully
    }
    return false;
  }

  /// Check if a file is a video file based on its extension
  bool _isVideoFile(String filePath) {
    final videoExtensions = ['mp4', 'mkv', 'avi', 'mov','VID'];
    final extension = filePath.split('.').last.toLowerCase();
    return videoExtensions.contains(extension);
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
                          leading: Icon(Icons.folder, color: Colors.orange),
                          title: Text(
                            folder.path.split('/').last,
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
