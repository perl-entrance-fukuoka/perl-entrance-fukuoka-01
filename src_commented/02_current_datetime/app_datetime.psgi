use strict;
use warnings;
use utf8;

use DateTime;   # DateTimeモジュールを読み込んでいます。
# DateTimeモジュールは、Time::Pieceモジュールより処理は遅いですが
# 複雑な日時計算を含め日時関連をフルカバーしたモジュールです。

my $app = sub {
    my $env = shift;

    my $datetime =
      DateTime->now( 'time_zone' => 'local' )->strftime('%Y-%m-%d %H:%M:%S');
    # DateTime->now を呼び出す事でDateTimeオブジェクトを生成し、生成された
    # オブジェクトのstrftime関数を呼び出しています。オブジェクト生成の際には
    # 「'time_zone' => 'local'」と引数を与えローカル時間を使用するようにしています。
    # 上記の記述は下記のように２行で書く事も出来ます。
    # my $dt = DateTime->now('time_zone' => 'local');   # オブジェクトの生成
    # my $datetime = $dt->strftime('%Y-%m-%d %H:%M:%S');# 処理の呼び出し

    return [ 200, [ 'Content-Type' => 'text/plain' ], ['DateTime: ', $datetime], ];
};
