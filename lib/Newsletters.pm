package Newsletters 1.0;

use strict;
use warnings;
use autodie;

use Exporter 'import';
our @EXPORT_OK   = qw(newsletters);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

use constant NEWSLETTERS_JSON_FILE             => 'private/newsletters.json';
use constant RSS_FEED_DEFAULT_UPDATED_SELECTOR => 'item/pubDate';
use constant RSS_FEED_DEFAULT_LINK_SELECTOR    => 'item/link';
use constant USER_AGENT =>
'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:15.0) Gecko/20100101 Firefox/15.0.1';
use constant GET_TIMEOUT         => 5;
use constant DATE_COMPARE_PRINTF => '%b %d';

use JSON::MaybeXS qw(decode_json);
use LWP::UserAgent;
use XML::Twig;
use DateTime::Format::DateParse;
use Date::Manip::Date;
use Mojo::DOM;
use List::SomeUtils qw(indexes);

sub _newsletters_file_json {
  my ($first_only) = @_;

  # read JSON file to string
  open my $fh, '<:encoding(UTF-8)', NEWSLETTERS_JSON_FILE;
  my $json_str = '';
  while ( my $line = <$fh> ) {
    $json_str .= $line;
  }
  close $fh;

  # decode JSON from string
  my $json = decode_json($json_str);

  # pull only the first entry?
  if ($first_only) {
    $json->{entries} = [ $json->{entries}[0] ];
  }

  return $json;
}

sub _newsletter_info_rss {
  my ($newsletter_entry) = @_;

  my $name     = $newsletter_entry->{name};
  my $url      = $newsletter_entry->{url};
  my $feed_url = $newsletter_entry->{feed_url};

  print "\nDownloading $name - $feed_url\n";
  my $ua = LWP::UserAgent->new( timeout => GET_TIMEOUT );
  $ua->agent(USER_AGENT);
  my $res = $ua->get($feed_url);
  if ( $res->is_error() ) {
    warn 'XML download error: ' . $res->error_as_HTML();
    return {};
  }
  my $xml = $res->content;
  if ( !$xml ) {
    die "Could not load XML for $name - $feed_url";
  }

  my $updated_selector =
    $newsletter_entry->{updated_selector} || RSS_FEED_DEFAULT_UPDATED_SELECTOR;
  my $updated_regex = $newsletter_entry->{updated_regex};
  my $link_selector =
    $newsletter_entry->{link_selector} || RSS_FEED_DEFAULT_LINK_SELECTOR;
  my $link_attr          = $newsletter_entry->{link_attr};
  my $link_last          = $newsletter_entry->{link_last};
  my $link_contains_text = $newsletter_entry->{link_contains_text};
  my $link_base_filter   = $newsletter_entry->{link_base_filter};
  my $link_constant      = $newsletter_entry->{link_constant};

  print "----> Parsing XML\n";
  my @dates;
  my @links;

  # Build up a list of XML parsing callback handlers
  # starting with the updated timestamp selector
  my $twig_handlers = {
    $updated_selector => sub { push( @dates, $_->text_only() ) },

    # '_default_' => sub { $_->purge },
  };

  # Add an XML parsing callback for the link selector
  my $link_selector_callback;
  if ($link_attr) {
    $link_selector_callback = sub { push( @links, $_->atts()->{$link_attr} ) }
  }
  else {
    $link_selector_callback = sub { push( @links, $_->text_only() ) }
  }

  # don't need a link callback handler if
  # the link is always the same
  unless ($link_constant) {

    # Tie the link callback to the configured link selector
    $twig_handlers->{$link_selector} = $link_selector_callback;
  }

  # Parse XML using the callbacks
  my $twig = XML::Twig->new( twig_handlers => $twig_handlers );
  $twig->safe_parse($xml);

  my $timestamp_index = 0;
  my $link_index      = 0;

  if ($link_base_filter) {
    @links = grep { /$link_base_filter/ } @links;
  }

  my $link;
  if ($link_contains_text) {
    if ( $#links != $#dates ) {
      warn
"Different number of $#links links and $#dates dates for $name - $feed_url";
      return {};
    }

    my ($matching_index) = indexes { /$link_contains_text/ } @links;

    $timestamp_index = $matching_index;
    $link_index      = $matching_index;
  }
  elsif ($link_last) {
    $link_index = -1;
  }

  # link is always the same no matter what
  elsif ($link_constant) {
    $link = $link_constant;
  }
  $link = $links[$link_index];

  my $timestamp;
  my $timestamp_string = $dates[$timestamp_index];
  if ($updated_regex) {
    ($timestamp_string) = $timestamp_string =~ qr{$updated_regex};
  }
  my $datetime = DateTime::Format::DateParse->parse_datetime($timestamp_string);
  if ($datetime) {
    $timestamp = $datetime->epoch();
  }
  else {
    warn
      "Error while parsing timestamp: $timestamp_string for $name - $feed_url";
    return {};
  }

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

  my $name = $newsletter_entry->{name};
  my $url  = $newsletter_entry->{url};

  print "\nDownloading $name - $url\n";
  my $ua = LWP::UserAgent->new( timeout => GET_TIMEOUT );
  $ua->agent(USER_AGENT);
  my $res  = $ua->get($url);
  my $html = $res->content;

  # good riddance
  if ( $html =~ /Attention Required! | Cloudflare/ ) {
    warn "Caught in CloudFlare while fetching $name - $url";
    return {};
  }

  my $updated_selector     = $newsletter_entry->{updated_selector};
  my $updated_regex        = $newsletter_entry->{updated_regex};
  my $updated_attr         = $newsletter_entry->{updated_attr};
  my $updated_fixed_day    = $newsletter_entry->{updated_fixed_day};
  my $link_selector        = $newsletter_entry->{link_selector};
  my $link_attr            = $newsletter_entry->{link_attr};
  my $follow_link          = $newsletter_entry->{follow_link};
  my $european_date_format = $newsletter_entry->{european_date_format};

  print "----> Parsing HTML\n";
  $html = Mojo::Util::decode( 'UTF-8', $html );
  my $dom = Mojo::DOM->new($html);
  if ( !$dom ) {
    die "Could not load DOM for $name - $url";
  }

  my $timestamp_string;
  my $link;

  if ($updated_fixed_day) {

    my $day = Date::Manip::Date->new;
    $day->parse($updated_fixed_day);

    my $today = Date::Manip::Date->new;
    $today->parse('today');

    my $selected_day;
    if (
      $day->printf(DATE_COMPARE_PRINTF) eq $today->printf(DATE_COMPARE_PRINTF) )
    {
      $selected_day = $day;
    }
    else {
      my $last_day = Date::Manip::Date->new;
      $last_day->parse("last $updated_fixed_day");

      $selected_day = $last_day;
    }

    # get epoch (seconds)
    $timestamp_string = $selected_day->printf(DATE_COMPARE_PRINTF);

    # get the link for the current newsletter issue
    $link = $dom->at($link_selector)->attr($link_attr);
  }
  else {
    my $element;

    # don't bother trying to parse the date if we have to follow
    # a link before we can find out the update timestamp.
    # we'll circle back on the next pass of this function to get it
    if ( !$follow_link ) {
      $element = $dom->at($updated_selector);

      if ( !$element ) {
        die
"Could not find updated timestamp for $name with selector '$updated_selector' for URL $url";
      }

      if ($updated_regex) {

        # get timestamp from an attribute or the underlying element text
        my $updated_text =
          $updated_attr ? $element->attr($updated_attr) : $element->text;

        # filter timestamp with regular expression
        ($timestamp_string) = $updated_text =~ qr{$updated_regex};
      }
      else {
        $timestamp_string = $element->text;
      }
    }

    # get the link for the current newsletter issue
    if ($link_selector) {

      # find link using selector
      my $link_elem = $dom->at($link_selector);
      $link = $link_elem->attr('href');
    }
    elsif ($link_attr) {

      # the link is contained within an attribute of
      # the updated timestamp element
      $link = $element->attr($link_attr);
    }
    else {

      # newsletter link is the original URL
      $link = $url;
    }
  }

  my $timestamp;

  # don't bother trying to parse the updated timestamp
  # if we have to follow a link to get that info first
  if ( !$follow_link ) {

    # trim surrounding whitespace
    $timestamp_string =~ s/(^\s+|\s+$)//g;

    # replace dots with dashes
    $timestamp_string =~ s/\./-/g;

    # swap month and day for european date formats
    if ($european_date_format) {
      $timestamp_string =~ /^(\d+)-(\d+)-(\d+)$/;
      $timestamp_string = "$2-$1-$3";
    }

    # parse the updated timestamp
    my $datetime =
      DateTime::Format::DateParse->parse_datetime($timestamp_string);
    unless ($datetime) {
      die "Could not parse datetime for timestamp string: $timestamp_string";
    }

    $timestamp = $datetime->epoch();
    if ( !$timestamp ) {
      die "Could not find updated timestamp for $name - $url";
    }
  }

  if ( !$link ) {
    die "Could not find link for $name - $url";
  }

  return {
    updated_at => $timestamp,
    url        => $link
  };
}

# parse newsletter info from either an XML feed or an HTML page
sub _newsletter_info {
  my ($newsletter_entry) = @_;

  my $info;

  # XML
  if ( $newsletter_entry->{feed_url} ) {

    # get newsletter info from XML parsing
    $info = _newsletter_info_rss($newsletter_entry);
  }

  # HTML
  else {
    # Need to follow a link before we can find the updated timestamp
    # which means parsing HTML before the main scrape
    if ( $newsletter_entry->{follow_link} ) {
      my $start_info = _newsletter_info_html($newsletter_entry);

      # get the URL where the updated timestamp lives
      $newsletter_entry->{url} = $start_info->{url};

      # don't need to follow links for the next pass
      # because we have enough info to get the updated timestamp now
      delete $newsletter_entry->{follow_link};

      # we already know the link for the first pass
      # so we'll default to the redirect URL for the link
      # therefore we don't need the link selector anymore
      delete $newsletter_entry->{link_selector};
    }

    # get newsletter info from HTML parsing
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
  my ($first_only) = @_;

  print "Parsing JSON list…\n";
  my $json = _newsletters_file_json($first_only);

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
