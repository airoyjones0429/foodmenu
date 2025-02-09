import 'dart:ffi';

import 'dart:math'; // 使用亂數時要引用這個

import 'package:flutter/material.dart';

import 'dart:io';

import 'dart:async'; //要使用 Timer 要用這個

import 'package:http/http.dart' as http; // http LIB

import 'package:path_provider/path_provider.dart'; // path_provider LIB

/// main.dart
/// 1140208 修改項目
/// 0.增加註解，產生另一個 main.dart
/// 1.從遠端下載圖片到本地端，並顯示在 APP 上
/// 2.處理切換圖片會發生延遲的問題，因為圖片先前還沒下載過，所造成的
/// 3.處理設定圖片 Key 時，會發生重複的 Key 的錯誤，不可以把初始化放
///   在 Wedgit build 下面，會造成每次重繪物件時 (setState)，都會初
///   始化一次，載入圖片時，有用到 precacheImage ，所以沒辦法放在
///   initState() 初始化，我是用二層 statefulWidget ，一層保存圖片，
///   一層負責變化。
/// 4.用 Timer 自動定時處理按下按鈕程序，這樣就會自動切換圖片
/// 5.用 Ramdom 隨機取回圖片，圖片切換時，才不會維持固定順序變化
///
/// 想完成但未完成的項目如下：
/// .切換圖片時，可以有過場動畫，要用 AnimatedSwitcher
/// .增加遊玩的感覺，要可以下注，得到分數
/// .相同圖片或規則時，圖片可以將圖片連線
///
///

void main() {
  runApp(MyApp());
}

///===========================================
///=====================================
///============================
///
///   上層的 StatefulWidget
///
///============================
///=====================================
///============================================
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// 計時器物件的宣告
  Timer? _timer1;
  int _counterTimer1 = 0; //計時器計數用

  /// 不同位置給不同的影像清單的索引
  int oImgIndex = 0; //第一個位置
  int ooImgIndex = 0; //第二個位置
  int oooImgIndex = 0; //第三個位置

  ///影像清單，圖片本生就是 Widget，可以直接放在任何 child 或 children 中
  List<Image> gitHubImg = [];

  ///影像的網路位址，這裡使用 github 的位址，所以圖片必須設定為公開的
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

  ///之後，用來產生動態效果，會用到的邏輯
  static int _keyCounter = 0; // 靜態變數來追踪鍵值
  int _getNextKey() {
    return _keyCounter++; // 返回當前鍵值，然後遞增
  }

  /// 當程式關閉時，會觸發這個程序
  @override
  void dispose() {
    _timer1?.cancel(); //取消計時器
    super.dispose();
  }

  ///計時器所要執行的排程工作，名稱可以自己修改
  void _executeTask() {
    Random random = Random(); //產生亂數
    oImgIndex = random.nextInt(imageUrls.length); // 生成隨機索引
    ooImgIndex = random.nextInt(imageUrls.length); // 生成隨機索引
    oooImgIndex = random.nextInt(imageUrls.length); // 生成隨機索引
    _counterTimer1++;

    //計時器自動停止
    print(_counterTimer1);
    if (_counterTimer1 >= 50) {
      _counterTimer1 = 0;
      _timer1!.cancel();
    }

    setState(() {}); //刷新畫面
  }

  ///載入圖片到清單中
  ///這是非同步函數，當沒有使用 precacheImage 時
  ///圖片切換時，會發生延遲，有很多方式處理
  ///這裡練習使用 precacheImage
  /// async  await 是搭配使用的，不一定要有 await，但效果不一樣
  Future<void> preloadImages() async {
    for (String url in imageUrls) {
      final image = Image.network(
        url,
        fit: BoxFit.cover,
      );
      gitHubImg.add(image);

      // 這裡可以使用 `await precacheImage` 來確保圖片被緩存
      await precacheImage(NetworkImage(url), context);
    }

    setState(() {}); //載入資料後，用來刷新畫面
  }

  /// 主要佈件的重繪程序
  @override
  Widget build(BuildContext context) {
    print('Test'); //用來測試上層被重繪的次數與時機

    /// MaterialApp 只能在根，沒記錯的話，只能有一個
    /// 所以後面都使用，Scaffold
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("顯示 Git Hub 上的圖片"),
        ),
        body: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// 一開始清單中沒有資料，避免發生錯誤
                  /// 所以在產生佈件時，使用類似 if 運算式的
                  /// ( 條件式 ) ? (條件為真執行這裡) : (條件為假執行這裡)
                  gitHubImg.isEmpty ? Text('下載資料中') : gitHubImg[oImgIndex],
                  gitHubImg.isEmpty ? Text('下載資料中') : gitHubImg[ooImgIndex],
                  gitHubImg.isEmpty ? Text('下載資料中') : gitHubImg[oooImgIndex],
                ],
              ),

              ///讓二個佈件不要靠得太近，用一個填位的佈件
              SizedBox(
                height: 20,
              ),

              ///這式按鈕佈件
              ///裡面有計時器的使用方法
              ElevatedButton(
                  onPressed: () {
                    _timer1 =
                        Timer.periodic(Duration(milliseconds: 250), (timer) {
                      _executeTask();
                    });
                  },
                  child: Text('隨機抽一張卡')),

              ///手動把圖片，全部載入
              ///可以設上層式登入畫面
              ///等待圖片都載入後，才跳到下一層去
              ElevatedButton(
                  onPressed: () {
                    preloadImages();
                  },
                  child: Text('載入圖片資料')),

              ///把下層的佈件，放在這裡並不是好辦法
              ///目前未保持程式的簡潔
              ///先放在這裡
              ///Expanded 佈件，內部可以放會動態變動尺寸的佈件
              Expanded(
                child: MyFruits(
                  gitHubImg: gitHubImg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///===========================================
///=====================================
///============================
///
///   下層的 StatefulWidget
///
///============================
///=====================================
///============================================

class MyFruits extends StatefulWidget {
  /// 宣告一個可為 Null 的影像清單，用來接收上層的 gitHubImg 清單內容
  /// 名稱是可以改變的
  final List<Image>? gitHubImg;

  /// 這個布建建構函數
  const MyFruits({
    super.key,
    this.gitHubImg, //名稱必須要對應到上面宣告區的變數
  });

  @override
  State<MyFruits> createState() => _MyFruitsState();
}

class _MyFruitsState extends State<MyFruits> {
  ///從上層複製過來的變數，之後會刪除
  int oImgIndex = 0;
  int ooImgIndex = 0;
  int oooImgIndex = 0;

  ///用來產生不同的圖片的二維陣列索引
  ///像是  水果盤連線遊戲
  ///陣列索引為從 0 開始為第一個元素
  List<List<int>> fruitDish = [
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0]
  ];

  ///產生一個計時器，與控制計時器自動停止的計數器
  Timer? _timer1;
  int _counterTimer1 = 0;

  void _executeTask() {
    Random random = Random(); //產生亂數
    int indexSeed = widget.gitHubImg!.length; //設定亂數最大值不超過清單長度

    //刷新畫面
    setState(() {
      oImgIndex = random.nextInt(indexSeed); // 生成隨機索引
      ooImgIndex = random.nextInt(indexSeed); // 生成隨機索引
      oooImgIndex = random.nextInt(indexSeed); // 生成隨機索引
      fruitDish[0][0] = random.nextInt(indexSeed); // 生成隨機索引
      fruitDish[0][1] = random.nextInt(indexSeed); // 生成隨機索引
      fruitDish[0][2] = random.nextInt(indexSeed); // 生成隨機索引
      fruitDish[1][0] = random.nextInt(indexSeed); // 生成隨機索引
      fruitDish[1][1] = random.nextInt(indexSeed); // 生成隨機索引
      fruitDish[1][2] = random.nextInt(indexSeed); // 生成隨機索引
      fruitDish[2][0] = random.nextInt(indexSeed); // 生成隨機索引
      fruitDish[2][1] = random.nextInt(indexSeed); // 生成隨機索引
      fruitDish[2][2] = random.nextInt(indexSeed); // 生成隨機索引

      _counterTimer1++; //累計變化的次數
    });

    print(_counterTimer1); //在終端機檢視變化次數

    //計時器自動停止
    if (_counterTimer1 >= 50) {
      _counterTimer1 = 0;
      _timer1!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        ///因為 Plaseholder 如果沒有被 Column Row 包起來，會有一個方向是最大值
        ///而不會是設定的大小
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ///如果要使用建構子中的參數，就要用小寫的 widgit
                /// widgit 就代表目前這個佈件
                ///  . 代表  的
                /// gitHubImg  什麼  變數名稱
                /// gitHubImg! 代表這個變數，保證不是 NULL，如果是就出錯誤
                widget.gitHubImg!.isEmpty
                    ? Placeholder(
                        fallbackHeight: 64,
                        fallbackWidth: 64,
                      )
                    : widget.gitHubImg![fruitDish[0][0]],
                widget.gitHubImg!.isEmpty
                    ? Placeholder(
                        fallbackHeight: 64,
                        fallbackWidth: 64,
                      )
                    : widget.gitHubImg![fruitDish[0][1]],
                widget.gitHubImg!.isEmpty
                    ? Placeholder(
                        fallbackHeight: 64,
                        fallbackWidth: 64,
                      )
                    : widget.gitHubImg![fruitDish[0][2]],
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.gitHubImg!.isEmpty
                    ? Placeholder(
                        fallbackHeight: 64,
                        fallbackWidth: 64,
                      )
                    : widget.gitHubImg![fruitDish[1][0]],
                widget.gitHubImg!.isEmpty
                    ? Placeholder(
                        fallbackHeight: 64,
                        fallbackWidth: 64,
                      )
                    : widget.gitHubImg![fruitDish[1][1]],
                widget.gitHubImg!.isEmpty
                    ? Placeholder(
                        fallbackHeight: 64,
                        fallbackWidth: 64,
                      )
                    : widget.gitHubImg![fruitDish[1][2]],
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.gitHubImg!.isEmpty
                    ? Placeholder(
                        fallbackHeight: 64,
                        fallbackWidth: 64,
                      )
                    : widget.gitHubImg![fruitDish[2][0]],
                widget.gitHubImg!.isEmpty
                    ? Placeholder(
                        fallbackHeight: 64,
                        fallbackWidth: 64,
                      )
                    : widget.gitHubImg![fruitDish[2][1]],
                widget.gitHubImg!.isEmpty
                    ? Placeholder(
                        fallbackHeight: 64,
                        fallbackWidth: 64,
                      )
                    : widget.gitHubImg![fruitDish[2][2]],
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  // 每 100 毫秒執行一次 _executeTask 方法
                  _timer1 =
                      Timer.periodic(Duration(milliseconds: 100), (timer) {
                    _executeTask();
                  });
                },
                child: Text('運轉')),
          ],
        ),
      ),
    );
  }
}

/// 因為一開始不想把檔案分開的太分散，這樣不好學習
/// 另外開一個檔案把這裡指令複製過去，在那邊修改
/// 是我目前控制版本的方式
