import 'package:flutter/material.dart';

///下注面板，上方的金額顯示
class MyMoney extends StatelessWidget {
  final bool AniScal;
  final String Title;
  final int Money;
  const MyMoney({
    super.key,
    required this.Money,
    required this.Title,
    this.AniScal = false, //沒有輸入 true 就當成 false
  });

  @override
  Widget build(BuildContext context) {
    // return AnimatedSwitcher(
    //   duration: const Duration(seconds: 2),
    //   transitionBuilder: (Widget child, Animation<double> animation) {
    //     return ScaleTransition(scale: animation, child: child);
    //   },
    //   child: Text(
    //     '${Money}',
    //     key: ValueKey<int>(Money),
    //   ),
    // );
    return AnimatedSwitcher(
      duration: Duration(
        milliseconds: 400,
      ),
      transitionBuilder: (this.AniScal) //如果為真 就用改變大小的動畫
          ? (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            }
          : AnimatedSwitcher.defaultTransitionBuilder, //如果為假 就用預設透明的動畫
      child: Row(
        ///如果動畫不見，這邊的KEY一定有重複
        ///或是Key沒有放在最外層
        ///如果這的KEY 設定給這裡的 Text 也就是 Row 的內容子容器
        ///就不會有動畫 !!
        ///所以改在最外層  也就是 Row 才是 AnimatedSwitcher 的子
        ///可能是因為  AnimatedSwitcher 會監測子容器 KEY 是否變化
        ///然後才會產生動畫效果
        key: ValueKey<String>(' ${this.Title}  ${this.Money}'),

        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${this.Title} ', // Title 部分
                  style: TextStyle(
                    color: Colors.blue, // 設定 Title 的顏色
                    fontSize: 24,
                  ),
                ),
                TextSpan(
                  text: '${this.Money}', // Money 部分
                  style: TextStyle(
                    color: Colors.red, // 設定 Money 的顏色
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
