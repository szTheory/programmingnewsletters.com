package Translate 1.0;

use strict;
use warnings;
use autodie;

use Exporter 'import';
our @EXPORT_OK   = qw(timestamp_string_normalize_french);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

sub timestamp_string_normalize_french {
  my ($timestamp) = @_;

  # lowercase for consistency
  $timestamp = lc($timestamp);

  # translate the month names
  $timestamp =~ s/janvier/january/g;
  $timestamp =~ s/février/february/g;
  $timestamp =~ s/mars/march/g;
  $timestamp =~ s/avril/april/g;
  $timestamp =~ s/mai/may/g;
  $timestamp =~ s/juin/june/g;
  $timestamp =~ s/juillet/july/g;
  $timestamp =~ s/août/august/g;
  $timestamp =~ s/septembre/september/g;
  $timestamp =~ s/octobre/october/g;
  $timestamp =~ s/novembre/november/g;
  $timestamp =~ s/décembre/december/g;

  return $timestamp;
}

1;