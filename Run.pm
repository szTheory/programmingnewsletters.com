package Run 1.0;

use strict;
use warnings;
use autodie;

use lib 'lib';
use Build 'build';

use Getopt::Long;

my $rebuild;
my $first_only;
GetOptions( 'rebuild' => \$rebuild, 'first-only' => \$first_only );

build( $rebuild, $first_only );

1;
