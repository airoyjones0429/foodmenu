import 'package:flutter/material.dart';
import 'dart:math'; // 使用亂數時要引用這個
import 'dart:async'; //要使用 Timer 要用這個

/// main7.dart => Hmain.dart
/// 1140211
/// 1.將圖片清單宣告成全域，還有一些相關的，也宣告成全域變數
///   很偷懶的方法，會減少傳遞參數的步驟
/// 2.規劃計算金額的介面，設定計算獎金的倍率
/// 3.原本要使用 Global Key 的方式，刷新畫面，遇到指令沒執行也沒錯誤的問題
///   該部分先保留，之後，有機會再另外練習
/// 4.把 MyApp 改成能儲存狀態的 StatefulWidget
/// 5.把 MyApp 改為用 清單的方式來顯示頁面

/// GlobalKey 放到外也沒辦法成功使用，真的要另外再試了
final GlobalKey<_playTopPannel> playTopPannel = GlobalKey<_playTopPannel>();

///下載的影像清單，這次把它移到外部，減少狀態控制，傳遞參數
List<Image> _listImg = [];
double downloadProgress = 0.0; // 下載進度

bool isLoading = true; // 用來判斷是否正在加載
bool isPlaying = false; // 是否正在遊戲中 true 正在運轉，false 沒有在玩

///==============================================================以下
///增加金額程序與變數

int currentMoney = 0; //目前的錢
int bonusMoney = 0; // 中獎的錢
//面板上下注的錢
List<int> pannelMoney = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

///面板上的基本賠率，出現二個相同時，才算贏，贏的錢為下注的 3 倍
List<int> pannelOdds = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];

///面板上重複圖片的賠率       1  2   3   4  5  6  7  8   9 張相同圖片
List<double> pannelPOdds = [0, 1, 1.5, 2, 3, 5, 8, 10, 20];

///因下注而獲得的金額，儲存在這裡
List<int> priceMoney = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

///==========================================
///
///
///               上方面板佈件
///
///
///=========================================
class PlayTopPanel extends StatefulWidget {
  final String uniqueId; // 用來生成唯一 Key 的值
  //設定為 Global Key
  //嘗試在程式執行在穩定的狀態下，看可不可以用這個方法
  //如果 Widget 被捲動到看不到，在出現時才會改變
  PlayTopPanel({
    Key? key, //將父類別設定的 key 內容，設定給目前的 Widget --- 2
    required this.uniqueId,
  }) : super(key: ValueKey(uniqueId)); //設定繼承父類別的 key 值 --- 1
  @override
  State<PlayTopPanel> createState() => _playTopPannel();
}

class _playTopPannel extends State<PlayTopPanel> {
  Timer? _timer1;
  Timer? _timer2;

  @override
  void dispose() {
    super.dispose();
    _timer1?.cancel();
    _timer2?.cancel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    ///定時檢查有沒有獎勵金，如果有 就動態加錢
    _timer2 = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _updateTopPanelMoney();
    });
  }

  void _updateTopPanelMoney() {
    _timer1 = Timer.periodic(
        Duration(milliseconds: 50),
        (timer) => setState(() {
              if (bonusMoney > 0) {
                currentMoney++;
                bonusMoney--;
              } else {
                timer.cancel();
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal, //這裡要設定，不然會 Layout 錯誤
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentMoney += 10;
                    // bonusMoney++;
                  });
                },
                child: Text('增加金幣'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentMoney--;
                    // bonusMoney--;
                  });
                },
                child: Text('減少金幣'),
              ),
              ElevatedButton(
                onPressed: () {
                  _updateTopPanelMoney();
                },
                child: Text('獎勵金額輸入'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('刷新狀態'),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('目前金額'),
            SizedBox(
              width: 50,
              child: AnimatedSwitcher(
                duration: Duration(
                  milliseconds: 300,
                ),
                child: Text(
                  style: TextStyle(
                    fontSize: 24,
                  ),
                  '${currentMoney}',
                  key: ValueKey<int>(currentMoney),
                ),
              ),
            ),
            Text('中獎金額'),
            SizedBox(
              width: 50,
              child: AnimatedSwitcher(
                duration: Duration(
                  milliseconds: 200,
                ),
                child: Text(
                  style: TextStyle(
                    fontSize: 24,
                  ),
                  '${bonusMoney}',
                  key: ValueKey<int>(bonusMoney),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

///==========================================================
///
///
///         下方下注按鈕 控制面板
///
///
///==========================================================
class PlayButtonPanel extends StatefulWidget {
  ///用 Global Key 讓刷新圖片的 Widget 也刷新這個 Widget 狀態
  ///flutter 官方不建議使用  用不好  程式並不容易維護
  ///要被動刷新的宣告下面那行指令
  PlayButtonPanel({Key? key}) : super(key: key);

  @override
  State<PlayButtonPanel> createState() => _PlayBottonPanelState();
}

class _PlayBottonPanelState extends State<PlayButtonPanel> {
  ///因為沒辦法用另外一個 Widget 觸發這個 Widget 更新狀態 (或說更新畫面)
  ///就改使用計時器定時看來處理刷新圖片的狀態
  Timer? _timerUpdateButton;
  Timer? _timerUpdateButtonMoney;

  ///這個事件會在 initState() 之後發生
  ///因為 iniState() 中不能初始化 Widget 狀態
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timerUpdateButton = Timer.periodic(Duration(milliseconds: 500), (time) {
      if (!isLoading) {
        updateState(); //刷新畫面後，就釋放計時器
        _timerUpdateButton?.cancel();
      }
    });

    _timerUpdateButtonMoney =
        Timer.periodic(Duration(milliseconds: 500), (time) {
      setState(() {
        // print('Test207');
      });
    });
  }

  @override
  void dispose() {
    _timerUpdateButton?.cancel();
    _timerUpdateButtonMoney?.cancel();
    super.dispose();
  }

  ///更新狀態
  void updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 80,
              child: SingleChildScrollView(
                //包住 ROW 就是水平卷軸
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ///下注按鈕區
                    ///按下第  1 個按鈕
                    ElevatedButton.icon(
                      label: Text(
                        '${pannelMoney[0]}',
                      ),
                      icon: SizedBox(
                          width: 32,
                          child: !isLoading ? _listImg[0] : Placeholder()),
                      onPressed: () {
                        setState(() {
                          if (currentMoney > 0) {
                            pannelMoney[0]++;
                            currentMoney--;
                          }

                          ///下面為使用 Global Key 的方法，因為沒用所以註解掉
                          // print(playTopPannel.currentState?.mounted);
                          // playTopPannel.currentState?.setState(() {});
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          if (currentMoney - 10 > 0) {
                            pannelMoney[0] += 10;
                            currentMoney -= 10;
                          } else if (currentMoney > 0) {
                            pannelMoney[0] += currentMoney;
                            currentMoney = 0;
                          }
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      label: Text(
                        '${pannelMoney[1]}',
                      ),
                      icon: SizedBox(
                          width: 32,
                          child: !isLoading ? _listImg[1] : Placeholder()),
                      onPressed: () {
                        setState(() {
                          if (currentMoney > 0) {
                            pannelMoney[1]++;
                            currentMoney--;
                          }
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          if (currentMoney - 10 > 0) {
                            pannelMoney[1] += 10;
                            currentMoney -= 10;
                          } else if (currentMoney > 0) {
                            pannelMoney[1] += currentMoney;
                            currentMoney = 0;
                          }
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      label: Text(
                        '${pannelMoney[2]}',
                      ),
                      icon: SizedBox(
                          width: 32,
                          child: !isLoading ? _listImg[2] : Placeholder()),
                      onPressed: () {
                        setState(() {
                          if (currentMoney > 0) {
                            pannelMoney[2]++;
                            currentMoney--;
                          }
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          if (currentMoney - 10 > 0) {
                            pannelMoney[2] += 10;
                            currentMoney -= 10;
                          } else if (currentMoney > 0) {
                            pannelMoney[2] += currentMoney;
                            currentMoney = 0;
                          }
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      label: Text(
                        '${pannelMoney[3]}',
                      ),
                      icon: SizedBox(
                          width: 32,
                          child: !isLoading ? _listImg[3] : Placeholder()),
                      onPressed: () {
                        setState(() {
                          if (currentMoney > 0) {
                            pannelMoney[3]++;
                            currentMoney--;
                          }
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          if (currentMoney - 10 > 0) {
                            pannelMoney[3] += 10;
                            currentMoney -= 10;
                          } else if (currentMoney > 0) {
                            pannelMoney[3] += currentMoney;
                            currentMoney = 0;
                          }
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      label: Text(
                        '${pannelMoney[4]}',
                      ),
                      icon: SizedBox(
                          width: 32,
                          child: !isLoading ? _listImg[4] : Placeholder()),
                      onPressed: () {
                        setState(() {
                          if (currentMoney > 0) {
                            pannelMoney[4]++;
                            currentMoney--;
                          }
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          if (currentMoney - 10 > 0) {
                            pannelMoney[4] += 10;
                            currentMoney -= 10;
                          } else if (currentMoney > 0) {
                            pannelMoney[4] += currentMoney;
                            currentMoney = 0;
                          }
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      label: Text(
                        '${pannelMoney[5]}',
                      ),
                      icon: SizedBox(
                          width: 32,
                          child: !isLoading ? _listImg[5] : Placeholder()),
                      onLongPress: () {
                        setState(() {
                          if (currentMoney - 10 > 0) {
                            pannelMoney[5] += 10;
                            currentMoney -= 10;
                          } else if (currentMoney > 0) {
                            pannelMoney[5] += currentMoney;
                            currentMoney = 0;
                          }
                        });
                      },
                      onPressed: () {
                        setState(() {
                          if (currentMoney > 0) {
                            pannelMoney[5]++;
                            currentMoney--;
                          }
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      label: Text(
                        '${pannelMoney[6]}',
                      ),
                      icon: SizedBox(
                          width: 32,
                          child: !isLoading ? _listImg[6] : Placeholder()),
                      onPressed: () {
                        setState(() {
                          if (currentMoney > 0) {
                            pannelMoney[6]++;
                            currentMoney--;
                          }
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          if (currentMoney - 10 > 0) {
                            pannelMoney[6] += 10;
                            currentMoney -= 10;
                          } else if (currentMoney > 0) {
                            pannelMoney[6] += currentMoney;
                            currentMoney = 0;
                          }
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      label: Text(
                        '${pannelMoney[7]}',
                      ),
                      icon: SizedBox(
                          width: 32,
                          child: !isLoading ? _listImg[7] : Placeholder()),
                      onPressed: () {
                        setState(() {
                          if (currentMoney > 0) {
                            pannelMoney[7]++;
                            currentMoney--;
                          }
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          if (currentMoney - 10 > 0) {
                            pannelMoney[7] += 10;
                            currentMoney -= 10;
                          } else if (currentMoney > 0) {
                            pannelMoney[7] += currentMoney;
                            currentMoney = 0;
                          }
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      label: Text(
                        '${pannelMoney[8]}',
                      ),
                      icon: SizedBox(
                          width: 32,
                          child: !isLoading ? _listImg[8] : Placeholder()),
                      onPressed: () {
                        setState(() {
                          if (currentMoney > 0) {
                            pannelMoney[8]++;
                            currentMoney--;
                          }
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          if (currentMoney - 10 > 0) {
                            pannelMoney[8] += 10;
                            currentMoney -= 10;
                          } else if (currentMoney > 0) {
                            pannelMoney[8] += currentMoney;
                            currentMoney = 0;
                          }
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      label: Text(
                        '${pannelMoney[9]}',
                      ),
                      icon: SizedBox(
                          width: 32,
                          child: !isLoading ? _listImg[9] : Placeholder()),
                      onPressed: () {
                        setState(() {
                          if (currentMoney > 0) {
                            pannelMoney[9]++;
                            currentMoney--;
                          }
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          if (currentMoney - 10 > 0) {
                            pannelMoney[9] += 10;
                            currentMoney -= 10;
                          } else if (currentMoney > 0) {
                            pannelMoney[9] += currentMoney;
                            currentMoney = 0;
                          }
                        });
                      },
                    ),

                    ElevatedButton.icon(
                      label: Text(
                        '${pannelMoney[10]}',
                      ),
                      icon: SizedBox(
                          width: 32,
                          child: !isLoading ? _listImg[10] : Placeholder()),
                      onPressed: () {
                        setState(() {
                          if (currentMoney > 0) {
                            pannelMoney[10]++;
                            currentMoney--;
                          }
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          if (currentMoney - 10 > 0) {
                            pannelMoney[10] += 10;
                            currentMoney -= 10;
                          } else if (currentMoney > 0) {
                            pannelMoney[10] += currentMoney;
                            currentMoney = 0;
                          }
                        });
                      },
                    ),

                    ElevatedButton.icon(
                      label: Text(
                        '${pannelMoney[11]}',
                      ),
                      icon: SizedBox(
                          width: 32,
                          child: !isLoading ? _listImg[11] : Placeholder()),
                      onPressed: () {
                        setState(() {
                          if (currentMoney > 0) {
                            pannelMoney[11]++;
                            currentMoney--;
                          }
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          if (currentMoney - 10 > 0) {
                            pannelMoney[11] += 10;
                            currentMoney -= 10;
                          } else if (currentMoney > 0) {
                            pannelMoney[11] += currentMoney;
                            currentMoney = 0;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton.icon(
              label: Text(
                '刷新按鈕',
              ),
              icon: SizedBox(height: 32, width: 32, child: Placeholder()),
              onPressed: () {
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}

///增加金額程序與變數
///================================================================以上

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("水果拼盤遊戲")),

        ///把遊戲放到 ListView 中
        ///因為 ImageSwitcher 大小是會變化的
        ///必須要用 SizeBox 限制大小，沒限制會出現錯誤
        body: ListView(
          children: [
            PlayTopPanel(
              uniqueId: 'myPlayTopPanel',
            ),
            SizedBox(
              height: 400,
              // width: 400,
              child: ImageSwitcher(),
            ),
            PlayButtonPanel(),
          ],
        ),
      ),
    );
  }
}

///=====================================================================
///=====================================================================
///=====================================================================
///=====================================================================
///
/// 水果盤的主要 Widget
///
///=====================================================================
///=====================================================================
///=====================================================================
///=====================================================================
class ImageSwitcher extends StatefulWidget {
  @override
  _ImageSwitcherState createState() => _ImageSwitcherState();
}

class _ImageSwitcherState extends State<ImageSwitcher> {
  //Global Key PlayButtonPanel
  final GlobalKey<_PlayBottonPanelState> playButtonPanel =
      GlobalKey<_PlayBottonPanelState>();

  ///可以改成圖片清單
  Image? _currentImg1;
  Image? _currentImg2;
  Image? _currentImg3;
  Image? _currentImg4;
  Image? _currentImg5;
  Image? _currentImg6;
  Image? _currentImg7;
  Image? _currentImg8;
  Image? _currentImg9;

  ///想縮短程式碼，時增加
  ///減少重複的 GestureDetector 與 onTap()
  Widget? MytouchImg1;
  Widget? MytouchImg2;
  Widget? MytouchImg3;
  Widget? MytouchImg4;
  Widget? MytouchImg5;
  Widget? MytouchImg6;
  Widget? MytouchImg7;
  Widget? MytouchImg8;
  Widget? MytouchImg9;

  List<bool> hLine = [false, false, false]; //上中下水平線，是否要畫出
  List<bool> vLine = [false, false, false]; //左中右垂直線，是否要畫出
  List<bool> sLine = [false, false]; //左上右下、右上左下，使否要畫出

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

  /// 計時器物件的宣告
  Timer? _timerFruitDish;
  int _counterTimer1 = 0; //計時器計數用

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    preloadImages(); //載入圖片
  }

  ///按下圖片或是按下按鈕，就會更換圖片
  Image _toggleImage({Image? Img}) {
    Random random = Random();
    int currentImageIndex = random.nextInt(_listImg.length);

    ///當亂數取回的 Key 與目前圖片相同，就在取一次亂數
    while (Img!.key == _listImg[currentImageIndex].key) {
      currentImageIndex = random.nextInt(_listImg.length);
    }

    // print(_listImg[currentImageIndex].key);

    return _listImg[currentImageIndex];
  }

  ///載入圖片到清單中
  ///這是非同步函數，當沒有使用 precacheImage 時
  ///圖片切換時，會發生延遲，有很多方式處理
  ///這裡練習使用 precacheImage
  /// async  await 是搭配使用的，不一定要有 await，但效果不一樣
  Future<void> preloadImages() async {
    ///用迴圈從遠端下載圖片，暫存到記憶體中
    for (int i = 0; i < imageUrls.length; i++) {
      final image = Image.network(
        imageUrls[i],
        key: ValueKey<int>(i), //一定要設定，且不能重複，不然沒動態效果
        width: 64,
        height: 64,
        fit: BoxFit.fitWidth,

        ///oxFit.cover：這會保持圖片的比例，並使圖片填滿容器，可能會裁切部分圖片。
        ///BoxFit.contain：這會保持圖片的比例，並使圖片適應容器，可能會留下空白區域。
        ///BoxFit.fill：這會拉伸圖片以完全填滿容器，可能會改變圖片的比例。
      );
      _listImg.add(image);

      // 這裡可以使用 `await precacheImage` 來確保圖片被緩存
      await precacheImage(NetworkImage(imageUrls[i]), context);

      // 更新下載進度
      setState(() {
        downloadProgress = (i + 1) / imageUrls.length;
      });
    }

    setState(() {
      isLoading = false; // 下載完成，不顯示進度條
      _currentImg1 = _listImg.first; //下載完成，顯示第一張圖片
      _currentImg2 = _listImg.first; //下載完成，顯示第一張圖片
      _currentImg3 = _listImg.first; //下載完成，顯示第一張圖片
      _currentImg4 = _listImg.first; //下載完成，顯示第一張圖片
      _currentImg5 = _listImg.first; //下載完成，顯示第一張圖片
      _currentImg6 = _listImg.first; //下載完成，顯示第一張圖片
      _currentImg7 = _listImg.first; //下載完成，顯示第一張圖片
      _currentImg8 = _listImg.first; //下載完成，顯示第一張圖片
      _currentImg9 = _listImg.first; //下載完成，顯示第一張圖片

      ///用 Global Key 來要求執行另一個 Widget 的函數
      ///因為 playButtonPanel.currentState 是 Null 所以沒效果
      ///下次要增加狀態管理，來處理
      playButtonPanel.currentState?.updateState();
    }); //載入資料後，用來刷新畫面
  }

  ///抽卡程序
  void selectImg() {
    _currentImg1 = _toggleImage(Img: _currentImg1);
    _currentImg2 = _toggleImage(Img: _currentImg2);
    _currentImg3 = _toggleImage(Img: _currentImg3);
    _currentImg4 = _toggleImage(Img: _currentImg4);
    _currentImg5 = _toggleImage(Img: _currentImg5);
    _currentImg6 = _toggleImage(Img: _currentImg6);
    _currentImg7 = _toggleImage(Img: _currentImg7);
    _currentImg8 = _toggleImage(Img: _currentImg8);
    _currentImg9 = _toggleImage(Img: _currentImg9);

    setState(() {});

    _counterTimer1++;
    if (_counterTimer1 >= 10) {
      _counterTimer1 = 0;
      _timerFruitDish?.cancel();
      computeMoney(); //當隨機圖片後，計算中獎金額
      drawPriceLine(); //當隨機圖片後，自動化出現來
    }
  }

  ///==================================以下
  ///為了要縮短佈件排列的程序而宣告的部分
  ///
  void _touchImg({Image? touchImg, int? imgPosition}) {
    setState(() {
      switch (imgPosition) {
        case 1:
          _currentImg1 = _toggleImage(Img: touchImg);
          break;
        case 2:
          _currentImg2 = _toggleImage(Img: touchImg);
          break;
        case 3:
          _currentImg3 = _toggleImage(Img: touchImg);
          break;
        case 4:
          _currentImg4 = _toggleImage(Img: touchImg);
          break;
        case 5:
          _currentImg5 = _toggleImage(Img: touchImg);
          break;
        case 6:
          _currentImg6 = _toggleImage(Img: touchImg);
          break;
        case 7:
          _currentImg7 = _toggleImage(Img: touchImg);
          break;
        case 8:
          _currentImg8 = _toggleImage(Img: touchImg);
          break;
        case 9:
          _currentImg9 = _toggleImage(Img: touchImg);
          break;
        default:
          print('發生意外在指令 _touchImg ');
      }
    });
  }

  Widget touchImg({Image? touchImg, int? imgPosition}) {
    return GestureDetector(
      onTap: () {
        _touchImg(touchImg: touchImg, imgPosition: imgPosition);
      },
      child: MyFruitImg(
        myFruitImg: touchImg,
      ),
    );
  }
  //為了要縮短佈件排列的程序而宣告的部分
  //=============================================以上

  ///======================以下
  ///畫出得分的線條
  void drawPriceLine() {
    List<Key?> fruitDish = [
      _currentImg1!.key, //0
      _currentImg2!.key,
      _currentImg3!.key,
      _currentImg4!.key, //3
      _currentImg5!.key,
      _currentImg6!.key,
      _currentImg7!.key, //6
      _currentImg8!.key,
      _currentImg9!.key,
    ];

    ///水平線設定
    hLine[0] = (fruitDish[0] == fruitDish[1]) && (fruitDish[0] == fruitDish[2]);
    hLine[1] = (fruitDish[3] == fruitDish[4]) && (fruitDish[3] == fruitDish[5]);
    hLine[2] = (fruitDish[6] == fruitDish[7]) && (fruitDish[6] == fruitDish[8]);

    ///垂直線設定
    vLine[0] = (fruitDish[0] == fruitDish[3]) && (fruitDish[0] == fruitDish[6]);
    vLine[1] = (fruitDish[1] == fruitDish[4]) && (fruitDish[1] == fruitDish[7]);
    vLine[2] = (fruitDish[2] == fruitDish[5]) && (fruitDish[2] == fruitDish[8]);

    ///斜線設定
    sLine[0] = (fruitDish[0] == fruitDish[4]) && (fruitDish[0] == fruitDish[8]);
    sLine[1] = (fruitDish[2] == fruitDish[4]) && (fruitDish[2] == fruitDish[6]);
  }

  ///畫出得分的線條
  ///======================以上

  ///=======================以下
  ///計算中獎金額
  void computeMoney() {
    int showTimer = 0; //顯示次數
    ///有下注的才計算是否有中獎
    for (int index = 0; index < pannelMoney.length; index++) {
      ///如果金額大於 0 ，就計算是否符合中獎規則
      if (pannelMoney[index] > 0) {
        Key? imgKey = _listImg[index].key; //保存目前下注的圖片Key

        for (Image _currentImg in [
          _currentImg1!,
          _currentImg2!,
          _currentImg3!,
          _currentImg4!,
          _currentImg5!,
          _currentImg6!,
          _currentImg7!,
          _currentImg8!,
          _currentImg9!
        ]) {
          if (imgKey == _currentImg.key) {
            ///下注的圖片KEY 等於 目前在畫面上的圖片 KEY 就加一
            showTimer++;
          }
        }
      }

      ///計算中獎金額，並將金額儲存到 priceMoney 中
      priceMoney[index] = (showTimer < 2) //沒中獎，只有出現一次
          ? 0
          : (showTimer < 3) //中獎，出現 2 次
              ? (pannelOdds[index] * pannelMoney[index] * pannelPOdds[1])
                  .toInt()
              : (showTimer < 4) //中獎，出現 3 次
                  ? (pannelOdds[index] * pannelMoney[index] * pannelPOdds[2])
                      .toInt()
                  : (showTimer < 5) //中獎，出現 4 次
                      ? (pannelOdds[index] *
                              pannelMoney[index] *
                              pannelPOdds[3])
                          .toInt()
                      : (showTimer < 6) //中獎，出現 5 次
                          ? (pannelOdds[index] *
                                  pannelMoney[index] *
                                  pannelPOdds[4])
                              .toInt()
                          : (showTimer < 7) //中獎，出現 6 次
                              ? (pannelOdds[index] *
                                      pannelMoney[index] *
                                      pannelPOdds[5])
                                  .toInt()
                              : (showTimer < 8) //中獎，出現 7 次
                                  ? (pannelOdds[index] *
                                          pannelMoney[index] *
                                          pannelPOdds[6])
                                      .toInt()
                                  : (showTimer < 9) //中獎，出現 8 次，
                                      ? (pannelOdds[index] *
                                              pannelMoney[index] *
                                              pannelPOdds[7])
                                          .toInt()
                                      //中獎，出現九次
                                      : (pannelOdds[index] *
                                              pannelMoney[index] *
                                              pannelPOdds[8])
                                          .toInt();

      ///處理判斷中獎後，清空下注金額
      pannelMoney[index] = 0;

      ///清空出現次數
      showTimer = 0;
    }

    ///將所有中獎的金額加到 bonusMoney 中
    for (int money in priceMoney) {
      bonusMoney += money;
    }
  }

  ///計算中獎金額
  ///=======================以下

  @override
  Widget build(BuildContext context) {
    // print(_listImg.length);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center, //水平置中設定
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center, //垂直置中設定
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 256, // 64 + 64 + 64 圖片高度  +64 讓線條超過圖片
                    width: 256, // 64 + 64 + 64  圖片寬度  +64 讓線條超過圖片
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        /// 顯示進度指示器，如果下載完成，就不會顯示
                        /// 以下水果圖片設定區域 ================================
                        if (isLoading)
                          LinearProgressIndicator(value: downloadProgress),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MytouchImg1 = touchImg(
                                touchImg: _currentImg1, imgPosition: 1),
                            MytouchImg2 = touchImg(
                                touchImg: _currentImg2, imgPosition: 2),
                            MytouchImg3 = touchImg(
                                touchImg: _currentImg3, imgPosition: 3),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MytouchImg4 = touchImg(
                                touchImg: _currentImg4, imgPosition: 4),
                            MytouchImg5 = touchImg(
                                touchImg: _currentImg5, imgPosition: 5),
                            MytouchImg6 = touchImg(
                                touchImg: _currentImg6, imgPosition: 6),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MytouchImg7 = touchImg(
                                touchImg: _currentImg7, imgPosition: 7),
                            MytouchImg8 = touchImg(
                                touchImg: _currentImg8, imgPosition: 8),
                            MytouchImg9 = touchImg(
                                touchImg: _currentImg9, imgPosition: 9),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 以上水果圖片設定區域 =======================================
                  ///以下重疊上面圖片區域，當水平圖片相同時，繪製水平線
                  Column(
                    children: [
                      SizedBox(
                        height: 32,
                      ),
                      if (hLine[0])
                        Container(
                          height: 1,
                          width: 256,
                          color: Colors.red,
                        ),
                      SizedBox(
                        height: 64,
                      ),
                      if (hLine[1])
                        Container(
                          height: 1,
                          width: 256,
                          color: Colors.red,
                        ),
                      SizedBox(
                        height: 64,
                      ),
                      if (hLine[2])
                        Container(
                          height: 1,
                          width: 256,
                          color: Colors.red,
                        ),
                      SizedBox(
                        height: 32,
                      ),
                    ],
                  ),

                  ///當垂直圖片相同時，繪製垂直線
                  ///以下重疊上面區域，當垂直圖片相同時，繪製垂直線
                  Row(
                    children: [
                      SizedBox(
                        width: 32 + 32,
                      ),

                      ///這裡因為只有 1 pixel 看不太出來後面的線位移
                      ///比較好的方式是想畫斜線那樣，要回補空間
                      if (vLine[0])
                        Container(
                          height: 256,
                          width: 1,
                          color: Colors.redAccent,
                        ),
                      SizedBox(
                        width: 64,
                      ),
                      if (vLine[1])
                        Container(
                          height: 256,
                          width: 1,
                          color: Colors.blue,
                        ),
                      SizedBox(
                        width: 64,
                      ),
                      if (vLine[2])
                        Container(
                          height: 256,
                          width: 1,
                          color: Colors.purple,
                        ),
                      SizedBox(
                        width: 32 + 32,
                      ),
                    ],
                  ),

                  ///當對角圖片相同時，繪畫出對角線
                  ///以下重疊上方的區域
                  SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ///對角斜線填空用
                        SizedBox(
                          height: 32,
                        ),

                        ///最上方的水平設置
                        Row(
                          children: [
                            // 因為斜線會占用這裡設定的空間吃掉了，所以註解掉
                            // SizedBox(
                            //   width: 32 - 32,
                            // ),

                            ///左上角斜線
                            if (sLine[0])
                              //為真就是要顯示斜線
                              Transform.rotate(
                                angle: 3.14 / 4,
                                child: Container(
                                  height: 1,
                                  width: 128,
                                  color: Colors.yellow,
                                ),
                              )
                            else
                              //為假，就要填補空缺
                              SizedBox(
                                width: 128,
                              ),

                            // 因為右上斜線佔用了這部分的空間，所以註解這部分
                            // SizedBox(
                            //   width: 64 - 64,
                            // ),

                            ///右上角斜線
                            if (sLine[1])
                              //為真就要畫出斜線
                              Transform.rotate(
                                angle: -3.14 / 4,
                                child: Container(
                                  height: 1,
                                  width: 128,
                                  color: Colors.yellow,
                                ),
                              )
                            else
                              //為假就要填補空間
                              SizedBox(
                                width: 128,
                              ),
                          ],
                        ),

                        ///中間斜線填空用
                        SizedBox(
                          height: 64,
                        ),

                        ///中間的水平設置
                        Row(
                          children: [
                            SizedBox(
                              width: 64,
                            ),

                            ///中間的斜線，因為中間的斜線，必須在同一個位置
                            ///所以使用 Stack() Widget 堆疊放置
                            Stack(children: [
                              ///左上右下的斜線，這部分會跟下部分重疊
                              if (sLine[0])
                                Transform.rotate(
                                  angle: 3.14 / 4,
                                  child: Container(
                                    height: 1,
                                    width: 64,
                                    color: Colors.yellow,
                                  ),
                                ),

                              ///右上左下的斜線，這部分會跟上部分重疊
                              if (sLine[1])
                                Transform.rotate(
                                  angle: -3.14 / 4,
                                  child: Container(
                                    height: 1,
                                    width: 64,
                                    color: Colors.yellow,
                                  ),
                                ),
                            ]),
                            SizedBox(
                              width: 64,
                            ),
                          ],
                        ),

                        ///最下方斜線填位用
                        SizedBox(
                          height: 64,
                        ),
                        Row(
                          children: [
                            if (sLine[1])
                              Transform.rotate(
                                angle: -3.14 / 4,
                                child: Container(
                                  height: 1,
                                  width: 128,
                                  color: Colors.yellow,
                                ),
                              )
                            else
                              SizedBox(
                                width: 128,
                              ),
                            // SizedBox(
                            //   width: 38,
                            // ),
                            if (sLine[0])
                              Transform.rotate(
                                angle: 3.14 / 4,
                                child: Container(
                                  height: 1,
                                  width: 128,
                                  color: Colors.yellow,
                                ),
                              )
                            else
                              SizedBox(
                                width: 128,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 50,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // 每 100 毫秒執行一次 selectImg 方法
                          _timerFruitDish = Timer.periodic(
                            Duration(milliseconds: 100),
                            (timer) {
                              selectImg();
                            },
                          );
                        },
                        child: Text('測試'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // print(_currentImg1!.key);
                          // print(_currentImg2!.key);
                          // print(_currentImg3!.key);
                          // print(_currentImg4!.key);
                          // print(_currentImg5!.key);
                          // print(_currentImg6!.key);
                          // print(_currentImg7!.key);
                          // print(_currentImg8!.key);
                          // print(_currentImg9!.key);
                          // setState(() {});

                          setState(() {
                            computeMoney(); //計算中獎金額
                            drawPriceLine(); //畫出線條
                          });
                        },
                        child: Text('計算分數'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // 每 100 毫秒執行一次 selectImg 方法
                            _timerFruitDish = Timer.periodic(
                              Duration(milliseconds: 100),
                              (timer) {
                                selectImg();
                              },
                            );
                          });
                        },
                        child: Text('開始'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

///用來取代上面指令
///原本五行指令變成一行指令
///因為這個 Widget 佈件本身沒有要儲存的狀態
class MyFruitImg extends StatelessWidget {
  final Widget? myFruitImg;

  const MyFruitImg({
    super.key,
    required this.myFruitImg,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      duration: Duration(milliseconds: 300),
      child: myFruitImg,
    );
  }
}
