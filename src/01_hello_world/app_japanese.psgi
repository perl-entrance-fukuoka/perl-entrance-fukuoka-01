use strict;
use warnings;
use utf8;

use Encode qw(encode_utf8);

my $app = sub {
    my $env = shift;
    return [
        200,
        [ 'Content-Type' => 'text/plain; charset=UTF-8' ],
        [ encode_utf8('perl入学式in福岡へようこそ') ],
    ];
};
