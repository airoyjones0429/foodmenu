import 'package:flutter/material.dart';

import 'dart:async'; //要使用 Timer 要用這個

import 'package:provider/provider.dart';

import 'MyMoney.dart';
import 'MyNineFruitDish.dart';

import 'appState.dart';
import 'betButton.dart'; //使用ChangeNotifier 要用這個

/// 完成下注按鈕 用 Wrap() 來排列，會自動換行
///正在運轉的時候  不能滾動畫面，已處理掉

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int palyerMoney = 0; //初始化玩家目前金額
  int BonusMoney = 0; //初始化中獎金額

  ///PageView 用的控制器
  final homePageViewCR = PageController(initialPage: 0);

  PageStorageBucket bucket1 = PageStorageBucket();
  PageStorageBucket bucket2 = PageStorageBucket();
  PageStorageBucket bucket3 = PageStorageBucket();

  Timer? _timerMyHomePageState;
  Timer? _timerPage2;

  @override
  void initState() {
    super.initState();
    homePageViewCR.addListener(() {
      // 當頁面改變時，這裡會被調用
      print("當前頁面: ${homePageViewCR.page}} ");
    });
  }

  @override
  void dispose() {
    super.dispose();
    homePageViewCR.dispose();
    _timerMyHomePageState?.cancel();
    _timerPage2?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<int> betMoney = appState.betMoney; //取回下注金額
    List<Image> fruitImg = appState.fruitImg; //取回設定的圖片
    List<betButton> betButtonEntity = List<betButton>.generate(12, (index) {
      return betButton(
        key: ValueKey<String>('betButton${index + 1}'),
        betImage: fruitImg[index],
        betMoney: betMoney[index],
      );
    });

    appState.betButtonEntity = betButtonEntity;

    //沒用先備註起來
    // ///讀取狀態並設定線條是否要顯示
    // void ReadGameState() => appState.ReadGameState();

    // ///讓水果開始跑起來
    // void MyPlayGame() => appState.PlayGame();

    // ///清除連線狀態
    // void MyClearLine() => appState.clearLine();

    // ///計算下注後，中獎金額
    // void calculateBonus() => appState.calculateBonus();

    // ///將押注的中獎金額，加總到中獎金額
    // void sumBonus() => appState.sumBonus();

    MyNineFruitDish myNineFD = MyNineFruitDish();

    ///狀態的金額與本地的金額  校正
    void _updateStateMoney() {
      ///AppState 金額小於 HomePage
      ///有按下  下注按鈕
      if (!(appState.palyerMoney is Null)) {
        if (appState.palyerMoney < this.palyerMoney) {
          this.palyerMoney = appState.palyerMoney;
        }
      }
    }

    ///更新金額到目前金額
    void _updateMoney() {
      ///將中獎金額放入暫存區，並開始處理動畫
      ///中獎金額 與中獎暫存區 不能同時有數值
      if (BonusMoney >= appState.BonusMoney) {
        appState.BonusMoney = BonusMoney;
      } else {
        BonusMoney = appState.BonusMoney;
      }

      BonusMoney = appState.BonusMoney;

      if (BonusMoney > 0) {
        if (BonusMoney + palyerMoney >= 999999) {
          setState(() {
            BonusMoney = 0;
            palyerMoney = 999999;
          });
        } else if (BonusMoney > 10000) {
          setState(() {
            BonusMoney -= 10000;
            palyerMoney += 10000;
          });
        } else if (BonusMoney > 1000) {
          setState(() {
            BonusMoney -= 1000;
            palyerMoney += 1000;
          });
        } else if (BonusMoney > 100) {
          setState(() {
            BonusMoney -= 100;
            palyerMoney += 100;
          });
        } else if (BonusMoney > 10) {
          setState(() {
            BonusMoney -= 10;
            palyerMoney += 10;
          });
        } else {
          setState(() {
            BonusMoney--;
            palyerMoney++;
          });
        }
      }
      appState.BonusMoney = BonusMoney;
      appState.palyerMoney = palyerMoney;
      setState(() {});
    }

    ///先關閉，再開啟
    _timerMyHomePageState?.cancel();
    _timerMyHomePageState = Timer.periodic(Duration(seconds: 2), (time) {
      if (homePageViewCR.page?.round() == 1) {
        print('timerMyHome');
        _timerPage2?.cancel();
        _timerPage2 = Timer.periodic(Duration(milliseconds: 200), (time) {
          _updateStateMoney();
          _updateMoney();
        });

        _timerMyHomePageState?.cancel();
      }
    });

    ///ＭＹＨＯＭＥ　ＰＡＧＥ　ＭＹＨＯＭＥ　ＰＡＧＥ　ＭＹＨＯＭＥ　ＰＡＧＥ　ＭＹＨＯＭＥ　ＰＡＧＥ
    ///
    ///
    ///                                        主程式頁面
    ///
    ///
    ///ＭＹＨＯＭＥ　ＰＡＧＥ　ＭＹＨＯＭＥ　ＰＡＧＥ　ＭＹＨＯＭＥ　ＰＡＧＥ　ＭＹＨＯＭＥ　ＰＡＧＥ
    return PageView(
        controller: homePageViewCR,
        scrollDirection: Axis.horizontal,
        children: [
          /// 第一頁
          PageStorage(bucket: bucket1, child: myNineFD),

          /// 第二頁
          PageStorage(
            bucket: bucket2,
            child: Scaffold(
              appBar: AppBar(
                title: Text('下注畫面'),
              ),
              body: LayoutBuilder(builder: (BuildContext context, constraints) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                  width: constraints.maxWidth / 2,
                                  child: MyMoney(
                                      Title: '中獎獎金', Money: BonusMoney)),
                              SizedBox(
                                  width: constraints.maxWidth / 2,
                                  child: MyMoney(
                                      Title: '目前金額', Money: palyerMoney)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  print(
                                      '${homePageViewCR.page?.round()}'); //列印出目前葉面索引值
                                  // _updateMoney();
                                  ///自動將金額載入目前金額
                                },
                                child: Text('測試')),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  BonusMoney += 9999;

                                  print(' ${BonusMoney}');
                                });
                              },
                              child: Text('增加中獎金額'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                for (int index = 0;
                                    index < betMoney.length;
                                    index++) {
                                  appState.betMoney[index] = 10;
                                  appState.palyerMoney -= 10;
                                }

                                ///設定自動執行
                                appState.autoRunningGame = true;

                                homePageViewCR.animateToPage(
                                  0,
                                  duration: Duration(seconds: 2),
                                  curve: Curves.easeInOutBack,
                                );
                              },
                              child: Text('開始遊戲'),
                            ),
                          ],
                        ),
                        Wrap(
                          direction: Axis.horizontal,
                          spacing: 4.0, // gap between adjacent chips
                          runSpacing: 4.0, // gap between lines
                          children: [
                            for (int index = 0; index < 12; index++)
                              GestureDetector(
                                  onTap: () {
                                    print('GestureDetector${index}');
                                  },
                                  child: betButtonEntity[index]),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),

          ///第三頁
          PageStorage(bucket: bucket3, child: Text('遊戲後台')),
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
