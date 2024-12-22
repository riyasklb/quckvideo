// import 'package:flutter/material.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:quckvideo/featurs/videofolder/folder_list_screen.dart';

// class PermissionScreen extends StatefulWidget {
//   const PermissionScreen({Key? key}) : super(key: key);

//   @override
//   _PermissionScreenState createState() => _PermissionScreenState();
// }

// class _PermissionScreenState extends State<PermissionScreen> {
//   final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

//   Future<bool> _requestPermission(Permission permission) async {
//     final androidInfo = await _deviceInfoPlugin.androidInfo;

//     if (androidInfo.version.sdkInt >= 30) {
//       var result = await Permission.manageExternalStorage.request();
//       return result.isGranted;
//     } else {
//       if (await permission.isGranted) {
//         return true;
//       } else {
//         var result = await permission.request();
//         return result.isGranted;
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//             onPressed: () {  Navigator.of(context).push(
//     MaterialPageRoute(builder: (context) =>  FolderListScreen()),
//   );
             
//             },
//             icon: Icon(Icons.video_call)),
//         backgroundColor: Colors.blue,
//         title: const Text(
//           'Storage Permission in Android (11, 12, and 13)',
//           style: TextStyle(fontSize: 16),
//         ),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             if (await _requestPermission(Permission.storage)) {
//               print("Permission is granted");
//             } else {
//               print("Permission is not granted");
//             }
//           },
//           child: const Text('Click'),
//         ),
//       ),
//     );
//   }
// }
