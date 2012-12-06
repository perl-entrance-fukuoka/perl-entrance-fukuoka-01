use strict;
use warnings;
use utf8;

use POSIX qw(strftime);

my $app = sub {
    my $env = shift;

    my $datetime = strftime( '%Y-%m-%d %H:%M:%S', localtime );
    return [
        200,
        [ 'Content-Type' => 'text/plain' ],
        [ 'POSIX: ', $datetime ],
    ];
};
