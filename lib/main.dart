import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quckvideo/core/util/permission.dart';
import 'package:quckvideo/featurs/videofolder/folder_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  runApp(MyApp());
}

Future<void> requestPermissions() async {
  if (await Permission.storage.isDenied) {
    await Permission.storage.request();
  }
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MX Player Clone',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FolderListScreen(),
    );
  }
}
