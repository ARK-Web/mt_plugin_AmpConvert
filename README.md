# 
「AMP Convert」 MT用AMPページ生成支援プラグイン
====

ARK-Web/mt_plugin_AmpConvert - Movable TypeでのAMP対応ページ生成を支援するプラグインです。

### 概要
* img タグを amp-img に変換し、さらに画像サイズ属性が不足していたら付加する
* YouTube埋め込みコードを amp-youtube タグに変換する
* 余分なインラインCSSの記述を除去する

といった変換を行います。

### 動作
次の変換が行われます。

#### 1. インライン style の除去

`<mt:AmpConvert>〜</mt:AmpConvert>` 内の 全てのインラインCSSの記述「style="XXX"」が削除されます。
※パラメーターの指定でオフにできます


#### 2. img → amp-imgへ変換

全ての `<img>`タグが、`<amp-img>` タグに置き換わります。

**amp-imgのwidth,height自動設定**

元のimgタグに width または height 属性が記述されていない場合に、画像のサイズを取得して、amp-img に自動設定します。
※パラメータの指定でオフにできます

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


### 動作条件

* Movable Type 6
* Movable Type 7
* MTクラウド対応

* 必要モジュール: 
  * AmpConvertの利用には、HTML::Parserモジュールが必要です。
  * HTML::Parserがインストールされていない環境の場合は、再構築時にエラーを出力します。

* スタティックパブリッシング専用

### ダウンロード

* [https://github.com/ARK-Web/mt_plugin_AmpConvert](https://github.com/ARK-Web/mt_plugin_AmpConvert)
* ライセンス: MIT License


### インストール

zipを解凍して [AmpConvert] フォルダーごと、MT設置ディレクトリー /plugins にアップロードします。


### 使い方

ampページを出力するアーカイブテンプレートを追加し、
変換したい範囲を、`<mt:AmpConvert>〜</mt:AmpConvert>` ブロックタグで囲みます。


#### MTAmpConvertタグのオプション

	<mt:AmpConvert fix_img_size="1" base_url="http://example.com">
	    <mt:EntryBody> など変換対象
	</mt:AmpConvert>


##### パラメーター: fix_img_size (画像サイズ属性自動設定機能のオン/オフ)

amp-img タグの width, height 属性の自動設定の実行を制御するパラメーターです。

* fix_img_size="0":  width,heightを自動設定しない
* fix_img_size="1":  width,heightを自動設定する
* dont_remove_style="1"：style属性を削除しない
* dont_remove_style="0"：style属性を削除する

* デフォルト(無指定時)は style属性を削除し、width,heightを自動設定します。

##### パラメーター: base_url ()

前述の fix_img_size パラメーターとセットで使います。

width,height を自動設定する場合、imgのsrc属性で指定された画像をダウンロードしてサイズ取得を行います。

しかし src属性が相対パスで書かれていると画像の取得ができません。これを解決するために、base_urlパラメーターを設定することができます。

imgのsrcが相対パスである場合、base_url + imgのsrcで画像を取得しに行きます。

	<mt:AmpConvert fix_img_size="1" base_url="http://example.com"></mt:AmpConvert>


* 元のコードが `<img src="/image/abc.jpg">` の場合
  * 相対パスなのでbase_urlが頭に付加され、http://example.com/image/abc.jpgの画像を取得します。
* 元のコードが `<img src="http://foo.jp/aaa/bbb.gif">` の場合
  * 絶対パスなのでbase_urlは使わず、http://foo.jp/aaa/bbb.gifの画像を取得する

**画像が取得できなかった場合**

* width,heightの自動設定は行なわれません。
* MTログにログを残します。

#### パラメーター:responsive_width_threshold(画像のwidthサイズ)

layout="responsive"の付与について指定できます。
画像が指定したwidthサイズ以上の場合、layout="responsive"を付与し、未満の場合は付与しません。

`<mtAmpConvert responsive_width_threshold="100">` 
* widthが100以上の画像の場合は、layout="responsive"を付与します。
* 以下の場合は適用されません
	* fix_img_size="0"など、widthが判定できない場合
	* 画像にBASIC認証がかかっている場合

#### amp-youtubeを使う場合

amp-youtubeを使う時には、`<head>` 内に次のスクリプトを記述する必要があります。
通常はAMP用のアーカイブテンプレートに追記してください。

bq. &lt;script async custom-element=&quot;amp-youtube&quot; src=&quot;https://cdn.ampproject.org/v0/amp-youtube-0.1.js&quot;&gt;&lt;/script&gt;

**サンプルテンプレート: 記事アーカイブ(AMP)**

	<!doctype html> <!-- Start with the doctype <!doctype html>. -->
	<html amp lang="ja"> <!-- <html ?> tag (<html amp> is accepted as well).-->
	  <head>
	    <meta charset="utf-8">
	    <title><$mt:EntryTitle$></title>
	    <link rel="canonical" href="<$mt:CanonicalURL current_mapping="0"$>" /> <!-- 通常ページへの関連づけを行う canonicalリンク。current_mapping="0"とすると優先アーカイブのURLが入る。 AMPページのみ存在する場合は自分自身のURLを指せばOK。 -->
	    <meta name="viewport" content="width=device-width,minimum-scale=1,initial-scale=1"><!-- It’s also recommended to include initial-scale=1 -->
	    <script type="application/ld+json"> <!-- 構造化データJSON-LD (AMPの必須項目ではないがGoogleのTop Stories carousel表示上の重要要素)
	      {
	        "@context": "http://schema.org",
	        "@type": "NewsArticle",
	        "headline": "<$mt:EntryTitle encode_json='1'$>",
	        "datePublished": "<$mt:EntryDate format_name='iso8601'$>,
	        "image": [
	          "logo.jpg"
	        ]
	      }
	    </script>
	    <style amp-boilerplate>body{-webkit-animation:-amp-start 8s steps(1,end) 0s 1 normal both;-moz-animation:-amp-start 8s steps(1,end) 0s 1 normal both;-ms-animation:-amp-start 8s steps(1,end) 0s 1 normal both;animation:-amp-start 8s steps(1,end) 0s 1 normal both}@-webkit-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@-moz-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@-ms-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@-o-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}</style><noscript><style amp-boilerplate>body{-webkit-animation:none;-moz-animation:none;-ms-animation:none;animation:none}</style></noscript> <!-- 書く。お約束ごと。 -->
	    <script async custom-element="amp-youtube" src="https://cdn.ampproject.org/v0/amp-youtube-0.1.js"></script><!-- amp-youtube を使う場合はこのコードが必要です -->
	    <script async src="https://cdn.ampproject.org/v0.js"></script> <!-- head要素内の最後に書く (this includes and loads the AMP JS library). -->
	  </head>
	  <body>
	    <h1><$mt:EntryTitle$></h1>
	    <mt:AmpConvert>
	        <$mt:EntryBody$>
	        <$mt:EntryMore$>
	    </mt:AmpConvert>
	  </body>
	</html>


### link rel="amphtml", "canonical"で元ページとAMPページを相互関連付けする

通常ページとAMPページ同士を関連づけして、お互いを参照しあえるようにします。

**通常ページ(non-AMP page)に付与:**

	<link rel="amphtml" href="https://www.example.com/url/to/amp/document.html">
	<!-- AMPページを amphtml で指し示す -->

**AMP pageに付与:**

	<link rel="canonical" href="https://www.example.com/url/to/full/document.html">
	<!-- 通常ページを canonical で指し示す -->

**AMPページ単独の場合:**

AMPページ単独の場合は自分自身を指すようになっていればOKです。

	<link rel="canonical" href="https://www.example.com/url/to/amp/document.html">


### 今後の対応予定など

本プラグインのｖ1.0では本文内で多用される機能に絞って実装しています。
AMP Projectにはこの他のampタグや、Extended components（外部ampタグ？）がたくさんあり、今現在も発展途中です。

[Accelerated Mobile Pages Project](https://www.ampproject.org/docs/reference/extended.html)

今後、必要に応じて対応する機能を増やしていこうと考えています。個別のカスタマイズニーズなどはご相談ください。

