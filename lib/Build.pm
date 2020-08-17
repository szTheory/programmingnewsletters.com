package Build 1.0;

use strict;
use warnings;
use autodie;

use JSON::MaybeXS qw(decode_json);

sub newsletters_json {
  open my $fh, '<:encoding(UTF-8)', 'newsletters.json';

  my $json = '';
  while ( my $line = <$fh> ) {
    $json .= $line;
  }

  close $fh;

  return decode_json($json);
}

use Data::Dumper;
print Dumper( newsletters_json() );

1;
