# foodstore

這是用來學習 flutter 的學習範例

原本是想做，買食物用的點菜表單，結果就走歪了！

範例使用的小佈件 Widget，就像 App Inventor 視覺化物件一樣，下面列出一些常用的佈件

Column()    垂直配置

ROW()       水平配置

Stack()     堆疊配置

SingleChildScrollView() +  Column() 垂直卷軸配置 

SingleChildScrollView() +  ROW()    水平卷軸配置  (一定要設定 scrollDirection: Axis.horizontal)

Image       放圖片用的物件 ( 範例中，都是用 Image.network )

SizeBox     限制畫面大小用的容器物件，有時也用來當佔空間，讓物件有間隔

container   限制畫面大小用的容器物件，這裡我用來畫線條，因為 SizeBox 沒有 Color 屬性可以設定

ElevatedButton          文字按鈕物件

ElevatedButton.icon     圖片按鈕物件

Text                    文字顯示物件，可以用 TextStyle() 來設定 style 屬性，可以改變文字樣式

Timer                   計時器物件，這裡都用 Timer.periodic() 方法，並且用 cancel() 停止計時器

LinearProgressIndicator 進度條物件

Transform.rotate        旋轉物件的容器，把物件放進去，設定角度，就可以旋轉該物件

ListView                清單顯示器，這裡用在 MyApp 把上中下的物件，當作清單項目來排列，應該不是正常的用法

AnimatedSwitcher        產生動態效果的容器物件

GestureDetector         產生一個偵測事件的容器，當容器內物件不支援一些事件時，可以用這個容器來產生互動的事件

Scaffold                傳回一個標準 APP 的介面

MaterialApp             傳回一個 Android 樣式的 APP 介面，照範例學習使用



本範例設計過程為 Amain -> Bmain -> Cmain -> ... -> Hmain

把檔案名稱修改為 mian 然後選擇 flutter emulator 再按 F5 就可以執行模擬了

foodstore\build\app\outputs\flutter-apk\app-debug.apk 這是在編譯時，自動產生的安裝檔案

也可以自己在 TERMINAL 終端機輸入 flutter build apk --release 

本次範例練習到的重點

1.可以用 if 條件來決定物件要不要顯示。

2.產生顯示物件的區域，可以用除了 if 之外，的方式設定，只要輸入類型相同就可以。

3.initState() didChangeDependencies() dispose() 的使用時機。

4.Future<void> 建立一個異步函數，來下載圖片資料，並且用進度條來表示，避免程式有當機的感覺。

5.不同物件，要根據彼此的資料互相更新，若不用狀態管理，真的很麻煩，這裡用全域變數與 Timer 來刷新資料

6.Stack() 中的物件，如果大小相同，最下面的物件會蓋住上面的物件，水果盤根線條就是用這種方式放上去的

7.ListView 需要知道子項目的大小，不然會產生 hasSize 錯誤。

