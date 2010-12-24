
use strict;
use warnings;

package Structure;
my @stack;

sub trace {
  my $label = shift;

  #return ();
  return (
    {
      FALLBACK => sub {
        if ( $label !~ /^\// ) {
          push @stack, $label;
          push @Scanner::checklist, [ "enter $label", [@stack] ];

        }
        else {
          my $xlabel = pop @stack;
          push @Scanner::checklist, [ "exit $label < $xlabel", [@stack] ];
        }
        push @{ $_[0] }, HINT->LABEL($label);
        }
    }
  );

}

sub property_list {
  return [
    trace('property_list'),
    @{ Structure->property() },
    'semicolon',
    {
      'FALLBACK' => sub {
        if ( $_[1] !~ /^\)/ ) {
          unshift @{ $_[2] }, @{ Structure->property_list };
        }
        }
    },
    trace('/property_list')
  ];
}

sub classbody {
  return [
    trace('classbody'),
    {
      'paren_open' => sub {
        push @{ $_[0] }, HINT->ENTER_NEST();
        if ( $_[1] !~ /^\)/ ) {
          unshift @{ $_[2] }, @{ Structure->property_list() };
        }

        }
    },
    {
      'paren_close' => sub {
        push @{ $_[0] }, HINT->EXIT_NEST();
        }
    },
    trace('/classbody')
  ];
}

sub quote_inner {
  return [
    trace('quote_inner'),
    {
      'pre_quote' => sub { },
      'pre_slash' => sub {
        unshift @{ $_[2] }, qw( slash any_char ), @{ Structure->quote_inner() };
      },
    },
    trace('/quote_inner')
  ];
}

sub quotebody {
  return [
    trace('quote_body'),
    @{ Structure->quote_inner },
    {
      'quote' => sub {

        push @{ $_[0] }, HINT->EXIT_NEST();
        }
    },
    trace('/quote_body')
  ];
}

sub variable_data {
  return [ trace('variable_data'), 'assign', @{ Structure->value }, trace('/variable_data') ];
}

sub value {
  return [
    trace('value'),
    {
      classname => sub {
        unshift @{ $_[2] }, @{ Structure->classbody };
      },
      c_class => sub {
        unshift @{ $_[2] }, @{ Structure->classbody };
      },
      quote => sub {
        push @{ $_[0] }, HINT->ENTER_NEST();
        unshift @{ $_[2] }, @{ Structure->quotebody };
        }
    },
    trace('/value')
  ];
}

sub property {
  return [
    trace('property'),
    {
      number => sub {
        unshift @{ $_[2] }, @{ Structure->variable_data },

      },
      variablename => sub {
        unshift @{ $_[2] }, @{ Structure->variable_data }

      },
    },
    trace('/property'),
  ];
}

sub vspec {
  return [
    trace('vspec'),
    qw( classname at number ),
    @{ Structure->classbody },
    'semicolon',
    {
      'eof' => sub { @{ $_[2] } = (); }
    },
    trace('/vspec')
  ];
}

1;
