package Build::HTML 1.0;

use strict;
use warnings;
use autodie;

use Exporter 'import';
our @EXPORT_OK   = qw(write_html_file);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

use lib 'lib';
use Presenter qw(presenter);

use Mojo::Template;
use HTML::Packer;

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
      grouped_entries => $presenter->{grouped_entries},
      year            => $presenter->{year},
      title           => $presenter->{title},
      subtitle        => $presenter->{subtitle},
      developer       => $presenter->{developer},
      source_url      => $presenter->{source_url}
    }
  );

  return $html;
}

sub write_html_file {
  my ($should_rebuild) = @_;

  my $html   = _build_html($should_rebuild);
  my $packer = HTML::Packer->init();
  $packer->minify(
    \$html,
    {
      remove_comments            => 'true',
      remove_newlines            => 'true',
      remove_comments_aggressive => 'true',
      html5                      => 'true'
    }
  );

  open my $fh, '>:encoding(UTF-8)', OUTPUT_FILE;
  print {$fh} $html;
  close $fh;

  return;
}

1;
