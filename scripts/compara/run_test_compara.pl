#!/usr/bin/env perl

use warnings ;
use strict;
use Bio::EnsEMBL::Compara::DBSQL::DBAdaptor;
use Bio::EnsEMBL::Pipeline::RunnableDB::CrossComparer;
use Getopt::Long qw(:config no_ignore_case);

print STDERR "starttime: ",time,"\n";

my $host   = 'ecs1b';
my $port   = '3306';
my $dbname = 'abel_crossmatch';
my $dbuser = 'ensadmin';
my $pass   = '***';
my $alnprog = 'crossmatch';
my $min_score = 50;

GetOptions('dbhost|host|h:s' => \$host,
	    'dbport|port|P:i' => \$port,
	    'dbname|db|D:s' => \$dbname,
	    'dbuser|user|u:s' => \$dbuser,
	    'pass|dbpass|p:s' => \$pass,
	    'alnprog:s' => \$alnprog,
	    'min_score:f' => \$min_score);

my $input_id = shift;

if (! defined $input_id) {
  die "Must call run_test_compara with an input id!";
}


my $db = new Bio::EnsEMBL::Compara::DBSQL::DBAdaptor (-host => $host,
						      -user => $dbuser,
						      -pass => $pass,
						      -dbname => $dbname );


my $tag1;
my $contig1;

my $tag2;
my $contig2;

if ($input_id =~ /^(\S+):(\S+)::(\S+):(\S+)$/) {
  ($tag1,$contig1,$tag2,$contig2) = ($1,$2,$3,$4);
} else {
  die "Input id should be dbname:contig_id::dbname:contig_id\n";
}


my $rundb = new Bio::EnsEMBL::Pipeline::RunnableDB::CrossComparer (-alnprog => $alnprog,
								   -dbobj => $db,
								   -input_id => $input_id,
								   -min_score => $min_score);


# run the runnabledb

$rundb->fetch_input();
$rundb->run();
$rundb->write_output();

print STDERR "endtime: ",time,"\n";
