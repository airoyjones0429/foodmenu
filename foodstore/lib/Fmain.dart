import 'package:flutter/material.dart';

import 'dart:math'; // 使用亂數時要引用這個

import 'dart:async'; //要使用 Timer 要用這個

/// main5.dart => Fmain.dart
/// 1140211
/// 1.將取回亂數圖片修改成用函式呼叫的方式

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

  //想縮短程式碼
  Widget? MytouchImg1;
  Widget? MytouchImg2;
  Widget? MytouchImg3;
  Widget? MytouchImg4;
  Widget? MytouchImg5;
  Widget? MytouchImg6;
  Widget? MytouchImg7;
  Widget? MytouchImg8;
  Widget? MytouchImg9;

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
    }
  }

  ///==================================
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
  //=============================================

  @override
  Widget build(BuildContext context) {
    print(_listImg.length);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 顯示進度指示器，如果下載完成，就不會顯示
        if (isLoading) LinearProgressIndicator(value: downloadProgress),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MytouchImg1 = touchImg(touchImg: _currentImg1, imgPosition: 1),
            MytouchImg2 = touchImg(touchImg: _currentImg2, imgPosition: 2),
            MytouchImg3 = touchImg(touchImg: _currentImg3, imgPosition: 3),

            ///下面的指令用上面三行取代了
            // GestureDetector(
            //   onTap: () {
            //     _currentImg1 = _toggleImage(Img: _currentImg1);
            //     setState(() {});
            //   },
            //   child: MyFruitImg(
            //     myFruitImg: _currentImg1,
            //   ),
            // ),
            // GestureDetector(
            //   onTap: () {
            //     _currentImg2 = _toggleImage(Img: _currentImg2);
            //     setState(() {});
            //   },
            //   child: MyFruitImg(
            //     myFruitImg: _currentImg2,
            //   ),
            // ),
            // GestureDetector(
            //   onTap: () {
            //     _currentImg3 = _toggleImage(Img: _currentImg3);
            //     setState(() {});
            //   },
            //   child: MyFruitImg(
            //     myFruitImg: _currentImg3,
            //   ),
            // ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MytouchImg4 = touchImg(touchImg: _currentImg4, imgPosition: 4),
            MytouchImg5 = touchImg(touchImg: _currentImg5, imgPosition: 5),
            MytouchImg6 = touchImg(touchImg: _currentImg6, imgPosition: 6),

            ///下面的指令用上面三行取代了
            // GestureDetector(
            //   onTap: () {
            //     _currentImg4 = _toggleImage(Img: _currentImg4);
            //     setState(() {});
            //   },
            //   child: MyFruitImg(
            //     myFruitImg: _currentImg4,
            //   ),
            // ),
            // GestureDetector(
            //   onTap: () {
            //     _currentImg5 = _toggleImage(Img: _currentImg5);
            //     setState(() {});
            //   },
            //   child: MyFruitImg(
            //     myFruitImg: _currentImg5,
            //   ),
            // ),
            // GestureDetector(
            //   onTap: () {
            //     _currentImg6 = _toggleImage(Img: _currentImg6);
            //     setState(() {});
            //   },
            //   child: MyFruitImg(
            //     myFruitImg: _currentImg6,
            //   ),
            // ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MytouchImg7 = touchImg(touchImg: _currentImg7, imgPosition: 7),
            MytouchImg8 = touchImg(touchImg: _currentImg8, imgPosition: 8),
            MytouchImg9 = touchImg(touchImg: _currentImg9, imgPosition: 9),

            ///下面的指令用上面三行取代了
            // GestureDetector(
            //   onTap: () {
            //     _currentImg7 = _toggleImage(Img: _currentImg7);
            //     setState(() {});
            //   },
            //   child: MyFruitImg(
            //     myFruitImg: _currentImg7,
            //   ),
            // ),
            // GestureDetector(
            //   onTap: () {
            //     _currentImg8 = _toggleImage(Img: _currentImg8);
            //     setState(() {});
            //   },
            //   child: MyFruitImg(
            //     myFruitImg: _currentImg8,
            //   ),
            // ),
            // GestureDetector(
            //   onTap: () {
            //     _currentImg9 = _toggleImage(Img: _currentImg9);
            //     setState(() {});
            //   },
            //   child: MyFruitImg(
            //     myFruitImg: _currentImg9,
            //   ),
            // ),
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
