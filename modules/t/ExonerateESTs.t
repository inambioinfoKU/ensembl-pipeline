use lib 't';
use strict;
use Test;

BEGIN { $| = 1; plan test => 5;
	require "Bio/EnsEMBL/Pipeline/pipeConf.pl";
      }

use Bio::EnsEMBL::Pipeline::Runnable::ExonerateESTs;
use Bio::PrimarySeq;
use Bio::Seq;
use Bio::SeqIO;

ok(1);

ok(my ($est1) =  set_est1());
ok(my ($est2) =  set_est2());
ok(my ($genomic) =  set_genomic());

ok(my $estseq1 =  Bio::PrimarySeq->new(  -seq         => $est1,
					 -id          => 'XX12345',
					 -accession   => 'XX12345',
					 -moltype     => 'dna'));

ok(my $estseq2 =  Bio::PrimarySeq->new(  -seq         => $est2,
					 -id          => 'M93650',
					 -accession   => 'M93650',
					 -moltype     => 'dna'));

ok(my $genseq =  Bio::PrimarySeq->new(  -seq         => $genomic,
					-id          => 'Z83307',
					-accession   => 'Z83307',
					-moltype     => 'dna'));

my $exargs = " -w 14 -t 65 -H 100 -D 15 -m 500 ";


ok(my $exe = $::pipeConf{'bindir'} . '/exonerate');

ok(my $exonerate = Bio::EnsEMBL::Pipeline::Runnable::ExonerateESTs->new (-ests           => [$estseq1,$estseq2],
									 -genomic        => $genseq,
									 -exonerate      => $exe,
									 -exonerate_args => $exargs));


ok($exonerate->run);

ok(my @results = $exonerate->output);

foreach my $pair (@results) {
  print $pair->seqname . "\t" . $pair->start  . "\t" . $pair->end      . "\t" . 
    $pair->percent_id . "\t" .
      $pair->score   . "\t" . $pair->strand . "\t" . $pair->hseqname . "\t" . 
	$pair->hstart  . "\t" . $pair->hend   . "\t" . $pair->hstrand  . "\n";
}

sub set_est1 {
  #embedded sequence! Because I can't create Bio::PrimarySeqs from files
  my $seq = 
    'cagaggtcaggcttcgctaatgggccagtgaggagcggtggaggcgaggccggcgccgca'.
      'cacacacattaacacacttgagccatcaccaatcagcataggaatctgagaattgctctc'.
	'acacaccaacccagcaacatccgtggagaaaactctcaccagcaactcctttaaaacacc'.
	  'gtcatttcaaaccattgtggtcttcaagcaacaacagcagcacaaaaaaccccaaccaaa'.
	    'caaaactcttgacagaagctgtgacaaccagaaaggatgcctcataaagggggaagactt'.
	      'taactaggggcgcgcagatgtgtgaggccttttattgtgagagtggacagacatccgaga'.
		'tttcagagccccatattcgagccccgtggaatcccgcggcccccagccagagccagcatg'.
		  'cagaacagtcacagcggagtgaatcagctcggtggtgtctttgtcaacgggcggccactg'.
		    'ccggactccacccggcagaagattgtagagctacctcacagcggggcccggccgtgcgac'.
		      'atttcccgaattctgcaggtgtccaacggatgtgtgagtaaaattctgggcaggtattac'.
			'gagactggctccatcagacccagggcaatcggtggtagtaaaccgagagtagcgactcca'.
			  'gaagttgtaagcaaaatagcccagtataagcgggagtgcccgtccatctttgcttgggaa'.
			    'atccgagacagattactgtccgagggggtctgtaccaacgataacataccaagcgtgtca'.
			      'tcaataaacagagttcttcgcaacctggctagcgaaaagcaacagatgggcgcagacggc'.
				'atgtatgataaactaaggatgttgaacgggcagaccggaagctggggcacccgccctggt'.
				  'tggtatccggggacttcggtgccagggcaacctacgcaagatggctgccagcaacaggaa'.
				    'ggagggggagagaataccaactccatcagttccaacggagaagattcagatgaggctcaa'.
				      'atgcgacttcagctgaagcggaagctgcaaagaaatagaacatcctttacccaagagcaa'.
					'attgaggccctggagaaagagtttgagagaacccattatccagatgtgtttgcccgagaa'.
					  'agactagcagccaaaatagatctacctgaagcaagaatacaggtatggttttctaatcga'.
					    'agggccaaatggagaagagaagaaaaactgaggaatcagagaagacaggccagcaacaca'.
					      'cctagtcatattcctatcagcagtagtttcagcaccagtgtctaccaaccaattccacaa'.
						'cccaccacaccggtttcctccttcacatctggctccatgttgggccgaacagacacagcc'.
						  'ctcacaaacacctacagcgctctgccgcctatgcccagcttcaccatggcaaataacctg'.
						    'cctatgcaacccccagtccccagccagacctcctcatactcctgcatgctgcccaccagc'.
						      'ccttcggtgaatgggcggagttatgatacctacacccccccacatatgcagacacacatg'.
							'aacagtcagccaatgggcacctcgggcaccacttcaacaggactcatttcccctggtgtg'.
							  'tcagttccagttcaagttcccggaagtgaacctgatatgtctcaatactggccaagatta'.
							    'cagtaaaaaaaaaaaaaa';
  
  return $seq;
}

sub set_genomic {
  #embedded sequence! Because I can't create Bio::PrimarySeqs from files
  my $seq 	= 
    'gatccggagcgacttccgcctatttccagaaattaagctcaaacttgacgtgcagctagt'.
      'tttattttaaagacaaatgtcagagaggctcatcatattttcccccctcttctatatttg'.
	'gagcttatttattgctaagaagctcaggctcctggcgtcaatttatcagtaggctccaag'.
	  'gagaagagaggagaggagaggagagctgaacagggagccacgtcttttcctgggagggct'.
	    'gctatctaagtcggggctgcaggttggagatttttaaggaagtggaaattggcaattggc'.
	      'tttgtgtgtctgtggtttttggggagggggactacaaagaggggctaactccctctccct'.
		'attctctaaggttggaccacagggatgaggttgtgagatacaaagataaaggagggatgg'.
		  'ggaacactatgatgtggtatttttcttttctgttttttctttttgataatatctatcctt'.
		    'ggctaaggggagggcggagttcagcggcggaaataaagcgagcagtggctggtgcgaacc'.
		      'gactcccggctctaagccttacttgcggtggccggacttgtctgtggctgaagccgagcc'.
			'cgggctctgactctcacgtctgcactggaggtgcggaaacctggactggggttcaccagc'.
			  'cacatactggctgctctggttgttctctcctcttccttcttctattctaaccaaacaaaa'.
			    'cccaactcgatgcttgtgccaggccttggccagtttggacggtgatggaaacatttctgg'.
			      'attttagcgtctaagggagcactcaagggctgtaaggtttgctatcactgtcccaacact'.
				'gcagagaccttgaaggttcagtgtgggatctgtagaacccatggtttgcggtgacactca'.
				  'gaggggatctttgggagatttatagagccggttcttagcgctttgtgggttcagaggctg'.
				    'gctgcagtgtttatgaagaggggcagtgggctggggacactgctggggttatggctgtag'.
				      'tgaggtccatgtgtacttgttccttggcatgtgtctgactctgtgttgctgctgcagtac'.
					'agtgggcaggggcacggttgcttggactgggctgcccgatgtctggcatggctggtggtc'.
					  'ctgttgtcctttatttgatcgatagcagggaactgaccgccgaggttggcacaggttggc'.
					    'agggggatgaggatgcattgtggttgtctcctcctcctctccttcttcctcttccccttc'.
					      'ctcctctcctttctgttcttgttctccctcatcttcctcttccttcttctccctcttctt'.
						'cctcttcactctgctctcttctcttcttttcccctttcctctcctctccctttcctcagg'.
						  'tcacagcggagtgaatcagctcggtggtgtctttgtcaacgggcggccactgccggactc'.
						    'cacccggcagaagattgtagagctagctcacagcggggcccggccgtgcgacatttcccg'.
						      'aattctgcaggtgatcctcccggcgccgccccactcgccgcccccgcggccctccactct'.
							'caacgccctctcttcatttcttactgtaaacgatgctaattatggacccccccaccctca'.
							  'cccaccccagtccccagtccccccacccactcccctgccttcccactttcccctctcctt'.
							    'ccaccatccttccctatctctttcaacctgggtcagttacataagataactcatctgctt'.
							      'cagaaaaatattgtgtgcggatttttttaaaaaaatctttctctttttatttggtaaaga'.
								'cattcattgtgggaacagtttatgaaccgtaataagctgagttatataaaccggcataat'.
								  'ttcattctgctctccccagcccatgcttacctcagcttttgaggtatttgtttattcttc'.
								    'atgtttatgaataatatatattgattttaaaaggcaaatgctatttactcctccctaact'.
								      'cacatttactcaattgagtattttttaaagaagaagaagtaaaaaaatcagtttattttt'.
									'tacctttgttctttaaaacataacgccactttaagcaaggtcagcacaaaaataaattta'.
									  'tctacttcgttttgatgcatcttcaggcagtgtttaagaaaagttttttttttaaaaaaa'.
									    'gcttttaaattcgttttttagttcaaattgtttgaaagtatcatcatatttgtagttttt'.
									      'agggctacaaatgtaattttaagaaaaaaagctctctacagtaagttctcataccattga'.
										'aggtatatttttgtgttatagacccatgcagatgcaaaagtccaagtgctggacaatcaa'.
										  'aacgtaagcttgtcattgtttaatgcatacttaaacaattttatttttgtcttgaaatta'.
										    'ttaataatgtggttttctgtccacttcccctatgcaggtgtccaacggatgtgtgagtaa'.
										      'aattctgggcaggtattacgagactggctccatcagacccagggcaatcggtggtagtaa'.
											'accgagagtagcgactccagaagttgtaagcaaaatagcccagtataagcgggagtgccc'.
											  'gtccatctttgcttgggaaatccgagacagattactgtccgagggggtctgtaccaacga'.
											    'taacataccaagcgtaagttcattgagaacatctgccctccctgccctaagcccaatgct'.
											      'ctctcctctttacctcctcccaccctctctctccactgtctcttagtctgtgtcctctcc'.
												'ctgctccacatttgtctcctttgtacctgggggaacagagaggaatgccctgacttttct'.
												  'ttgactgtctggaaaatgggagtcaagtgtggggagtcattcacttcatttgcatgctgc'.
												    'aaaacagagggcggaggcaccagggaaaggcacttgaatgaagaaggaaaatgagaacca'.
												      'gattgtaacttcgtcctaatccacctgccagaactttccttcaggtgtcacacatccatt'.
													'tccatcctaatattaaacaatataatgaaagaaagctttacaacaagtctaaatagtttt'.
													  'tattttcgggcagtcttttaacaaagcaaagcaaccgtgtgagttaggtcaccagagaca'.
													    'ccaagcaatggtgaaggaccccctccgcccaattctctatccaactaaatttccatgccc'.
													      'aaagtgatagctatcattttttccacggtgtatctgcaaatccacccactgtcccggggt'.
														'ggctgggagctttttaacgggttgagagttgctttttaaggttgtgggtgagctgagatg'.
														  'ggtgactgtgtcttcaggagacactaccatttggtttgattttggtttgatttgcaggtg'.
														    'tcatcaataaacagagttcttcgcaacctggctagcgaaaagcaacagatgggcgcagac'.
														      'ggcatgtatgataaactaaggatgttgaacgggcagaccggaagctggggcacccgccct'.
															'ggttggtatccggggacttcggtgccagggcaacctacgcaaggtaaaacccaagcagcc'.
															  'atccacgcagctctccatatgtgcatccctttgcctgtcccctactctcccaaccatttc'.
															    'ctctcagggcttccatgcttggggaatgtcatgggtgagactgcatttgaaggcctggga'.
															      'cacatcgaccacattgtatgtaggtggtgtttgttgaaccattttgttggcctgggaatg'.
																'tgagggttgtgtatgtcaggagcggtatgaaggtggctggtgggtgcgtgtgtgtgtttg'.
																  'tgggcagcactgtgtgcataagaacgagctgcgtggtgcactattcaaatttgacattag'.
																    'aatgcagggagagcccccttgtagaagtgtgacaagataacgcactgacagactgcgagg'.
																      'ttaacataattgtatcctgttgctttttgctgtaattgacaaattatgtgactatgagta'.
																	'gggtgcacatgaaaaggtgagcagggagatgcagggcgagtcggggatggggcattggaa'.
																	  'gtggtggtctcccaactaaaaccaccccactatccttgcccctcccccgttcgcccctct'.
																	    'gggtcccactttctcactctctgtgggtggcgactatgtggaagtggtgaggtgaagata'.
																	      'ctgtgagcaggacggcgggatgccgggagccgctctggtctgggaggagagatgggacct'.
																		'gaaacaccccaggttctgtgagaagggctggaggaagaagagcgggggatggggggggtg'.
																		  'gggcggaggggagggtcagttggctcccctccgctcccctccacaccccgaggtagcttg'.
																		    'gtcaagaataggaaacagtttactccgaagattaatcggtatttgttgtcctcgtgacaa'.
																		      'ggagataatatgcgggataatgggacgtggcgtctcactcccaggagcacaacggagccg'.
																			'aggggctcggggccaggggcggcgcgcgggactgcgaggaggctgccggcgcatccgtga'.
																			  'gctctcggaccggctccggatgcccggcgcctccatggagtcgggcgagggaagggaaaa'.
																			    'tcggtaacagtatgcgaaatatctggtacaaaggatgcttctgtcactcgcaagaatttg'.
																			      'ttatgggaacaatcctgtcgctctgtaattgctcattagagaacgttttgtttctcatta'.
																				'aggcgacatgaataagcgtctagttgaaggagacagctgtagaaatgttccacaagagac'.
																				  'ctctggacacgattcggcaccaattgccaattagacatgtcagttttaagagcagaaaac'.
																				    'aatataggacggacactgggaagatagggagcaaagcgctcgcttcttgtttcccagcgc'.
																				      'ggccgctcggccggcggaggcctcctgacgcgcggggcccgggctcccctgggcgacccc'.
																					'gcccgcacgggccccgaacccgccgcctccgcgagctcagagggcccccaggcccgctcc'.
																					  'cgcctctggtgagactagcgattgaccccaccgagtgtaggcaaccccatccctgcctga'.
																					    'cttttgaaaccgtaggattcccacttgtagacactggacacacccaagtgacacccgaac'.
																					      'ttcgcactcacgagcgtccacccctccgcccccagcaatctgaggtcctggtgatccctc'.
																						'ccctgacaagagtctggcccacttagtccgagaagtcttggggagggactcagggcacgg'.
																						  'tggcctaggcctgggagggctgagcccagagcctccactccgggctctccccggtgcgtg'.
																						    'ggctcccatgagcttggggcgcaggatacaccccccttccgcttcttggagttgggcaga'.
																						      'agccgaggacagcagcttccaccagaggtggcgcccgattcgggcggattttcgtcgccg'.
																							'gcagtctgagggcgggaagtgagagtcaaatcagctagggtccgcctgtgatggttgggg'.
																							  'ccggaggtggagctagtccaggggcttttcactttaacgcgcctagttgctagaaaattc'.
																							    'tgggtcaactggcaatcaccacccccccacccgcaagtgaggtttttggggggtgattgt'.
																							      'cacctcaggcacaggaccgtcgcccctagttgcgtggggaggacacgtgggccaaacgaa'.
																								'gcacagagttgccggcgtgggggtagcgggcaccggtggtgagcttcgcttcacgttccc'.
																								  'ggggaatcctcagactttttggtgctaagagggtccccctccctccctagccccctttcc'.
																								    'cagcccaggaagcctttcttgggttttaaagagtccatactccaaaagcataaggcgggg'.
																								      'gttaggtctcagagggagacaaatatggtttccatctgatcaacgccatgcggcggtgaa'.
																									'taaaatcgcgacgacgtgggctgacaacaacaagagacaactctatccagccccaattct'.
																									  'ccggcgatttggtggttttagggatcacggagacactttttcttatctcctcccctcacc'.
																									    'ccacccccaccccccataatacccaagccctctataggatttagtcagcctctctttcaa'.
																									      'cagatgctacaatgttttgatccgcgctccagagctgaaaaggtgccgcaaccgggttgc'.
																										'tatcttttcttgcttgttttccgcctcactgattaagacactaagaaactaaggaatgat'.
																										  'tttatttcccagcaactctctctctgtctctctctctctctctctctctcacctccttcc'.
																										    'aggaaacaaatcctattcccatcgtcagatggtcctggggctgggataatgggaggcgct'.
																										      'ttcactcgctttctcacggattaggctggaaggtgaacggcacccactgaaggcccctgc'.
																											'tttgcgcggctccgagggggcgccttttgaagaagatatcttaattgtccaccacttagg'.
																											  'tttatcgtgggggtgggggagtcgagatccaacttctagttttattttgttaaaagcttt'.
																											    'aagagtggaaggcaaatccactaaagtggggggaaatgtacccattttatgtaagagcag'.
																											      'ccgctaggtcaccgcctggctgcaaacagttgccacttctaaagtaatgaactgtctccg'.
																												'tgccgctctccccgcggggtagagaagggatcctgcagcgacaggtttctttttgctgtg'.
																												  'gaattccaatccccgcttcccatcttttttttttttttttttttttccagatttaaaatt'.
																												    'gagctctactgtccctgctgacttttctctcttaagtgtcagttctggaggcagcacagg'.
																												      'gcctggcggcgatcgcgtgctgcctgtgtaaacccgtgtgtatgtttgtgtgagacagaa'.
																													'catggataagaatgtgaatctccatgttttaaaattaagaaaatgtcaaagaggcaaatg'.
																													  'agagcagagcatgctatcggcggggttcttcggaggcagattcgggcaactttgtttaat'.
																													    'tggcgagatcgaatgtgccagaaaagggaccgagatggggcccctaggaaggcatgggca'.
																													      'tgagtggccatggggagatgggcattgtgttctcctcagtgtcccccaccccataccaga'.
																														'tgtgcacagatttttgtctgttttccaaaagcaataaccctccggcctttctagttggcc'.
																														  'aaaaggagctatttccagtcttccttcttcaccaaacccgaaaataaagcgaggggtggg'.
																														    'ggtggtcgcttcatttcttcccttgaaaaacgctttgaaaagtccccggaaacttggggc'.
																														      'agtaaattagcacagacgcttgtgcccgcacacgtgagcggagcgcgtctccctcagcta'.
																															'agtagccctcctcgacccccacctttctgatggagtgcaaagacccagagtccagatggg'.
																															  'gctcagttactaatattctctggccctcatcctccttttcctctctctcccactcttgtt'.
																															    'cggccctcgtgtctctttttcctctcagcattcttttctgtccttttttaaaaatacctt'.
																															      'tctagcctctatgttttttgagccttcttttcccctccatcgccctctttttccctccat'.
																																'cgccctctgtctttcccctaacccaggccccccaatccttcccccttgcttccaccccca'.
																																  'ccgctggtttccatcctgcctcccctccatctcctctatgtaggaacccagccctggtcc'.
																																    'ccgtccactctccctgcctccccccatgctgggccctggcccccccatccaccctccatc'.
																																      'cccccagccaagcgccctaaatagcacggaggcgcccgctcttcggacagtgattaatga'.
																																	'tagcagagcagaggggttaacacacttcactgaaaagtctgttgactgggcttcttgtaa'.
																																	  'cacaatgtggcccgctgcacgcctcaagagaatccttttgttgtccgcgctcattgtagc'.
																																	    'ctcaaaattctgcccacgaaagtttgccaacgctcctgccccaggagtttaatagtttcc'.
																																	      'cttactcgcggggcattgtgcagcgctgaaaagcagcccctcgctattcaagtgttggtg'.
																																		'gtcatctcaatagatctccaagggcccatatggtggccagtgccgatgaatccgcctgtt'.
																																		  'taaatgggggagaaagttggggttttaaaacatttcaaagttcctgaaaagatcccacta'.
																																		    'gatcctgtcacaattccctgaactctttgaaggcgcagcctattgtctcctggttataaa'.
																																		      'taatattcctggccaagtcgattcccaccaaggcgctcctaggggcccctccaccccgcc'.
																																			'tctggccaagttttgaggatagggaggtgggtagcccatgctggtatcccttgggggtca'.
																																			  'tttcaggaccccagacccaggacccagcctgtagtggccctggaggcccagtcagagttt'.
																																			    'aggcaatcctgcttcccttcactgtggccttacaggcaaggtgcaagccgggagccagct'.
																																			      'agcccaagtgcacatcttgccctccaggcagcaagggaaaaccataaaactttccccctg'.
																																				'tataatgatagaagttacattcaaagtggtggaaatgccctaattaaaaatgtaccactt'.
																																				  'aaatgatatgccaaagattcagctgcagcatagaatatttagctagttagtgaactctct'.
																																				    'actatttcttttttaaaattacacgttaaaaatttaaaagaaatcttacttttctctggt'.
																																				      'gcaacacattacaaagaatggacagtccttttatctaaatataaaattccattttcagca'.
																																					'attatagcctgttcttggtgatgatataattacagctgtgctcgtaataggtgtcaaggc'.
																																					  'gaagcgcactcatacaatagttgaataaaactgcagaacaatgcgagcacttctaaattc'.
																																					    'acaacctttaaatgaaattgactgtgcagaattcaaataaaaactagataaatatttttt'.
																																					      'aaaaaagattacaagcttggtttggtttcttaatagcattttctacaaacctatcaacat'.
																																						'ctaattgattagataggaattactgattatagatcaactgaaatcttgaacatcactctt'.
																																						  'ctattttcccaacacagccataggtaaagagattctgtagggagtggagtgaggcatttg'.
																																						    'gggagttggggttacttataaaagatcattttaattggaaacttcagtgcttattttttc'.
																																						      'attcaagaaatgccacttagtgtgtgtattataaagtctcatcttgataaaaacaaagaa'.
																																							'aatggtggtcaggtaactaacatcgcaaatgtatttttttaaaagaaggctgacagttac'.
																																							  'cttgggaatgttttggtgaggctgtcgggatataatgctcttggagtttaagactacacc'.
																																							    'aggccccttttggaggctccaagttaatccaaatttctcttaccatcctattctttttgt'.
																																							      'tccagatggctgccagcaacaggaaggagggggagagaataccaactccatcagttccaa'.
																																								'cggagaagattcagatgaggctcaaatgcgacttcagctgaagcggaagctgcaaagaaa'.
																																								  'tagaacatcctttacccaagagcaaattgaggccctggagaaaggtgatagagtttttca'.
																																								    'aagtagagaagcagtaaatcaaagtaaatgccacatcttcagtacaaagagctaaattta'.
																																								      'gccagggccctttgcatagaagaatgaaaagatttccttttttctgtctttttatttctc'.
																																									'tgggcatcttttcagtgtgtgtgtgtgtgtgtgtgtgtgtgtgtgtgtgtgtgtgtgtgt'.
																																									  'gtgtgtgtgtgtggtgtgtgtgtgtgtgtttcttcttttcatctaccagtaattcaaaga'.
																																									    'ctaaatgtctgacttataaggaaaaatgatgatttggctatttcaggccacagaaaggtc'.
																																									      'actgaatgccattccaaagaaaatttaacttggttctggtgggaaagttcttccaagtac'.
																																										'agtcaacactagaagcattttaaagggaattggttggaggtaatgggagtggggaggtgg'.
																																										  'gaaccagtttgatgcacagtttggtcaacatattttgtgtagttctggcacaatatggaa'.
																																										    'aatcaacttactctttcagagtttgagagaacccattatccagatgtgtttgcccgagaa'.
																																										      'agactagcagccaaaatagatctacctgaagcaagaatacaggtaccgagagactgtgca'.
																																											'gtttcacactttgtgattcataccatttgtctttcctagagacagaggtgcttgtacaga'.
																																											  'gtactatttatttataggactaatataataaaaaggttcagtctgctaaatgctctgctg'.
																																											    'ccatgggcgtggggagggcagcagtggaggtgccaaggtggggctgggctcgacgtagac'.
																																											      'acagtgctaacctgtcccacctgatttccaggtatggttttctaatcgaagggccaaatg'.
																																												'gagaagagaagaaaaactgaggaatcagagaagacaggccagcaacacacctagtcatat'.
																																												  'tcctatcagcagtagtttcagcaccagtgtctaccaaccaattccacaacccaccacacc'.
																																												    'gggtaatttgaaatactaatactacgaatcaatgtctttaaacctgtttgctccgggctc'.
																																												      'tgactctcactctgactactgtcatttctcttgccctcagtttcctccttcacatctggc'.
																																													'tccatgttgggccgaacagacacagccctcacaaacacctacagcgctctgccgcctatg'.
																																													  'cccagcttcaccatggcaaataacctgcctatgcaagtaagtgcggctggtggtggcctg'.
																																													    'cataacccaggccccagagaagtgaggagtggctcagggcctgcggacctcattggctgt'.
																																													      'gtctgcacccttgagagcttttcgcactacagtgattggcttgaccagtcaagtcggaga'.
																																														'cagtcaatcccatcacttttaagtgattgactcattaattcatgccctaaaaaaatgagt'.
																																														  'aataaaaatctgtccagttttgtcaggttgatctgccttttattatactgttaccttgat'.
																																														    'aatgttgggtggtggtggggcatgttttgggtaccagggagccttgcaccagaaagtgga'.
																																														      'aataatgctggcacattatcagatagcagattagtagtttaaaatttgggtttatattaa'.
																																															'tgtgtttgtatgctaaatatagaatctgtgcacgcatttggggcattactttgggtatat'.
																																															  'gtgataaactagtgagaaagaaaaaaggatcagaaatgggattcatatttacatggtgag'.
																																															    'atatacataatataatgagaatgctagttttctgtctgtatctacaataagaaaaggcat'.
																																															      'agcaggtatttgctggaaatttagtgtgtctttgctgtgaatggtgtgacgagtttgtgg'.
																																																'ccctcctagctgcctgggaagcttgatgctattcacttggtatgacagcctgcctctcct'.
																																																  'cttagttctgtcccaaatatctattagcccctacatttagaggtcctgcactaggttcac'.
																																																    'cctttatgatgtaagttggataaggcagatggtttgtactagacctttgttgctggatgg'.
																																																      'attcttgataggaaaaatgtctgtcttctggtaggcctttcccagtggttttcctagaac'.
																																																	'tcctgtttgtgcaacaattagagatattagatggtacgatattggccagcatgagcctct'.
																																																	  'gctggaaacagttctggggctacactgattgtttattctccattgaacattttttgctgg'.
																																																	    'atttcaaatccaaataacagcaaaataaatgtttcacagtcttcagactaatataggagc'.
																																																	      'agctagataagcaacttcagaggaattattcacatgtttatttttattgcatctggatat'.
																																																		'tgttggccatagtgcaattgatgtaaattaagggattaacagcccattagttggtgttgc'.
																																																		  'tataactgcgttggaattttccagaagtcaggttgcctagaggaactcattgcaggaatt'.
																																																		    'agaaacaaatgcaagctgaaattctggcaggccctcaaggcctgtttgcctctttgaact'.
																																																		      'tgatgttagcattcatcatctgactttaataaggccacagagtgtctcgttcagtttcat'.
																																																			'gtattataacaacatccaggtttctgtgaagatagcaaaatgtgtatgtgagaaaataat'.
																																																			  'aagacgaacaagtagatgctgcaattatattagggctgtttccacatacagagcggtatg'.
																																																			    'gggaatcaatctatttcaaacactgacttttaaaaattacataatttgtataattcaaaa'.
																																																			      'agtacatgcattcattaagcataaagaaaatcaaaatgatcaataactttactcttcaga'.
																																																				'gaaaactactctttgaattttggagtgggtgagcccgattgtctatccatttattcattc'.
																																																				  'tcttgaccaaaatcatcattttacaaatggtgggtgtcttcctctggaccttctctgata'.
																																																				    'tgcttccctctctgagcatatggattttggaaattaaacatttctccagtttgcagagaa'.
																																																				      'gagaaatgatagtatactgtactatcatctgacctgcttgttcccgacacacttctttta'.
																																																					'attcatcccaagtttgctgccatggcatagtaccatgagagctcatgaggcgttttgtta'.
																																																					  'ggagaaaggtttacctcctcagtgctgccattccgaacagttcgagggtagcaacagttt'.
																																																					    'tctagttataagtcagtctgggcttttgggtctgttaggaagtcatggttaattctcagg'.
																																																					      'atggaggtcgttatatttactaacacttctgatcactttaacttggggtcattacagatc'.
																																																						'tgcttcttcaaagaatctttaatcccatcagtgaaaggttcccaaggtccctgaaccata'.
																																																						  'ctttactgagagctcctcccactgctctctgtcccaaagcttgagatatgggctctgggg'.
																																																						    'gtcatagggttcccaaataaatccagatttgcagggagaggggatgtgttttgatgaagg'.
																																																						      'tcctcatgctataggttcttcaaagatgctagcagaggttagagacaaaaatcctattaa'.
																																																							'tttatggatagtggcaaccatctagctggacagttgtcagaacctaaagtgctttagagg'.
																																																							  'cttgatacataggcagctttcttctagctgtggccagtggaaggactagctcgaggccca'.
																																																							    'atcttagatttatcatatggaattccagtacttcacgtgaaggcatctttaatgatcaga'.
																																																							      'cttgttggcagagttcctcgggaggagggagcctggggctgtggctgtgtgatgtgttcc'.
																																																								'tcagtaaccacaggtttgcctctctcctcacagcccccagtccccagccagacctcctca'.
																																																								  'tactcctgcatgctgcccaccagcccttcggtgaatgggcggagttatgatacctacacc'.
																																																								    'cccccacatatgcagacacacatgaacagtcagccaatgggcacctcgggcaccacttca'.
																																																								      'acaggtgagccactgctttctgcaggctgcacagaggcgatctctcttcactagaagttt'.
																																																									'acccaaacagaatctcctggtcttatgggagggcgtgtttaactccttgctttccttgtc'.
																																																									  'cctgggggatggggattgaaaagggaaattcagttaagctaattagtaactttacaccat'.
																																																									    'atagacaaaaactaaaattgtttttcctgaatttggtcacaaaagttgtgtatgaagaca'.
																																																									      'aggcctgagactgcaagttttctgaggacagattattagacgaagctcagtagggggccc'.
																																																										'actgagctgtaggtgcgtgcttgttgaaatgcttcttgccctcatagctcctctagacct'.
																																																										  'tttgctggaaataaaaagtgacacattggttttccagagacagctttattgtaaaagttc'.
																																																										    'caaacatgcaaacaaacagaggattttttttttcttttcctttggattggggtggggggt'.
																																																										      'acttgggatccaataggtatatatacatatattgtctagtttctgaaggtgctactttta'.
																																																											'tttgtaacaattgaagtgattttaatacagtaaaaaatgttagaaagtattagttttttt'.
																																																											  'ttttttttttttttttgtaaacctataaatttgtattccatgtctgtttctcaaagggaa'.
																																																											    'tatctacatggctatttctttcatccacttctaggactcatttcccctggtgtgtcagtt'.
																																																											      'ccagttcaagttcccggaagtgaacctgatatgtctcaatactggccaagattacagtaa'.
																																																												'aaaaaaaaaaaaaaaaaaaaaggaaaggaaatattgtgttaattcagtcagtgactatgg'.
																																																												  'ggacacaacagttgagctttcaggaaagaaagaaaaatggctgttagagccgcttcagtt'.
																																																												    'ctacaattgtgtcctgtattgtaccactggggaaggaatggacttgaaacaaggaccttt'.
																																																												      'gtatacagaaggcacgatatcagttggaacaaatcttcattttggtatccaaacttttat'.
																																																													'tcattttggtgtattatttgtaaatgggcatttgtatgttataatgaaaaaaagaacaat'.
																																																													  'gtagactggatggatgtttgatctgtgttggtcatgaagttgttttttttttttttaaaa'.
																																																													    'agaaaaccatgatcaacaagctttgccacgaatttaagagttttatcaagatatatcgaa'.
																																																													      'tacttctacccatctgttcatagtttatggactgatgttccaagtttgtatcattccttt'.
																																																														'gcatataattaaacctggaacaacatgcactagatttatgtcagaaatatctgttggttt'.
																																																														  'tccaaaggttgttaacagatgaagtttatgtgcaaaaaagggtaagatataaattcaagg'.
																																																														    'aagaaaaaaagttgatagctaaaaggtagagtgtgtcttcgatataatccaatttgtttt'.
																																																														      'atgtcaaaatgtaagtatttgtcttccctagaaatcctcagaatgatttctataataaag'.
																																																															'ttaatttcatttatatttgacaagaatatagatgttttatacacattttcatgcaatcat'.
																																																															  'acgtttcttttttggccagcaaaagttaattgttcttagatatagttgtattactgttca'.
																																																															    'cggtccaatcattttgtgcatctagagttcattcctaatcaattaaaagtgcttgcaaga'.
																																																															      'gttttaaacttaagtgttttgaagttgttcacaactacatatcaaaattaaccattgttg'.
																																																																'attgtaaaaaaccatgccaaagcctttgtatttcctttattatacagttttctttttaac'.
																																																																  'cttatagtgtggtgttacaaattttatttccatgttagatcaacattctaaaccaatggt'.
																																																																    'tactttcacacacactctgttttacatcctgatgatccttaaaaaataatccttatagat'.
																																																																      'accataaatcaaaaacgtgttagaaaaaaattccacttacagcagggtgtagatctgtgc'.
																																																																	'ccatttatacccacaacatatatacaaaatggtaacatttcccagttagccatttaattc'.
																																																																	  'taaagctcaaagtctagaaataatttaaaaatgcaacaagcgattagctaggaattgttt'.
'tttgaattaggactggcattttcaatctgggcagatttccattgtcagcctatttcaaca'.
'atgatttcactgaagtatattcaaaagtagatttcttaaaggagactttctgaaagctgt'.
'tgcctttttcaaataggccctctcccttttctgtctccctcccctttgcacaagaggcat'.
'catttcccattgaaccactacagctgttcccatttgaatcttgctttctgtgcggttgtg'.
'gatggttggagggtggaggggggatgttgcatgtcaaggaataatgagcacagacacatc'.
'aacagacaacaacaaagcagactgtgactggccggtgggaattaaaggccttcagtcatt'.
'ggcagcttaagccaaacattcccaaatctatgaagcagggcccattgttggtcagttgtt'.
'atttgcaatgaagcacagttctgatcatgtttaaagtggaggcacgcagggcaggagtgc'.
'ttgagcccaagcaaaggatggaaaaaaataagcctttgttgggtaaaaaaggactgtctg'.
'agactttcatttgttctgtgcaacatataagtcaatacagataagtcttcctctgcaaac'.
'ttcactaaaaagcctgggggttctggcagtctagattaaaatgcttgcacatgcagaaac'.
'ctctggggacaaagacacacttccactgaattatactctgctttaaaaaaatccccaaaa'.
'gcaaatgatcagaaatgtagaaattaatggaaggatttaaacatgaccttctcgttcaat'.
'atctactgttttttagttaaggaattacttgtgaacagataattgagattcattgctccg'.
'gcatgaaatatactaataattttattccaccagagttgctgcacatttggagacaccttc'.
'ctaagttgcagtttttgtatgtgtgcatgtagttttgttcagtgtcagcctgcactgcac'.
'agcagcacatttctgcaggggagtgagcacacatacgcactgttggtacaattgccggtg'.
'cagacatttctacctcctgacattttgcagcctacattccctgagggctgtgtgctgagg'.
'gaactgtcagagaagggctatgtgggagtgcatgccacagctgctggctggcttacttct'.
'tccttctcgctggctgtaatttccaccacggtcaggcagccagttccggcccacggttct'.
'gttgtgtagacagcagagactttggagacccggatgtcgcacgccaggtgcaagaggtgg'.
'gaatgggagaaaaggagtgacgtgggagcggagggtctgtatgtgtgcacttgggcacgt'.
'atatgtgtgctctgaaggtcaggattgccagggcaaagtagcacagtctggtatagtctg'.
'aagaagcggctgctcagctgcagaagccctctggtccggcaggatgggaacggctgcctt'.
'gccttctgcccacaccctagggacatgagctgtccttccaaacagagctccaggcactct'.
'cttggggacagcatggcaggctctgtgtggtagcagtgcctgggagttggccttttactc'.
'attgttgaaataatttttgtttattatttatttaacgatacatatatttatatatttatc'.
'aatggggtatctgcagggatgttttgacaccatcttccaggatggagattatttgtgaag'.
'acttcagtagaatcccaggactaaacgtctaaattttttctccaaacttgactgacttgg'.
'gaaaaccaggtgaatagaataagagctgaatgttttaagtaataaacgttcaaactgctc'.
'taagtaaaaaaatgcattttactgcaatgaatttctagaatatttttcccccaaagctat'.
'gcctcctaacccttaaatggtgaacaactggtttcttgctacagctcactgccatttctt'.
'cttactatcatcactaggtttcctaagattcactcatacagtattatttgaagattcagc'.
'tttgttctgtgaatgtcatcttaggattgtgtctatattcttttgcttatttctttttac'.
'tctgggcctctcatactagtaagattttaaaaagccttttcttctctgtatgtttggctc'.
'accaaggcgaaatatatattcttctctttttcatttctcaagaataaacctcatctgctt'.
'ttttgtttttctgtgttttggcttggtactgaatgactcaactgctcggttttaaagttc'.
'aaagtgtaagtacttagggttagtactgcttatttcaataatgttgacggtgactatctt'.
'tggaaagcagtaacatgctgtcttagaaatgacattaataatgggcttaaacaaatgaat'.
'aggggggtccccccactctccttttgtatgcctatgtgtgtctgatttgttaaaagatgg'.
'acagggaattgattgcagagtgtcgcttccttctaaagtagttttattttgtctactgtt'.
'agtatttaaagatcctggaggtggacataaggaataaatggaagagaaaagtagatattg'.
'tatggtggctactaaaaggaaattcaaaaagtcttagaacccgagcacctgagcaaactg'.
'cagtagtcaaaatatttatctcatgttaaagaaaggcaaatctagtgtaagaaatgagta'.
'ccatatagggttttgaagttcatatactagaaacacttaaaagatatcatttcagatatt'.
'acgtttggcattgttcttaagtatttatatctttgagtcaagctgataattaaaaaaaat'.
'ctgttaatggagtgtatatttcataatgtatcaaaatggtgtctatacctaaggtagcat'.
'tattgaagagagatatgtttatgtagtaagttattaacataatgagtaacaaataatgtt'.
'tccagaagaaaggaaaacacattttcagagtgcgtttttatcagaggaagacaaaaatac'.
'acacccctctccagtagcttatttttacaaagccggcccagtgaattagaaaaacaaagc'.
'acttggatatgatttttggaaagcccaggtacacttattattcaaaatgcacttttactg'.
'agtttgaaaagtttcttttatatttaaaataagggttcaaatatgcatattcaattttta'.
'tagtagttatctatttgcaaagcatatattaactagtaattggctgttaattttatagac'.
'atggtagccagggaagtatatcaatgacctattaagtattttgacaagcaatttacatat'.
'ctgatgacctcgtatctctttttcagcaagtcaaatgctatgtaattgttccattgtgtg'.
'ttgtataaaatgaatcaacacggtaagaaaaaggttagagttattaaaataataaactga'.
'ctaaaatactcatttgaatttattcagaatgttcataatgctttcaaaggacatagcaga'.
'gcttttgtggagtatccgcacaacattatttattatctatggactaaatcaattttttga'.
'agttgctttaaaatttaaaagcacctttgcttaatataaagccctttaattttaactgac'.
'agatcaattctgaaactttattttgaaaagaaaatggggaagaatctgtgtctttagaat'.
'taaaagaaatgaaaaaaataaacccgacattctaaaaaaatagaataagaaacctgattt'.
'ttagtactaatgaaatagcgggtgacaaaatagttgtctttttgattttgatcacaaaaa'.
'ataaactggtagtgacaggatatgatggagagatttgacatcctggcaaatcactgtcat'.
'tgattcaattattctaattctgaataaaagctgtatacagtatgtgtttatgctacagtg'.
'ggtttttttaagtgactgacattcatcatattggttagacagttttaaaaacctagtctt'.
'tgttttctacaatgttgtcaagaacaaataaagtataatttgtggtatattaaaagcaag'.
'ctgcttaaaaatgctagttataactgcttcaaaatattaaatacatttgaaaatgtattt'.
'tggaaattcagtttctcccaatggatgttaaacaccttttaaaaaatcaagactcttaaa'.
'tatgcaagttacttttcaactttcattttttatccattatctgtcaaaagctttgagaat'.
'atagaattgtaattaaaacacctaatgtttcatatgaaaactggttcgatatgctatacc'.
'ccccaaagacatgtttacatggttagaaatttacacactcaaccaatgttcattattaac'.
'aaaatatttatgtgatgcaatggaaatctgagttagtttcattttttcactttgtctcag'.
'acctatgttctgtaaaatctctcaacaagcttcagtatatgtttttctcctggtatccta'.
'gcattaatgtagctgtcagtttgaatttcaatcctgaatgatgcctgttgacataatttc'.
'atagtactgacttcaattgtttaggattactaaactaaagaccatccacttcttttttct'.
'atgtttcctatcactgaagttctttatatttaataactactatggtagactaattatctc'.
'tagtggaatctaaatcccaaaatattactttgtctttatcaatttaataactggatacat'.
'aaatgcaaatttattttatatattagtaaacacattttcatttaaaaaacagcatttttg'.
'gtggcaagtgactgtttctgtaataaagagaaagtatgttttcacatacaatcttgaatt'.
'tcatcatgttttgtatgctacctgctgtgacatgcactttaccatgacactaaatgcctt'.
'agtacacacacgaatgaccactgtcaggaatcttgagattttgacattttttggcgttta'.
'tttaaaaataaaattattttctctagagcatgaaggaaaaatttaaaagtatttctgctg'.
'tgctagttctgtaaaaagttaaaaaatgagaaatggcggcaccattttataatcctgtgt'.
'ttttcaaggagtggagggtcaaattgttaagaaaaatatttacataagctattagcaatc'.
'ataattagagtgtcatagaattctgcatgcagcgactaaggaggaatccctagaagtcca'.
'ggtgcttcttgcctccggccatcatgccacagcctgggcccagccgcttggcggattctg'.
'ccagatccattttgcttgagcggctcactgtgtctgacaagtctggaggcaaatgcagtc'.
'gctatggcagaagatttcaggagaagaaaaaaagaagaaagaagaaaaaaaattaatttt'.
'gctttggctagcatacttcagattacaatattatgctctgttgatcagcatttagacttg'.
'catataaaattcctgctaaaacaattcttcagactgaattccagtataatcacctcctgt'.
'tcctactggattttacaaattacagccatcacagaaaccgtaccaggaatcttattggaa'.
'cattttcagtgtccaaaccaaaatgtattaagatcttttctcattaggtagaagtgaaca'.
'catgtaaacacataaataacagcaacgttggaaatatcgcataaataacggcagatgtct'.
'tttttctttttggctttgttttattttgccagagctccaacatgcaatttttaaggtcaa'.
'atgtagcttttcagcaattatagattcccatgaatacttgtttgtctttgtctattagtt'.
'gacctgacgattctttttcaaggttatactttctctaggaacttaaaattttcacagaaa'.
'tgttgacaacataaaaaaatgataccaaccggagggtcaattttttcatatgttcaggta'.
'agtcagccacagcatctattaccggtcttggtaagtttgtttctatgcataatgttgggt'.
'catgttttcaaaagtatagtgttgctttgaacaccctcccaacccccgcccatcccaact'.
'gtttttctgcagatacaggctgatttaaactgaccccagcaactgaccacaattacagaa'.
'gttactgcaattagggagaaacatccatatttcaaaataacatttttctgttttcaaaag'.
'aatatcaaattcatttaactctccgtgctcccagctcgcaaaatttatttcataaaaatc'.
'caaacttaaaggaacttatctgttgtgtgagacacaaagtggtgtgggaggctaaagata'.
'aggcagcatagggctccccactgatgactacacacagccttctagaggagaactgacctg'.
'gagacaacctagctgaaacccttcatttggaaaattctcttcaatatgggggggaaaaac'.
'agatgaaaaaggggagaaccatattattttggtcaaaatattgtggtccacaagcatatg'.
'ctccagttagtttctttcttgaataaaggctttttattgtcatgtaaacacaagctgtgt'.
'gcacatgatcaaaatattttaaaactaaaaataatttatgaaaaaatattcttccttgat'.
'ttcaacctgcctgtacttatttttaatacaaatatatctaggataaaagatactattata'.
'caaatgcatgatcaaggaagatgtcagaaaggttaacggggtcaagaaaagctgtaacac'.
'tcatagagtaatatccatacagaactattccttagtatccatgggacccagcc';

return $seq;
}

sub set_est2 {
  #embedded sequence! Because I can't create Bio::PrimarySeqs from files
my $seq =
'CAGAGGTCAGGCTTCGCTAATGGGCCAGTGAGGAGCGGTGGAGGCGAGGCCGGCGCCGCA'.
'CACACACATTAACACACTTGAGCCATCACCAATCAGCATAGGAATCTGAGAATTGCTCTC'.
'ACACACCAACCCAGCAACATCCGTGGAGAAAACTCTCACCAGCAACTCCTTTAAAACACC'.
'GTCATTTCAAACCATTGTGGTCTTCAAGCAACAACAGCAGCACAAAAAACCCCAACCAAA'.
'CAAAACTCTTGACAGAAGCTGTGACAACCAGAAAGGATGCCTCATAAAGGGGGAAGACTT'.
'TAACTAGGGGCGCGCAGATGTGTGAGGCCTTTTATTGTGAGAGTGGACAGACATCCGAGA'.
'TTTCAGAGCCCCATATTCGAGCCCCGTGGAATCCCGCGGCCCCCAGCCAGAGCCAGCATG'.
'CAGAACAGTCACAGCGGAGTGAATCAGCTCGGTGGTGTCTTTGTCAACGGGCGGCCACTG'.
'CCGGACTCCACCCGGCAGAAGATTGTAGAGCTAGCTCACAGCGGGGCCCGGCCGTGCGAC'.
'ATTTCCCGAATTCTGCAGGTGTCCAACGGATGTGTGAGTAAAATTCTGGGCAGGTATTAC'.
'GAGACTGGCTCCATCAGACCCAGGGCAATCGGTGGTAGTAAACCGAGAGTAGCGACTCCA'.
'GAAGTTGTAAGCAAAATAGCCCAGTATAAGCGGGAGTGCCCGTCCATCTTTGCTTGGGAA'.
'ATCCGAGACAGATTACTGTCCGAGGGGGTCTGTACCAACGATAACATACCAAGCGTGTCA'.
'TCAATAAACAGAGTTCTTCGCAACCTGGCTAGCGAAAAGCAACAGATGGGCGCAGACGGC'.
'ATGTATGATAAACTAAGGATGTTGAACGGGCAGACCGGAAGCTGGGGCACCCGCCCTGGT'.
'TGGTATCCGGGGACTTCGGTGCCAGGGCAACCTACGCAAGATGGCTGCCAGCAACAGGAA'.
'GGAGGGGGAGAGAATACCAACTCCATCAGTTCCAACGGAGAAGATTCAGATGAGGCTCAA'.
'ATGCGACTTCAGCTGAAGCGGAAGCTGCAAAGAAATAGAACATCCTTTACCCAAGAGCAA'.
'ATTGAGGCCCTGGAGAAAGAGTTTGAGAGAACCCATTATCCAGATGTGTTTGCCCGAGAA'.
'AGACTAGCAGCCAAAATAGATCTACCTGAAGCAAGAATACAGGTATGGTTTTCTAATCGA'.
'AGGGCCAAATGGAGAAGAGAAGAAAAACTGAGGAATCAGAGAAGACAGGCCAGCAACACA'.
'CCTAGTCATATTCCTATCAGCAGTAGTTTCAGCACCAGTGTCTACCAACCAATTCCACAA'.
'CCCACCACACCGGTTTCCTCCTTCACATCTGGCTCCATGTTGGGCCGAACAGACACAGCC'.
'CTCACAAACACCTACAGCGCTCTGCCGCCTATGCCCAGCTTCACCATGGCAAATAACCTG'.
'CCTATGCAACCCCCAGTCCCCAGCCAGACCTCCTCATACTCCTGCATGCTGCCCACCAGC'.
'CCTTCGGTGAATGGGCGGAGTTATGATACCTACACCCCCCCACATATGCAGACACACATG'.
'AACAGTCAGCCAATGGGCACCTCGGGCACCACTTCAACAGGACTCATTTCCCCTGGTGTG'.
'TCAGTTCCAGTTCAAGTTCCCGGAAGTGAACCTGATATGTCTCAATACTGGCCAAGATTA'.
'CAGTAAAAAAAAAAAAAA';

return $seq;
}
