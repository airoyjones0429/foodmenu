import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:async';

import 'PageViewImg.dart';
import 'appState.dart'; //Timer

///完整的 九宮格水果盤物件 在這裡整合
// ignore: must_be_immutable
class MyNineFruitDish extends StatefulWidget {
  bool isInitialized;

  MyNineFruitDish({
    super.key,
    this.isInitialized = false,
  });

  @override
  State<MyNineFruitDish> createState() => _MyNineFruitDishState();
}

class _MyNineFruitDishState extends State<MyNineFruitDish> {
  Timer? timePlayGame;
  Timer? timeAutoRunning;
  bool isAuto = false;
  bool isRunning = false;

  @override
  void dispose() {
    super.dispose();
    timePlayGame?.cancel();
    timeAutoRunning?.cancel();
  }

  @override
  void initState() {
    super.initState();

    widget.isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    // List<Image> fruitImg = appState._fruitImg;
    List<PageViewImg> listPageView = appState.listPageView;
    List<bool> hLine = appState.hLine;
    List<bool> vLine = appState.vLine;
    List<bool> sLine = appState.sLine;
    bool isPlaying = appState.isPlaying; //按下開始遊玩為真

    int palyerMoney = appState.palyerMoney; //目前玩家金額
    int BonusMoney = appState.BonusMoney; //中獎金額

    void ReadGameState() => appState.ReadGameState();
    void MyPlayGame() => appState.PlayGame();
    void MyClearLine() => appState.clearLine();
    void calculateBonus() => appState.calculateBonus();

    void sumBonus() => appState.sumBonus();

    void clearBetMoney() => appState.clearBetMoney();

    void testPlay() {
      setState(() {
        ReadGameState();
      });
    }

    ///按下開始遊戲
    void PlayGame() {
      ///清除先前畫的線
      setState(() {
        MyClearLine();
      });

      ///設定目前正在遊戲記號
      isPlaying = true;

      ///設定單一水果盤運轉記號，讓水果盤跑起來
      MyPlayGame();

      ///設定計時器，計時器延遲  設定運轉時間 + 1 秒，並且會自己關閉自己
      timePlayGame = Timer.periodic(
          Duration(seconds: appState.runningMaxTimeSecond + 1), (time) {
        if (isPlaying) {
          ///讀取遊戲執行完的結果
          ReadGameState();

          ///設定為遊戲停止的狀態
          isPlaying = false;

          ///計算獎勵
          calculateBonus();

          ///清除下注金額
          clearBetMoney();

          ///將獎勵加總，將各注的金額加總
          sumBonus();

          ///關閉計時器
          timePlayGame?.cancel();

          ///刷新目前 Widget 狀態
          if (widget.isInitialized) {
            setState(() {});
          }
        }
        // print('test189'); //在外部宣告計時器後，就可以自己關閉自己了
      });
    }

    ///沒有自動運行  而且  要自動運行時  執行
    if (!isAuto && appState.autoRunningGame) {
      isAuto = true; //正在自動運行
      timeAutoRunning = Timer.periodic(Duration(milliseconds: 500), (time) {
        ///若還沒運轉
        if (!isRunning) {
          isRunning = true; //設定正在運轉
          PlayGame();
        }
        timeAutoRunning?.cancel();
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.amber),
                                    text: '目前金額   '),
                                TextSpan(
                                    style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.greenAccent),
                                    text: '${palyerMoney}'),
                                TextSpan(
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.amber),
                                    text: '   中獎金額   '),
                                TextSpan(
                                    style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.greenAccent),
                                    text: '${BonusMoney}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 50,
                          color: Colors.amber, //沒顯示出來，被蓋住了!?
                        ),
                        Container(
                          color: Colors.black, //水果盤背景
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
