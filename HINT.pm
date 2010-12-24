use strict;
use warnings;

package HINT;

sub ENTER_NEST {
  my $i = "ENTER_NEST";
  return bless \$i, shift;
}

sub EXIT_NEST {
  my $i = "EXIT_NEST";
  return bless \$i, shift;
}

sub FALLBACK {
  my $i = "FALLBACK";
  return bless \$i, shift;
}

sub LABEL {
  my $i = "LABEL:" . $_[1];
  return bless \$i, shift;
}

1;
