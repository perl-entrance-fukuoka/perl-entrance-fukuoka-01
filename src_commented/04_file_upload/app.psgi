use strict;
use warnings;
use utf8;

use File::Spec; # OS固有のファイル名の区切り文字を使ってファイル名を作成したりできます。
use File::Basename; # ファイル名からベース名やディレクトリ名を取得するためのモジュールです。
use constant UPLOAD_DIR => File::Spec->catdir( dirname(__FILE__), 'data' );
# use constant は定数を定義します。
# UPLOAD_DIR は定数名です。
# __FILE__ はスクリプトのファイル名を取得します。この場合は「/home/user1/04/app.psgi」
# dirname(__FILE__)はこのpsgiファイルのあるデリレクトリを返します。
# dirname は File::Basename をuseすることでインポートされています。
# File::Spec->catdirは与えられたリストをOSの区切り文字で連結します。
# 上記の場合、定数UPLOAD_DIRの値は/home/user1/04/dataとなります。

use Encode qw(encode_utf8);
use Plack::Request;
use Text::Xslate;   # テンプレートを使う為のモジュールです。

my $template = join( '', <DATA> );
# joinは文字列を連結します。
# 上記は__DATA__トークン以降のすべての行を空文字列で連結しています。 

my $app = sub {
    my $env = shift;

    my $req  = Plack::Request->new($env);
    my $path = $req->path;

    if ( $path eq '/' ) {
        return list();
        # サブルーチン(関数)listを呼び出しています。
        # サブルーチンは45行目以降に定義されています。
    }
    elsif ( $path eq '/upload' ) {
        return upload($req);
        # サブルーチンuploadを呼び出しています。
        # 引数に$reqを渡しています。
    }
    else {
        return not_found();
        # サブルーチンnot_foundを呼び出しています。
    }
};

# ファイルアップロードフォームとアップロード済みファイルの一覧を
# 表示するサブルーチンの定義箇所です。
sub list {
    # サブルーチンを定義する際は「sub 関数名 {処理内容}」とします。

    opendir( my $dh, UPLOAD_DIR ) or return server_error($!);
    # ディレクトリの情報を読み出す準備をしています。
    # $dhにはディレクトリハンドルが入ります。ディレクトリハンドルとは
    # ファイルハンドルと同じく、OSとの間でディレクトリに関する情報を
    # やり取りする為の通信経路だと思ってください。
    #opendirが 失敗した場合は偽が返り、以降のreturn文が実行されます。
    # $!は特殊な変数で、その時点でのエラー情報が入っています。

    my @files =
      grep { !/^\./ && -f File::Spec->catfile( UPLOAD_DIR, $_ ) } readdir($dh);
    # readdirはディレクトリ内のファイルやサブディレクトリを取得します。
    # grepはリストから条件に一致する要素を返します。
    # この場合、リストは「readdir($dh)」条件式は{}の部分になります。
    # 条件式は「&&」で連結され複合条件(AND)になっています。
    # 複合条件は左から順番に評価され、AND条件の場合は式が偽と評価された
    # 時点で以降の式の評価は行いません。OR条件の場合は式が真と評価された
    # 時点で以降の式の評価は行いません。
    # grepはreaddirで得られたリストの要素を一つずつ評価します。
    # 評価される要素は$_という特殊な変数に入っており、この$_は
    # 可能であれば省略できます。「!/^\./」は正規表現によるパターン
    # マッチングですが、$_が評価される事が分かっているので省略されています。
    # catfileの場合は、「, $_」と書かなければ、第２引数として$_を渡して
    # 良いか分からない為、明記されています。
    # $_はパターンマッチングや大抵の引数を取る標準関数のデフォルトの
    # 引数として省略可能です。
    # 上記の１行はディレクトリのファイル名やサブディレクトリ名を読み出し
    # ファイル名（またはディレクトリ名）の先頭に.（ドット）が無ければ
    # catfileによってUPLOAD_DIRと連結し絶対パスにした上で
    # ディレクトリではなくファイルの場合のみ配列@filesに代入されます。
    
    closedir($dh);
    # ディレクトリハンドルに対する処理が終わったのでクローズします。

    my $tx = Text::Xslate->new();
    # テンプレートを扱う為のクラスのインスタンスを生成しています。

    my $html = $tx->render_string( $template, { files => \@files } );
    # インスタンスメソッドのrender_stringを呼び出し、テンプレートに
    # パラメータを埋め込んだ結果を変数$htmlに格納しています。
    
    return [
        200,
        [ 'Content-Type' => 'text/html; charset=UTF-8' ],
        [ encode_utf8($html) ]
    ];
}

# アップロードされたファイルを受け取り保存するサブルーチンの定義箇所です。
sub upload {
    my $req        = shift;
    # サブルーチンの引数としてリクエストオブジェクトを受け取っています。

    my $uploadfile = $req->uploads->{uploadfile};
    # uploadfileで指定されたアップロードファイルを取得

    return redirect_list($req) unless $uploadfile;
    # $uploadfileが空なら一覧にリダイレクトするサブルーチンを呼び出します。
    # return はサブルーチンの戻り値を返すので、以降の処理は実行されません。

    my $out_file = File::Spec->catfile( UPLOAD_DIR, $uploadfile->filename );
    # アップロードされたファイル名を取得し、保存先ファイル名を作成します。
    
    open my $fh_in,  "<", $uploadfile->path or return server_error($!);
    # アップロードされたファイルを読み込みモードでオープンします。
    
    open my $fh_out, ">", $out_file         or return server_error($!);
    # 保存先ファイルを書き込みモードでオープンします。
    
    my $buff;
    while ( read( $fh_in, $buff, 8192 ) ) {
        # アップロードされたファイルを8192バイトずつ変数$buffに読み出し
        # 全て読み出したら終了します。

        print $fh_out $buff;
        # 読み出したデータを保存先ファイルに書き込んでいます。
    }
    close $fh_in;
    close $fh_out;
    # ファイルに対する処理が終わったのでファイルハンドルをクローズしています。

    return redirect_list($req);
    # アップロード処理が終わったので一覧ページにリダイレクトする処理を
    # 呼び出しています。
}

# ファイルが見つからない場合の表示処理を行うサブルーチンの定義箇所です。
sub not_found {
    return [ 404, [ 'Content-Type' => 'text/plain' ], ['Not Found'] ];
    # ファイルが見つからない場合はステータス404を返します。
}

# ファイルのアップロード処理の後に一覧ページにリダイレクトするサブルーチンの
# 定義箇所です。
sub redirect_list {
    my $req = shift;
    return [
        303, [ 'Location' => $req->uri->scheme . '://' . $req->uri->host_port ],
        []
        # アップロードが完了、またはファイルが指定されなかった場合、結果として
        # 別のURL（アップロードされたファイル一覧）を参照してほしいので、この
        # ような場合はステータス303を使用します。
        # 「.」はその左右のデータを文字列として連結する際に使用します。
        # $req->uri->scheme ではリソースの取得の方法であるhttpが得られます。
        # $req->uri->host_port ではホスト名とポート番号（192.168.33.10:5000）が
        # 得られます.
    ];
}

# エラーが発生した際にエラー表示を行うサブルーチンの定義箇所です。
sub server_error {
    my $reason = shift || '';
    return [
        500,
        [ 'Content-Type' => 'text/plain' ],
        [ 'Server Error' . ( $reason ? " [$reason]" : '' ) ]
        # サーバー側のエラーが発生した場合はステータス500を返します。
    ];
}

__DATA__
<html>
  <head>
    <title>ファイルアップロード</title>
  </head>
  <body>
    <p>アップロード</p>
    <form action="/upload" method="post" enctype="multipart/form-data">
      <input type="file" name="uploadfile" /> <input type="submit" value="アップロード" />
    </form>
    <p>アップロードファイル一覧</p>
    <ul>
: for $files -> $file {
      <li><: $file :></li>
: } # for
    </ul>
  </body>
</html>
