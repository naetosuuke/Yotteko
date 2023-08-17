# Yotteko<br>
Yotteko is an application which supports the "side trip."<br>
「ちょっと寄ってく？」<br>
## アプリ概要<br>
<br>
App Store: https://apps.apple.com/jp/app/yotteko/id6446333046<br>
<br>
休みの日に、自転車に乗ってどこかに出かけよう！と思った時、寄り道できそうな場所までの距離を確認できるアプリが欲しく、作成しました。<br>
<br>
アプリ内のマップに出発地点/目的地点を登録すると、その地点までの経路情報を記載します。<br>
経路情報には、マップ、各地点の(名前 / 移動距離 / 移動時間)を記載します。(徒歩:2km/h, 自転車 8km/h計算)<br>
<br>
※実装予定の機能<br>
●検索したルートを、経路履歴として保存。別途、お気に入り経路も保存可能<br>
●API通信も実装したく、現在地をもとに天気情報を表示する<br>
●作成したマップ画像、経路情報を SNSで共有できる<br>
●最終的に、出発地点、目的地を登録すると、2点間で休憩できそうなポイントをリストアップし、リストから選択した地点を経由する経路を表示するアプリへと仕様を変更します。<br>

<br>
## 使用ライブラリ<br>
#### MapKit <br>
地図画面、経路作成機能の実装のため使用<br>
<br>
#### FloatingPanel<br>
ハーフモーダル実装のために使用<br>
<br>
以下、使用予定分<br>
#### SnapKit<br>
レイアウト設定のために使用予定<br>
<br>
#### Realm<br>
検索結果を保存するために使用予定（GeneratedRouteViewControllerに表示する）<br>
<br>
#### Firebase<br>
各ユーザーがアップロードしたルートを表示するため実装予定（OnlineRouteViewControllerに表示する）<br>
<br>
<br>
## 各画面の説明<br>
#### メイン画面: MainViewController<br>
地図の画面を表示、出発地点、到着地点、ピンボタン、❔ボタンがある<br>
出発地点、到着地点を押すと各地点を設定るすため、検索画面に飛ぶ。<br>
<br>
#### 検索画面: RouteCandidateController<br>
出発地点、到着地点を、MKLocalSearchで検索して、候補をUITableViewで表示。<br>
選ぶと出発地点、到着地点の情報をメイン画面に渡す。<br>
※出発、到着のどちらを検索しているかを、MainViewControllerがもつIdentifierで判断している<br>
<br>
#### 経路表示画面: RouteViewContorller<br>
MainViewControllerで、出発地点、到着時点の両方が選択された時に<br>
モーダルで画面が現れ、経路と距離、所要時間を表示する。
<br>
####　ヘルプ画面: HelpViewController<br>
使用方法を表示。ハーフモーダルで現れるよう実装<br>

## 学習した内容<br>
・MapKitを利用した経路検索機能の実装
・宣言的UI　(InterfaceBuilderなしで画面を作成)<br>
・非同期通信への処理方法(MKLocalSearchの検索結果がでるまで画面が表示できないので、検索メソッドの中に画面表示メソッドをネストしている。もうすこしいいやり方あるかもしれない...)<br>
・Figmaを用いたアイコン作成<br>
・ストア公開の手続き、AppReviewへの対応　<br>
https://zesty-idea-01f.notion.site/App-review-a53bd26d495447118d4fd0d150063115?pvs=4<br>

##　今後　修正したい内容(8/17時点)<br>
・ひどいFatViewControllerになっているので、検索メソッドや画面表示用のメソッドを分離させる。<br>
・Realm,Firebaseを用いて、早急に検索結果のデータを保存できるようにしたい。<br>
・色々なFrag、Identifierを使っているので、初めて見た人がコードの全容を把握する事が難しいと思う。もっとわかりやすい書き方に変えたい。<br>

##　なぜこのアプリを作ったか<br>
自転車で遠出することにハマっていたため、移動中にコンビニやカフェなどの寄り道先をすぐに調べられるアプリが欲しかった。<br>
初めてのアプリでMapKitを使うことは難しかったが、たまに自分でも使う機会があるので愛着を持つ事ができ、結果的に良かったと思う。<br>


