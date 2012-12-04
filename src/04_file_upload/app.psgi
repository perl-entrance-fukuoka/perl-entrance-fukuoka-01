use strict;
use warnings;
use utf8;

=pod

 /       ... アップロードフォーム & アップロードファイル一覧
 /upload ... アップロード実行


 STUDY:
   - File::Spec
   - File::Basename
   - function
   - grep
   - opendir/readdir/closedir

 TODO:
   - Text::Xslate ?

=cut

use File::Spec;
use File::Basename;
use constant UPLOAD_DIR => File::Spec->catdir( dirname(__FILE__), 'data' );

use Encode qw(encode_utf8);
use Plack::Request;
use Text::Xslate;

my $template = join( '', <DATA> );

my $app = sub {
    my $env = shift;

    my $req  = Plack::Request->new($env);
    my $path = $req->path;

    if ( $path eq '/' ) {
        return list();
    }
    elsif ( $path eq '/upload' ) {
        return upload($req);
    }
    else {
        return not_found();
    }
};

sub list {
    opendir( my $dh, UPLOAD_DIR ) or return server_error($!);
    my @files =
      grep { !/^\./ && -f File::Spec->catfile( UPLOAD_DIR, $_ ) } readdir($dh);
    closedir($dh);

    my $tx = Text::Xslate->new( syntax => 'TTerse' );
    my $html = $tx->render_string( $template, { files => \@files } );
    return [
        200,
        [ 'Content-Type' => 'text/html; charset=UTF-8' ],
        [ encode_utf8($html) ]
    ];
}

sub upload {
    my $req        = shift;
    my $uploadfile = $req->uploads->{uploadfile};

    return redirect_list($req) unless $uploadfile;

    my $out_file = File::Spec->catfile( UPLOAD_DIR, $uploadfile->filename );
    open my $fh_in,  "<", $uploadfile->path or return server_error($!);
    open my $fh_out, ">", $out_file         or return server_error($!);
    my $buff;
    while ( read( $fh_in, $buff, 8192 ) ) {
        print $fh_out $buff;
    }
    close $fh_in;
    close $fh_out;

    return redirect_list($req);
}

sub not_found {
    return [ 404, [ 'Content-Type' => 'text/plain' ], ['Not Found'] ];
}

sub redirect_list {
    my $req = shift;
    return [
        303, [ 'Location' => $req->uri->scheme . '://' . $req->uri->host_port ],
        []
    ];
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
    <title>ファイルアップロード</title>
  </head>
  <body>
    <p>アップロード</p>
    <form action="/upload" method="post" enctype="multipart/form-data">
      <input type="file" name="uploadfile" /> <input type="submit" value="アップロード" />
    </form>
    <p>アップロードファイル一覧</p>
    <ul>
[% FOREACH file in files %]
      <li>[% file %]</li>
[% END %]
    </ul>
  </body>
</html>
