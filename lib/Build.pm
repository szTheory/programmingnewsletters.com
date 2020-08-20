package Build 1.0;

use strict;
use warnings;
use autodie;

use lib 'lib';
use Build::HTML qw(write_html_file);
use Build::CSS qw(write_css_files);

use Exporter 'import';
our @EXPORT_OK   = qw(build);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

use Mojo::Template;

sub build {
  my ($should_rebuild) = @_;

  write_html_file($should_rebuild);
  write_css_files();

  return;
}

1;
