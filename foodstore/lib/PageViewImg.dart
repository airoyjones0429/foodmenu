import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; //ChangeNotifierProvider
import 'dart:async'; //Timer
import 'dart:math'; //Random

import 'MyRunFruitsPageView.dart';
import 'appState.dart';

///每一個小格子的動態效果，隨機效果都寫在這裡
class PageViewImg extends StatefulWidget {
  PageViewImg({required super.key});

  @override
  State<PageViewImg> createState() => _PageViewImgState();
}

class _PageViewImgState extends State<PageViewImg> {
  int imgIndex = 0;
  int? myPVindex;

  Timer? timeRun; //設定自動執行程序的計時器

  ///放在外部
  PageController imgPageCR = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PageViewImg oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(' 更新 ${myPVindex}');
  }

  @override
  void dispose() {
    super.dispose();
    print(' 移除 ${myPVindex}');
    timeRun?.cancel();
    imgPageCR.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<Image> fruitImg = appState.fruitImg; //取回設定的圖片
    List<int> fruitPositionImgKey = appState.fruitPositionImgKey;
    List<int> fruitPositionIsRunning = appState.fruitPositionIsRunning;
    List<int> fruitPositionRandom = appState.fruitPositionRandom;

    ///取回這個 PageViewImg 的Key 索引值
    int thisWidgetIntKey = appState.getPVIKeyInt(widget.key);

    myPVindex = thisWidgetIntKey;

    ///設定項目
    const int MaxRunning = 48; //跑動清單的圖片數量，最後一張為中獎圖片
    const bool isVertical = true; //設定為垂直捲動

    ///初始化設定
    Random random = Random();
    // int imgIndex = 0;
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
      // 因為隱藏物件後   再出現一次   會自動回到第一頁
      // imgPageCR.jumpToPage(0); //回到 PageView 第一頁

      // myImg.clear(); //清除照片

      ///隨機取數值
      // imgIndex = random.nextInt(12);

      ///刷新目前數量為 MaxRunning 圖片排列
      ///隨機選取第一張圖片，就會固定決定最後一張照片
      myImg = List.generate(MaxRunning, (index) {
        int imgI = (imgIndex + index) % 12; //循環取圖片
        return fruitImg[imgI];
      });
    }

    ///切換畫面 會發生錯誤  xxxx
    void onTap() {
      ///如果這個 Widget 已經被安裝
      // if (mounted) {

      ///setState() 會因為物件被隱藏在後方 就會將該狀態移除....
      ///雖然重新出現後  直接點擊物件  可以觸發它的功能
      ///但無法用  定時的方式  觸發程序....
      ///無解  所以改用別的方法
      ///不用 setState()  PageView 物件 依然可以自動捲動  MaxRunning

      updateImgList();

      ///從第二頁  切換回來會錯誤  先註解掉
      ///不能註解調  因為在同一頁跑時  需要跳回去
      // print(' imgPageCR.page 是不是 NULL ${imgPageCR.page == null}');

      ///最後在將物件改成 Stateful   用 initState() 控制物件是否初始化的記號
      ///如果物件初始化後  就可以繼續執行
      print(myRunFruitsPageView0.isInitialized);
      if (myRunFruitsPageView0.isInitialized) {
        // if (imgPageCR.page!.round() > 0) {
        if (imgPageCR.positions.length > 0) {
          imgPageCR.jumpTo(0);

          imgPageCR.animateToPage((36 + random.nextInt(12)), //MaxRunning = 48
              duration: Duration(seconds: appState.runningMaxTimeSecond), //動畫速度

              ///這個變化曲線，慢曼加速 中間高速 慢慢減速停止，符合遊戲感覺
              curve: Curves.easeInOutCubic);
        }

        // }
      }

      ///上面的這些  改成用下面處理  因為 上面會發生  類似沒初始化  就使用物件的錯誤
      // if (!_callbackAdded) {
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     // 現在可以安全地訪問 PageController.page
      //     imgPageCR.jumpTo(0);
      //   });
      // } // 用了更慘  正常跑都會邏輯錯誤

      ///同時用二個  animateToPage 只有一次效果

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
