use strict;
use warnings;

package Tokens;

sub classname {
  if ( $_[0] =~ /^([A-Z][A-Za-z]+)/ ) {
    return [ "$1", length "$1" ];
  }
  return;
}

sub c_class {
  if ( $_[0] =~ /^c\(/ ) {
    return [ "c", length 1 ];
  }
  return;
}

sub number {
  if ( $_[0] =~ /^([0-9]+)/ ) {
    return [ "$1", length "$1" ];
  }
  return;
}

sub variablename {
  if ( $_[0] =~ /^([a-z_]+)/ ) {
    return [ "$1", length "$1" ];
  }
}

sub paren_open {
  if ( $_[0] =~ /^\(/ ) {
    return [ "(", 1 ];
  }
  return;
}

sub paren_close {
  if ( $_[0] =~ /^\)/ ) {
    return [ ")", 1 ];
  }
  return;
}

sub at {
  if ( $_[0] =~ /^\@/ ) {
    return [ "@", 1 ];
  }
  return;
}

sub assign {
  if ( $_[0] =~ /^=/ ) {
    return [ "=", 1 ];
  }
  return;
}

sub quote {
  if ( $_[0] =~ qr{^"} ) {
    return [ '"', 1 ];
  }
  return;
}

sub pre_slash {
  if ( $_[0] =~ qr{^([^\"]+)\\} ) {
    return [ "$1", length "$1" ];
  }
  return;
}

sub pre_quote {
  if ( $_[0] =~ qr{^([^\"]+)"} ) {
    return [ "$1", length "$1" ];
  }
  return;
}

sub slash {
  if ( $_[0] =~ qr{^\\} ) {
    return [ '\\', 1 ];
  }
  return;
}

sub any_char {
  if ( $_[0] =~ qr{^(.)} ) {
    return [ "$1", 1 ];
  }
  return;
}

sub semicolon {
  if ( $_[0] =~ qr{^;} ) {
    return [ ";", 1 ];
  }
  return;

}

sub whitespace {
  if ( $_[0] =~ qr/(\s)/ ) {
    return [ "$1", length($1) ];
  }
  return;
}
sub eof {
    if ( $_[0] eq '' ){
        return [ "", 0 ];
    }
    return;
}

1;
