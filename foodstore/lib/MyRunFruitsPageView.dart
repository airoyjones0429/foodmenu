import 'package:flutter/material.dart';

///將 48 張圖片放到 PageView 中，這樣就可以最多捲動 47 次了
///每一個小格子 都要放 48 張圖片  48 * 9 =  432
class MyRunFruitsPageView extends StatefulWidget {
  final bool isVertical;
  final PageController imgPageCR;
  final List<Image> myImg;
  final int maxRunning;

  bool isInitialized; // 標誌，表示 Widget 是否已初始化

  MyRunFruitsPageView({
    required this.isVertical,
    required this.imgPageCR,
    required this.myImg,
    required this.maxRunning,
    this.isInitialized = false,
  });

  @override
  State<MyRunFruitsPageView> createState() => _MyRunFruitsPageViewState();
}

class _MyRunFruitsPageViewState extends State<MyRunFruitsPageView> {
  @override
  void initState() {
    super.initState();

    widget.isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      scrollDirection: widget.isVertical ? Axis.vertical : Axis.horizontal,
      controller: widget.imgPageCR,
      children: [
        for (int i = 0; i < widget.maxRunning; i++) widget.myImg[i],
      ],
    );
  }
}
