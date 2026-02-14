package Run 1.0;

use strict;
use warnings;
use autodie;

use lib 'lib';
use Build 'build';

use Getopt::Long;

my ( $rebuild, $first_only, $assets_only );
GetOptions(
  'rebuild'     => \$rebuild,
  'first-only'  => \$first_only,
  'assets-only' => \$assets_only,
);

build( $rebuild, $first_only, $assets_only );

1;
