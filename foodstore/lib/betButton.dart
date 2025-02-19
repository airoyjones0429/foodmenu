import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'appState.dart';

///下注面板，下注的單一按鈕，邏輯程序
class betButton extends StatelessWidget {
  final Image betImage; //顯示圖片
  final int betMoney; //顯示金額
  final bool betOpt; //背景控制
  // final Function onPressed; //圖片按鈕按下觸發程序

  const betButton({
    required super.key,
    required this.betImage,
    required this.betMoney,
    // required this.onPressed,
    this.betOpt = false,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    void addBetMoney() =>
        appState.pressbetButton(betKey: this.key!, addMoney: 1);
    void addBetBigMoney() =>
        appState.pressbetButton(betKey: this.key!, addMoney: 10);

    bool subPlayerMoney(money) => appState.subPlayerMoney(money: money);

    return Container(
      child: Container(
        color: Colors.grey,
        child: Column(
          children: [
            Text.rich(TextSpan(
                style: TextStyle(
                  color: Colors.limeAccent,
                  fontSize: 36,
                ),
                children: [TextSpan(text: betMoney.toString())])),
            IconButton(
              onPressed: () {
                int index = appState.getbetButtonKeyInt(betKey: this.key!);
                print(' 取回按鈕的索引值 ${index}');
                if (subPlayerMoney(1)) {
                  ///如果能扣除金額，就增加金額
                  addBetMoney();
                }
              },
              icon: this.betImage,
            ),
          ],
        ),
      ),
    );
  }
}
