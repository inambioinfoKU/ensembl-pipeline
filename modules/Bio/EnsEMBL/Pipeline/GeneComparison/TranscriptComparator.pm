#
# Cared for by EnsEMBL 
#
# Copyright GRL & EBI
#
# You may distribute this module under the same terms as perl itself
#
# POD documentation - main docs before the code

=pod 

=head1 NAME

Bio::EnsEMBL::Pipeline::GeneComparison::TranscriptComparator

=head1 SYNOPSIS
    
    my $comparator = Bio::EnsEMBL::Pipeline::::GeneComparison::TranscriptComparator->new();
);

so far there are two methods that check whether two transcripts have consecutive exon overlap:

my ($merge,$overlaps,$exact) = $comparator->test_for_Merge($transcript1,$transcript2)

this second allows two exons to merge into one at the other transcript
my ($merge,$overlaps,$exact) = $comparator->test_for_Merge_with_gaps($transcript1,$transcript2)
    
    $merge =1 if the exons overlap consecutively
    $overlaps is the number of exon overlaps
    $exact = 1 if the exon matches are exact


=head1 CONTACT

ensembl-dev@ebi.ac.uk

=cut

# Let the code begin...

package Bio::EnsEMBL::Pipeline::GeneComparison::TranscriptComparator;

use vars qw(@ISA);
use strict;

use Bio::EnsEMBL::Pipeline::GeneComparison::GeneCluster;
use Bio::EnsEMBL::Pipeline::GeneComparison::TranscriptCluster;
use Bio::EnsEMBL::Pipeline::GeneCombinerConf;

# config file; parameters searched for here if not passed in as @args

@ISA = qw(Bio::EnsEMBL::Root);

######################################################################

sub new{
  my ($class,@args) = @_;
  my $self = $class->SUPER::new(@args);
  return $self;  
}

############################################################

=head2 compare
  Arg[1] and Arg[2] : 2 transcript objects to compare
  Arg[3]: the mode ( a string of text). Possible modes:

      semiexact_merge = test for exact exon matches, except for possible mismatches in the extremal exons

fuzzy_semiexact_merge = this function checks whether two transcripts merge
                        with fuzzy exon matches: there is consecutive exon overlap 
                        but there are mismatches of $allowed_mismatches bases allowed at the edges of any exon pair

         simple_merge = this function checks whether two transcripts merge
                        according to consecutive exon overlap (just overlap, without looking at the 
                        exon positions) and it only considers 1-to-1 matches

      merge_allow_gaps = this function checks whether two transcripts merge
                        according to consecutive exon overlap allowing for 1-to-many ot many-to-1 matches

=cut 

sub compare{

  my ($self, $tran1, $tran2, $mode, $parameter ) = @_;

  if ( $mode eq 'semiexact_merge' ){
    $self->_test_for_semiexact_Merge( $tran1, $tran2,$parameter );
  } 
  elsif( $mode eq 'fuzzy_semiexact_merge' ){
    $self->_test_for_fuzzy_semiexact_Merge( $tran1, $tran2,$parameter );
  }
  elsif( $mode eq 'simple_merge' ){
    $self->_test_for_Simple_Merge( $tran1, $tran2,$parameter );
  }
  elsif( $mode eq 'merge_allow_gaps' ){
    $self->_test_for_Merge_allow_gaps( $tran1, $tran2,$parameter );
  }
}

#########################################################################
# this function checks whether two transcripts merge
# with exact exon matches, except for
# possible mismatches in the extremal exons

sub _test_for_semiexact_Merge{
  my ($self,$est_tran,$ens_tran,$allowed_exterior_mismatch) = @_;

  # allowed_exterior_mismatch is the number of bases that we allow the first or last exon
  # of a transcript to extend beyond an overlapping exon in the other transcript
  # which is an internal exon. We default it to zero:
  unless ($allowed_exterior_mismatch){
    $allowed_exterior_mismatch = 0;
  }

  my @exons1 = @{$est_tran->get_all_Exons};
  my @exons2 = @{$ens_tran->get_all_Exons};	
  
  @exons1 = sort {$a->start <=> $b->start} @exons1;
  @exons2 = sort {$a->start <=> $b->start} @exons2;

  my $foundlink = 0; # flag that gets set when starting to link exons
  my $start     = 0; # start looking at the first one
  my $merge     = 0; # =1 if they merge
  my $overlaps  = 0;
  
 EXON1:
  for (my $j=0; $j<=$#exons1; $j++) {
      
    EXON2:
      for (my $k=$start; $k<=$#exons2; $k++){
	#print STDERR "comparing j = $j : ".$exons1[$j]->start."-".$exons1[$j]->end." and k = $k : ".$exons2[$k]->start."-".$exons2[$k]->end."\n";
	  
	  # we allow some mismatches at the extremities
	  #                        ____     ____     ___   
	  #              exons1   |____|---|____|---|___|  $j
	  #                         ___     ____     ____     __
	  #              exons2    |___|---|____|---|____|---|__|  $k
	  
	  # if there is no overlap, go to the next EXON2
	  if ( $foundlink == 0 && !( $exons1[$j]->overlaps($exons2[$k]) ) ){
	      #print STDERR "foundlink = 0 and no overlap --> go to next EXON2\n";
	      next EXON2;
	  }
	  # if there is no overlap and we had found a link, there is no merge
	  if ( $foundlink == 1 && !($exons1[$j]->overlaps($exons2[$k]) ) ){
	      #print STDERR "foundlink = 1 and no overlap --> leaving\n";
	      $merge = 0;
	      last EXON1;
	  }	
	  
	  # the first exon can have a mismatch in the start 
	  if ( ( ($k == 0 && ( $exons1[$j]->start - $exons2[$k]->start ) <= $allowed_exterior_mismatch ) || 
		 ($j == 0 && ( $exons2[$k]->start - $exons1[$j]->start ) <= $allowed_exterior_mismatch )   )
	       && 
	       $exons1[$j]->end == $exons2[$k]->end 
	     ){
	    
	      # but if it is also the last exon
	    if ( ( ( $k == 0 && $k == $#exons2 )   || 
		   ( $j == 0 && $j == $#exons1 ) ) ){
	      
	      # we force it to match the start
	      if ( $exons1[$j]->start == $exons2[$k]->start ){
		$foundlink  = 1;
		$merge      = 1;
		$overlaps++;
		#print STDERR "merged single exon transcript\n";
		last EXON1;
	      }
	      # we call it a non-merge
	      else{
		$foundlink = 0;
		$merge     = 0;
		#print STDERR "non-merged single exon transcript\n";
		last EXON1;
	      }
	    }
	    else{
	      #else, we have a link
	      $foundlink = 1;
	      $start = $k+1;
	      $overlaps++;
	      #print STDERR "found a link\n";
	      next EXON1;
	    }
	  }
	  # the last one can have a mismatch on the end
	  elsif ( ( $k == $#exons2 && ( $exons2[$k]->end - $exons1[$j]->end ) <= $allowed_exterior_mismatch ) || 
		  ( $j == $#exons1 && ( $exons1[$j]->end - $exons2[$k]->end ) <= $allowed_exterior_mismatch ) 
		  &&
		  ( $foundlink == 1 )                  
		  &&
		  ( $exons1[$j]->start == $exons2[$k]->start ) 
		){
	    #print STDERR "link completed, merged transcripts\n";
	    $overlaps++;
	    $merge = 1;
	    last EXON1;
	  }
	  # the middle one must have exact matches
	  elsif ( ($k != 0 && $k != $#exons2) && 
		  ($j != 0 && $j != $#exons1) &&
		  ( $foundlink == 1)          &&
		  ( $exons1[$j]->start == $exons2[$k]->start ) &&
		  ( $exons1[$j]->end   == $exons2[$k]->end   )
		){
	    $overlaps++;
	    $start = $k+1;
	    #print STDERR "continue link\n";
	    next EXON1;
	  }
	  
	} # end of EXON2 
      
      if ($foundlink == 0){
	$start = 0;
      }
      
    }   # end of EXON1      
  
  return ($merge, $overlaps);
}

#########################################################################
# this function checks whether two transcripts merge
# with fuzzy exon matches: there is consecutive exon overlap 
# but there are mismatches of $allowed_mismatches bases allowed at the edges of any exon pair
#
# This is defauleted to 2 bases: 2 bases is perhaps not meaningful enough to be considered
# a biological difference, and it is possibly an artifact of any of the
# analysis previously run: genomewise, est2genome,... it is more likely to
# happen 

sub _test_for_fuzzy_semiexact_Merge{
  my ($self,$est_tran,$ens_tran, $allowed_mismatch) = @_;
  
  #print STDERR "=========== comparing ================\n";
  Bio::EnsEMBL::Pipeline::Tools::TranscriptUtils->_print_Transcript( $est_tran );
  Bio::EnsEMBL::Pipeline::Tools::TranscriptUtils->_print_Transcript( $ens_tran );

  unless ($allowed_mismatch){
    $allowed_mismatch = 2;
  }

  my @exons1 = @{$est_tran->get_all_Exons};
  my @exons2 = @{$ens_tran->get_all_Exons};	
  
  @exons1 = sort {$a->start <=> $b->start} @exons1;
  @exons2 = sort {$a->start <=> $b->start} @exons2;

  my $foundlink = 0; # flag that gets set when starting to link exons
  my $start     = 0; # start looking at the first one
  my $merge     = 0; # =1 if they merge
  my $overlaps  = 0; # number of exon overlaps
  
 EXON1:
  for (my $j=0; $j<=$#exons1; $j++) {
    
  EXON2:
    for (my $k=$start; $k<=$#exons2; $k++){
      print STDERR "comparing j = $j : ".$exons1[$j]->start."-".$exons1[$j]->end.
        " and k = $k : ".$exons2[$k]->start."-".$exons2[$k]->end."\n";
      
      # we allow some mismatches at the extremities
      #                        ____     ____     ___   
      #              exons1   |____|---|____|---|___|  $j
      #                         ___     ____     ____  
      #              exons2    |___|---|____|---|____|  $k
      
      # if there is no overlap, go to the next EXON2
      if ( $foundlink == 0 && !($exons1[$j]->overlaps($exons2[$k]) ) ){
	print STDERR "foundlink = 0 and no overlap --> go to next EXON2\n";
	next EXON2;
      }
      # if there is no overlap and we had found a link, there is no merge
      if ( $foundlink == 1 && !($exons1[$j]->overlaps($exons2[$k]) ) ){
	print STDERR "foundlink = 1 and no overlap --> leaving\n";
	$merge = 0;
	last EXON1;
      }	
      
      # the first exon can have a mismatch ( any number of bases) in the start
      # and $allowed_mismatch bases mismatch at the end
      if ( ($k == 0 || $j == 0) && abs($exons1[$j]->end - $exons2[$k]->end)<= $allowed_mismatch ){
	
	# but if it is also the last exon
	if ( ( ( $k == 0 && $k == $#exons2 )   || 
	       ( $j == 0 && $j == $#exons1 ) ) ){
	  
	  # we force it to match the start (with a mismatch of $allowed_mismatch bases allowed)
	  if ( abs($exons1[$j]->start - $exons2[$k]->start)<= $allowed_mismatch ){
	    $foundlink  = 1;
	    $merge      = 1;
	    $overlaps++;
	    print STDERR "merged single exon transcript\n";
	    last EXON1;
	  }
	  # we call it a non-merge
	  else{
	    $foundlink = 0;
	    $merge     = 0;
	    print STDERR "non-merged single exon transcript\n";
	    last EXON1;
	  }
	}
	else{
	  #else, we have a link
	  $foundlink = 1;
	  $overlaps++;
	  $start = $k+1;
	  print STDERR "found a link\n";
	  next EXON1;
	}
      }
      # the last one can have any mismatch on the end
      # but must have a match at the start (with $allowed_mismatch mismatches allowed)
      elsif ( ( $k == $#exons2 || $j == $#exons1 ) &&
	      ( $foundlink == 1 )                  &&
	      ( abs($exons1[$j]->start - $exons2[$k]->start)<= $allowed_mismatch ) 
	    ){
	print STDERR "link completed, merged transcripts\n";
	$merge = 1;
	$overlaps++;
	last EXON1;
      }
      # the middle one must have exact matches
      # (up to an $allowed_mismatch mismatch)
      elsif ( ($k != 0 && $k != $#exons2) && 
	      ($j != 0 && $j != $#exons1) &&
	      ( $foundlink == 1)          &&
	      abs( $exons1[$j]->start - $exons2[$k]->start )<= $allowed_mismatch &&
	      abs( $exons1[$j]->end   - $exons2[$k]->end   )<= $allowed_mismatch
	    ){
	$overlaps++;
	$start = $k+1;
	print STDERR "continue link\n";
	next EXON1;
      }
      
    } # end of EXON2 
    
    if ($foundlink == 0){
      $start = 0;
    }
    
  }   # end of EXON1      
  
  return ($merge, $overlaps);
}

#########################################################################
# this function checks whether two transcripts merge
# according to consecutive exon overlap (just overlap, without looking at the 
# exon positions) and it only considers 1-to-1 matches, so things like
#                        ____     ____        
#              exons1 --|____|---|____|------ etc... $j
#                        ____________  
#              exons2 --|____________|------ etc...  $k
#
# are considered a mismatch

sub _test_for_Simple_Merge{
  my ($self,$tran1,$tran2) = @_;
  my @exons1 = @{$tran1->get_all_Exons};
  my @exons2 = @{$tran2->get_all_Exons};	
 
  my $foundlink = 0; # flag that gets set when starting to link exons
  my $start     = 0; # start looking at the first one
  my $overlaps  = 0; # independently if they merge or not, we compute the number of exon overlaps
  my $merge     = 0; # =1 if they merge

  my $one2one_overlap = 0;
  my $one2two_overlap = 0;
  my $two2one_overlap = 0;
 EXON1:
  for (my $j=0; $j<=$#exons1; $j++) {
    
  EXON2:
    for (my $k=$start; $k<=$#exons2; $k++){
    #print STDERR "comparing ".($j+1)." and ".($k+1)."\n";
	    
      # if exon 1 is not the first, check first whether it matches the previous exon2 as well, i.e.
      #                        ____     ____        
      #              exons1 --|____|---|____|------ etc... $j
      #                        ____________  
      #              exons2 --|____________|------ etc...  $k
      #
      if ($foundlink == 1 && $j != 0){
	if ( $k != 0 && $exons1[$j]->overlaps($exons2[$k-1]) ){
	  #print STDERR ($j+1)." <--> ".($k)."\n";
	  $overlaps++;
	  $two2one_overlap++;
	  next EXON1;
	}
      }
      
      # if texons1[$j] and exons2[$k] overlap go to the next exon1 and  next $exon2
      if ( $exons1[$j]->overlaps($exons2[$k]) ){
	#print STDERR ($j+1)." <--> ".($k+1)."\n";
        $overlaps++;
	
        # in order to merge the link always start at the first exon of one of the transcripts
        if ( $j == 0 || $k == 0 ){
          $foundlink = 1;
        }
      }          
      else {  
	# if you haven't found an overlap yet, look at the next exon 
	if ( $foundlink == 0 ){
	  next EXON2;
	}
	# leave if we stop finding links between exons before the end of transcripts
	if ( $foundlink == 1 ){
	  $merge = 0;
	  last EXON1;
	}
      }
      
      # if foundlink = 1 and we get to the end of either transcript, we merge them!
      if ( $foundlink == 1 && ( $j == $#exons1 || $k == $#exons2 ) ){
	
	# and we can leave
        $merge = 1;
	last EXON1;
      }
      # if foundlink = 1 but we're not yet at the end, go to the next exon 
      if ( $foundlink == 1 ){
	
	# but first check whether in exons2 there are further exons overlapping exon1, i.e.
        #                       ____________        
	#             exons1 --|____________|------ etc...
	#                       ____     ___  
	#             exons2 --|____|---|___|------ etc...
	# 
	my $addition = 0;
	while ( $k+1+$addition < scalar(@exons2) && $exons1[$j]->overlaps($exons2[$k+1+$addition]) ){
	  #print STDERR ($j+1)." <--> ".($k+2+$addition)."\n";
	  $one2two_overlap++;
	  $overlaps++;
          $addition++;
	}      
	$start = $k+1+$addition;
	next EXON1;
      }    
      
    } # end of EXON2 
    
    # if you haven't found any match for this exon1, start again from the first exon2:
    if ($foundlink == 0){
      $start = 0;
    }
 
  }   # end of EXON1      

  # we only make them merge if $merge = 1 and the 2-to-1 and 1-to-2 overlaps are zero;
  if ( $merge == 1 && $one2two_overlap == 0 && $two2one_overlap == 0 ){
    return ( 1, $overlaps );
  }
  else{
    return ( 0, $overlaps);
  }
}


#########################################################################
# this function checks whether two transcripts merge
# according to consecutive exon overlap
# this time, matches like this:
#                        ____     ____        
#              exons1 --|____|---|____|------ etc... $j
#                        ____________  
#              exons2 --|____________|------ etc...  $k
#
# are considered a match


=head2 _test_for_Merge_allow_gaps
 Function: this function is called from link_Transcripts and actually checks whether two transcripts
           inputs merge.
 Returns : It returns two numbers ($merge,$overlaps), where
           $merge = 1 (0) when they do (do not) merge,
           and $overlaps is the number of exon-overlaps.

=cut

sub _test_for_Merge_allow_gaps{
  my ($self,$tran1,$tran2) = @_;
  my @exons1 = @{$tran1->get_all_Exons};
  my @exons2 = @{$tran2->get_all_Exons};
  my $foundlink = 0; # flag that gets set when starting to link exons
  my $start     = 0; # start looking at the first one
  my $overlaps  = 0; # independently if they merge or not, we compute the number of exon overlaps
  my $merge     = 0; # =1 if they merge

  #print STDERR "comparing ".$tran1->dbID." ($tran1)  and ".$tran2->dbID." ($tran2)\n";


EXON1:
  for (my $j=0; $j<=$#exons1; $j++) {
  
  EXON2:
    for (my $k=$start; $k<=$#exons2; $k++){
    #print STDERR "comparing ".($j+1)." and ".($k+1)."\n";
	    
      # if exon 1 is not the first, check first whether it matches the previous exon2 as well, i.e.
      #                        ____     ____        
      #              exons1 --|____|---|____|------ etc... $j
      #                        ____________  
      #              exons2 --|____________|------ etc...  $k
      #
      if ($foundlink == 1 && $j != 0){
	if ( $k != 0 && $exons1[$j]->overlaps($exons2[$k-1]) ){
	  #print STDERR ($j+1)." <--> ".($k)."\n";
	  $overlaps++;
          next EXON1;
	}
      }
      
      # if texons1[$j] and exons2[$k] overlap go to the next exon1 and  next $exon2
      if ( $exons1[$j]->overlaps($exons2[$k]) ){
	#print STDERR ($j+1)." <--> ".($k+1)."\n";
        $overlaps++;
	
        # in order to merge the link always start at the first exon of one of the transcripts
        if ( $j == 0 || $k == 0 ){
          $foundlink = 1;
        }
      }          
      else {  
	# if you haven't found an overlap yet, look at the next exon 
	if ( $foundlink == 0 ){
	  next EXON2;
	}
	# leave if we stop finding links between exons before the end of transcripts
	if ( $foundlink == 1 ){
	  $merge = 0;
	  last EXON1;
	}
      }
      
      # if foundlink = 1 and we get to the end of either transcript, we merge them!
      if ( $foundlink == 1 && ( $j == $#exons1 || $k == $#exons2 ) ){
	
	# and we can leave
        $merge = 1;
	last EXON1;
      }
      # if foundlink = 1 but we're not yet at the end, go to the next exon 
      if ( $foundlink == 1 ){
	
	# but first check whether in exons2 there are further exons overlapping exon1, i.e.
        #                       ____________        
	#             exons1 --|____________|------ etc...
	#                       ____     ___  
	#             exons2 --|____|---|___|------ etc...
	# 
	my $addition = 0;
	while ( $k+1+$addition < scalar(@exons2) && $exons1[$j]->overlaps($exons2[$k+1+$addition]) ){
	  #print STDERR ($j+1)." <--> ".($k+2+$addition)."\n";
	  $overlaps++;
          $addition++;
	}      
	$start = $k+1+$addition;
	next EXON1;
      }    
    
    } # end of EXON2 
  
    if ($foundlink == 0){
      $start = 0;
    }
 
  }   # end of EXON1      

  # if we haven't returned at this point, they don't merge, thus
  return ($merge,$overlaps);
}



#########################################################################
# this function checks whether two transcripts merge
# according to consecutive exon overlap
# this time, matches like this:
#                        ____     ____        
#              exons1 --|____|---|____|------ etc... $j
#                        ____________  
#              exons2 --|____________|------ etc...  $k
#
# are checked, it won't be considered a merge, but it will count how many of those occur

sub _test_for_Merge_with_gaps{
  my ($self,$tran1,$tran2) = @_;
  my @exons1 = @{$tran1->get_all_Exons};
  my @exons2 = @{$tran2->get_all_Exons};	
 
  my $foundlink = 0; # flag that gets set when starting to link exons
  my $start     = 0; # start looking at the first one
  my $overlaps  = 0; # independently if they merge or not, we compute the number of exon overlaps
  my $merge     = 0; # =1 if they merge

  my $one2one_overlap = 0;
  my $one2two_overlap = 0;
  my $two2one_overlap = 0;
 EXON1:
  for (my $j=0; $j<=$#exons1; $j++) {
    
  EXON2:
    for (my $k=$start; $k<=$#exons2; $k++){
    #print STDERR "comparing ".($j+1)." and ".($k+1)."\n";
	    
      # if exon 1 is not the first, check first whether it matches the previous exon2 as well, i.e.
      #                        ____     ____        
      #              exons1 --|____|---|____|------ etc... $j
      #                        ____________  
      #              exons2 --|____________|------ etc...  $k
      #
      if ($foundlink == 1 && $j != 0){
	if ( $k != 0 && $exons1[$j]->overlaps($exons2[$k-1]) ){
	  #print STDERR ($j+1)." <--> ".($k)."\n";
	  $overlaps++;
	  $two2one_overlap++;
	  next EXON1;
	}
      }
      
      # if texons1[$j] and exons2[$k] overlap go to the next exon1 and  next $exon2
      if ( $exons1[$j]->overlaps($exons2[$k]) ){
	#print STDERR ($j+1)." <--> ".($k+1)."\n";
        $overlaps++;
	
        # in order to merge the link always start at the first exon of one of the transcripts
        if ( $j == 0 || $k == 0 ){
          $foundlink = 1;
        }
      }          
      else {  
	# if you haven't found an overlap yet, look at the next exon 
	if ( $foundlink == 0 ){
	  next EXON2;
	}
	# leave if we stop finding links between exons before the end of transcripts
	if ( $foundlink == 1 ){
	  $merge = 0;
	  last EXON1;
	}
      }
      
      # if foundlink = 1 and we get to the end of either transcript, we merge them!
      if ( $foundlink == 1 && ( $j == $#exons1 || $k == $#exons2 ) ){
	
	# and we can leave
        $merge = 1;
	last EXON1;
      }
      # if foundlink = 1 but we're not yet at the end, go to the next exon 
      if ( $foundlink == 1 ){
	
	# but first check whether in exons2 there are further exons overlapping exon1, i.e.
        #                       ____________        
	#             exons1 --|____________|------ etc...
	#                       ____     ___  
	#             exons2 --|____|---|___|------ etc...
	# 
	my $addition = 0;
	while ( $k+1+$addition < scalar(@exons2) && $exons1[$j]->overlaps($exons2[$k+1+$addition]) ){
	  #print STDERR ($j+1)." <--> ".($k+2+$addition)."\n";
	  $one2two_overlap++;
	  $overlaps++;
          $addition++;
	}      
	$start = $k+1+$addition;
	next EXON1;
      }    
      
    } # end of EXON2 
    
    # if you haven't found any match for this exon1, start again from the first exon2:
    if ($foundlink == 0){
      $start = 0;
    }
 
  }   # end of EXON1      

  # we only make them merge if $merge = 1 and the 2-to-1 and 1-to-2 overlaps are zero;
  if ( $merge == 1 ){
    return ( 1, $overlaps );
  }
  else{
    return ( 0, $overlaps);
  }
}
  

#########################################################################
   
# this compares both transcripts and calculate the number of overlapping exons and
# the length of the overlap

sub _compare_Transcripts {         
  my ($tran1, $tran2) = @_;
  my @exons1   = @{$tran1->get_all_Exons};
  my @exons2   = @{$tran2->get_all_Exons};
  my $overlaps = 0;
  my $overlap_length = 0;
  foreach my $exon1 (@exons1){
    foreach my $exon2 (@exons2){
      if ( ($exon1->overlaps($exon2)) && ($exon1->strand == $exon2->strand) ){
	$overlaps++;
	
	# calculate the extent of the overlap
	if ( $exon1->start > $exon2->start && $exon1->start <= $exon2->end ){
	  if ( $exon1->end < $exon2->end ){
	    $overlap_length += ( $exon1->end - $exon1->start + 1);
	  }
	  elsif ( $exon1->end >= $exon2->end ){
	    $overlap_length += ( $exon2->end - $exon1->start + 1);
	  }
	}
	elsif( $exon1->start <= $exon2->start && $exon2->start <= $exon1->end ){
	  if ( $exon1->end < $exon2->end ){
	    $overlap_length += ( $exon1->end - $exon2->start + 1);
	  }
	  elsif ( $exon1->end >= $exon2->end ){
	    $overlap_length += ( $exon2->end - $exon2->start + 1);
	  }
	}
      }
    }
  }
  
  return ($overlaps,$overlap_length);
}    

#########################################################################

	
########################################################################

1;
