#!/usr/bin/perl

use strict;
use warnings;

use lib '.';
use Tokens;
use OP;
use HINT;
use Structure;
use Scanner;

my @tokens;
my $content;

{
  open my $file, '<', './resumefile-1293138973' or die "Cant open file";
  {
    local $/ = undef;
    $content = <$file>;
  }
}

use Data::Dumper qw( Dumper );

my ( $success, $out ) = Scanner::get_structure( $content, 'vspec' );

my $i = 0;
for ( @{$out} ) {
  if ( ref $_ eq 'ARRAY' ) {

    #        print "\e[32m{\e[0m" . $_->[1] . "\e[32m}\e[0m";
    #        print "\e[33m{\e[0m" . $_->[0] . "\e[33m}\e[0m";
    print " " x ( ( $i + 1 ) * 4 );
    print "\e[34m{\e[32m" . $_->[0] . "\e[34m:\e[33m" . $_->[1] . "\e[34m}\e[0m\n";

  }
  else {

    if ( $$_ =~ /ENTER/ ) {
      $i++;
      print( " " x ( ($i) * 4 ) );
      print "\e[31m[{$i}\e[0m\n";
    }
    elsif ( $$_ =~ /EXIT/ ) {
      print( " " x ( ($i) * 4 ) );
      print "\e[31m]{$i}\e[0m\n";
      $i--;
    }
    elsif ( $$_ =~ /LABEL:(.*$)/ ) {
#       print( " " x ( ($i+1) * 4 ) );
#      print "\e[36m$1\e[0m\n";
    }
  }
}
if ( !$success ) {
  print "Parser Terminated:";
  print Dumper( \$content );

  #print "Context: " . ( substr $content, 0, 40 ) . "....\n";
  print Dumper ( \@Scanner::checklist );
}

