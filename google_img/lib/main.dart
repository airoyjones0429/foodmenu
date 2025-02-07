import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

///
///注意事項：
// 使用 getExternalStorageDirectory 需要在 Android 的 AndroidManifest.xml 中添加相應的權限：
// xml

// <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
// <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
///
///
///

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImageLoader(),
    );
  }
}

class ImageLoader extends StatefulWidget {
  @override
  _ImageLoaderState createState() => _ImageLoaderState();
}

class _ImageLoaderState extends State<ImageLoader> {
  String? imagePath;

  @override
  void initState() {
    super.initState();
    _checkAndLoadImage();
  }

  Future<void> _checkAndLoadImage() async {
    // 獲取應用的本地目錄
    //final directory = await getApplicationDocumentsDirectory();

    // 獲取應用的外部目錄
    final directory = await getExternalStorageDirectory();

    final filePath = '${directory!.path}/A.png';

    // 檢查圖片是否存在
    final file = File(filePath);
    if (await file.exists()) {
      setState(() {
        imagePath = filePath; // 如果存在，設定路徑
      });
    } else {
      // 如果不存在，從網路下載圖片
      await _downloadImage(filePath);
      setState(() {
        imagePath = filePath; // 設定下載後的路徑
      });
    }
  }

  Future<void> _downloadImage(String filePath) async {
    final url =
        'https://drive.google.com/uc?id=1u6QHab21o8Df-4tKyQ5pbKy0cpK8znW-'; // 替換成你的圖片網址
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // 將圖片寫入本地文件
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Failed to load image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Loader")),
      body: GestureDetector(
        onTap: () {
          print(imagePath);
        },
        child: Center(
          child: Column(
            children: [
              imagePath != null
                  ? Image.file(File(imagePath!)) // 從本地顯示圖片
                  : CircularProgressIndicator(),
              imagePath != null ? Text(imagePath!) : Text('ImagePath is null'),
            ],
          ), // 加載時顯示進度指示器
        ),
      ),
    );
  }
}

void main() => runApp(MyApp());
