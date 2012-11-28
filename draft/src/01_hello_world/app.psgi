use strict;
use warnings;
use utf8;

=pod

 STUDY:
   - use strict, warnings, utf8
   - my
   - sub
   - get argument by shift
   - array(ref), hash(ref)

=cut

my $app = sub {
    my $env = shift;
    return [ 200, [ 'Content-Type' => 'text/plain' ], ['Hello World'], ];
};
