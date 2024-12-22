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
    // Check for Manage External Storage permission
    if (await Permission.manageExternalStorage.isGranted ||
        await Permission.storage.isGranted) {
      return; // Permission already granted
    }

    // Request permissions dynamically
    final result = await Permission.manageExternalStorage.request();
    if (!result.isGranted) {
      throw Exception("Storage permission not granted.");
    }
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

      // Attempt to list video folders
      final List<Directory> folders = await _getVideoFolders();

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

  /// Dummy method to simulate fetching video folders
  /// Replace with actual implementation to list folders with video files
  Future<List<Directory>> _getVideoFolders() async {
    // Example: Fetch folders under /storage/emulated/0/
    final rootDir = Directory('/storage/emulated/0/');
    if (!await rootDir.exists()) {
      throw Exception('Root directory does not exist.');
    }

    return rootDir
        .listSync()
        .whereType<Directory>()
        .where((dir) => dir.path.contains("Videos") || dir.path.contains("Movies"))
        .toList();
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
                            // Navigate to VideoListScreen (optional)
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


