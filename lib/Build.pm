package Build 1.0;

use strict;
use warnings;
use autodie;

use lib 'lib';
use Build::HTML qw(write_html_file);
use Build::CSS qw(write_css_files);
use Build::JavaScript qw(write_js_files);
use Build::JSON qw(write_json_file);

use Exporter 'import';
our @EXPORT_OK   = qw(build);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

use Mojo::Template;

sub build {
  my ( $should_rebuild, $first_only ) = @_;

  write_json_file( $should_rebuild, $first_only );
  write_html_file();
  write_css_files();
  write_js_files();

  return;
}

1;
