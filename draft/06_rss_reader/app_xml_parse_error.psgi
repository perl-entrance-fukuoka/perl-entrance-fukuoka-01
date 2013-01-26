use strict;
use warnings;
use utf8;

use Encode qw(encode_utf8);
use Plack::Request;
use Text::Xslate;
use LWP::Simple;
use XML::RSS;

my $template = join( '', <DATA> );
my $uri = 'http://yahoo.co.jp';

my $app = sub {
    my $env = shift;

    my $req  = Plack::Request->new($env);
    my $path = $req->path;

    if ( $path eq '/' ) {
      return list($uri);
    }
    else {
      return not_found();
    }
};

sub list {
  my $uri = shift;
 
  my $doc = LWP::Simple::get($uri) 
    or return server_error("cannot get content from $uri");

  return server_error("status error from $uri") 
    if( is_error($doc) );

  my $rss = XML::RSS->new; 

  $rss->parse($doc);

  my $tx = Text::Xslate->new( syntax => 'TTerse' );
  my $html = $tx->render_string( $template, { items => $rss->{items} } );
  return [
    200,
    [ 'Content-Type' => 'text/html; charset=UTF-8' ],
    [ encode_utf8($html) ]
  ];
}


sub not_found {
    return [ 404, [ 'Content-Type' => 'text/plain' ], ['Not Found'] ];
}

sub server_error {
    my $reason = shift || '';
    return [
        500,
        [ 'Content-Type' => 'text/plain' ],
        [ 'Server Error' . ( $reason ? " [$reason]" : '' ) ]
    ];
}


__DATA__
<html>
  <head>
    <title>RSS Reader</title>
  </head>
  <body>
  <p>RSS Reader</p>
    <p>RSS</p>
    <ul>
      [% FOREACH item in items %]
        <li><a href="[% item.link %]">[% item.title %]</a>[% item.pubDate  %]</li>
      [% END %]
    </ul>
  </body>
</html>
