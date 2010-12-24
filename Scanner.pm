
use strict;
use warnings;

package Scanner;

our @checklist;

sub get_a {
  my ( $cspec, $string ) = @_;
  push @checklist, [ 'get_a', $cspec ];
  my $cb = Tokens->can($cspec);
  return undef unless $cb;
  my $result = $cb->($string);
  if ($result) {
    substr $_[1], 0, $result->[1], q{};
    return [ $cspec, @$result ];
  }
  return undef;
}

sub get_first {
  my ( $string, @tokens ) = @_;
  push @checklist, [ 'get_first', @tokens ];
  for my $tok (@tokens) {
    if ( my $result = Scanner::get_a( $tok, $_[0] ) ) {
      return $result;
    }
  }
  return;
}

sub get_spec {
  my ( $spec, $string ) = @_;
  push @checklist, [ 'get_spec', $spec ];
  if ( not ref $spec ) {
    if ( my $result = Scanner::get_a( $spec, $_[1] ) ) {
      return $result, undef;
    }
    return undef, undef;
  }
  my $realresult;
  my $to_call;

  for my $key ( keys %{$spec} ) {
    next unless my $result = Scanner::get_a( $key, $_[1] );
    $realresult = $result;
    $to_call    = $spec->{$key};
    last;
  }
  if ( !$realresult && exists $spec->{FALLBACK} ) {
    $realresult = HINT->FALLBACK;
    $to_call    = $spec->{FALLBACK};
  }
  if ( !$realresult ) {
    return undef, undef;
  }
  return $realresult, $to_call;
}

sub get_sequence {
  my ( $string, @sequence ) = @_;
  my @out;
  while (@sequence) {
    my $cspec = shift @sequence;
    #  push @checklist, [ 'sequence', [ map { if( ref $_ eq 'HASH' ){ { hash => [keys %{$_}]}} elsif( ref $_  ){ ref $_ } else { $_ } } @sequence ] ];
    my ( $result, $caller ) = Scanner::get_spec( $cspec, $_[0] );
    if ( !$result ) {
        # push @checklist, [ 'no result for ', $cspec ];
      return undef, \@out;
    }
    unless ( ref $result ne 'ARRAY' and $$result eq 'FALLBACK' ) {
      push @out, $result;
    }
    if ($caller) {
      $caller->( \@out, $_[0], \@sequence );
    }
  }
  return 1, \@out;
}

sub get_structure {
  my ( $string, $structure ) = @_;
  my $sequence = Structure->can($structure)->();
  return Scanner::get_sequence( $_[0], @{$sequence} );
}

sub for_tokens {
  my ( $string, @tokens ) = @_;
  for my $tok (@tokens) {
    if ( my $result = Scanner::get_a( $tok, $_[0] ) ) {
      return substr $_[0], 0, $result->[1], q{};
      return [ $tok, @$result ];
    }
  }
  return;

  #die "No matching token, characters are: " . substr $string, 0, 10 ;
}

sub spec {
  my ( $string, $specname ) = @_;
  my $spec = Structure->can($specname)->();
  my @out;
  for my $cspec ( @{$spec} ) {

    if ( not ref $cspec ) {
      my $result = Scanner::for_tokens( $_[0], $cspec );
      if ( !$result ) {
        die "Expected $cspec : " . substr( $string, 0, 10 );
      }
      push @out, $result;
      next;
    }
    my $realresult;
    my $to_call;
    #  push @checklist, { $specname => [ keys %{$cspec} ] };
    for my $key ( keys %{$cspec} ) {
      my $result = Scanner::for_tokens( $_[0], $key );
      next if !$result;
      $realresult = $result;
      $to_call    = $cspec->{$key};
      last;
    }
    if ( !$realresult ) {
      die "Expected one of : [ " . ( join q{,}, keys %{$cspec} ) . " ]  : " . substr( $string, 0, 10 );
    }
    push @out, $realresult;
    $to_call->( $_[0], \@out );
    next;
  }
  return \@out;
}

1;
