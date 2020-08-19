package Presenter 1.0;

use strict;
use warnings;
use autodie;

use Exporter 'import';
our @EXPORT_OK   = qw(newsletters);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

use lib 'lib';
use Newsletters qw(newsletters_json);

use Data::Dumper;

sub _sort_newsletters {
  my ($entries) = @_;

  @{$entries} = sort { $b->{updated_at} <=> $a->{updated_at} } @{$entries};

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
    $entry->{updated_at_formatted} = $date->strftime('%A %D');
  }

  return;
}

sub newsletters {
  my ($entries) = newsletters_json();

  _sort_newsletters($entries);
  _add_formatted_timestamp($entries);
  my $grouped_entries = _grouped_by_date($entries);

  return $grouped_entries;
}

1;
