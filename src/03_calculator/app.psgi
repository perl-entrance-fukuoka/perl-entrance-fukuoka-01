use strict;
use warnings;
use utf8;

use Plack::Request;

my @html = <DATA>;

my $app = sub {
    my $env = shift;

    my $req  = Plack::Request->new($env);
    my $path = $req->path;

    if ( $path eq '/' ) {
        return [ 200, [ 'Content-Type' => 'text/html' ], \@html ];
    }
    elsif ( $path eq '/add' ) {
        my $x = $req->param('x') || 0;
        my $y = $req->param('y') || 0;
        my $result = $x + $y;
        return [ 200, [ 'Content-Type' => 'text/plain' ], [$result] ];
    }
    else {
        return [ 404, [ 'Content-Type' => 'text/plain' ], ['Not Found'] ];
    }
};

__DATA__
<html>
  <head>
    <title>calculator</title>
  </head>
  <body>
    <form action="/add">
      <input type="text" name="x" /> + <input type="text" name="y" /> <input type="submit" value=" = " />
    </form>
  </body>
</html>
