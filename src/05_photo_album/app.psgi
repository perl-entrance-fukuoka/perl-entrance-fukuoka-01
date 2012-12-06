use strict;
use warnings;
use utf8;

use File::Spec;
use File::Basename;
use constant UPLOAD_DIR => File::Spec->catdir( dirname(__FILE__), 'data' );

use Encode qw(encode_utf8);
use Plack::Request;
use Text::Xslate;

use Data::Section::Simple qw(get_data_section);
use File::stat;
use POSIX qw(strftime);

my $template = {
    list  => get_data_section('list.html'),
    photo => get_data_section('photo.html'),
};

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
    elsif ( $path =~ m|^/photo/([^/]+)$| ) {
        return photo( $req, $1 );
    }
    elsif ( $path =~ m|^/photo/([^/]+)/raw$| ) {
        return photo_raw( $req, $1 );
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

    my $tx = Text::Xslate->new(
        syntax => 'TTerse',
        module => ['Text::Xslate::Bridge::TT2Like'],
    );
    my $html = $tx->render_string( $template->{list}, { files => \@files } );
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

sub photo_raw {
    my ( $req, $filename ) = @_;
    my $file = File::Spec->catfile( UPLOAD_DIR, $filename );
    unless ( -f $file ) {
        return not_found();
    }
    my $content_type;
    if ( $filename =~ /\.png/ ) {
        $content_type = 'image/png';
    }
    elsif ( $filename =~ /\.jpe?g/ ) {
        $content_type = 'image/jpeg';
    }
    elsif ( $filename =~ /\.gif/ ) {
        $content_type = 'image/gif';
    }
    open my $fh, '<', $file or return server_error($!);
    return [ 200, [ 'Content-Type' => $content_type ], $fh ];
}

sub photo {
    my ( $req, $filename ) = @_;
    my $file = File::Spec->catfile( UPLOAD_DIR, $filename );
    unless ( -f $file ) {
        return not_found();
    }
    my $tx = Text::Xslate->new(
        syntax => 'TTerse',
        module => ['Text::Xslate::Bridge::TT2Like'],
    );
    my $stat = stat($file);
    my $html = $tx->render_string(
        $template->{photo},
        {
            file => {
                name => $filename,
                size => $stat->size,
                mtime =>
                  strftime( '%Y-%m-%d %H:%M:%S', localtime( $stat->mtime ) )
            }
        }
    );
    return [
        200,
        [ 'Content-Type' => 'text/html; charset=UTF-8' ],
        [ encode_utf8($html) ]
    ];
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
@@ list.html
<html>
  <head>
    <title>フォトアルバム</title>
  </head>
  <body>
    <p>フォトアルバム</p>
    <form action="/upload" method="post" enctype="multipart/form-data">
      <input type="file" name="uploadfile" /> <input type="submit" value="アップロード" />
    </form>
[% FOREACH file in files %]
    <a href="/photo/[% url(file) %]"><img src="/photo/[% url(file) %]/raw" style="max-height: 100px; border: 2px solid #ccc;" alt="[% $file %]" /></a>
[% END %]
  </body>
</html>

@@ photo.html
<html>
  <head>
    <title>[% file.name %] - フォトアルバム</title>
  </head>
  <body>
    <p>フォトアルバム</p>
    <a href="/">&lt;&lt; 戻る</a>
    <div>
      <img src="/photo/[% url(file.name) %]/raw" style="border: 2px solid #ccc;" />
      <dl>
        <dt>ファイル名</dt><dd>[% file.name %]</dd>
        <dt>ファイルサイズ</dt><dd>[% file.size %] byte</dd>
        <dt>アップロード日時</dt><dd>[% file.mtime %]</dd>
      </dl>
    </div>
  </body>
</html>
