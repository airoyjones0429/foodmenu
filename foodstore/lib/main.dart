import 'dart:ffi';

import 'dart:math'; // 使用亂數時要引用這個

import 'package:flutter/material.dart';

import 'dart:io';

import 'dart:async'; //要使用 Timer 要用這個

import 'package:http/http.dart' as http; // http LIB

import 'package:path_provider/path_provider.dart'; // path_provider LIB

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _counterTimer1 = 0;
  Timer? _timer1;

  int oImgIndex = 0;
  int ooImgIndex = 0;
  int oooImgIndex = 0;

  List<Image> gitHubImg = [];
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

  static int _keyCounter = 0; // 靜態變數來追踪鍵值

  int _getNextKey() {
    return _keyCounter++; // 返回當前鍵值，然後遞增
  }

  @override
  void dispose() {
    _timer1?.cancel(); //取消計時器
    super.dispose();
  }

  void _executeTask() {
    Random random = Random();
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

  //載入圖片到清單中
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

    setState(() {
      //載入資料後，用來刷新畫面
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Test');
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
                  gitHubImg.isEmpty ? Text('下載資料中') : gitHubImg[oImgIndex],
                  gitHubImg.isEmpty ? Text('下載資料中') : gitHubImg[ooImgIndex],
                  gitHubImg.isEmpty ? Text('下載資料中') : gitHubImg[oooImgIndex],
                ],
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    // 每 2 秒執行一次 _executeTask 方法
                    _timer1 =
                        Timer.periodic(Duration(milliseconds: 250), (timer) {
                      _executeTask();
                    });
                  },
                  child: Text('隨機抽一張卡')),
              ElevatedButton(
                  onPressed: () {
                    preloadImages();
                  },
                  child: Text('載入圖片資料')),
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

class MyFruits extends StatefulWidget {
  final List<Image>? gitHubImg;

  const MyFruits({
    super.key,
    this.gitHubImg,
  });

  @override
  State<MyFruits> createState() => _MyFruitsState();
}

class _MyFruitsState extends State<MyFruits> {
  int oImgIndex = 0;
  int ooImgIndex = 0;
  int oooImgIndex = 0;

  List<List<int>> fruitDish = [
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0]
  ];

  Timer? _timer1;
  int _counterTimer1 = 0;

  void _executeTask() {
    Random random = Random();
    int indexSeed = widget.gitHubImg!.length;

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

      _counterTimer1++;
    }); //刷新畫面

    //計時器自動停止
    print(_counterTimer1);
    if (_counterTimer1 >= 50) {
      _counterTimer1 = 0;
      _timer1!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                  // 每 2 秒執行一次 _executeTask 方法
                  _timer1 =
                      Timer.periodic(Duration(milliseconds: 100), (timer) {
                    _executeTask();
                  });
                },
                child: Text('隨機抽一張卡')),
          ],
        ),
      ),
    );
  }
}
