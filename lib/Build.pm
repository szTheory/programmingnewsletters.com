package Build 1.0;

use strict;
use warnings;
use autodie;

use Exporter 'import';
our @EXPORT_OK   = qw(write_html_file);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

use lib 'lib';
use Presenter qw(newsletters);

use Mojo::Template;

use constant TEMPLATE_FILE => 'private/templates/index.html.ep';
use constant OUTPUT_FILE   => 'public/index.html';

sub _build_html {
  my ($grouped_entries) = newsletters();

  my $mt = Mojo::Template->new( vars => 1 );
  use Data::Dumper;
  print 'GROUPED ENTRIES ----' . "\n";
  print Dumper($grouped_entries);
  my $html =
    $mt->render_file( TEMPLATE_FILE, { grouped_entries => $grouped_entries } );

  return $html;
}

sub write_html_file {
  my $html = _build_html();
  use Data::Dumper;
  print "--------\n";
  print "$html\n";

  open my $fh, '>:encoding(UTF-8)', OUTPUT_FILE;
  print {$fh} $html;
  close $fh;

  return;
}

1;
