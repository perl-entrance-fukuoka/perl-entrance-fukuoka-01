use strict;
use warnings;
use utf8;

use Time::Piece;    # Time::Piece モジュールを読み込んでいます。
# Time::Piece モジュールは、日付と時間を扱うモジュールで
# 様々な日付表現と簡単な日付の演算ができます。

my $app = sub {
    my $env = shift;

    my $t        = localtime;
    # Time::Pieceモジュールをuseするとlocaltimeの戻り値が自動的に
    # 日時オブジェクトになります。オブジェクトとはデータと処理を
    # セットにした物と考えてください。処理はTime::Pieceモジュール
    # の中で定義されており、localtime関数を呼び出す事でデータと
    # 結びつきオブジェクトとして使用できるようになります。

    my $datetime = $t->strftime('%Y-%m-%d %H:%M:%S');
    # 日時(Time::Piece)オブジェクトのstrftimeという処理を呼び出しています。
    # POSIX::strftimeと同様にフォーマットを指定し、日時を表す文字列を生成
    # しています。POSIX::strftimeではフォーマットの他に日時データを指定する
    # 必要がありましたが、Time::Pieceオブジェクトは内部に日時データを持って
    # いるので、別途指定する必要がありません。

    return [ 200, [ 'Content-Type' => 'text/plain' ], ['Time::Piece: ', $datetime], ];
};
