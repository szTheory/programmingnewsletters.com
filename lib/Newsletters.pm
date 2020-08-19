package Newsletters 1.0;

use strict;
use warnings;
use autodie;

use Exporter 'import';
our @EXPORT_OK   = qw(newsletters_json);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

use JSON::MaybeXS qw(decode_json);
use LWP::Simple;
use XML::Twig;
use DateTime::Format::DateParse;

use constant NEWSLETTERS_JSON_FILE => 'newsletters.json';

sub _newsletters_file_json {
  open my $fh, '<:encoding(UTF-8)', NEWSLETTERS_JSON_FILE;

  my $json = '';
  while ( my $line = <$fh> ) {
    $json .= $line;
  }

  close $fh;

  return decode_json($json);
}

sub _newsletter_updated_at {
  my ($newsletter_entry) = @_;
  use Data::Dumper;
  print Dumper($newsletter_entry);
  my $name     = $newsletter_entry->{name};
  my $feed_url = $newsletter_entry->{feed_url};

  print "-- Downloading $name - $feed_url\n";
  my $content = get($feed_url);

  print "-- Parsing XML\n";
  my @dates;
  my $twig = XML::Twig->new(
    twig_handlers => {
      'pubDate'   => sub { push( @dates, $_->text_only() ) },
      '_default_' => sub { $_->purge },
    }
  );
  $twig->parse($content);

  my $timestamp =
    DateTime::Format::DateParse->parse_datetime( $dates[0] )->epoch();

  return $timestamp;
}

sub _newsletter_decorate_json {
  my ($json) = @_;

  print "............\n";
  use Data::Dumper;
  print Dumper($json);
  my $updated_at = _newsletter_updated_at($json);
  $json->{updated_at} = $updated_at;
  print Dumper($json);

  return $json;
}

sub newsletters_json {
  print "Parsing JSON list…\n";

  use Data::Dumper;
  my $json = _newsletters_file_json();
  print Dumper( $json->{entries} );

  print "---------------------------------------\n";
  print "Loading newsletter pages…\n";
  print "---------------------------------------\n";

  foreach my $entry ( @{ $json->{entries} } ) {
    _newsletter_decorate_json($entry);
  }

  print "///////////////\n";
  use Data::Dumper;
  print Dumper($json);
  return $json->{entries};
}

1;
