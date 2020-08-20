package Cache 1.0;

use strict;
use warnings;
use autodie;

use Exporter 'import';
our @EXPORT_OK   = qw(cached_presenter);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

use JSON::MaybeXS qw(encode_json decode_json);

use lib 'lib';
use Presenter qw(presenter);

use constant PRESENTER_CACHE_JSON_FILE => 'private/presenter-cache.json';

sub _write_json_cache {
  my ($presenter) = @_;

  open my $fh, '>:encoding(UTF-8)', PRESENTER_CACHE_JSON_FILE;
  print {$fh} encode_json($presenter);
  close $fh;

  return;
}

sub _read_json_cache {
  open my $fh, '<:encoding(UTF-8)', PRESENTER_CACHE_JSON_FILE;

  my $json = '';
  while ( my $line = <$fh> ) {
    $json .= $line;
  }

  close $fh;

  return decode_json($json);
}

sub _is_json_cached {
  if ( -e PRESENTER_CACHE_JSON_FILE ) {
    return 1;
  }
  else {
    return 0;
  }
}

sub cached_presenter {
  my ($should_rebuild) = @_;

  my $presenter;

  if ( $should_rebuild || !_is_json_cached() ) {
    print "/// REBUILDING PRESENTER ///\n";
    $presenter = presenter();
    _write_json_cache($presenter);
  }
  else {
    $presenter = _read_json_cache();
  }

  return $presenter;
}

1;
