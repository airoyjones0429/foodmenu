import 'package:flutter/material.dart';
import 'dart:math'; // 使用 Random 時需呼叫

import 'dart:async'; //要使用 Timer 要用這個

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
  final GlobalKey<_PageViewImgState> _key = GlobalKey<_PageViewImgState>();

  int get imgIndex => _key.currentState?.imgIndex ?? 0; // 獲取 imgIndex

  PageViewImg({required super.key});

  @override
  State<PageViewImg> createState() => _PageViewImgState();
}

class _PageViewImgState extends State<PageViewImg> {
  int _imgIndex = 0;

  int get imgIndex => _imgIndex; // 提供 imgIndex 的 getter

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<Image> fruitImg = appState._fruitImg;
    List<int> fruitPositionImgKey = appState.fruitPositionImgKey;
    List<bool> fruitPositionIsRunning = appState.fruitPositionIsRunning;

    ///取回這個 PageViewImg 的Key
    int thisWidgetIntKey = appState.getPVIKeyInt(widget.key);

    ///設定項目
    const int MaxRunning = 48; //跑動清單的圖片數量，最後一張為中獎圖片
    const bool isVertical = true; //設定為垂直捲動

    ///初始化設定
    Random random = Random();
    int imgIndex = 0;
    imgIndex = random.nextInt(12); //產生 0 ~ 11 的整數亂數

    /// 產生數量為 MaxRunning 個圖片 Widget 清單
    /// myImg 代表這個 PageView 的圖片清單，每一個 PageView 各自獨立的清單
    /// 的最後一張照片，就是中獎的圖片
    List<Image> myImg = List.generate(MaxRunning, (index) {
      int imgI = (imgIndex + index) % 12; //循環取圖片
      return fruitImg[imgI];
    });

    ///PageView 用的控制器
    final imgPageCR = PageController(initialPage: 0);
    imgPageCR.addListener(() {
      ///取回 thisWidgetIntKey 位置的 PageView 物件，並將目前頁數傳回
      ///傳回 0 表示第 1 頁，傳回 1 表示第 2 頁 ...
      int pageIndex = imgPageCR.page!.round(); //頁所引
      fruitPositionImgKey[thisWidgetIntKey] = pageIndex;

      ///會列印出目前在第幾頁，動態列出目前第幾頁
      // print(imgPageCR.page!.round());
    });

    ///產生圖形頁面
    PageView myRunFruitsPageView1() {
      return PageView(
        ///將參數設定條件畫，可以將參數同一在一個位置設定，且可以多了解程序
        scrollDirection: isVertical ? Axis.vertical : Axis.horizontal,
        controller: imgPageCR,
        children: [
          ///用迴圈產生 MaxRunning 數量的 Image
          for (int i = 0; i < MaxRunning; i++) myImg[i],

          /// 以下除錯用檢查圖片的 KEY 有沒有錯誤，結果沒錯誤
          // for (int i = 0; i < MaxRunning; i++)
          //   IconButton(
          //       onPressed: () {
          //         print(myImg[i].key);
          //       },
          //       icon: myImg[i]),
        ],
      );
    }

    ///產生畫面時，就要設定內容，之後就用這個變數來設定
    PageView myRunFruitsPageView0 = myRunFruitsPageView1();

    ///更新圖片，將 PageView 設定為顯示第一張圖片，並且重新產生48張圖片清單
    void updateImgList() {
      ///重新設定
      myRunFruitsPageView0 = myRunFruitsPageView1();
      imgPageCR.jumpToPage(0); //回到 PageView 第一頁

      myImg.clear(); //清除照片

      ///刷新目前數量為 MaxRunning 圖片排列
      myImg = List.generate(MaxRunning, (index) {
        int imgI = (imgIndex + index) % 12; //循環取圖片
        return fruitImg[imgI];
      });
    }

    void displayInfo() {
      ///debug
      print('最後一張圖片的KEY => ${myImg[MaxRunning - 1].key}  亂數種子為 ${imgIndex} ');
      print(
          '目前點到第 ${thisWidgetIntKey}  ${widget.key}   ${myImg[MaxRunning - 1].key}  ');
    }

    void onTap() {
      setState(() {
        updateImgList();
      });
      imgPageCR.animateToPage(MaxRunning - 1,
          duration: Duration(seconds: 10),

          ///這個變化曲線，慢曼加速 中間高速 慢慢減速停止，符合遊戲感覺
          curve: Curves.easeInOutCubic);

      displayInfo();
    }

    return Expanded(
      child: SizedBox(
        width: 64,
        child: GestureDetector(
          onTap: () => onTap(),
          child: myRunFruitsPageView0,
        ),
      ),
    );
  }
}

class MyImgList extends StatefulWidget {
  @override
  State<MyImgList> createState() => _MyImgListState();
}

class _MyImgListState extends State<MyImgList> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<Image> fruitImg = appState._fruitImg;
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
    var appState = context.watch<MyAppState>();
    List<Image> fruitImg = appState._fruitImg;
    List<PageViewImg> listPageView = appState.listPageView;

    void playGame() => appState.showGameState();

    return Scaffold(
      body: Container(
        color: Colors.white,
        height: 500,
        width: 500,
        child: SafeArea(
          child: Column(
            children: [
              ///最上排
              Container(
                height: 64,
                child: Row(
                  children: [
                    // PageViewImg(
                    //   key: ValueKey<int>(1),
                    // ),
                    // PageViewImg(
                    //   key: ValueKey<int>(2),
                    // ),
                    // PageViewImg(
                    //   key: ValueKey<int>(3),
                    // ),
                    ///上面用下面程序替換
                    listPageView[0],
                    listPageView[1],
                    listPageView[2],
                  ],
                ),
              ),

              ///中排
              Container(
                height: 64,
                child: Row(
                  children: [
                    // PageViewImg(
                    //   key: ValueKey<int>(4),
                    // ),
                    // PageViewImg(
                    //   key: ValueKey<int>(5),
                    // ),
                    // PageViewImg(
                    //   key: ValueKey<int>(6),
                    // ),
                    listPageView[3],
                    listPageView[4],
                    listPageView[5],
                  ],
                ),
              ),

              ///最下排
              Container(
                height: 64,
                child: Row(
                  children: [
                    // PageViewImg(
                    //   key: ValueKey<int>(7),
                    // ),
                    // PageViewImg(
                    //   key: ValueKey<int>(8),
                    // ),
                    // PageViewImg(
                    //   key: ValueKey<int>(9),
                    // ),
                    listPageView[6],
                    listPageView[7],
                    listPageView[8],
                  ],
                ),
              ),

              ElevatedButton(
                onPressed: () => playGame(),
                child: Text('測試'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///管理 APP 與使用者的互動狀態，互動時有些 Wigdets 需要有變化，都靠這裡處理
class MyAppState extends ChangeNotifier {
  ///預設水果盤狀態，全都設定為 0
  List<int> fruitPositionImgKey = List.generate(9, (index) {
    return 0;
  });

  ///預設水果盤，每個盤子的運轉狀態，為真，就是要開始運轉
  List<bool> fruitPositionIsRunning = [
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true
  ];

  @override
  void dispose() {
    super.dispose();
    timeAppState?.cancel();
  }

  Timer? timeAppState;
  void showGameState() {
    ///定時列出狀態，如果要在類別中，使用變數，解決辦法之一就是設定為靜態變數
    timeAppState = Timer.periodic(Duration(milliseconds: 5000), (time) {
      if (fruitPositionImgKey.isNotEmpty) {
        print(
            ' 1>> ${fruitPositionImgKey[0]}   ${fruitPositionImgKey[1]}  ${fruitPositionImgKey[2]}');
        print(
            ' 2>> ${fruitPositionImgKey[3]}   ${fruitPositionImgKey[4]}  ${fruitPositionImgKey[5]}');
        print(
            ' 3>> ${fruitPositionImgKey[6]}   ${fruitPositionImgKey[7]}  ${fruitPositionImgKey[8]}');
      }
    });
  }

  int getPVIKeyInt(Key? key) {
    if (listPageView[0].key == key) {
      return 0;
    } else if (listPageView[1].key == key) {
      return 1;
    } else if (listPageView[2].key == key) {
      return 2;
    } else if (listPageView[3].key == key) {
      return 3;
    } else if (listPageView[4].key == key) {
      return 4;
    } else if (listPageView[5].key == key) {
      return 5;
    } else if (listPageView[6].key == key) {
      return 6;
    } else if (listPageView[7].key == key) {
      return 7;
    } else if (listPageView[8].key == key) {
      return 8;
    } else {
      return 9;
    }
  }

  getPageviewImgState() {
    print(listPageView[0]);
  }

  ///設定每個 PageView 的 KEY
  List<PageViewImg> listPageView = [
    PageViewImg(
      key: ValueKey<int>(1),
    ),
    PageViewImg(
      key: ValueKey<int>(2),
    ),
    PageViewImg(
      key: ValueKey<int>(3),
    ),
    PageViewImg(
      key: ValueKey<int>(4),
    ),
    PageViewImg(
      key: ValueKey<int>(5),
    ),
    PageViewImg(
      key: ValueKey<int>(6),
    ),
    PageViewImg(
      key: ValueKey<int>(7),
    ),
    PageViewImg(
      key: ValueKey<int>(8),
    ),
    PageViewImg(
      key: ValueKey<int>(9),
    ),
  ];

  ///設定每個清單的圖片，圖片的位置不會變化
  final List<Image> _fruitImg = [
    Image.asset(
      'assets/fruitimg/fruit01.png',
      semanticLabel: '51',
      key: ValueKey<int>(51),
    ),
    Image.asset(
      'assets/fruitimg/fruit02.png',
      semanticLabel: '52',
      key: ValueKey<int>(52),
    ),
    Image.asset(
      'assets/fruitimg/fruit03.png',
      semanticLabel: '53',
      key: ValueKey<int>(53),
    ),
    Image.asset(
      'assets/fruitimg/fruit04.png',
      semanticLabel: '54',
      key: ValueKey<int>(54),
    ),
    Image.asset(
      'assets/fruitimg/fruit05.png',
      semanticLabel: '55',
      key: ValueKey<int>(55),
    ),
    Image.asset(
      'assets/fruitimg/fruit06.png',
      semanticLabel: '56',
      key: ValueKey<int>(56),
    ),
    Image.asset(
      'assets/fruitimg/fruit07.png',
      semanticLabel: '57',
      key: ValueKey<int>(57),
    ),
    Image.asset(
      'assets/fruitimg/fruit08.png',
      semanticLabel: '58',
      key: ValueKey<int>(58),
    ),
    Image.asset(
      'assets/fruitimg/fruit09.png',
      semanticLabel: '59',
      key: ValueKey<int>(59),
    ),
    Image.asset(
      'assets/fruitimg/fruit10.png',
      semanticLabel: '60',
      key: ValueKey<int>(60),
    ),
    Image.asset(
      'assets/fruitimg/fruit11.png',
      semanticLabel: '61',
      key: ValueKey<int>(61),
    ),
    Image.asset(
      'assets/fruitimg/fruit12.png',
      semanticLabel: '62',
      key: ValueKey<int>(62),
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
