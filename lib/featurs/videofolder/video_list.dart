import 'dart:io';
import 'package:flutter/material.dart';

class VideoListScreen extends StatelessWidget {
  final String folderPath;

  VideoListScreen({required this.folderPath});

  @override
  Widget build(BuildContext context) {
    final folder = Directory(folderPath);
    final videoFiles = folder
        .listSync()
        .where((file) => file.path.endsWith('.mp4') || file.path.endsWith('.mkv'))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Videos"),
      ),
      body: videoFiles.isEmpty
          ? Center(child: Text("No videos found"))
          : ListView.builder(
              itemCount: videoFiles.length,
              itemBuilder: (context, index) {
                final videoFile = videoFiles[index];
                return ListTile(
                  leading: Icon(Icons.play_circle_fill, color: Colors.blue),
                  title: Text(videoFile.path.split('/').last),
                  onTap: () {
                    // Navigate to video player screen
                  },
                );
              },
            ),
    );
  }
}
