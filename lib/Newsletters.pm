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
use Date::Manip qw(ParseDate UnixDate);

use Mojo::Dom;

use constant NEWSLETTERS_JSON_FILE             => 'private/newsletters.json';
use constant RSS_FEED_DEFAULT_UPDATED_SELECTOR => 'pubDate';
use constant RSS_FEED_DEFAULT_LINK_SELECTOR    => 'item/link';

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
  print Dumper($newsletter_entry);
  my $name     = $newsletter_entry->{name};
  my $feed_url = $newsletter_entry->{feed_url};

  print "-- Downloading $name - $feed_url\n";
  my $xml = get($feed_url);
  my $updated_selector =
    $newsletter_entry->{updated_selector} || RSS_FEED_DEFAULT_UPDATED_SELECTOR;
  my $link_selector =
    $newsletter_entry->{link_selector} || RSS_FEED_DEFAULT_LINK_SELECTOR;
  my $link_attr = $newsletter_entry->{link_attr};
  print Dumper($updated_selector);
  print Dumper($link_selector);

  print "-- Parsing XML\n";
  my @dates;
  my @links;

  my $twig_handlers = {
    $updated_selector => sub { push( @dates, $_->text_only() ) },

    # '_default_' => sub { $_->purge },
  };

  my $link_selector_callback;
  if ($link_attr) {
    print ",,,, link_attr\n";
    $link_selector_callback = sub { push( @links, $_->atts()->{$link_attr} ) }
  }
  else {
    print ",,,, NOOOOO link_attr\n";
    $link_selector_callback = sub { push( @links, $_->text_only() ) }
  }
  $twig_handlers->{$link_selector} = $link_selector_callback;
  print "############## twig handlers\n";
  print Dumper($twig_handlers);

  my $twig = XML::Twig->new( twig_handlers => $twig_handlers );
  $twig->parse($xml);
  print "--- Dates---\n";
  print Dumper(@dates);
  print "---- LINKS ----\n";
  print Dumper(@links);

  my $timestamp =
    DateTime::Format::DateParse->parse_datetime( $dates[0] )->epoch();

  return {
    updated_at => $timestamp,
    url        => @links[0]
  };
}

sub _newsletter_info_html {
  my ($newsletter_entry) = @_;

  use Data::Dumper;
  print Dumper($newsletter_entry);
  my $name = $newsletter_entry->{name};
  my $url  = $newsletter_entry->{url};

  print "-- Downloading $name - $url\n";
  my $html = get($url);
  print Dumper($html);

  my $updated_selector  = $newsletter_entry->{updated_selector};
  my $updated_regex     = $newsletter_entry->{updated_regex};
  my $updated_fixed_day = $newsletter_entry->{updated_fixed_day};
  my $link_selector     = $newsletter_entry->{link_selector};
  my $link_attr         = $newsletter_entry->{link_attr};

  print "-- Parsing HTML\n";
  my $dom = Mojo::DOM->new($html);
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
    $timestamp_string = UnixDate( $timestamp_string, "%A %D" );

    $link = $dom->at($link_selector)->attr($link_attr);
  }
  else {
    my $element = $dom->at($updated_selector);

    print ".... ELEMENT\n";
    print Dumper($element);

    if ( !$element ) {
      die
"Could not find updated timestamp for $name with selector '$updated_selector' for URL $url";
    }

    ($timestamp_string) = $element->text =~ qr{$updated_regex};

    $link = $element->attr($link_attr);
  }

  print "--- TIMESTAMP STRING -----\n";
  print Dumper($timestamp_string);

  my $timestamp =
    DateTime::Format::DateParse->parse_datetime($timestamp_string)->epoch();

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

sub _newsletter_decorate_json {
  my ($json) = @_;

  print "............\n";
  use Data::Dumper;
  print Dumper($json);
  my $info = _newsletter_info($json);
  print "~~~~ INFO ~~~~~\n";
  print Dumper($info);
  $json->{updated_at} = $info->{updated_at};
  $json->{url}        = $info->{url};
  print "~~~~~ JSON ~~~~~\n";
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
  print Dumper($json);
  return $json->{entries};
}

1;
