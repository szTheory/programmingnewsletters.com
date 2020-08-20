package Build 1.0;

use strict;
use warnings;
use autodie;

use Exporter 'import';
our @EXPORT_OK   = qw(write_html_file);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

use lib 'lib';
use Presenter qw(presenter);

use Mojo::Template;

use constant TEMPLATE_FILE => 'private/templates/index.html.ep';
use constant OUTPUT_FILE   => 'public/index.html';

sub _build_html {
  my ($should_rebuild) = @_;

  my $presenter = presenter($should_rebuild);

  my $mt = Mojo::Template->new( vars => 1 );

  my $html = $mt->render_file(
    TEMPLATE_FILE,
    {
      categories      => $presenter->{categories},
      grouped_entries => $presenter->{grouped_entries}
    }
  );

  return $html;
}

sub write_html_file {
  my ($should_rebuild) = @_;

  my $html = _build_html($should_rebuild);
  use Data::Dumper;

  open my $fh, '>:encoding(UTF-8)', OUTPUT_FILE;
  print {$fh} $html;
  close $fh;

  return;
}

1;
