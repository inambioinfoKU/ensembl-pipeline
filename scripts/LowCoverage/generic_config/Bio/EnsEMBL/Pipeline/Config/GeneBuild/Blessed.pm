# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::EnsEMBL::Pipeline::Config::GeneBuild::Targetted - imports global variables used by EnsEMBL gene building

=head1 SYNOPSIS
    use Bio::EnsEMBL::Pipeline::Config::GeneBuild::Targetted;
    use Bio::EnsEMBL::Pipeline::Config::GeneBuild::Targetted qw(  );

=head1 DESCRIPTION

Targetted is a pure ripoff of humConf written by James Gilbert.

humConf is based upon ideas from the standard perl Env environment
module.

It imports and sets a number of standard global variables into the
calling package, which are used in many scripts in the human sequence
analysis system.  The variables are first decalared using "use vars",
so that it can be used when "use strict" is in use in the calling
script.  Without arguments all the standard variables are set, and
with a list, only those variables whose names are provided are set.
The module will die if a variable which doesn\'t appear in its
C<%Targetted> hash is asked to be set.

The variables can also be references to arrays or hashes.

Edit C<%Targetted> to add or alter variables.

All the variables are in capitals, so that they resemble environment
variables.

=head1 CONTACT

=cut


package Bio::EnsEMBL::Pipeline::Config::GeneBuild::Blessed;

use strict;
use vars qw( %Blessed );

# Hash containing config info
%Blessed = (
	      # genetypes for Blessed genes - one hash per type
	      GB_BLESSED_GENETYPES            => [
						 # {
						 #  'type' => 'ensembl',
						 # },
						 ],	      

	     );
sub import {
  my ($callpack) = caller(0); # Name of the calling package
  my $pack = shift; # Need to move package off @_
  
  # Get list of variables supplied, or else
  # all of Blessed:
  my @vars = @_ ? @_ : keys( %Blessed );
  return unless @vars;
  
  # Predeclare global variables in calling package
  eval "package $callpack; use vars qw("
    . join(' ', map { '$'.$_ } @vars) . ")";
    die $@ if $@;


    foreach (@vars) {
	if ( defined $Blessed{ $_ } ) {
            no strict 'refs';
	    # Exporter does a similar job to the following
	    # statement, but for function names, not
	    # scalar variables:
	    *{"${callpack}::$_"} = \$Blessed{ $_ };
	} else {
	    die "Error: Blessed: $_ not known\n";
	}
    }
}

1;