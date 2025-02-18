import 'package:flutter/material.dart';
import 'dart:math'; // 使用 Random 時需呼叫

import 'dart:async'; //要使用 Timer 要用這個

import 'package:provider/provider.dart';

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

  Timer? timeRun; //設定自動執行程序的計時器

  ///放在外部
  PageController imgPageCR = PageController(initialPage: 0);

  @override
  void dispose() {
    super.dispose();

    timeRun?.cancel();
    imgPageCR.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<Image> fruitImg = appState._fruitImg; //取回設定的圖片
    List<int> fruitPositionImgKey = appState.fruitPositionImgKey;
    List<int> fruitPositionIsRunning = appState.fruitPositionIsRunning;
    List<int> fruitPositionRandom = appState.fruitPositionRandom;

    ///取回這個 PageViewImg 的Key 索引值
    int thisWidgetIntKey = appState.getPVIKeyInt(widget.key);

    ///設定項目
    const int MaxRunning = 48; //跑動清單的圖片數量，最後一張為中獎圖片
    const bool isVertical = true; //設定為垂直捲動

    ///初始化設定
    Random random = Random();
    int imgIndex = 0;
    imgIndex = (appState.isPlaying)
        ? fruitPositionRandom[thisWidgetIntKey]
        : random.nextInt(12); //產生 0 ~ 11 的整數亂數

    fruitPositionRandom[thisWidgetIntKey] = imgIndex;

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

    ///產生畫面時，就要設定內容，之後就用這個變數來設定
    MyRunFruitsPageView myRunFruitsPageView0 = MyRunFruitsPageView(
      isVertical: isVertical,
      myImg: myImg,
      imgPageCR: imgPageCR,
      maxRunning: MaxRunning,
    );

    ///更新圖片，將 PageView 設定為顯示第一張圖片，並且重新產生48張圖片清單
    void updateImgList() {
      imgPageCR.jumpToPage(0); //回到 PageView 第一頁

      myImg.clear(); //清除照片

      ///刷新目前數量為 MaxRunning 圖片排列
      ///隨機選取第一張圖片，就會固定決定最後一張照片
      myImg = List.generate(MaxRunning, (index) {
        int imgI = (imgIndex + index) % 12; //循環取圖片
        return fruitImg[imgI];
      });
    }

    ///切換畫面 會發生錯誤  xxxx
    void onTap() {
      ///重新設定
      myRunFruitsPageView0 = MyRunFruitsPageView(
        isVertical: isVertical,
        myImg: myImg,
        imgPageCR: imgPageCR,
        maxRunning: MaxRunning,
      );

      ///如果這個 Widget 已經被安裝
      // if (this.mounted) {
      setState(() {
        updateImgList();
      });
      imgPageCR.animateToPage(MaxRunning - 1,
          duration: Duration(seconds: appState.runningMaxTimeSecond), //動畫速度

          ///這個變化曲線，慢曼加速 中間高速 慢慢減速停止，符合遊戲感覺
          curve: Curves.easeInOutCubic);
      // }
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

class MyNineFruitDish extends StatefulWidget {
  @override
  State<MyNineFruitDish> createState() => _MyNineFruitDishState();
}

class _MyNineFruitDishState extends State<MyNineFruitDish> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<Image> fruitImg = appState._fruitImg;
    List<PageViewImg> listPageView = appState.listPageView;
    List<bool> hLine = appState.hLine;
    List<bool> vLine = appState.vLine;
    List<bool> sLine = appState.sLine;
    bool isPlaying = appState.isPlaying; //按下開始遊玩為真

    Timer? timePlayGame;

    void ReadGameState() => appState.ReadGameState();
    void MyPlayGame() => appState.PlayGame();
    void MyClearLine() => appState.clearLine();

    void testPlay() {
      setState(() {
        ReadGameState();
      });
    }

    void PlayGame() {
      // appState.PlayGame();
      setState(() {
        MyClearLine();
      });
      isPlaying = true;
      MyPlayGame();
      timePlayGame = Timer.periodic(
          Duration(seconds: appState.runningMaxTimeSecond + 1), (time) {
        if (isPlaying) {
          ReadGameState();
          isPlaying = false;
          timePlayGame?.cancel();
          setState(() {});
        }
        // print('test189'); //在外部宣告計時器後，就可以自己關閉自己了
      });
    }

    double spaceTop1 = 50; //Green
    double spaceTop2 = 50; //Blue  必須在填空這裡  不然斜線位置會不正確
    double spaceLeft1 = 105;
    double lineLength = 400; //線長度
    double MyFruitHeight = 256;
    double MyFruitWidth = 256;
    double MyScreenHeight = 500;
    double MyScreenWidth = 500;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(children: [
              Container(
                height: MyScreenHeight,
                width: MyScreenWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: spaceTop1,
                      color: Colors.green,
                    ),
                    Container(
                      height: spaceTop2,
                      color: Color.fromARGB(255, 0, 0, 255),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 50,
                          color: Colors.amber,
                        ),
                        Container(
                          color: Colors.white,
                          height: MyFruitHeight,
                          width: MyFruitWidth,
                          child: Column(
                            children: [
                              ///最上排
                              Container(
                                height: 64,
                                child: Row(
                                  children: [
                                    listPageView[0],
                                    SizedBox(
                                      width: 32,
                                    ),
                                    listPageView[1],
                                    SizedBox(
                                      width: 32,
                                    ),
                                    listPageView[2],
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 32,
                              ),

                              ///中排
                              Container(
                                height: 64,
                                child: Row(
                                  children: [
                                    listPageView[3],
                                    SizedBox(
                                      width: 32,
                                    ),
                                    listPageView[4],
                                    SizedBox(
                                      width: 32,
                                    ),
                                    listPageView[5],
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 32,
                              ),

                              ///最下排
                              Container(
                                height: 64,
                                child: Row(
                                  children: [
                                    listPageView[6],
                                    SizedBox(
                                      width: 32,
                                    ),
                                    listPageView[7],
                                    SizedBox(
                                      width: 32,
                                    ),
                                    listPageView[8],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 50,
                          color: Colors.amber,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              ///
              ///
              ///
              ///
              ///顯示水平紅線
              SizedBox(
                height: MyScreenHeight,
                width: MyScreenWidth,
                child: SafeArea(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 26.5 + spaceTop1 + spaceTop2,
                      ),

                      ///最上水平線
                      (hLine[0])
                          ? Container(
                              height: 11,
                              width: 500,
                              color: Color.fromARGB(50, 255, 0, 0),
                            )
                          : SizedBox(
                              height: 11,
                            ),
                      SizedBox(
                        height: 53 + 32,
                      ),

                      ///中間水平線
                      (hLine[1])
                          ? Container(
                              height: 11,
                              width: 500,
                              color: Color.fromARGB(50, 255, 0, 0),
                            )
                          : SizedBox(
                              height: 11,
                            ),
                      SizedBox(
                        height: 53 + 32,
                      ),

                      ///最下水平線
                      (hLine[2])
                          ? Container(
                              height: 11,
                              width: 500,
                              color: Color.fromARGB(50, 255, 0, 0),
                            )
                          : SizedBox(
                              height: 11,
                            ),
                    ],
                  ),
                ),
              ),

              ///
              ///
              ///
              ///顯示垂直線
              SizedBox(
                height: MyScreenHeight,
                width: MyScreenWidth,
                child: SafeArea(
                  child: Row(
                    children: [
                      SizedBox(
                        width: spaceLeft1,
                      ),

                      ///最左垂直線
                      (vLine[0])
                          ? Container(
                              width: 11,
                              height: lineLength,
                              color: Color.fromARGB(50, 255, 0, 0),
                            )
                          : SizedBox(
                              width: 11,
                            ),
                      SizedBox(
                        width: 86,
                      ),

                      ///中間垂直線
                      (vLine[1])
                          ? Container(
                              width: 11,
                              height: lineLength,
                              color: Color.fromARGB(50, 255, 0, 0),
                            )
                          : SizedBox(
                              width: 11,
                            ),
                      SizedBox(
                        width: 86,
                      ),

                      ///右邊垂直線
                      (vLine[2])
                          ? Container(
                              width: 11,
                              height: lineLength,
                              color: Color.fromARGB(50, 255, 0, 0),
                            )
                          : SizedBox(
                              width: 11,
                            ),
                    ],
                  ),
                ),
              ),

              ///
              ///
              ///
              ///顯示右上左下斜線
              (sLine[0])
                  ? SizedBox(
                      height: MyScreenHeight,
                      width: MyScreenWidth,
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 4,
                            ),

                            ///
                            Transform.rotate(
                              angle: 3.14 / 4,
                              child: Container(
                                width: 11,
                                height: 450,
                                color: Color.fromARGB(100, 0, 192, 192),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),

              ///
              ///
              ///
              ///顯示左上右下斜線
              (sLine[1])
                  ? SizedBox(
                      height: MyScreenHeight,
                      width: MyScreenWidth,
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 4,
                            ),

                            ///
                            Transform.rotate(
                              angle: -3.14 / 4,
                              child: Container(
                                width: 11,
                                height: 450,
                                color: Color.fromARGB(100, 0, 192, 192),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),
            ]),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => testPlay(),
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
    );
  }
}

///管理 APP 與使用者的互動狀態，互動時有些 Wigdets 需要有變化，都靠這裡處理
class MyAppState extends ChangeNotifier {
  ///預設水果盤狀態，全都設定為 0
  List<int> fruitPositionImgKey = List.generate(9, (index) {
    return 0;
  });

  ///水果盤亂數狀態，全都設定為 0
  List<int> fruitPositionRandom = List.generate(9, (index) {
    return 0;
  });

  bool isGameRunning = true;

  void clearLine() {
    vLine[0] = false;
    vLine[1] = false;
    vLine[2] = false;
    hLine[0] = false;
    hLine[1] = false;
    hLine[2] = false;
    sLine[0] = false;
    sLine[1] = false;
  }

  void ReadGameState() {
    print(
        '  ${fruitPositionImgKey[0]}   ${fruitPositionImgKey[1]}   ${fruitPositionImgKey[2]}  ');
    print(
        '  ${fruitPositionImgKey[3]}   ${fruitPositionImgKey[4]}   ${fruitPositionImgKey[5]}  ');
    print(
        '  ${fruitPositionImgKey[6]}   ${fruitPositionImgKey[7]}   ${fruitPositionImgKey[8]}  ');

    ///水平線設定
    hLine[0] = (fruitPositionImgKey[0] == fruitPositionImgKey[1]) &&
        (fruitPositionImgKey[0] == fruitPositionImgKey[2]);
    hLine[1] = (fruitPositionImgKey[3] == fruitPositionImgKey[4]) &&
        (fruitPositionImgKey[3] == fruitPositionImgKey[5]);
    hLine[2] = (fruitPositionImgKey[6] == fruitPositionImgKey[7]) &&
        (fruitPositionImgKey[6] == fruitPositionImgKey[8]);

    ///垂直線設定
    vLine[0] = (fruitPositionImgKey[0] == fruitPositionImgKey[3]) &&
        (fruitPositionImgKey[0] == fruitPositionImgKey[6]);
    vLine[1] = (fruitPositionImgKey[1] == fruitPositionImgKey[4]) &&
        (fruitPositionImgKey[1] == fruitPositionImgKey[7]);
    vLine[2] = (fruitPositionImgKey[2] == fruitPositionImgKey[5]) &&
        (fruitPositionImgKey[2] == fruitPositionImgKey[8]);

    ///斜線設定
    sLine[1] = (fruitPositionImgKey[0] == fruitPositionImgKey[4]) &&
        (fruitPositionImgKey[0] == fruitPositionImgKey[8]);
    sLine[0] = (fruitPositionImgKey[2] == fruitPositionImgKey[4]) &&
        (fruitPositionImgKey[2] == fruitPositionImgKey[6]);
  }

  ///被動式的啟動，物件上面有計時器，會偵測對應數據，而產生運轉與不運轉二種狀態，可增加狀態
  void PlayGame() {
    for (int index = 0; index < fruitPositionIsRunning.length; index++) {
      ///將所有水果盤都跑起來
      fruitPositionIsRunning[index] = 1;
    }
  }

  ///水平線顯示設定
  List<bool> hLine = [
    false, //上水平線
    false, //中水平線
    false, //下水平線
  ];

  ///垂直線顯示設定
  List<bool> vLine = [
    false, //左垂直
    false, //中垂直
    false, //右垂直
  ];

  ///對角線顯示設定
  List<bool> sLine = [
    false, //右上左下
    false, //左上右下
  ];

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

  ///按下開始遊戲按鈕
  bool isPlaying = false;

  ///運轉的最大時間設定
  int runningMaxTimeSecond = 5;
  Timer? timeAppState; //自己不能直接 cancel() 自己?!
  void showGameState() {
    ///定時列出狀態，如果要在類別中，使用變數，解決辦法之一就是設定為靜態變數
    timeAppState =
        Timer.periodic(Duration(seconds: runningMaxTimeSecond + 1), (time) {
      if (fruitPositionImgKey.isNotEmpty) {
        print(
            ' 1>> ${fruitPositionImgKey[0]}   ${fruitPositionImgKey[1]}  ${fruitPositionImgKey[2]}');
        print(
            ' 2>> ${fruitPositionImgKey[3]}   ${fruitPositionImgKey[4]}  ${fruitPositionImgKey[5]}');
        print(
            ' 3>> ${fruitPositionImgKey[6]}   ${fruitPositionImgKey[7]}  ${fruitPositionImgKey[8]}');
      }

      ///執行一次後停止
      timeAppState?.cancel();
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
      fit: BoxFit.fill,
    ),
    Image.asset(
      'assets/fruitimg/fruit02.png',
      semanticLabel: '52',
      key: ValueKey<int>(52),
      fit: BoxFit.fill,
    ),
    Image.asset(
      'assets/fruitimg/fruit03.png',
      semanticLabel: '53',
      key: ValueKey<int>(53),
      fit: BoxFit.fill,
    ),
    Image.asset(
      'assets/fruitimg/fruit04.png',
      semanticLabel: '54',
      key: ValueKey<int>(54),
      fit: BoxFit.fill,
    ),
    Image.asset(
      'assets/fruitimg/fruit05.png',
      semanticLabel: '55',
      key: ValueKey<int>(55),
      fit: BoxFit.fill,
    ),
    Image.asset(
      'assets/fruitimg/fruit06.png',
      semanticLabel: '56',
      key: ValueKey<int>(56),
      fit: BoxFit.fill,
    ),
    Image.asset(
      'assets/fruitimg/fruit07.png',
      semanticLabel: '57',
      key: ValueKey<int>(57),
      fit: BoxFit.fill,
    ),
    Image.asset(
      'assets/fruitimg/fruit08.png',
      semanticLabel: '58',
      key: ValueKey<int>(58),
      fit: BoxFit.fill,
    ),
    Image.asset(
      'assets/fruitimg/fruit09.png',
      semanticLabel: '59',
      key: ValueKey<int>(59),
      fit: BoxFit.fill,
    ),
    Image.asset(
      'assets/fruitimg/fruit10.png',
      semanticLabel: '60',
      key: ValueKey<int>(60),
      fit: BoxFit.fill,
    ),
    Image.asset(
      'assets/fruitimg/fruit11.png',
      semanticLabel: '61',
      key: ValueKey<int>(61),
      fit: BoxFit.fill,
    ),
    Image.asset(
      'assets/fruitimg/fruit12.png',
      semanticLabel: '62',
      key: ValueKey<int>(62),
      fit: BoxFit.fill,
    ),
  ];
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ///PageView 用的控制器
  final homePageViewCR = PageController(initialPage: 0);

  List<bool> isVisiblePage = [true, true, true];

  @override
  void initState() {
    super.initState();
    homePageViewCR.addListener(() {
      // 當頁面改變時，這裡會被調用
      // print("當前頁面: ${homePageViewCR.page}");
      switch (homePageViewCR.page?.round()) {
        case 0.0:
          setState(() {
            isVisiblePage[0] = true;
            isVisiblePage[1] = false;
            isVisiblePage[2] = false;
          });
          print("當前頁面: ${homePageViewCR.page}");
          break;
        case 1.0:
          setState(() {
            isVisiblePage[0] = false;
            isVisiblePage[1] = true;
            isVisiblePage[2] = false;
          });
          print("當前頁面: ${homePageViewCR.page}");
          break;
        case 2.0:
          setState(() {
            isVisiblePage[0] = false;
            isVisiblePage[1] = false;
            isVisiblePage[2] = true;
          });
          print("當前頁面: ${homePageViewCR.page}");
          break;
      }
    });
  }

  @override
  void dispose() {
    homePageViewCR.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
        controller: homePageViewCR,
        scrollDirection: Axis.horizontal,
        children: [
          if (isVisiblePage[0]) MyNineFruitDish() else Text('遊戲畫面'),
          if (isVisiblePage[1])
            Scaffold(
              appBar: AppBar(
                title: Text('下注畫面'),
              ),
              body: Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        print('${homePageViewCR.page?.round()}');
                      },
                      child: Text('測試'))
                ],
              ),
            )
          else
            Text('下注畫面'),
          if (isVisiblePage[2]) Text('遊戲後台') else Text('遊戲後台'),
        ]);
  }
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
