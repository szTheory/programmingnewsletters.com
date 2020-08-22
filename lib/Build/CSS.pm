package Build::CSS 1.0;

use strict;
use warnings;
use autodie;

use Exporter 'import';
our @EXPORT_OK   = qw(write_css_files);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

# use CSS::Compressor qw(css_compress);
use CSS::Packer;

use File::Basename qw(basename);
use File::Spec;

use constant SOURCE_DIR      => 'private/css';
use constant OUTPUT_DIR      => 'public/css';
use constant OUTPUT_FILENAME => 'index.css';
use constant SOURCE_CSS_FILENAMES =>
  ( 'normalize.css', 'default.css', 'main.css' );

sub _compress_css_file {
  my ($filename) = @_;

  open my $fh, '<:encoding(UTF-8)',
    File::Spec->catfile( SOURCE_DIR, $filename );

  my $css = '';
  while ( my $line = <$fh> ) {
    $css .= $line;
  }

  close $fh;

  my $packer = CSS::Packer->init();
  $packer->minify( \$css,
    { compress => 'minify', remove_copyright => 'true' } );

  return $css;
}

sub _write_css_file {
  my ($compressed_css) = @_;

  my $output_full_path = File::Spec->catfile( OUTPUT_DIR, OUTPUT_FILENAME );

  open my $fh, '>:encoding(UTF-8)', $output_full_path;
  print {$fh} $compressed_css;
  close $fh;

  return;
}

sub write_css_files {
  my $compressed_css = '';

  foreach my $source_filename (SOURCE_CSS_FILENAMES) {
    $compressed_css .= _compress_css_file($source_filename);
  }

  _write_css_file($compressed_css);

  return;
}

1;
