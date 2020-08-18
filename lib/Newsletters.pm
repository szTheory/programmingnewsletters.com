package Build 1.0;

use strict;
use warnings;
use autodie;

use JSON::MaybeXS qw(decode_json);
use LWP::Simple;
use XML::Twig;
use DateTime::Format::DateParse;

sub newsletters_json {
  open my $fh, '<:encoding(UTF-8)', 'newsletters.json';

  my $json = '';
  while ( my $line = <$fh> ) {
    $json .= $line;
  }

  close $fh;

  return decode_json($json);
}

sub newsletter_updated_at {
  my ($newsletter_entry) = @_;

  my $name = $newsletter_entry->{'name'};
  my $url  = $newsletter_entry->{'url'};

  print "-- Downloading $name - $url\n";
  my $content = get($url);

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
    DateTime::Format::DateParse->parse_datetime( @dates[0] )->datetime;

  return $timestamp;
}

print "Parsing JSON list…\n";

use Data::Dumper;
my $json = newsletters_json();
print Dumper($json);

print "---------------------------------------\n";
print "Loading newsletter pages…\n";
print "---------------------------------------\n";

my $entry      = $json->{entries}->[0];
my $updated_at = newsletter_updated_at($entry);
$entry->{updated_at} = $updated_at;
print Dumper($entry);

1;

