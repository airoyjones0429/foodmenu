import 'package:flutter/material.dart';
import 'dart:math'; // 使用 Random 時需呼叫

/// 要使用本機裝置資料夾功能時，需要引用 LIB

import 'package:provider/provider.dart';

///
///
///
class RamdomImg extends StatefulWidget {
  const RamdomImg({required super.key});

  @override
  State<RamdomImg> createState() => _RamdomImgState();
}

class _RamdomImgState extends State<RamdomImg> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<Image> fruitImg = appState._fruitImg;
    Random random = Random();
    int imgIndex = random.nextInt(12); //產生 0 ~ 11 的整數亂數

    onTap(int iIndex) {
      int nIndex;
      do {
        nIndex = random.nextInt(12);
      } while (nIndex == iIndex);

      setState(() {
        imgIndex = nIndex;
      });
    }

    return GestureDetector(

        /// 用上面這行，不會觸發 onTap，設定中斷點確定不會觸發呼叫程序
        /// 但是改用下面哪一行，就可以正常觸發程序
        //  onTap: onTap(imgIndex), child: fruitImg[imgIndex]);
        onTap: () => onTap(imgIndex),
        child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: fruitImg[imgIndex]));
  }
}

///
///
///
///
///
///
class PageViewImg extends StatefulWidget {
  const PageViewImg({required super.key});

  @override
  State<PageViewImg> createState() => _PageViewImgState();
}

class _PageViewImgState extends State<PageViewImg> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<Image> fruitImg = appState._fruitImg;

    const int MaxRunning = 48; //跑動清單的圖片數量，最後一張為中獎圖片
    const bool isVertical = true; //設定為垂直捲動

    Random random = Random();
    int imgIndex = random.nextInt(12); //產生 0 ~ 11 的整數亂數

    ///PageView 用的控制器
    final imgPageCR = PageController(initialPage: 0);

    ///產生數量為 MaxRunning 個圖片 Widget 清單
    List<Image> myImg = List.generate(MaxRunning, (index) {
      int imgI = (imgIndex + index) % 12; //循環取圖片
      return fruitImg[imgI];
    });

    PageView myRunFruitsPageView1() {
      return PageView(
        ///將參數設定條件畫，可以將參數同一在一個位置設定，且可以多了解程序
        scrollDirection: isVertical ? Axis.vertical : Axis.horizontal,
        controller: imgPageCR,
        children: [
          for (int i = 0; i < MaxRunning; i++) myImg[i],
        ],
      );
    }

    ///產生畫面時，就要設定內容，之後就用這個變數來設定
    PageView myRunFruitsPageView0 = myRunFruitsPageView1();

    void updateImgList() {
      imgIndex = random.nextInt(12); //產生 0 ~ 11 的整數亂數
      myImg = List.generate(48, (index) {
        int imgI = (imgIndex + index) % 12; //循環取圖片
        return fruitImg[imgI];
      });

      myRunFruitsPageView0 = myRunFruitsPageView1();
      imgPageCR.jumpToPage(0);
    }

    onTap() {
      setState(() {
        updateImgList();
      });
      imgPageCR.animateToPage(MaxRunning,
          duration: Duration(seconds: 10),

          ///這個變化曲線，慢曼加速 中間高速 慢慢減速停止，符合遊戲感覺
          curve: Curves.easeInOutCubic);
    }

    return Expanded(
      child: SizedBox(
        width: 64,
        child: GestureDetector(
          onTap: () => onTap(),
          child: myRunFruitsPageView0,

          /// 下面改成寫成用變數的方式來設定 child 內容
          //  PageView(
          //   controller: imgPageCR,
          //   children: [
          //     for (int i = 0; i < MaxRunning; i++) myImg[i],
          //   ],
          // ),
        ),
      ),
    );
  }
}

///
///
// ///    return AnimatedSwitcher(
//       transitionBuilder: (Widget child, Animation<double> animation) {
//         return ScaleTransition(scale: animation, child: child);
//       },
//       duration: Duration(milliseconds: 300),
//       child: myFruitImg,
//     );
///
///
///
///
///
///
///
///

class MyImgList extends StatefulWidget {
  @override
  State<MyImgList> createState() => _MyImgListState();
}

class _MyImgListState extends State<MyImgList> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<Image> fruitImg = appState._fruitImg;
    // return SafeArea(
    //   child: Column(
    //     children: [
    //       Image.asset('assets/fruitimg/fruit01.png'),
    //       Image.asset('assets/fruitimg/fruit02.png'),
    //       Image.asset('assets/fruitimg/fruit03.png'),
    //       Image.asset('assets/fruitimg/fruit04.png'),

    //       ///這種情況不太可能發生，因為是設計階段就可以修正的
    //       Image.asset(
    //         'assets/fruitimg/fruit94.png',
    //         errorBuilder: (context, error, stackTrace) {
    //           return Text('圖片錯誤');
    //         },
    //       ),
    //     ],
    //   ),
    // );

    return ListView.builder(
        itemCount: 12,
        itemBuilder: (BuildContext context, index) {
          return SizedBox(height: 64, child: fruitImg[index]);
        });
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        height: 500,
        width: 500,
        child: SafeArea(
          child: Column(
            children: [
              ///1
              // Expanded(child: MyImgList()),
              ///2
              // RamdomImg(
              //   key: ValueKey<int>(0),
              // ),

              ///最上排
              Container(
                height: 64,
                child: Row(
                  children: [
                    PageViewImg(
                      key: ValueKey<int>(1),
                    ),
                    PageViewImg(
                      key: ValueKey<int>(2),
                    ),
                    PageViewImg(
                      key: ValueKey<int>(3),
                    ),
                  ],
                ),
              ),

              ///中排
              Container(
                height: 64,
                child: Row(
                  children: [
                    PageViewImg(
                      key: ValueKey<int>(4),
                    ),
                    PageViewImg(
                      key: ValueKey<int>(5),
                    ),
                    PageViewImg(
                      key: ValueKey<int>(6),
                    ),
                  ],
                ),
              ),

              ///最下排
              Container(
                height: 64,
                child: Row(
                  children: [
                    PageViewImg(
                      key: ValueKey<int>(7),
                    ),
                    PageViewImg(
                      key: ValueKey<int>(8),
                    ),
                    PageViewImg(
                      key: ValueKey<int>(9),
                    ),
                  ],
                ),
              ),
              // PageViewImg(
              //   key: ValueKey<int>(2),
              // ),
              // PageViewImg(
              //   key: ValueKey<int>(3),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

///管理 APP 與使用者的互動狀態，互動時有些 Wigdets 需要有變化，都靠這裡處理
class MyAppState extends ChangeNotifier {
  final List<Image> _fruitImg = [
    Image.asset(
      'assets/fruitimg/fruit01.png',
      key: ValueKey<int>(1),
    ),
    Image.asset(
      'assets/fruitimg/fruit02.png',
      key: ValueKey<int>(2),
    ),
    Image.asset(
      'assets/fruitimg/fruit03.png',
      key: ValueKey<int>(3),
    ),
    Image.asset(
      'assets/fruitimg/fruit04.png',
      key: ValueKey<int>(4),
    ),
    Image.asset(
      'assets/fruitimg/fruit05.png',
      key: ValueKey<int>(5),
    ),
    Image.asset(
      'assets/fruitimg/fruit06.png',
      key: ValueKey<int>(6),
    ),
    Image.asset(
      'assets/fruitimg/fruit07.png',
      key: ValueKey<int>(7),
    ),
    Image.asset(
      'assets/fruitimg/fruit08.png',
      key: ValueKey<int>(8),
    ),
    Image.asset(
      'assets/fruitimg/fruit09.png',
      key: ValueKey<int>(9),
    ),
    Image.asset(
      'assets/fruitimg/fruit10.png',
      key: ValueKey<int>(10),
    ),
    Image.asset(
      'assets/fruitimg/fruit11.png',
      key: ValueKey<int>(11),
    ),
    Image.asset(
      'assets/fruitimg/fruit12.png',
      key: ValueKey<int>(12),
    ),
  ];
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => MyAppState(),
      child: MaterialApp(
          theme: ThemeData.dark(
            useMaterial3: true,
          ),
          home: MyHomePage()),
    );
  }
}

void main() {
  runApp(MyApp());
}
