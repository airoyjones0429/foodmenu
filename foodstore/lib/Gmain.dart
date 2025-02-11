import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dart:math'; // 使用亂數時要引用這個

import 'dart:async'; //要使用 Timer 要用這個

/// main6.dart => Gmain.dart
/// 1140211
/// 1.增加畫出線條的設定，用 Stack Column Row 混和的配置
/// 2.增加畫出得分線條的邏輯
/// 3.縮短先前的程式碼，GestureDetector 部分改用函數的方式設定

///在 Flutter 中，SizedBox 是一個用來限制其子部件大小的容器。
///在你的代碼中，SizedBox 的高度和寬度都設定為 192，這意味著它
///會強制其子部件（在這裡是 Container）的大小為 192 x 192。
///儘管你在 Container 中設定了高度為 5 和寬度為 100，
///但因為 SizedBox 的限制，Container 仍然會佔據 192 x 192 的空間。
///這是因為 SizedBox 會擴展其子部件以填滿指定的大小。
///如果你希望 Container 僅顯示為 100 x 5 的紅色方塊，你可以考慮將
///Container 放在不受 SizedBox 限制的上下文中，或者直接使用 Container 並設定其大小。

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

  ///想縮短程式碼，時增加
  ///減少重複的 GestureDetector 與 onTap()
  Widget? MytouchImg1;
  Widget? MytouchImg2;
  Widget? MytouchImg3;
  Widget? MytouchImg4;
  Widget? MytouchImg5;
  Widget? MytouchImg6;
  Widget? MytouchImg7;
  Widget? MytouchImg8;
  Widget? MytouchImg9;

  List<bool> hLine = [false, false, false]; //上中下水平線，是否要畫出
  List<bool> vLine = [false, false, false]; //左中右垂直線，是否要畫出
  List<bool> sLine = [false, false]; //左上右下、右上左下，使否要畫出

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
      drawPriceLine(); //當隨機圖片後，自動化出現來
    }
  }

  ///==================================以下
  ///為了要縮短佈件排列的程序而宣告的部分
  ///
  void _touchImg({Image? touchImg, int? imgPosition}) {
    setState(() {
      switch (imgPosition) {
        case 1:
          _currentImg1 = _toggleImage(Img: touchImg);
          break;
        case 2:
          _currentImg2 = _toggleImage(Img: touchImg);
          break;
        case 3:
          _currentImg3 = _toggleImage(Img: touchImg);
          break;
        case 4:
          _currentImg4 = _toggleImage(Img: touchImg);
          break;
        case 5:
          _currentImg5 = _toggleImage(Img: touchImg);
          break;
        case 6:
          _currentImg6 = _toggleImage(Img: touchImg);
          break;
        case 7:
          _currentImg7 = _toggleImage(Img: touchImg);
          break;
        case 8:
          _currentImg8 = _toggleImage(Img: touchImg);
          break;
        case 9:
          _currentImg9 = _toggleImage(Img: touchImg);
          break;
        default:
          print('發生意外在指令 _touchImg ');
      }
    });
  }

  Widget touchImg({Image? touchImg, int? imgPosition}) {
    return GestureDetector(
      onTap: () {
        _touchImg(touchImg: touchImg, imgPosition: imgPosition);
      },
      child: MyFruitImg(
        myFruitImg: touchImg,
      ),
    );
  }
  //為了要縮短佈件排列的程序而宣告的部分
  //=============================================以上

  ///======================以下
  ///畫出得分的線條
  void drawPriceLine() {
    List<Key?> fruitDish = [
      _currentImg1!.key, //0
      _currentImg2!.key,
      _currentImg3!.key,
      _currentImg4!.key, //3
      _currentImg5!.key,
      _currentImg6!.key,
      _currentImg7!.key, //6
      _currentImg8!.key,
      _currentImg9!.key,
    ];

    ///水平線設定
    hLine[0] = (fruitDish[0] == fruitDish[1]) && (fruitDish[0] == fruitDish[2]);
    hLine[1] = (fruitDish[3] == fruitDish[4]) && (fruitDish[3] == fruitDish[5]);
    hLine[2] = (fruitDish[6] == fruitDish[7]) && (fruitDish[6] == fruitDish[8]);

    ///垂直線設定
    vLine[0] = (fruitDish[0] == fruitDish[3]) && (fruitDish[0] == fruitDish[6]);
    vLine[1] = (fruitDish[1] == fruitDish[4]) && (fruitDish[1] == fruitDish[7]);
    vLine[2] = (fruitDish[2] == fruitDish[5]) && (fruitDish[2] == fruitDish[8]);

    ///斜線設定
    sLine[0] = (fruitDish[0] == fruitDish[4]) && (fruitDish[0] == fruitDish[8]);
    sLine[1] = (fruitDish[2] == fruitDish[4]) && (fruitDish[2] == fruitDish[6]);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print(_listImg.length);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center, //水平置中設定
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center, //垂直置中設定
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 256, // 64 + 64 + 64 圖片高度  +64 讓線條超過圖片
                    width: 256, // 64 + 64 + 64  圖片寬度  +64 讓線條超過圖片
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        /// 顯示進度指示器，如果下載完成，就不會顯示
                        /// 以下水果圖片設定區域 ================================
                        if (isLoading)
                          LinearProgressIndicator(value: downloadProgress),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MytouchImg1 = touchImg(
                                touchImg: _currentImg1, imgPosition: 1),
                            MytouchImg2 = touchImg(
                                touchImg: _currentImg2, imgPosition: 2),
                            MytouchImg3 = touchImg(
                                touchImg: _currentImg3, imgPosition: 3),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MytouchImg4 = touchImg(
                                touchImg: _currentImg4, imgPosition: 4),
                            MytouchImg5 = touchImg(
                                touchImg: _currentImg5, imgPosition: 5),
                            MytouchImg6 = touchImg(
                                touchImg: _currentImg6, imgPosition: 6),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MytouchImg7 = touchImg(
                                touchImg: _currentImg7, imgPosition: 7),
                            MytouchImg8 = touchImg(
                                touchImg: _currentImg8, imgPosition: 8),
                            MytouchImg9 = touchImg(
                                touchImg: _currentImg9, imgPosition: 9),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 以上水果圖片設定區域 =======================================
                  ///以下重疊上面圖片區域，當水平圖片相同時，繪製水平線
                  Column(
                    children: [
                      SizedBox(
                        height: 32,
                      ),
                      if (hLine[0])
                        Container(
                          height: 1,
                          width: 256,
                          color: Colors.red,
                        ),
                      SizedBox(
                        height: 64,
                      ),
                      if (hLine[1])
                        Container(
                          height: 1,
                          width: 256,
                          color: Colors.red,
                        ),
                      SizedBox(
                        height: 64,
                      ),
                      if (hLine[2])
                        Container(
                          height: 1,
                          width: 256,
                          color: Colors.red,
                        ),
                      SizedBox(
                        height: 32,
                      ),
                    ],
                  ),

                  ///當垂直圖片相同時，繪製垂直線
                  ///以下重疊上面區域，當垂直圖片相同時，繪製垂直線
                  Row(
                    children: [
                      SizedBox(
                        width: 32 + 32,
                      ),

                      ///這裡因為只有 1 pixel 看不太出來後面的線位移
                      ///比較好的方式是想畫斜線那樣，要回補空間
                      if (vLine[0])
                        Container(
                          height: 256,
                          width: 1,
                          color: Colors.redAccent,
                        ),
                      SizedBox(
                        width: 64,
                      ),
                      if (vLine[1])
                        Container(
                          height: 256,
                          width: 1,
                          color: Colors.blue,
                        ),
                      SizedBox(
                        width: 64,
                      ),
                      if (vLine[2])
                        Container(
                          height: 256,
                          width: 1,
                          color: Colors.purple,
                        ),
                      SizedBox(
                        width: 32 + 32,
                      ),
                    ],
                  ),

                  ///當對角圖片相同時，繪畫出對角線
                  ///以下重疊上方的區域
                  SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ///對角斜線填空用
                        SizedBox(
                          height: 32,
                        ),

                        ///最上方的水平設置
                        Row(
                          children: [
                            // 因為斜線會占用這裡設定的空間吃掉了，所以註解掉
                            // SizedBox(
                            //   width: 32 - 32,
                            // ),

                            ///左上角斜線
                            if (sLine[0])
                              //為真就是要顯示斜線
                              Transform.rotate(
                                angle: 3.14 / 4,
                                child: Container(
                                  height: 1,
                                  width: 128,
                                  color: Colors.yellow,
                                ),
                              )
                            else
                              //為假，就要填補空缺
                              SizedBox(
                                width: 128,
                              ),

                            // 因為右上斜線佔用了這部分的空間，所以註解這部分
                            // SizedBox(
                            //   width: 64 - 64,
                            // ),

                            ///右上角斜線
                            if (sLine[1])
                              //為真就要畫出斜線
                              Transform.rotate(
                                angle: -3.14 / 4,
                                child: Container(
                                  height: 1,
                                  width: 128,
                                  color: Colors.yellow,
                                ),
                              )
                            else
                              //為假就要填補空間
                              SizedBox(
                                width: 128,
                              ),
                          ],
                        ),

                        ///中間斜線填空用
                        SizedBox(
                          height: 64,
                        ),

                        ///中間的水平設置
                        Row(
                          children: [
                            SizedBox(
                              width: 64,
                            ),

                            ///中間的斜線，因為中間的斜線，必須在同一個位置
                            ///所以使用 Stack() Widget 堆疊放置
                            Stack(children: [
                              ///左上右下的斜線，這部分會跟下部分重疊
                              if (sLine[0])
                                Transform.rotate(
                                  angle: 3.14 / 4,
                                  child: Container(
                                    height: 1,
                                    width: 64,
                                    color: Colors.yellow,
                                  ),
                                ),

                              ///右上左下的斜線，這部分會跟上部分重疊
                              if (sLine[1])
                                Transform.rotate(
                                  angle: -3.14 / 4,
                                  child: Container(
                                    height: 1,
                                    width: 64,
                                    color: Colors.yellow,
                                  ),
                                ),
                            ]),
                            SizedBox(
                              width: 64,
                            ),
                          ],
                        ),

                        ///最下方斜線填位用
                        SizedBox(
                          height: 64,
                        ),
                        Row(
                          children: [
                            if (sLine[1])
                              Transform.rotate(
                                angle: -3.14 / 4,
                                child: Container(
                                  height: 1,
                                  width: 128,
                                  color: Colors.yellow,
                                ),
                              )
                            else
                              SizedBox(
                                width: 128,
                              ),
                            // SizedBox(
                            //   width: 38,
                            // ),
                            if (sLine[0])
                              Transform.rotate(
                                angle: 3.14 / 4,
                                child: Container(
                                  height: 1,
                                  width: 128,
                                  color: Colors.yellow,
                                ),
                              )
                            else
                              SizedBox(
                                width: 128,
                              ),
                          ],
                        ),
                      ],
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
                  // print(_currentImg1!.key);
                  // print(_currentImg2!.key);
                  // print(_currentImg3!.key);
                  // print(_currentImg4!.key);
                  // print(_currentImg5!.key);
                  // print(_currentImg6!.key);
                  // print(_currentImg7!.key);
                  // print(_currentImg8!.key);
                  // print(_currentImg9!.key);
                  // setState(() {});
                  drawPriceLine();
                },
                child: Text('計算分數'),
              ),
            ],
          ),
        ],
      ),
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
