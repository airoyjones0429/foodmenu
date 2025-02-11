import 'package:flutter/material.dart';

/// main4.dart => Emain.dart
/// 1140211
/// 1.用 Stack() 堆疊設置，讓佈件重疊再一起
/// 2.圖片上用 Container 劃一條線，當作成功連線

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double angleA1 = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("在圖片上放置橫線")),
        body: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ///徑度角 1.57  = 3.14 / 2 = 90 度
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        angleA1 += 0.01;
                        print(angleA1);
                      });
                    },
                    child: Text('增加角度'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        angleA1 -= 0.01;
                        print(angleA1);
                      });
                    },
                    child: Text('減少角度'),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 64,
                          ),
                          Image.network(
                            'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit02.png?raw=true',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                          Image.network(
                            'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit02.png?raw=true',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                          Image.network(
                            'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit02.png?raw=true',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(
                            width: 64,
                          ),
                        ],
                      ),

                      ///第 二 個 ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 64,
                          ),
                          Image.network(
                            'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit02.png?raw=true',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                          Image.network(
                            'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit02.png?raw=true',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                          Image.network(
                            'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit02.png?raw=true',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(
                            width: 64,
                          ),
                        ],
                      ),

                      ///第三個 ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 64,
                          ),
                          Image.network(
                            'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit02.png?raw=true',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                          Image.network(
                            'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit02.png?raw=true',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                          Image.network(
                            'https://github.com/airoyjones0429/foodmenu/blob/main/fruitimg/fruit02.png?raw=true',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(
                            width: 64,
                          ),
                        ],
                      ),
                    ],
                  ),

                  ///三條水平線
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 300,
                        height: 2, // 橫線的高度
                        color: Colors.red, // 橫線的顏色
                      ),
                      SizedBox(
                        height: 64,
                      ),
                      Container(
                        width: 300,
                        height: 2, // 橫線的高度
                        color: Colors.red, // 橫線的顏色
                      ),
                      SizedBox(
                        height: 64,
                      ),
                      Container(
                        width: 300,
                        height: 2, // 橫線的高度
                        color: Colors.red, // 橫線的顏色
                      ),
                    ],
                  ),

                  /// X 斜線
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 64,
                      ),
                      Transform.rotate(
                        angle: 0.666,
                        child: Container(
                          width: 300,
                          height: 2, // 橫線的高度
                          color: Colors.indigo, // 橫線的顏色
                        ),
                      ),
                      Transform.rotate(
                        angle: -0.666,
                        child: Container(
                          width: 300,
                          height: 2, // 橫線的高度
                          color: Colors.indigo, // 橫線的顏色
                        ),
                      ),
                      SizedBox(
                        height: 64,
                      ),
                    ],
                  ),

                  /// 計算角度使用
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.rotate(
                        angle: angleA1,
                        child: Container(
                          width: 300,
                          height: 2, // 橫線的高度
                          color: Colors.amber, // 橫線的顏色
                        ),
                      ),
                    ],
                  ),

                  /// 垂直線 1 2 3 的順序  要用 ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 108,
                      ),
                      Container(
                        width: 2,
                        height: 300, // 橫線的高度
                        color: Colors.amber, // 橫線的顏色
                      ),
                      SizedBox(
                        width: 64,
                      ),
                      Container(
                        width: 2,
                        height: 300, // 橫線的高度
                        color: Colors.black, // 橫線的顏色
                      ),
                      SizedBox(
                        width: 64,
                      ),
                      Container(
                        width: 2,
                        height: 300, // 橫線的高度
                        color: Colors.black, // 橫線的顏色
                      ),
                      SizedBox(
                        width: 108,
                      ),
                    ],
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
