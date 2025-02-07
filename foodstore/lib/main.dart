import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("顯示 Google Drive 圖片"),
        ),
        body: Center(
          child: Image.network(
            'https://drive.google.com/uc?id=1u6QHab21o8Df-4tKyQ5pbKy0cpK8znW-', // 將 YOUR_FILE_ID 替換為實際的檔案 ID
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
