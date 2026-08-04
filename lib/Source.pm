package Source 1.0;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(
  classify_source
  normalize_issue_url
  same_origin_issue_url
  validate_issue_url
);

use URI;

use constant DEFAULT_CADENCE_DAYS => 30;
use constant GRACE_MULTIPLIER     => 3;

sub validate_issue_url {
  my ($url) = @_;

  return if !defined $url || $url =~ /[\x00-\x1F\x7F]/;

  my $uri = URI->new($url);
  return if lc($uri->scheme // '') ne 'https';
  return if !defined $uri->host || !length $uri->host;
  return if defined $uri->userinfo && length $uri->userinfo;

  return 1;
}

sub normalize_issue_url {
  my ( $url, $base_url ) = @_;

  return if !defined $url || !defined $base_url;

  my $absolute_url = URI->new_abs( $url, $base_url )->as_string;
  return validate_issue_url($absolute_url) ? $absolute_url : undef;
}

sub same_origin_issue_url {
  my ( $url, $base_url ) = @_;
  my $absolute_url = normalize_issue_url( $url, $base_url );
  return if !$absolute_url;

  my $target = URI->new($absolute_url);
  my $base   = URI->new($base_url);
  return if lc($target->host // '') ne lc($base->host // '');

  return $absolute_url;
}

sub classify_source {
  my ( $entry, $now ) = @_;
  $now //= time();

  return 'failed' if !$entry->{updated_at};
  return 'low_confidence' if $entry->{updated_fixed_day};

  my $cadence_days = $entry->{cadence_days} || DEFAULT_CADENCE_DAYS;
  my $grace_seconds = $cadence_days * GRACE_MULTIPLIER * 24 * 60 * 60;

  return $entry->{updated_at} < $now - $grace_seconds ? 'stale' : 'current';
}

1;
