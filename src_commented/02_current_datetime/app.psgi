use strict;
use warnings;
use utf8;

use POSIX qw(strftime); # POSIXで定義された関数を使えるようにします。
# POSIXとは、Portable Operating System Interface の略で、Linux など
# UNIX系を中心とする様々なOSで共通のAPIを定めたもので、異なるOS間で
# 移植製の高いアプリケーションをの開発を用意にするために定められた
# 仕様です。上記はPOSIXのstrftimeという関数をインポートしています。

my $app = sub {
    my $env = shift;

    my $datetime = strftime( '%Y-%m-%d %H:%M:%S', localtime );
    # strftime関数は１番目の引数で指定したフォーマットに
    # ２番目の引数で指定した日時のデータを変換する関数です。
    # localtime は各地域のローカル時間を取得する関数です。

    return [ 200, [ 'Content-Type' => 'text/plain' ], ['POSIX: ', $datetime], ];
};
