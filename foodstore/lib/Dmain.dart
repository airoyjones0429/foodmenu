import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:http/http.dart' as http;

import 'dart:math'; // 使用亂數時要引用這個

import 'dart:async'; //要使用 Timer 要用這個

/// main3.dart => Dmain.dart
/// 1140210
/// 1.完成了，多張圖片的動態效果設定
/// 2.傳遞物件給函數時，雖然是傳遞位址，但只是部分引用，改變內容並不會跟著改變
///   想在函數中更改傳遞進去的物件內容，簡單的為傳回一個該物件的設定值
///   是這個範例的做法
/// 3.設定了計時器，自動執行換圖片的程序

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

  ///可以改成圖片清單
  Image? _currentImg1;
  Image? _currentImg2;
  Image? _currentImg3;
  Image? _currentImg4;
  Image? _currentImg5;
  Image? _currentImg6;
  Image? _currentImg7;
  Image? _currentImg8;
  Image? _currentImg9;

  List<Image> _listImg = [];

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

  /// 計時器物件的宣告
  Timer? _timer1;
  int _counterTimer1 = 0; //計時器計數用

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
  Image _toggleImage({Image? Img}) {
    Random random = Random();
    int currentImageIndex = random.nextInt(_listImg.length);

    ///當亂數取回的 Key 與目前圖片相同，就在取一次亂數
    while (Img!.key == _listImg[currentImageIndex].key) {
      currentImageIndex = random.nextInt(_listImg.length);
    }

    print(_listImg[currentImageIndex].key);

    return _listImg[currentImageIndex];
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

        ///oxFit.cover：這會保持圖片的比例，並使圖片填滿容器，可能會裁切部分圖片。
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
      _currentImg1 = _listImg.first; //下載完成，顯示第一張圖片
      _currentImg2 = _listImg.first; //下載完成，顯示第一張圖片
      _currentImg3 = _listImg.first; //下載完成，顯示第一張圖片
      _currentImg4 = _listImg.first; //下載完成，顯示第一張圖片
      _currentImg5 = _listImg.first; //下載完成，顯示第一張圖片
      _currentImg6 = _listImg.first; //下載完成，顯示第一張圖片
      _currentImg7 = _listImg.first; //下載完成，顯示第一張圖片
      _currentImg8 = _listImg.first; //下載完成，顯示第一張圖片
      _currentImg9 = _listImg.first; //下載完成，顯示第一張圖片
    }); //載入資料後，用來刷新畫面
  }

  ///抽卡程序
  void selectImg() {
    _currentImg1 = _toggleImage(Img: _currentImg1);
    _currentImg2 = _toggleImage(Img: _currentImg2);
    _currentImg3 = _toggleImage(Img: _currentImg3);
    _currentImg4 = _toggleImage(Img: _currentImg4);
    _currentImg5 = _toggleImage(Img: _currentImg5);
    _currentImg6 = _toggleImage(Img: _currentImg6);
    _currentImg7 = _toggleImage(Img: _currentImg7);
    _currentImg8 = _toggleImage(Img: _currentImg8);
    _currentImg9 = _toggleImage(Img: _currentImg9);

    setState(() {});

    _counterTimer1++;
    if (_counterTimer1 >= 10) {
      _counterTimer1 = 0;
      _timer1?.cancel();
    }
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
              height: 64,
              width: 64,
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

        // 顯示進度指示器，如果下載完成，就不會顯示
        if (isLoading) LinearProgressIndicator(value: downloadProgress),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _currentImg1 = _toggleImage(Img: _currentImg1);
                setState(() {});
              },
              child: MyFruitImg(
                myFruitImg: _currentImg1,
              ),
            ),
            GestureDetector(
              onTap: () {
                _currentImg2 = _toggleImage(Img: _currentImg2);
                setState(() {});
              },
              child: MyFruitImg(
                myFruitImg: _currentImg2,
              ),
            ),
            GestureDetector(
              onTap: () {
                _currentImg3 = _toggleImage(Img: _currentImg3);
                setState(() {});
              },
              child: MyFruitImg(
                myFruitImg: _currentImg3,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _currentImg4 = _toggleImage(Img: _currentImg4);
                setState(() {});
              },
              child: MyFruitImg(
                myFruitImg: _currentImg4,
              ),
            ),
            GestureDetector(
              onTap: () {
                _currentImg5 = _toggleImage(Img: _currentImg5);
                setState(() {});
              },
              child: MyFruitImg(
                myFruitImg: _currentImg5,
              ),
            ),
            GestureDetector(
              onTap: () {
                _currentImg6 = _toggleImage(Img: _currentImg6);
                setState(() {});
              },
              child: MyFruitImg(
                myFruitImg: _currentImg6,
              ),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _currentImg7 = _toggleImage(Img: _currentImg7);
                setState(() {});
              },
              child: MyFruitImg(
                myFruitImg: _currentImg7,
              ),
            ),
            GestureDetector(
              onTap: () {
                _currentImg8 = _toggleImage(Img: _currentImg8);
                setState(() {});
              },
              child: MyFruitImg(
                myFruitImg: _currentImg8,
              ),
            ),
            GestureDetector(
              onTap: () {
                _currentImg9 = _toggleImage(Img: _currentImg9);
                setState(() {});
              },
              child: MyFruitImg(
                myFruitImg: _currentImg9,
              ),
            ),
          ],
        ),

        SizedBox(
          height: 100,
        ),
        ElevatedButton(
          onPressed: () {
            // 每 100 毫秒執行一次 selectImg 方法
            _timer1 = Timer.periodic(
              Duration(milliseconds: 100),
              (timer) {
                selectImg();
              },
            );
          },
          child: Text('測試'),
        ),
        ElevatedButton(
          onPressed: () {
            print(_currentImg1!.key);
            print(_currentImg2!.key);
            print(_currentImg3!.key);
            print(_currentImg4!.key);
            print(_currentImg5!.key);
            print(_currentImg6!.key);
            print(_currentImg7!.key);
            print(_currentImg8!.key);
            print(_currentImg9!.key);
            setState(() {});
          },
          child: Text('讀取結果'),
        ),
      ],
    );
  }
}

///用來取代上面指令
///原本五行指令變成一行指令
///因為這個 Widget 佈件本身沒有要儲存的狀態
class MyFruitImg extends StatelessWidget {
  final Widget? myFruitImg;

  const MyFruitImg({
    super.key,
    required this.myFruitImg,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      duration: Duration(milliseconds: 300),
      child: myFruitImg,
    );
  }
}
