use strict;
use warnings;
use utf8;

use Encode qw(encode_utf8);

=pod

 STUDY:
   - use [Module]
   - Encode

=cut

my $app = sub {
    my $env = shift;
    return [
        200,
        [ 'Content-Type' => 'text/plain; charset=UTF-8' ],
        [ encode_utf8('こんにちは、世界') ],
    ];
};
