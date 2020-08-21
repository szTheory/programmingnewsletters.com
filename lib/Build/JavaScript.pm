package Build::JavaScript 1.0;

use strict;
use warnings;
use autodie;

use Exporter 'import';
our @EXPORT_OK   = qw(write_js_files);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

use JavaScript::Packer;

use File::Basename qw(basename);
use File::Spec;

use constant SOURCE_DIR => 'private/javascript';
use constant OUTPUT_DIR => 'public/javascript';

sub _compress_js_file {
  my ($filename) = @_;

  open my $fh, '<:encoding(UTF-8)',
    File::Spec->catfile( SOURCE_DIR, $filename );

  my $js = '';
  while ( my $line = <$fh> ) {
    $js .= $line;
  }

  close $fh;

  my $packer = JavaScript::Packer->init();
  $packer->minify( \$js, { compress => 'clean', remove_copyright => 'true' } );

  return $js;
}

sub _source_js_filenames {
  opendir( my $dh, SOURCE_DIR );
  my @filenames = grep { /\.js\Z/ } readdir($dh);

  return @filenames;
}

sub _write_js_file {
  my ( $source_filename, $compressed_js ) = @_;

  my $output_filename  = basename($source_filename);
  my $output_full_path = File::Spec->catfile( OUTPUT_DIR, $output_filename );

  open my $fh, '>:encoding(UTF-8)', $output_full_path;
  print {$fh} $compressed_js;
  close $fh;

  return;
}

sub write_js_files {
  foreach my $source_filename ( _source_js_filenames() ) {
    my $compressed_js = _compress_js_file($source_filename);
    _write_js_file( $source_filename, $compressed_js );
  }

  return;
}

1;
