use strict;
use warnings;
use utf8;

use Plack::Request; # Plack::Request モジュールを読み込んでいます。
# Plack::Request はPlackディストリビューションに同梱されているモジュールです。
# ディストリビューションとは広く流通させる為にまとめられた物の事をいい
# PerlにおいてはCPANからダウンロードして利用できるようにしたものを意味します。

# PlackとはWebサーバとアプリケーションのAPIを定めたPSGIという仕様の実装です。
# この仕様の実装があるおかげで、Webサーバを変更してもアプリケーション側では
# ほとんどコードを変更する必要がありません。

# 今回はWebブラウザからの入力を処理する為、Plack::Requestを使います。
# これまで、サンプルプログラムの動作を確認する際には下記のようなコマンドを
# 実行してきました。plackup app.psgi
# これはPlackに同梱されている単独で動くWebサーバ上でPSGIアプリケーションを
# 動かしていた事になります。Webサーバはアプリケーションに処理を依頼する際に
# データを渡します。Plack::Requestはそのデータを扱う為の道具と考えてください。

my @html = <DATA>;
# Perlはソースコード中に__DATA__ または __END__ という行（トークン）が現れた
# 場合、以降の記述を無視します。トークン以降に記載された内容はDATAという特殊
# なファイルハンドルで読み出す事が出来ます。ファイルハンドルとはアプリケーション
# からファイルにアクセスする為の通信経路のようなものです。
# ファイルから行を読み出すには上記のように<>でファイルハンドルを括ります。
# 読み出すデータを配列に代入する場合、自動的に全ての行が順番に配列の要素に代入
# されます。このソースコードの下の方には__DATA__トークンがあるので確認してみて
# ください。トークン以降には入力フォームを表示する為のHTMLが記述されています。
# HTML（HyperText Markup Language）とはホームページなどを記述するための言語です。

my $app = sub {
    my $env = shift;
    use Data::Dumper;die Dumper([$env]);
    # Webサーバから受け取った情報を変数$envに格納しています。

    my $req  = Plack::Request->new($env);
    # Webサーバからの受け取った情報を元にPlack::Requestオブジェクトを生成し
    # 変数$reqに代入しています。

    my $path = $req->path;
    # オブジェクトの処理（pathメソッド）を呼び出して、アクセスされたパスを取得し
    # 変数$pathに代入しています。アクセスされたパスとはブラウザのロケーション欄で
    # 確認できるURLのドメインより後ろのスラッシュ以降の文字列の事です。
    # 例）アクセスされたURLが「http://www.example.com/index.html」のとき
    #     パスは「/index.html」となります。

    if ( $path eq '/' ) {
        # ifは後に続く式(この場合は「$path eq '/'」)が真(成立)の場合に、以降の
        # ブロックを実行します。eqはequalの略で文字列が等しければ真になります。

        return [ 200, [ 'Content-Type' => 'text/html' ], \@html ];
        # 数値を足し算する為のフォームを表示します。
    }
    elsif ( $path eq '/add' ) {
        # elsifはifの条件判断が偽(不成立)の場合に、続けて条件判断を行う際に使用します。
        my $x = $req->param('x') || 0;
        # $req->param('x') はリクエストオブジェクトのparamメソッドを使って入力値xを
        # 取得するという意味になります。入力値xが真であれば、変数$xに入力値xを代入し
        # 入力値xが偽の場合、代わりに0を代入します。
        # Perlでは値を評価する際、下記の場合は偽となりそれ以外は真となります。
        # 0     数値の0
        # "0"   0のみから構成される文字列
        # undef 未定義値(初期かされていない変数など)
        # ""    空文字列 (長さが0の文字列)
        # ()    空の配列
        
        my $y = $req->param('y') || 0;
        
        my $result = $x + $y;
        # + は左辺値と右辺値を数値として評価し加算します。足し算します。
        
        return [ 200, [ 'Content-Type' => 'text/plain' ], [$result] ];
        # 計算結果を表示します。
    }
    else {
        # elseはifやelsifなどいずれの条件も成立しなかった場合に実行されます。

        return [ 404, [ 'Content-Type' => 'text/plain' ], ['Not Found'] ];
        # パスが/でも/addでも無い場合、はページが存在しない旨を表示します。
    }
};

__DATA__
<html>
  <head>
    <title>calculator</title>
  </head>
  <body>
    <form action="/add">
      <input type="text" name="x" /> + <input type="text" name="y" /> <input type="submit" value=" = " />
    </form>
  </body>
</html>
