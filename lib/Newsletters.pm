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
use constant GET_TIMEOUT               => 5;
use constant DATE_COMPARE_PRINTF       => '%b %d';
use constant TIMESTAMP_MISSING_CENTURY => qr/^(\d+) (\w+), (\d{2})$/;
use constant TIMESTAMP_MISSING_DAY     => qr/^(\w+) (\d{4})$/;

use JSON::MaybeXS qw(decode_json);
use LWP::UserAgent;
use XML::Twig;
use DateTime::Format::DateParse;
use Date::Manip::Date;
use Mojo::DOM;
use List::SomeUtils qw(indexes);

use Translate qw(timestamp_string_normalize_french);

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
    warn "Could not load XML for $name - $feed_url";
    return {};
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
  my $link_regex         = $newsletter_entry->{link_regex};

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

  # process the link text
  if ($link_regex) {
    ($link) = $link =~ qr{$link_regex};
  }

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
  if ( index( $html, "Attention Required!" ) != -1 ) {
    warn "Caught in CloudFlare while fetching $name - $url";
    return {};
  }
  if ( index( $html, "Generated by cloudfront" ) != -1 ) {
    warn "Caught in Cloudfront while fetching $name - $url";
    return {};
  }

  my $updated_selector     = $newsletter_entry->{updated_selector};
  my $updated_regex        = $newsletter_entry->{updated_regex};
  my $updated_attr         = $newsletter_entry->{updated_attr};
  my $updated_fixed_day    = $newsletter_entry->{updated_fixed_day};
  my $updated_link_attr    = $newsletter_entry->{updated_link_attr};
  my $link_selector        = $newsletter_entry->{link_selector};
  my $link_constant        = $newsletter_entry->{link_contant};
  my $follow_link          = $newsletter_entry->{follow_link};
  my $european_date_format = $newsletter_entry->{european_date_format};
  my $translate_french_timestamp =
    $newsletter_entry->{translate_french_timestamp};

  print "----> Parsing HTML\n";
  $html = Mojo::Util::decode( 'UTF-8', $html );

  # DEBUG
  # use Data::Dumper;
  # print Dumper($html);

  my $dom = Mojo::DOM->new($html);
  if ( !$dom ) {
    die "Could not load DOM for $name - $url";
  }

  my $timestamp_string;
  my $link;
  my $updated_element;

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
  }
  else {

    # don't bother trying to parse the date if we have to follow
    # a link before we can find out the update timestamp.
    # we'll circle back on the next pass of this function to get it
    if ( !$follow_link ) {
      $updated_element = $dom->at($updated_selector);

      if ( !$updated_element ) {
        warn
"Could not find updated timestamp element with selector: $updated_selector for $name - $url\n";
        return {};
      }

      # get timestamp from an attribute or the underlying element text
      my $updated_text =
          $updated_attr
        ? $updated_element->attr($updated_attr)
        : $updated_element->text;

      $timestamp_string = $updated_text;

      # filter timestamp with regular expression
      if ($updated_regex) {
        ($timestamp_string) = $updated_text =~ qr{$updated_regex};
      }
    }
  }

  # get the link for the current newsletter issue
  my $link_element;
  if ($link_selector) {

    # find link using selector
    $link_element = $dom->at($link_selector);
  }

  if ($updated_link_attr) {

    # the link is contained within an attribute of
    # the updated timestamp element
    $link = $updated_element->attr($updated_link_attr);
  }
  elsif ($link_element) {
    $link = $link_element->attr('href');
  }
  else {
    # newsletter link is the original URL
    $link = $url;
  }

  my $timestamp;

  # don't bother trying to parse the updated timestamp
  # if we have to follow a link to get that info first
  if ( !$follow_link ) {

    # trim surrounding whitespace
    $timestamp_string =~ s/(^\s+|\s+$)//g;

    # replace Feburary (typo) with February
    $timestamp_string =~ s/Feburary/February/g;

    # replace dots with dashes
    $timestamp_string =~ s/\./-/g;

    # swap month and day for european date formats
    if ($european_date_format) {
      $timestamp_string =~ /^(\d+)[-\/.](\d+)[-\/.](\d+)$/;
      $timestamp_string = "$2-$1-$3";
    }

    # add century if the year is only two digits
    if ( $timestamp_string =~ TIMESTAMP_MISSING_CENTURY ) {
      $timestamp_string = "$1 $2, 20$3";
    }

    # add day if the date is only a month and a year
    if ( $timestamp_string =~ TIMESTAMP_MISSING_DAY ) {
      my $day = 31;

      if ( $1 eq "Feb" || $1 eq "February" ) {
        $day = 28;
      }
      elsif ( $1 eq "Apr"
        || $1 eq "April"
        || $1 eq "Jun"
        || $1 eq "June"
        || $1 eq "Sep"
        || $1 eq "September"
        || $1 eq "Nov"
        || $1 eq "November" )
      {
        $day = 30;
      }

      $timestamp_string = "$1 $day, $2";
    }

    # translate from french
    if ($translate_french_timestamp) {
      $timestamp_string = timestamp_string_normalize_french($timestamp_string);
    }

    # parse the updated timestamp
    my $datetime =
      DateTime::Format::DateParse->parse_datetime($timestamp_string);
    unless ($datetime) {
      warn "Could not parse datetime for timestamp string: $timestamp_string";
      return {};
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

      # build the URL where the updated timestamp lives
      my $timestamp_page_url = $start_info->{url};

      # is there a base URL?
      if ( $newsletter_entry->{base_url} ) {

# then build the full URL by concatenating the base URL and the timestamp page URL
# and get the string value of the URI object
        $timestamp_page_url =
          URI->new_abs( $timestamp_page_url, $newsletter_entry->{base_url} )
          ->as_string;

        # don't need to a base URL for the next pass
        delete $newsletter_entry->{base_url};
      }

      # get the URL where the updated timestamp lives
      $newsletter_entry->{url} = $timestamp_page_url;

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
