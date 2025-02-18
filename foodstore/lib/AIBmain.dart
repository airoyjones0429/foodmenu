import 'package:flutter/material.dart';

///上層會蓋掉下層
///無法實現  單純的  同步觸發
///下面是 AI 寫的

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("透明區塊範例")),
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // 按鈕的事件
                  print("按鈕被點擊了");
                },
                child: Text("按鈕"),
              ),
              GestureDetector(
                onTap: () {
                  // 透明區塊的事件
                  print("透明區塊被點擊了");
                },
                child: Container(
                  width: 200,
                  height: 100,
                  color: Colors.transparent, // 使這個區塊透明
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
