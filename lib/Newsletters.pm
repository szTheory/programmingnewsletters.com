package Newsletters 1.0;

use strict;
use warnings;
use autodie;

use Exporter 'import';
our @EXPORT_OK   = qw(newsletters);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

use JSON::MaybeXS qw(decode_json);
use LWP::UserAgent;
use XML::Twig;
use DateTime::Format::DateParse;
use Date::Manip qw(ParseDate UnixDate);
use Mojo::Dom;
use List::SomeUtils qw(indexes);

use constant NEWSLETTERS_JSON_FILE             => 'private/newsletters.json';
use constant RSS_FEED_DEFAULT_UPDATED_SELECTOR => 'pubDate';
use constant RSS_FEED_DEFAULT_LINK_SELECTOR    => 'item/link';
use constant USER_AGENT =>
'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:15.0) Gecko/20100101 Firefox/15.0.1';
use constant GET_TIMEOUT => 5;

sub _newsletters_file_json {
  open my $fh, '<:encoding(UTF-8)', NEWSLETTERS_JSON_FILE;

  my $json = '';
  while ( my $line = <$fh> ) {
    $json .= $line;
  }

  close $fh;

  return decode_json($json);
}

sub _newsletter_info_rss {
  my ($newsletter_entry) = @_;

  use Data::Dumper;

  # print Dumper($newsletter_entry);
  my $name     = $newsletter_entry->{name};
  my $url      = $newsletter_entry->{url};
  my $feed_url = $newsletter_entry->{feed_url};

  print "\nDownloading $name - $feed_url\n";
  my $ua = LWP::UserAgent->new( timeout => GET_TIMEOUT );
  $ua->agent(USER_AGENT);
  my $res = $ua->get($feed_url);
  if ( $res->is_error() ) {
    die 'XML download error: ' . $res->error_as_HTML();
  }
  my $xml = $res->content;
  if ( !$xml ) {
    die "Could not load XML for $name - $feed_url";
  }

  # print ".... XML ....\n";
  # print Dumper($xml);
  my $updated_selector =
    $newsletter_entry->{updated_selector} || RSS_FEED_DEFAULT_UPDATED_SELECTOR;
  my $link_selector =
    $newsletter_entry->{link_selector} || RSS_FEED_DEFAULT_LINK_SELECTOR;
  my $link_attr          = $newsletter_entry->{link_attr};
  my $link_last          = $newsletter_entry->{link_last};
  my $link_contains_text = $newsletter_entry->{link_contains_text};

  print "----> Parsing XML\n";
  my @dates;
  my @links;

  my $twig_handlers = {
    $updated_selector => sub { push( @dates, $_->text_only() ) },

    # '_default_' => sub { $_->purge },
  };

  my $link_selector_callback;
  if ($link_attr) {
    $link_selector_callback = sub { push( @links, $_->atts()->{$link_attr} ) }
  }
  else {
    $link_selector_callback = sub { push( @links, $_->text_only() ) }
  }
  $twig_handlers->{$link_selector} = $link_selector_callback;

  my $twig = XML::Twig->new( twig_handlers => $twig_handlers );
  $twig->parse($xml);

  my $timestamp_index = 0;
  my $link_index      = 0;

  my $link;
  if ($link_contains_text) {
    my ($matching_index) = indexes { /$link_contains_text/ } @links;

    $timestamp_index = $matching_index;
    $link_index      = $matching_index;
  }
  elsif ($link_last) {
    $link_index = -1;
  }
  $link = $links[$link_index];

  my $timestamp =
    DateTime::Format::DateParse->parse_datetime( $dates[$timestamp_index] )
    ->epoch();

  if ( !$link ) {
    $link = $url;
  }
  if ( !$timestamp ) {
    die "Could not find updated timestamp for $name - $feed_url";
  }

  return {
    updated_at => $timestamp,
    url        => $link
  };
}

sub _newsletter_info_html {
  my ($newsletter_entry) = @_;

  use Data::Dumper;

  # print Dumper($newsletter_entry);
  my $name = $newsletter_entry->{name};
  my $url  = $newsletter_entry->{url};

  print "\nDownloading $name - $url\n";
  my $ua = LWP::UserAgent->new( timeout => GET_TIMEOUT );
  $ua->agent(USER_AGENT);
  my $res  = $ua->get($url);
  my $html = $res->content;

  my $updated_selector  = $newsletter_entry->{updated_selector};
  my $updated_regex     = $newsletter_entry->{updated_regex};
  my $updated_fixed_day = $newsletter_entry->{updated_fixed_day};
  my $link_selector     = $newsletter_entry->{link_selector};
  my $link_attr         = $newsletter_entry->{link_attr};

  print "-- Parsing HTML\n";
  my $dom = Mojo::DOM->new($html);
  if ( !$dom ) {
    die "Could not load DOM for $name - $url";
  }

  my $timestamp_string;
  my $link;

  if ($updated_fixed_day) {
    my $day = ParseDate($updated_fixed_day);

    if ( $day eq ParseDate('today') ) {
      $timestamp_string = $day;
    }
    else {
      $timestamp_string = ParseDate("last $updated_fixed_day");
    }
    $timestamp_string = UnixDate( $timestamp_string, '%A %D' );

    $link = $dom->at($link_selector)->attr($link_attr);
  }
  else {
    my $element = $dom->at($updated_selector);

    # print Dumper( $element->text );

    if ( !$element ) {
      die
"Could not find updated timestamp for $name with selector '$updated_selector' for URL $url";
    }

    if ($updated_regex) {
      ($timestamp_string) = $element->text =~ qr{$updated_regex};
    }
    else {
      $timestamp_string = $element->text;
    }

    if ($link_selector) {
      my $link_elem = $dom->at($link_selector);
      $link = $link_elem->attr('href');
    }
    elsif ($link_attr) {
      $link = $element->attr($link_attr);
    }
    else {
      $link = $url;
    }
  }

  my $timestamp =
    DateTime::Format::DateParse->parse_datetime($timestamp_string)->epoch();

  if ( !$link ) {
    die "Could not find link for $name - $url";
  }
  if ( !$timestamp ) {
    die "Could not find updated timestamp for $name - $url";
  }

  return {
    updated_at => $timestamp,
    url        => $link
  };
}

sub _newsletter_info {
  my ($newsletter_entry) = @_;

  my $info;

  if ( $newsletter_entry->{feed_url} ) {
    $info = _newsletter_info_rss($newsletter_entry);
  }
  else {
    $info = _newsletter_info_html($newsletter_entry);
  }

  return $info;
}

sub _newsletter_decorate {
  my ($json) = @_;

  my $info = _newsletter_info($json);
  $json->{updated_at} = $info->{updated_at};
  $json->{url}        = $info->{url};

  return $json;
}

sub newsletters {
  print "Parsing JSON list…\n";
  my $json = _newsletters_file_json();

  print "\n";
  print "---------------------------------------\n";
  print "Loading newsletter pages…\n";
  print "---------------------------------------\n";

  foreach my $entry ( @{ $json->{entries} } ) {
    _newsletter_decorate($entry);
  }

  return $json->{entries};
}

1;
