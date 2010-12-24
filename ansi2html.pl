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
    31 => 'color: #FF0000',
    32 => 'color: #00FF00',
    33 => 'color: #5555FF',
    34 => 'color: #FFFF00',
    35 => 'color: #FF00FF',
    36 => 'color: #00FFFF',
    0  => '',
};
$content =~ s/ /&nbsp;/g;
$content =~ s{\n}{<br
/>}g;

$content =~ s{\e\[(\d+)m(.*?)(?=\e\[\d+m)}{
    '<span style="' . $colors->{$1} . '">' . $2 . '</span>
';
}gsex;

$content =~ s/\e\[\d+m//g;

print '<html>
    <head>
        <title>Parse Tree</title>
    </head>
    <body style="padding: 0px; margin: 0px;">
        <div style="background-color: #051005; font: monospace">' . $content . '</div>
    </body>
</html>';
