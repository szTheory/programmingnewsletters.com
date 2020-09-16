package Build::HTML 1.0;

use strict;
use warnings;
use autodie;

use Exporter 'import';
our @EXPORT_OK   = qw(write_html_file);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

use lib 'lib';
use Build::JSON qw(read_json_file);

use Mojo::Template;
use HTML::Packer;

use constant TEMPLATE_FILE => 'private/templates/index.html.ep';
use constant OUTPUT_FILE   => 'public/index.html';

sub _build_html {
  my $json = read_json_file();
  my $mt   = Mojo::Template->new( vars => 1 );

  my $html = $mt->render_file(
    TEMPLATE_FILE,
    {
      categories      => $json->{categories},
      grouped_entries => $json->{grouped_entries},
      year            => $json->{year},
      title           => $json->{title},
      subtitle        => $json->{subtitle},
      developer       => $json->{developer},
      source_url      => $json->{source_url},
      api_path        => $json->{api_path}
    }
  );

  return $html;
}

sub write_html_file {

  # build HTML
  my $html = _build_html();

  # minify
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

  # write to file
  open my $fh, '>:encoding(UTF-8)', OUTPUT_FILE;
  print {$fh} $html;
  close $fh;

  return;
}

1;
