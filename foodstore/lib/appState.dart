import 'package:flutter/material.dart';
import 'dart:async';

import 'PageViewImg.dart';

///管理 APP 與使用者的互動狀態，互動時有些 Wigdets 需要有變化，都靠這裡處理
class MyAppState extends ChangeNotifier {
  ///自動執行遊戲
  bool autoRunningGame = false;

  int palyerMoney = 0; //保存目前玩家金額，主要用來扣除下注金額
  int BonusMoney = 0; //保存中獎金額

  bool subPlayerMoney({int money = 1}) {
    ///如果目前金額可以扣除
    if ((palyerMoney! - money) > 0) {
      palyerMoney = palyerMoney! - money;
      return true; //就扣除金額
    }

    print(palyerMoney);

    return false; //沒辦法扣除金額
  }

  ///下注金額清單
  List<int> betMoney = List.filled(12, 0, growable: false);

  ///計算每個圖片出現的次數清單
  List<int> betImageCounter = List.filled(12, 0, growable: false);

  ///計算後的中獎金額清單
  List<int> betBonus = List.filled(12, 0, growable: false);

  ///面板上的基本賠率，出現二個相同時，才算贏，贏的錢為下注的 3 倍，與網路上圖片清單對應位置。
  List<int> pannelOdds = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];

  ///面板上重複圖片的額外的賠率 1   2  3   4  5  6  7   8   9 張相同圖片
  List<double> pannelPOdds = [0, 1, 1.5, 2, 3, 5, 8, 10, 20];

  ///清除中獎次數，這樣才能重新計數，新一輪的開始
  void clearBetImageCounter() {
    for (int index = 0; index < betImageCounter.length; index++) {
      betImageCounter[index] = 0;
    }
  }

  ///將押注中獎金額，加總到中獎金額
  void sumBonus() {
    for (int index = 0; index < betBonus.length; index++) {
      BonusMoney = BonusMoney + betBonus[index];
      betBonus[index] = 0;
    }
  }

  ///清除下注金額
  void clearBetMoney() {
    for (int index = 0; index < betMoney.length; index++) {
      betMoney[index] = 0;
    }
  }

  ///根據下注金額清單，計算中獎獎金清單金額
  void calculateBonus() {
    for (int index = 0; index < betImageCounter.length; index++) {
      ///暫存圖片出現的次數
      int showTimer = betImageCounter[index];

      ///計算中獎金額，並將金額儲存到 priceMoney 中
      betBonus[index] = (showTimer < 2) //沒中獎，只有出現一次
          ? 0
          : (showTimer < 3) //中獎，出現 2 次
              ? (pannelOdds[index] * betMoney[index] * pannelPOdds[1]).toInt()
              : (showTimer < 4) //中獎，出現 3 次
                  ? (pannelOdds[index] * betMoney[index] * pannelPOdds[2])
                      .toInt()
                  : (showTimer < 5) //中獎，出現 4 次
                      ? (pannelOdds[index] * betMoney[index] * pannelPOdds[3])
                          .toInt()
                      : (showTimer < 6) //中獎，出現 5 次
                          ? (pannelOdds[index] *
                                  betMoney[index] *
                                  pannelPOdds[4])
                              .toInt()
                          : (showTimer < 7) //中獎，出現 6 次
                              ? (pannelOdds[index] *
                                      betMoney[index] *
                                      pannelPOdds[5])
                                  .toInt()
                              : (showTimer < 8) //中獎，出現 7 次
                                  ? (pannelOdds[index] *
                                          betMoney[index] *
                                          pannelPOdds[6])
                                      .toInt()
                                  : (showTimer < 9) //中獎，出現 8 次，
                                      ? (pannelOdds[index] *
                                              betMoney[index] *
                                              pannelPOdds[7])
                                          .toInt()
                                      //中獎，出現九次
                                      : (pannelOdds[index] *
                                              betMoney[index] *
                                              pannelPOdds[8])
                                          .toInt();

      ///

      print(
          ' ${index + 51}  ${betImageCounter[index]}  中獎金額為 ${betBonus[index]} ');
    }
  }

  // List<betButton> betButtonEntity = []; //從頁面傳回物件的實體
  List<Widget> betButtonEntity = []; //從頁面傳回物件的實體

  int getbetButtonKeyInt({required Key betKey}) {
    for (int index = 0; index < betButtonEntity.length; index++) {
      if (betButtonEntity[index].key == betKey) {
        return index;
      }
    }
    return 99; //找不到 Key 傳回數值
  }

  ///執行後按下按鈕的下注金額加 上 輸入參數
  void pressbetButton({
    required Key betKey,
    required int addMoney,
  }) {
    for (int index = 0; index < betButtonEntity.length; index++) {
      if (betButtonEntity[index].key == betKey) {
        betMoney[index] += addMoney;
      }
    }
    notifyListeners(); //從狀態管理這，觸發刷新畫面
  }

  ///下注金額，對應圖片位置
  List<int> betfruitPos = List.filled(12, 0, growable: false);

  ///預設水果盤狀態，全都設定為 0
  List<int> fruitPositionImgKey = List.generate(9, (index) {
    return 0;
  });

  ///水果盤亂數狀態，全都設定為 0
  List<int> fruitPositionRandom = List.generate(9, (index) {
    return 0;
  });

  bool isGameRunning = true;

  ///設定相同圖片的連線顯示狀態為不顯示
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

  ///讀取狀態，並且設定那些線條，要被顯示出來
  ///設定圖片出現次數
  void ReadGameState() {
    print(
        '  ${fruitPositionImgKey[0]}   ${fruitPositionImgKey[1]}   ${fruitPositionImgKey[2]}  ');
    print(
        '  ${fruitPositionImgKey[3]}   ${fruitPositionImgKey[4]}   ${fruitPositionImgKey[5]}  ');
    print(
        '  ${fruitPositionImgKey[6]}   ${fruitPositionImgKey[7]}   ${fruitPositionImgKey[8]}  ');

    ///設定圖片 Key 的整數數值
    List<int> imgIntKey = List.generate(12, (index) {
      return 51 + index;
    });

    ///清除先前圖片出現次數的計算結果
    clearBetImageCounter();

    ///計算圖片出現次數
    for (int index = 0; index < fruitPositionImgKey.length; index++) {
      if (imgIntKey[0] == fruitPositionImgKey[index]) {
        betImageCounter[0]++;
      } else if (imgIntKey[1] == fruitPositionImgKey[index]) {
        betImageCounter[1]++;
      } else if (imgIntKey[2] == fruitPositionImgKey[index]) {
        betImageCounter[2]++;
      } else if (imgIntKey[3] == fruitPositionImgKey[index]) {
        betImageCounter[3]++;
      } else if (imgIntKey[4] == fruitPositionImgKey[index]) {
        betImageCounter[4]++;
      } else if (imgIntKey[5] == fruitPositionImgKey[index]) {
        betImageCounter[5]++;
      } else if (imgIntKey[6] == fruitPositionImgKey[index]) {
        betImageCounter[6]++;
      } else if (imgIntKey[7] == fruitPositionImgKey[index]) {
        betImageCounter[7]++;
      } else if (imgIntKey[8] == fruitPositionImgKey[index]) {
        betImageCounter[8]++;
      } else if (imgIntKey[9] == fruitPositionImgKey[index]) {
        betImageCounter[9]++;
      } else if (imgIntKey[10] == fruitPositionImgKey[index]) {
        betImageCounter[10]++;
      } else if (imgIntKey[11] == fruitPositionImgKey[index]) {
        betImageCounter[11]++;
      }
    }

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

  ///取回PageView  Key 的對應 int 數值
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
    if (fruitImg[0].key == key) {
      //51
      return 51;
    } else if (fruitImg[1].key == key) {
      //52
      return 52;
    } else if (fruitImg[2].key == key) {
      //53
      return 53;
    } else if (fruitImg[3].key == key) {
      //54
      return 54;
    } else if (fruitImg[4].key == key) {
      //55
      return 55;
    } else if (fruitImg[5].key == key) {
      //56
      return 56;
    } else if (fruitImg[6].key == key) {
      //57
      return 57;
    } else if (fruitImg[7].key == key) {
      //58
      return 58;
    } else if (fruitImg[8].key == key) {
      //59
      return 59;
    } else if (fruitImg[9].key == key) {
      //60
      return 60;
    } else if (fruitImg[10].key == key) {
      //61
      return 61;
    } else if (fruitImg[11].key == key) {
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
  final List<Image> fruitImg = [
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
