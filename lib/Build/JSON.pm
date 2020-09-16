package Build::JSON 1.0;

use strict;
use warnings;
use autodie;

use Exporter 'import';
our @EXPORT_OK   = qw(write_json_file read_json_file);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

use File::Spec;
use JSON::MaybeXS qw(encode_json decode_json);

use lib 'lib';
use Presenter qw(presenter API_PATH);

use constant JSON_FILE => File::Spec->catfile( 'public/', API_PATH );

sub write_json_file {
  my ( $should_rebuild, $first_only ) = @_;

  my $presenter = presenter( $should_rebuild, $first_only );

  # write to file
  open my $fh, '>:encoding(UTF-8)', JSON_FILE;
  print {$fh} encode_json($presenter);
  close $fh;

  return;
}

sub read_json_file {

  # read from file into a string
  open my $fh, '<:encoding(UTF-8)', JSON_FILE;
  my $json_str = '';
  while ( my $line = <$fh> ) {
    $json_str .= $line;
  }
  close $fh;

  # decode json from string
  return decode_json($json_str);
}

1;
