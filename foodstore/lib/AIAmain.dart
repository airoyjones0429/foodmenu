import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int winningAmount = 0;
  int playerAmount = 100; // 初始玩家金額
  List<int> bets = List.filled(12, 0); // 下注金額
  List<bool> isHighlighted = List.filled(12, false); // 按鈕高亮狀態

  void placeBet(int index) {
    if (playerAmount > 0) {
      setState(() {
        bets[index]++;
        playerAmount--;
      });
    }
  }

  void setWinningAmount(int amount) {
    setState(() {
      winningAmount = amount;
    });
  }

  void deductWinningAmount() {
    if (winningAmount > 0) {
      setState(() {
        winningAmount--;
        playerAmount++;
      });
    }
  }

  void startGame() {
    // 隨機選擇中獎按鈕
    int winningIndex = (DateTime.now().millisecondsSinceEpoch % 12).toInt();
    setState(() {
      isHighlighted[winningIndex] = true;
      Future.delayed(Duration(seconds: 10), () {
        setState(() {
          winningAmount += bets[winningIndex] * 10; // 中獎金額
          bets[winningIndex] = 0; // 清空中獎按鈕的下注金額
          isHighlighted[winningIndex] = false; // 重置高亮狀態
        });
      });
    });

    // 讓按鈕高亮
    for (var i = 0; i < 12; i++) {
      Future.delayed(Duration(milliseconds: i * 500), () {
        setState(() {
          isHighlighted[i] = true;
        });
        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            isHighlighted[i] = false;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text("遊戲"),
        backgroundColor: Colors.yellow,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("中獎金額: $winningAmount",
                  style: TextStyle(fontSize: 18, color: Colors.yellow)),
              Text("玩家金額: $playerAmount",
                  style: TextStyle(fontSize: 18, color: Colors.yellow)),
            ],
          ),
          SizedBox(height: 8),
          buildBetRow(0),
          SizedBox(height: 8),
          buildBetRow(4),
          SizedBox(height: 8),
          buildBetRow(8),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: startGame,
                child: Text("開始玩"),
              ),
              ElevatedButton(
                onPressed: () => setWinningAmount(100),
                child: Text("設定獎金為100"),
              ),
              ElevatedButton(
                onPressed: deductWinningAmount,
                child: Text("獎金輸入"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBetRow(int startIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        int betIndex = startIndex + index;
        return Column(
          children: [
            Text("${bets[betIndex]}", style: TextStyle(color: Colors.yellow)),
            GestureDetector(
              onTap: () => placeBet(betIndex),
              child: Container(
                width: 64,
                height: 64,
                color: isHighlighted[betIndex]
                    ? Colors.green.withOpacity(0.5)
                    : Colors.white,
                child: Center(child: Text("圖片${betIndex + 1}")),
              ),
            ),
          ],
        );
      }),
    );
  }
}
