#!/usr/bin/perl
#
use strict;
use warnings;

my $content = do {
  open my $fh, '<', $ARGV[0] or die "Cant open $ARGV[0] , $!";
  local $/ = undef;
  scalar <$fh>;
};

my $colors = {
    31 => 'red',
    32 => 'blue',
    33 => 'green',
    34 => 'yellow',
    35 => 'purple',
    36 => 'cyan',
    0  => '',
};

sub replace_space{
    $_[0] =~ s{([ ]+)}{
        '<span class="space" style="width: ' . ( (length($1)) * 2 ). 'pt">'. "</span\n>"
    }gex;
}
sub skip_0m {
    if( $_[0] eq '0' ){
        return $_[1];
    }
    else {
        return '<span class="' . $colors->{$_[0]} . '">' . $_[1] . "</span\n>";
    }
}
sub replace_colors{
    $_[0] =~ s{\e\[(\d+)m([^\e]+)(?=\e\[\d+m)}{
        skip_0m( $1, $2 );
    }gex;
}

{
    local $@;
$content =~ s{^([ ]*)(.*)$}{
    my $space = "$1";
    my $line = "$2";
    my $padleft = length( $space ) * 2 ;
    replace_space($line);
    replace_colors($line);
    $line =~ s/\e\[\d+m//g;
    "<div class=\"line\" style=\"padding-left: ${padleft}pt\">$line</div>"
}mgex;
    die $@ if($@);
}

print '<html>
    <head>
        <title>Parse Tree</title>
        <style>
            .red { color: #FF0000 }
            .green { color: #00FF00 }
            .blue { color: #5555FF }
            .yellow { color: #FFFF00 }
            .purple { color: #FF00FF }
            .cyan  { color: #00FFFF }
            body { padding: 0px; margin: 0px; font-family: monospace; background-color: #051005 }
            span { padding: 0px; margin: 0px; }
            span.space { display: inline-block; }
        </style>
    </head>
    <body>
        <div>' . $content . '</div>
    </body>
</html>';
