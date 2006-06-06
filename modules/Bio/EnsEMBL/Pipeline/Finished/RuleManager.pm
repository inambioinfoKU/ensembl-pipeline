# May 16, 2006 3:59:20 PM
#
# Created by Mustapha Larbaoui <ml6@sanger.ac.uk>

# POD documentation - main docs before the code

=head1 NAME

Bio::EnsEMBL::Pipeline::Finished::RuleManager.pm

=head1 SYNOPSIS


=head1 DESCRIPTION

Finished group specific RuleManager module. 
Allow a better job submission handling through a priority queue 
and limit the number of submitted jobs.

=head1 FEEDBACK

=head1 AUTHOR - Mustapha Larbaoui

Mustapha Larbaoui E<lt>ml6@sanger.ac.ukE<gt>

=head1 CONTACT

Post general queries to B<anacode@sanger.ac.uk>

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _


=cut

# Let the code begin...

package Bio::EnsEMBL::Pipeline::Finished::RuleManager;

use vars qw(@ISA);
use strict;

use Bio::EnsEMBL::Pipeline::Config::General;
use Bio::EnsEMBL::Pipeline::Config::BatchQueue;
use Bio::EnsEMBL::Utils::Exception qw(verbose throw warning info);
use Bio::EnsEMBL::Utils::Argument qw( rearrange );
use Bio::EnsEMBL::Pipeline::RuleManager;
use Bio::EnsEMBL::Pipeline::Finished::Job;
use File::stat;

@ISA = qw(Bio::EnsEMBL::Pipeline::RuleManager);


=head2 _job_internal_queue

  Function  : Gets the RuleManager internal queue. The data structure is a hashtable 
  			  with job priority as key and a array ref. of job_id as value. 
  Exceptions: none

=cut

sub _job_internal_queue {
	my ( $self, $queue ) = @_;

	if ($queue) {
		$self->{'queue'} = $queue;
	}
	if ( !$self->{'queue'} ) {
		$self->{'queue'} = {};
	}

	return $self->{'queue'};
}

=head2 add_created_jobs_back_in_queue

  Arg [1]   : none
  Function  : ensures that created jobs get readded into the internal queue
  Returntype: int
  Exceptions: none
  Example   : 

=cut

sub add_created_jobs_back_in_queue {
	my ($self) = @_;
	my @created_jobs = $self->job_adaptor->fetch_by_Status("CREATED");
	foreach my $j (@created_jobs) {
		$self->push_job($j);
	}

	return 1;
}

=head2 push_job/shift_job/size/empty

  Function  : queue management functions
  Exceptions: none

=cut

sub push_job {
	my ( $self, $job, $priority ) = @_;
	my $job_id = $job->dbID;
	$priority = $priority || $job->priority;
	my $queue = $self->_job_internal_queue();
	if ( $queue->{$priority} ) {
		push @{ $queue->{$priority} }, $job_id;
	}
	else {
		$queue->{$priority} = [$job_id];
	}
}

sub shift_job {
	my ($self) = @_;
	my $queue = $self->_job_internal_queue();
	my @priority = sort { $b <=> $a } keys %$queue;
	foreach my $p (@priority) {
		if ( scalar( @{ $queue->{$p} } ) ) {
			my $job_id = shift @{ $queue->{$p} };
			my $job = $self->job_adaptor->fetch_by_dbID($job_id);
			$job->priority($p);
			
			return $job;
		}
	}

	return undef;
}

sub size {
	my ($self) = @_;
	my $queue  = $self->_job_internal_queue();
	my $size   = 0;
	foreach my $p ( keys %$queue ) {
		$size += scalar( @{ $queue->{$p} } );
	}

	return $size;
}

sub empty {
	my ($self) = @_;
	return $self->size() == 0;
}

=head2 can_run_job

  Arg [1]   : string, input_id
  Arg [2]   : Bio::EnsEMBL::Pipeline::Analysis
  Arg [3]   : string, directory path  (optional)
  Arg [4]   : string, runner script path (optional)
  Arg [5]   : int, for a boolean flag to mark verbosity (optional)
  Function  : Check if a job can be created for an input_id and analysis
              If a job already exists check if it needs to be retried, 
              then push the job in a priority queue.
  Returntype: int
  Exceptions: throws if not passed an input_id or an analysis object and
              if fails to submit the job 
  Example   : $rulemanager->can_run_job('filename', $analysis
                                        'path/to/dir', 
                                        'path/to/runner', 1);

=cut

sub can_job_run {
	my ( $self, $input_id, $analysis, $current_jobs ) = @_;

	if ( !$input_id || !$analysis ) {
		throw(  "Can't create job without an input_id $input_id or analysis "
			  . "$analysis" );
	}

	my $job;
	my $status;

	if ( $current_jobs->{ $analysis->dbID } ) {
		my $cj     = $current_jobs->{ $analysis->dbID };
		$status = $cj->{_status}->status;

		if (
			(
				   $status eq 'FAILED'
				|| $status eq 'AWOL'
				|| $status eq 'BUS_ERROR'
				|| $status eq 'OUT_OF_MEMORY'
			)
			&& $cj->can_retry
		  )
		{
			print "Retrying job " . $cj->dbID . " with status $status\n"
			  if $self->be_verbose;

			if ( $self->rename_on_retry ) {
				$self->rename_files($cj);
			}
			$cj->set_status('CREATED') unless $status eq 'OUT_OF_MEMORY';
			$job = $cj;
		}
	}
	else {
		$job = $self->create_and_store_job( $input_id, $analysis );
		print "Creating job " . $job->dbID . "\n" if $self->be_verbose;
	}

	if ($job) {
		my $priority = 0;
		$priority = $BIG_MEM_PRIORITY if($status && ($status eq 'OUT_OF_MEMORY'));
		$priority = $URGENT_JOB_PRIORITY if($self->urgent_input_id->{$input_id});
		$self->push_job($job,$priority);

		return 1;
	}

	return 0;
}

=head2 flush_queue

  Arg [1]   : int, number of jobs to submit 
  Function  : Take a certain number of job out of the internal queue and submitting them into the farm.
  Returntype: none

=cut

sub flush_queue {
	my ( $self, $slots ) = @_;

	for ( ; $slots > 0 ; $slots-- ) {
		my $job = $self->shift_job;
		if ($job) {
			eval {
				print "\tBatch running job " . $job->dbID ." priority ".$job->priority."\n"
				  if $self->be_verbose;
				$job->batch_runRemote;
			};
			if ($@) {
				throw(  "ERROR running job "
					  . $job->dbID . " "
					  . $job->analysis->logic_name . " "
					  . $job->stderr_file
					  . " [$@]" );
			}
		}
		else { last; }

	}
}

sub create_and_store_job {
	my ( $self, $input_id, $analysis ) = @_;

	if ( !$input_id || !$analysis ) {
		throw(  "Can't create job without an input_id $input_id or analysis "
			  . "$analysis" );
	}
	my $job = Bio::EnsEMBL::Pipeline::Finished::Job->new(
		-input_id   => $input_id,
		-analysis   => $analysis,
		-output_dir => $self->output_dir,
		-runner     => $self->runner,
	);

	eval { $self->job_adaptor->store($job); };

	if ($@) {
		throw(  "Failed to store job "
			  . $job->input_id . " "
			  . $job->analysis->logic_name . " "
			  . $@ );
	}

	return $job;
}

=head2 job_stats

  Arg [1]   : int, max number of jobs (optional)
  Arg [2]   : array_ref to array of Bio::EnsEMBL::Pipeline::Job objects
  (optional)
  Function  : gets statistics from BatchSubmission module about what
  jobs are running and what their status is then take action on this 
  information. job_stats will mark awol and out_of_memory jobs as well
  Return : number of free job slots in the farm. It depends on the JOB_LIMIT set in BatchQeue.pm
  Returntype: int
  Exceptions: throws if batch_submission module can't do the method
  job stats'
  Example   : $rulemanager->job_stats;('1000', \@jobs);

=cut

sub job_stats {
	my ( $self, $job_limit, $jobs ) = @_;

	if ( !$job_limit ) {
		$job_limit = $self->job_limit;
	}

	# Do job_stats call before getting jobs
	if ( !$self->batch_q_module->can('job_stats') ) {
		throw( $self->batch_q_module . " doesn't have the job_stats method" );
	}
	my %statuses_to_count = map { $_, 1 } @{$JOB_STATUSES_TO_COUNT};   #found in
	       #BatchQueue.pm
	my %job_stats = %{ $self->batch_q_module->job_stats };

	my @jobs;
	if ( !$jobs ) {
		@jobs = $self->job_adaptor->fetch_by_Status_not_like('CREATED');
	}
	else {
		@jobs = @$jobs;
	}

	my @awol_jobs;
	my $global_job_count = 0;    # job count for all pipelines
	my $local_job_count  = 0;    # job count for this pipeline

  GLOBAL: foreach my $sub_id ( keys %job_stats ) {
		if ( $statuses_to_count{ $job_stats{$sub_id} } ) {
			$global_job_count++;
		}
	}

  LOCAL: foreach my $job (@jobs) {
		if ( !$job_stats{ $job->submission_id } ) {
			push( @awol_jobs, $job );
			next LOCAL;
		}
		if ( $statuses_to_count{ $job_stats{ $job->submission_id } } ) {
			$local_job_count++;
		}
	}
	print $self->db->dbc->dbname
	  . ": $local_job_count / $global_job_count (limit: $job_limit) Pending jobs in the farm\n"
	  if ( $self->be_verbose );

	if ( $self->mark_awol_jobs ) {
		foreach my $awol (@awol_jobs) {
			my $status = $awol->current_status->status;
			if ( $self->valid_statuses_for_awol->{$status} ) {

				# Test if job exited with an out_of_memory error
				if ( $self->is_memory_error($awol) ) {
					$awol->set_status('OUT_OF_MEMORY');
				}
				else {
					$awol->set_status('AWOL');
				}

				print "Job "
				  . $awol->dbID
				  . " status $status changed to "
				  . $awol->current_status->status . "\n"
				  if ( $self->be_verbose );
			}
		}
	}
	my $free_slots = $job_limit - $local_job_count;			# number of free farm slots 
	$free_slots = $free_slots > 0 ? $free_slots : 0;			# total nb. of jobs must not exceeds job limit 

	return $free_slots;
}

=head2 urgent_input_id/read_input_file

  Arg : None
  Function  : gets a hash reference of the input_id that need to be completed at short notice.
  			  The path to the file that contains the list of urgent input_ids 
  			  is set in the BatchQueue configuration file.
  			  (see variable URGENT_INPUTID_FILE)
  Returntype: Hash reference

=cut

my $input_list = {};
my $s_last_modified = '';

sub urgent_input_id {
	my ($self) = @_;
	my $file = $URGENT_INPUTID_FILE;
	if( -e $file ) {
		my $c_last_modified = stat($file)->[9];
		if($s_last_modified ne $c_last_modified) {
			$s_last_modified = 	$c_last_modified;
			$input_list = $self->read_input_file($file);
		}
	} else {
		$input_list = {};	
	}
	
	return $input_list;
}

sub read_input_file {
	my ($self,$file) = @_;
	my $list = {};
	open(my $IN, "<$file") || throw("Unable to open input id file $file");
	while(<$IN>) {
		chomp;s/\s//g;
		$list->{$_} = 1;
	}
	close($IN);
	
	return $list;
}

=head2 is_memory_error

  Arg : Job object
  Function  : Read the job's output file and return true if job exited 
  			  with MEMORY LIMIT exception.
  Returntype: boolean

=cut

sub is_memory_error {
	my ( $self, $job ) = @_;
	my $out_file = $job->stdout_file;
	my $is_mem   = 0;
	eval {
		print "READING: $out_file\n" if ( $self->be_verbose );
		if ( -e $out_file ) {
			open( my $F, "<$out_file" );
			while (<$F>) {
				if (/TERM_MEMLIMIT/) { $is_mem = 1; last; }
			}
			close($F);
		}
	};
	print STDERR "ERROR [$@]\n" if ( $@ && $self->be_verbose );

	return $is_mem;
}

1;
