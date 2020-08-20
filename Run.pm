package Run 1.0;

use strict;
use warnings;
use autodie;

use lib 'lib';    #tell perl we'll find modules in lib/
use Build 'write_html_file';

use Getopt::Long;

my $rebuild;
GetOptions( 'rebuild' => \$rebuild );

write_html_file($rebuild);

1;
