package Presenter 1.0;

use strict;
use warnings;
use autodie;

use Exporter 'import';
our @EXPORT_OK   = qw(presenter);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

use lib 'lib';
use Cache qw(cached_newsletters);

use Data::Dumper;
use List::SomeUtils qw(uniq);

use constant TITLE     => 'ProgrammingNewsletters';
use constant SUBTITLE  => 'No email needed';
use constant DEVELOPER => 'szTheory';
use constant SOURCE_URL =>
  'https://github.com/szTheory/ProgrammingNewsletters.com';

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
      $entry->{url} = $entry->{base_url} . $entry->{url};
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
    delete $entry->{updated_at};
    delete $entry->{updated_at_formatted};

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
  }

  return;
}

sub _remove_extra_fields {
  my ($entries) = @_;

  foreach my $entry ( @{$entries} ) {
    delete $entry->{updated_regex};
    delete $entry->{updated_selector};
    delete $entry->{link_attr};
    delete $entry->{link_selector};
    delete $entry->{base_url};
    delete $entry->{feed_url};
  }

  return;
}

sub _grouped_entries_categories {
  my ($entries) = @_;

  use Data::Dumper;
  my @categories = map { $_->{category} }
    map { @{$_} }
    map { $_->{entries} } @{$entries};

  my @unique_categories = uniq(@categories);
  my @sorted_categories = sort @unique_categories;

  return \@sorted_categories;
}

sub presenter {
  my ($should_rebuild) = @_;

  my ($entries) = cached_newsletters($should_rebuild);

  _sort_newsletters($entries);
  _add_formatted_timestamp($entries);
  _update_with_base_url($entries);
  _remove_extra_fields($entries);
  my $grouped_entries = _grouped_by_date($entries);

  my $categories = _grouped_entries_categories($grouped_entries);
  unshift @{$categories}, 'All';

  my $presenter = {
    grouped_entries => $grouped_entries,
    categories      => $categories,
    year            => DateTime->today()->year(),
    developer       => DEVELOPER,
    title           => TITLE,
    subtitle        => SUBTITLE,
    source_url      => SOURCE_URL
  };

  # print "--- Presenter Output ---\n";
  # use Data::Dumper;
  # print Dumper($presenter);

  return $presenter;
}

1;
