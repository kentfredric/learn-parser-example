
use strict;
use warnings;

package OP;

sub TERMINAL {
  my $i = 1;
  bless \$i, shift;
}

1;
