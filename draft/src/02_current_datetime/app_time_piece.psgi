use strict;
use warnings;
use utf8;

use Time::Piece;

my $app = sub {
    my $env = shift;

    my $t        = localtime;
    my $datetime = $t->strftime('%Y-%m-%d %H:%M:%S');
    return [ 200, [ 'Content-Type' => 'text/plain' ], [$datetime], ];
};
