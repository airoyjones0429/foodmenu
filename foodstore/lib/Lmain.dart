import 'package:flutter/material.dart';
import 'dart:math'; // 使用 Random 時需呼叫

import 'dart:async'; //要使用 Timer 要用這個

import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

class MyRunFruitsPageView extends StatelessWidget {
  final bool isVertical;
  final PageController imgPageCR;
  final List<Image> myImg;
  final int maxRunning;

  MyRunFruitsPageView({
    required this.isVertical,
    required this.imgPageCR,
    required this.myImg,
    required this.maxRunning,
  });

  @override
  Widget build(BuildContext context) {
    return PageView(
      scrollDirection: isVertical ? Axis.vertical : Axis.horizontal,
      controller: imgPageCR,
      children: [
        for (int i = 0; i < maxRunning; i++) myImg[i],
      ],
    );
  }
}

class PageViewImg extends StatefulWidget {
  final GlobalKey<_PageViewImgState> _key = GlobalKey<_PageViewImgState>();

  int get imgIndex => _key.currentState?.imgIndex ?? 0; // 獲取 imgIndex

  PageViewImg({required super.key});

  @override
  State<PageViewImg> createState() => _PageViewImgState();
}

class _PageViewImgState extends State<PageViewImg> {
  int _imgIndex = 0;

  ///想要取回某一個位置，目前的圖片 KEY 整數代碼
  int get imgIndex => _imgIndex; // 提供 imgIndex 的 getter

  Timer? timeRun; //設定自動執行程序的ˋ計時器
  ///PageView 用的控制器，這個控制器，不要放在 build 中，會造成第二次的執行時
  ///程式會說你沒有設定給 PageView 所以不能控制
  final imgPageCR = PageController(initialPage: 0);

  @override
  void dispose() {
    super.dispose();
    timeRun?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<Image> fruitImg = appState._fruitImg; //取回設定的圖片
    List<int> fruitPositionImgKey = appState.fruitPositionImgKey;
    List<int> fruitPositionIsRunning = appState.fruitPositionIsRunning;

    ///取回這個 PageViewImg 的Key 索引值
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

    imgPageCR.addListener(() {
      ///取回 thisWidgetIntKey 位置的 PageView 物件，並將目前頁數傳回
      ///傳回 0 表示第 1 頁，傳回 1 表示第 2 頁 ...
      int pageIndex = imgPageCR.page!.round(); //頁所引
      ///設定圖片的整數 Key 讓外部知道
      fruitPositionImgKey[thisWidgetIntKey] =
          appState.getImgKeyInt(myImg[pageIndex].key);

      ///會列印出目前在第幾頁，動態列出目前第幾頁
      // print(imgPageCR.page!.round());
    });

    ///將這部分改成外部的 Widget
    // ///產生圖形頁面
    // PageView myRunFruitsPageView1() {
    //   return PageView(
    //     ///將參數設定條件畫，可以將參數同一在一個位置設定，且可以多了解程序
    //     scrollDirection: isVertical ? Axis.vertical : Axis.horizontal,
    //     controller: imgPageCR,
    //     children: [
    //       ///用迴圈產生 MaxRunning 數量的 Image
    //       for (int i = 0; i < MaxRunning; i++) myImg[i],
    //     ],
    //   );
    // }

    ///產生畫面時，就要設定內容，之後就用這個變數來設定
    MyRunFruitsPageView myRunFruitsPageView0 = MyRunFruitsPageView(
      isVertical: isVertical,
      myImg: myImg,
      imgPageCR: imgPageCR,
      maxRunning: MaxRunning,
    );

    ///更新圖片，將 PageView 設定為顯示第一張圖片，並且重新產生48張圖片清單
    void updateImgList() {
      ///重新設定
      myRunFruitsPageView0 = MyRunFruitsPageView(
        isVertical: isVertical,
        myImg: myImg,
        imgPageCR: imgPageCR,
        maxRunning: MaxRunning,
      );
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
      print(
          '最後一張圖片的KEY => ${myImg[MaxRunning - 1].key}  亂數種子為 ${imgIndex}  目前點到第 ${thisWidgetIntKey}  ${widget.key}   ${myImg[MaxRunning - 1].key}  ');
    }

    void onTap() {
      setState(() {
        updateImgList();
      });
      imgPageCR.animateToPage(MaxRunning - 1,
          duration: Duration(seconds: 10),

          ///這個變化曲線，慢曼加速 中間高速 慢慢減速停止，符合遊戲感覺
          curve: Curves.easeInOutCubic);

      ///在這裡列印出資訊，會得到上次的最後結果，不是這次的，所以沒用
      displayInfo();
    }

    ////定時檢查設定
    timeRun = Timer.periodic(Duration(milliseconds: 500), (time) {
      ///如果要執行狀態為 true 就要執行
      if (fruitPositionIsRunning[thisWidgetIntKey] == 1) {
        onTap();
        fruitPositionIsRunning[thisWidgetIntKey] = 0;
      }
    });

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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<Image> fruitImg = appState._fruitImg;
    List<PageViewImg> listPageView = appState.listPageView;

    void ReadGameState() => appState.ReadGameState();

    void PlayGame() => appState.PlayGame();

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
                    listPageView[6],
                    listPageView[7],
                    listPageView[8],
                  ],
                ),
              ),

              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => ReadGameState(),
                    child: Text('讀取遊戲狀態'),
                  ),
                  ElevatedButton(
                    onPressed: () => PlayGame(),
                    child: Text('開始遊戲'),
                  ),
                ],
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
  ///水果盤的圖片清單
  List<List<Image>> listFruitImg = [];

  ///預設水果盤狀態，全都設定為 0
  List<int> fruitPositionImgKey = List.generate(9, (index) {
    return 0;
  });

  bool isGameRunning = true;

  void ReadGameState() {
    print(
        '  ${fruitPositionImgKey[0]}   ${fruitPositionImgKey[1]}   ${fruitPositionImgKey[2]}  ');
    print(
        '  ${fruitPositionImgKey[3]}   ${fruitPositionImgKey[4]}   ${fruitPositionImgKey[5]}  ');
    print(
        '  ${fruitPositionImgKey[6]}   ${fruitPositionImgKey[7]}   ${fruitPositionImgKey[8]}  ');
  }

  void PlayGame() {
    for (int index = 0; index < fruitPositionIsRunning.length; index++) {
      ///將所有水果盤都跑起來
      fruitPositionIsRunning[index] = 1;
    }
  }

  ///預設水果盤，每個盤子的運轉狀態，為 1，就是要開始運轉
  List<int> fruitPositionIsRunning = [
    0, //左上
    0, //中上
    0, //右上
    0, //左中
    0, //中中
    0, //右中
    0, //左下
    0, //中下
    0, //右下
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

  ///取回傳入圖片 Key 的整數值
  int getImgKeyInt(Key? key) {
    if (_fruitImg[0].key == key) {
      //51
      return 51;
    } else if (_fruitImg[1].key == key) {
      //52
      return 52;
    } else if (_fruitImg[2].key == key) {
      //53
      return 53;
    } else if (_fruitImg[3].key == key) {
      //54
      return 54;
    } else if (_fruitImg[4].key == key) {
      //55
      return 55;
    } else if (_fruitImg[5].key == key) {
      //56
      return 56;
    } else if (_fruitImg[6].key == key) {
      //57
      return 57;
    } else if (_fruitImg[7].key == key) {
      //58
      return 58;
    } else if (_fruitImg[8].key == key) {
      //59
      return 59;
    } else if (_fruitImg[9].key == key) {
      //60
      return 60;
    } else if (_fruitImg[10].key == key) {
      //61
      return 61;
    } else if (_fruitImg[11].key == key) {
      //62
      return 62;
    } else {
      //63 錯誤的資料
      return 63;
    }
  }

  ///設定每個 PageView 的 KEY，並將該物件放到清單中
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
