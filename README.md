# mt_plugin_AmpConvert

Movable Type用AMPページ作成プラグイン
====

ARK-Web/mt_plugin_AmpConvert - Movable TypeでのAMP対応ページ生成を支援するプラグインです。

### 概要
* img タグを amp-img に変換し、さらに画像サイズ属性が不足してたら付加する
* YouTube埋め込みコードを amp-youtube タグに変換する
* 余分なインラインCSSの記述を除去する

といった変換を行います。

### 動作
次の変換が行われます。

#### 1. インライン style の除去

`<mt:AmpConvert>〜</mt:AmpConvert>` 内の 全てのインラインCSSの記述「style="XXX"」が削除されます。


#### 2. img → amp-imgへ変換

全ての `<img>`タグが、`<amp-img>` タグに置き換わります。

**amp-imgのwidth,height自動設定**

元のimgタグに width または height 属性が記述されていない場合に、画像のサイズを取得して、amp-img に自動設定します(パラメータの指定でオフにできます)。

なんらかの理由で画像が取得できなかった場合は、width,heightの自動設定は行われず、MTログにログを残します。

#### 3. YouTubeの埋め込みコード を amp-youtube に変換

iframe タグのうち、srcが「https://www.youtube.com/embed/〜」のものが変換対象となります。

タグ `<iframe>〜</iframe>` が `<amp-youtube>〜</amp-youtube>`に変換され、パラメータについては次のルールで変換されます。

* data-videoid
  * https://www.youtube.com/embed/XXXX の「XXXX」がdata-videoidに設定される
  * layout: 「responsive」が設定されます
  * src: 削除されます
  * frameborder: 削除されます
  * allowfullscreen: 削除されます

元のYouTube埋め込みコード

	<iframe
		width="560"
		height="315"
		src="https://www.youtube.com/embed/RDDxlJld2AxSo" 
		frameborder="0"
		allowfullscreen>
	</iframe>

↓
amp-youtube 変換後

	<amp-youtube
		data-videoid="RDDxlJld2AxSo" 
		layout="responsive" 
		width="560"
		height="315"
	</amp-youtube>
