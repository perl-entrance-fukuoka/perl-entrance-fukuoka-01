use strict;
use warnings;
use utf8;

use DateTime;

my $app = sub {
    my $env = shift;

    my $datetime =
      DateTime->now( 'time_zone' => 'local' )->strftime('%Y-%m-%d %H:%M:%S');
    return [ 200, [ 'Content-Type' => 'text/plain' ], [$datetime], ];
};
