import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:http/http.dart' as http;

import 'dart:math'; // 使用亂數時要引用這個

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("圖片動畫示範")),
        body: ImageSwitcher(),
      ),
    );
  }
}

class ImageSwitcher extends StatefulWidget {
  @override
  _ImageSwitcherState createState() => _ImageSwitcherState();
}

class _ImageSwitcherState extends State<ImageSwitcher> {
  bool _showFirstImage = true;
  double downloadProgress = 0.0; // 下載進度

  bool isLoading = true; // 用來判斷是否正在加載

  Image? _currentImg;

  List<Image> _listImg = [];
  int currentImageIndex = 0;

  List<String> imageUrls = [
    'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit01.png?raw=true',
    'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit02.png?raw=true',
    'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit03.png?raw=true',
    'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit04.png?raw=true',
    'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit05.png?raw=true',
    'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit06.png?raw=true',
    'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit07.png?raw=true',
    'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit08.png?raw=true',
    'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit09.png?raw=true',
    'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit10.png?raw=true',
    'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit11.png?raw=true',
    'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit12.png?raw=true',
  ];

  @override
  void initState() {
    super.initState();

    /// 設定載入一筆圖片的設定，如果一筆設定成功，就可以設定多筆
    // _currentImg = Image.network(
    //   imageUrls[0],
    //   loadingBuilder: (context, child, loadingProgress) {
    //     return loadingProgress == null ? child : LinearProgressIndicator();
    //   },
    //   key: ValueKey<int>(1),
    // );

    /// 載入圖片Widget 的設定，但在執行前，並不會從網路上下載下來
    // for (int uIndex = 0; uIndex < imageUrls.length; uIndex++) {
    //   Image tempImg = Image.network(
    //     imageUrls[uIndex],
    //     loadingBuilder: (context, child, loadingProgress) {
    //       return loadingProgress == null ? child : LinearProgressIndicator();
    //     },
    //     key: ValueKey<int>(uIndex),
    //   );

    //   _listImg.add(tempImg);
    // }
  }

  void _toggleImage() {
    setState(() {
      currentImageIndex += 1;
      currentImageIndex %= _listImg.length; // 確保不會超出範圍
      _currentImg = _listImg[currentImageIndex]; // 確保這裡的 _currentImg 是非空的
      print(_listImg[currentImageIndex].key);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    preloadImages();
  }

  ///載入圖片到清單中
  ///這是非同步函數，當沒有使用 precacheImage 時
  ///圖片切換時，會發生延遲，有很多方式處理
  ///這裡練習使用 precacheImage
  /// async  await 是搭配使用的，不一定要有 await，但效果不一樣
  Future<void> preloadImages() async {
    for (int i = 0; i < imageUrls.length; i++) {
      final image = Image.network(
        imageUrls[i],
        key: ValueKey<int>(i),
        fit: BoxFit.cover,
      );
      _listImg.add(image);

      // 這裡可以使用 `await precacheImage` 來確保圖片被緩存
      await precacheImage(NetworkImage(imageUrls[i]), context);

      // 更新下載進度
      setState(() {
        downloadProgress = (i + 1) / imageUrls.length;
      });
    }

    setState(() {
      isLoading = false; // 下載完成，不顯示進度條
      _currentImg = _listImg.first;
    }); //載入資料後，用來刷新畫面
  }

  @override
  Widget build(BuildContext context) {
    print(_listImg.length);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 顯示進度指示器
        if (isLoading) LinearProgressIndicator(value: downloadProgress),
        // Expanded(
        //   child: SizedBox(
        //     height: 64,
        //     width: 128,
        //     child: ListView.builder(
        //       // padding: EdgeInsets.all(8),
        //       scrollDirection: Axis.horizontal, //水平捲動，水平方向產生清單
        //       itemCount: _listImg.length,
        //       itemBuilder: (BuildContext context, int index) {
        //         return SizedBox(width: 64, child: _listImg[index]);
        //       },
        //     ),
        //   ),
        // ),
        // Expanded(
        //   child: ListView.builder(
        //     // padding: EdgeInsets.all(8),
        //     scrollDirection: Axis.vertical, //水平捲動，水平方向產生清單
        //     itemCount: _listImg.length,
        //     itemBuilder: (BuildContext context, int index) {
        //       return SizedBox(
        //         //width: 64,
        //         height: 64, // 設定固定高度
        //         child: _listImg[index],
        //       );
        //     },
        //   ),
        // ),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _toggleImage,
                child: AnimatedSwitcher(
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  duration: Duration(milliseconds: 300),
                  child: _currentImg,
                ),
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            _toggleImage();
          },
          child: Text('測試'),
        ),
      ],
    );
  }
}
