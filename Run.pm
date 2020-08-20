package Run 1.0;

use strict;
use warnings;
use autodie;

use lib 'lib';
use Build 'build';

use Getopt::Long;

my $rebuild;
GetOptions( 'rebuild' => \$rebuild );

build($rebuild);

1;
