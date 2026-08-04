package Presenter 1.0;

use strict;
use warnings;
use autodie;

use Exporter 'import';
our @EXPORT_OK   = qw(presenter API_PATH);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

use lib 'lib';
use Cache qw(cached_newsletters);
use Source qw(classify_source normalize_issue_url);

use List::SomeUtils qw(uniq);

use constant TITLE     => 'ProgrammingNewsletters.com';
use constant SUBTITLE  => 'No email needed';
use constant DEVELOPER => 'szTheory';
use constant SOURCE_URL =>
  'https://github.com/szTheory/programmingnewsletters.com';
use constant API_PATH             => "index.json";
use constant ENTRY_KEYS_WHITELIST => qw(url category name updated_at);

sub _remove_empty {
  my ($entries) = @_;

  @{$entries} = grep { ($_->{health_status} || classify_source($_)) eq 'current' }
    @{$entries};

  return;
}

sub _sort_newsletters {
  my ($entries) = @_;

  @{$entries} =
    reverse sort { $a->{updated_at} <=> $b->{updated_at} } @{$entries};

  return;
}

sub _update_with_base_url {
  my ($entries) = @_;

  foreach my $entry ( @{$entries} ) {
    if ( $entry->{base_url} ) {
      $entry->{url} = normalize_issue_url( $entry->{url}, $entry->{base_url} );
    }
  }

  return;
}

sub _grouped_by_date {
  my ($entries) = @_;

  my $grouped_entries = [];

  foreach my $entry ( @{$entries} ) {
    my $entries_for_date = @{$grouped_entries}[-1];

    # create a new set of entries when the date has changed
    if (!$entries_for_date
      || $entries_for_date->{date} ne $entry->{updated_at_formatted} )
    {
      $entries_for_date = {
        date    => $entry->{updated_at_formatted},
        entries => []
      };

      push @{$grouped_entries}, $entries_for_date;
    }

    # remove unused values from entry
    my $entry = _filter_entry_fields($entry);

    # push entry
    push @{ $entries_for_date->{entries} }, $entry;
  }

  return $grouped_entries;
}

sub _add_formatted_timestamp {
  my ($entries) = @_;

  foreach my $entry ( @{$entries} ) {
    my $date = DateTime->from_epoch( epoch => $entry->{updated_at} );
    $entry->{updated_at_formatted} = $date->strftime('%b %d');
    $entry->{updated_at_iso8601}   = $date->iso8601() . 'Z';
  }

  return;
}

sub _filter_entry_fields {
  my ($entry) = @_;

  my $new_entry = {};
  foreach my $key (ENTRY_KEYS_WHITELIST) {
    $new_entry->{$key} = $key eq 'updated_at'
      ? $entry->{updated_at_iso8601}
      : $entry->{$key};
  }

  return $new_entry;
}

sub _source_health {
  my ($entries) = @_;

  return [ map {
    my $status = $_->{health_status} || classify_source($_);
    my $updated_at = $_->{updated_at}
      ? DateTime->from_epoch( epoch => $_->{updated_at} )->iso8601() . 'Z'
      : undef;

    {
      name       => $_->{name},
      category   => $_->{category},
      status     => $status,
      updated_at => $updated_at,
    };
  } @{$entries} ];
}

sub _grouped_entries_categories {
  my ($entries) = @_;

  my @categories = map { $_->{category} }
    map { @{$_} }
    map { $_->{entries} } @{$entries};

  my @unique_categories = uniq(@categories);
  my @sorted_categories = sort @unique_categories;

  return \@sorted_categories;
}

sub presenter {
  my ( $should_rebuild, $first_only ) = @_;

  # get entries
  my ($entries) = cached_newsletters( $should_rebuild, $first_only );

  # process entries
  my $source_health = _source_health($entries);
  _remove_empty($entries);
  _sort_newsletters($entries);
  _add_formatted_timestamp($entries);
  _update_with_base_url($entries);
  my $grouped_entries = _grouped_by_date($entries);

  # categorize entries
  my $categories = _grouped_entries_categories($grouped_entries);
  unshift @{$categories}, 'All';

  my $presenter = {
    grouped_entries => $grouped_entries,
    categories      => $categories,
    current_sources => scalar @{$entries},
    generated_at    => DateTime->now( time_zone => 'UTC' )->iso8601() . 'Z',
    source_health   => $source_health,
    year            => DateTime->today()->year(),
    developer       => DEVELOPER,
    title           => TITLE,
    subtitle        => SUBTITLE,
    source_url      => SOURCE_URL,
    api_path        => API_PATH
  };

  # print "--- Presenter Output ---\n";
  # use Data::Dumper;
  # print Dumper($presenter);

  return $presenter;
}

1;
