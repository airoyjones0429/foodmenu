import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:http/http.dart' as http;

import 'dart:math'; // 使用亂數時要引用這個

/// main1.dart => Bmain.dart
/// 1140210
/// 0.從網路上下載圖片，會顯示進度條，照片數量必須先知道
/// 1.單一圖片的動態轉變測試
/// 2.把圖片放在清單卷軸中，嘗試水平捲動設定與垂直捲動設定
/// 3.要使用 SizeBox 或 Container 把 ListView 包起來
///   這樣就可以控制 ListView 的大小，本範例為可以控制寬度，需再深入
/// 4.在建立佈件時，用條件式，讓物件顯示與不顯示
/// 5.Column 搭配 Expanded 沒辦法控制卷軸高度
///   Row 搭配 Expanded 需要測試
/// 6.在設定圖片時，就可以直接設定圖片的 Key 方便做動態效果
/// 7.LinearProgressIndicator(value) 這個佈件，可以產生下載的進度
///   value 的數據為 0.0 ~ 1.0 的倍精度資料型態

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

    /// 測試結果，在initState 不能使用到產生 Widget 的方法或函式
    /// 會發生，還沒完成初始化就呼叫的錯誤
    /// 在初始化完成後，會執行 didChangeDependencies，這時就可以正常預載圖片
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    preloadImages(); //載入圖片
  }

  ///按下圖片或是按下按鈕，就會更換圖片
  void _toggleImage() {
    setState(() {
      currentImageIndex += 1;
      currentImageIndex %= _listImg.length; // 確保不會超出範圍
      _currentImg = _listImg[currentImageIndex]; // 確保這裡的 _currentImg 是非空的
      print(_listImg[currentImageIndex].key);
    });
  }

  ///載入圖片到清單中
  ///這是非同步函數，當沒有使用 precacheImage 時
  ///圖片切換時，會發生延遲，有很多方式處理
  ///這裡練習使用 precacheImage
  /// async  await 是搭配使用的，不一定要有 await，但效果不一樣
  Future<void> preloadImages() async {
    ///用迴圈從遠端下載圖片，暫存到記憶體中
    for (int i = 0; i < imageUrls.length; i++) {
      final image = Image.network(
        imageUrls[i],
        key: ValueKey<int>(i), //一定要設定，且不能重複，不然沒動態效果
        width: 64,
        height: 64,
        fit: BoxFit.fitWidth,

        ///BoxFit.cover：這會保持圖片的比例，並使圖片填滿容器，可能會裁切部分圖片。
        ///BoxFit.contain：這會保持圖片的比例，並使圖片適應容器，可能會留下空白區域。
        ///BoxFit.fill：這會拉伸圖片以完全填滿容器，可能會改變圖片的比例。
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
      _currentImg = _listImg.first; //下載完成，顯示第一張圖片
    }); //載入資料後，用來刷新畫面
  }

  @override
  Widget build(BuildContext context) {
    print(_listImg.length);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (!isLoading)
          Expanded(
            child: Container(
              height: 64, //最外層為 Column 有用 Expanded 垂直為自動分配!?
              width: 64, //寬度可以控制
              child: ListView.builder(
                // padding: EdgeInsets.all(8),
                shrinkWrap: true, // 設置為 true
                scrollDirection: Axis.horizontal, //水平捲動，水平方向產生清單
                itemCount: _listImg.length,
                itemBuilder: (BuildContext context, int index) {
                  return _listImg[index];
                },
              ),
            ),
          ),
        SizedBox(
          height: 5,
        ),
        if (!isLoading)
          Expanded(
            child: Container(
              height: 64,
              width: 64,
              child: ListView.builder(
                // padding: EdgeInsets.all(8),
                scrollDirection: Axis.vertical, //垂直捲動，垂直方向產生清單
                itemCount: _listImg.length,
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    //width: 64,
                    // height: 64, //這會限制圖片的大小
                    child: _listImg[index],
                  );
                },
              ),
            ),
          ),
        SizedBox(
          height: 10,
        ),
        // 顯示進度指示器，如果下載完成，就不會顯示
        if (isLoading) LinearProgressIndicator(value: downloadProgress),
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
        SizedBox(
          height: 100,
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
