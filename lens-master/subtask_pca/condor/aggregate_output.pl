#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.09.27 @ UT Austin
##
## - input:
##
## - output:
##
## - e.g.
##
##########################################

use strict;

#############
# Debug
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1; ## print progress
my $DEBUG3 = 1; ## print output


#############
# Constants
#############
my $NUM_CURVE = 8;


#############
# Variables
#############
my $input_dir  = "/u/yichao/anomaly_compression/condor_data/subtask_pca/condor/output";
my $output_dir = "/u/yichao/anomaly_compression/condor_data/subtask_pca/output";
my $gnuplot_mother = "plot.pr";

## data - TRACE - OPT_DECT - OPT_DELTA - BLOCK_SIZE - THRESH - [TP, TN, FP, TN, ...]
my %data = ();
## best - TRACE - [OPT_DECT | OPT_DELTA | BLOCK_SIZE] - [F1SCORE | SETTING | FP | ...]
my %best = ();


#############
# check input
#############
if(@ARGV != 0) {
    print "wrong number of input: ".@ARGV."\n";
    exit;
}


#############
# Main starts
#############
my $func = "pca_based";
open FH_OUT, "> $output_dir/$func.txt" or die $!;

for my $file_name ("TM_Airport_period5_") {
    
    my $num_frames = 12;
    my $width = 300;
    my $height = 300;
    if($file_name eq "TM_Manhattan_period5_") {
        my $width = 500;
        my $height = 500;
    }

    for my $expnum (0, 1, 2) {

        for my $opt_swap_mat (0, 1, 2, 3) {
            if(!(exists $best{TRACE}{"$file_name.exp$expnum."}{OPT_SWAP_MAT}{$opt_swap_mat}{F1SCORE})) {
                $best{TRACE}{"$file_name.exp$expnum."}{OPT_SWAP_MAT}{$opt_swap_mat}{F1SCORE} = 0;
            }

            for my $opt_dect (1, 2) {
                if(!(exists $best{TRACE}{"$file_name.exp$expnum."}{OPT_DECT}{$opt_dect}{F1SCORE})) {
                    $best{TRACE}{"$file_name.exp$expnum."}{OPT_DECT}{$opt_dect}{F1SCORE} = 0;
                }
                
                for my $block_size (30, 100, 300) {
                    if(!(exists $best{TRACE}{"$file_name.exp$expnum."}{BLOCK_SIZE}{$block_size}{F1SCORE})) {
                        $best{TRACE}{"$file_name.exp$expnum."}{BLOCK_SIZE}{$block_size}{F1SCORE} = 0;
                    }
                    

                    ## gnuplot - data
                    open FH_OUT_2, "> $output_dir/$func.$file_name.exp$expnum..$block_size.$opt_dect.$opt_swap_mat.txt" or die $!;

                    ## gnuplot - RP
                    my $cmd = "sed 's/FILENAME/$func.$file_name.exp$expnum..$block_size.$opt_dect.$opt_swap_mat/g;s/FIGNAME/$func.$file_name.exp$expnum..$block_size.$opt_dect.$opt_swap_mat/g;s/X_RANGE_S/0/g;s/X_RANGE_E/1/g;s/Y_RANGE_S/0/g;s/Y_RANGE_E/1/g;s/X_LABEL/Precision/g;s/Y_LABEL/Recall/g;s/DEGREE/0/g;' $gnuplot_mother.mother.plot > tmp.$gnuplot_mother.$func.$file_name.exp$expnum..$block_size.$opt_dect.$opt_swap_mat.plot";
                    `$cmd`;
                    open FH_GNU, ">> tmp.$gnuplot_mother.$func.$file_name.exp$expnum..$block_size.$opt_dect.$opt_swap_mat.plot" or die $!;

                    ## gnuplot - F1
                    my $cmd = "sed 's/FILENAME/$func.$file_name.exp$expnum..$block_size.$opt_dect.$opt_swap_mat/g;s/FIGNAME/$func.$file_name.exp$expnum..$block_size.$opt_dect.$opt_swap_mat.f1/g;s/X_RANGE_S//g;s/X_RANGE_E//g;s/Y_RANGE_S//g;s/Y_RANGE_E//g;s/X_LABEL/threshold/g;s/Y_LABEL/F1-Score/g;s/DEGREE/-45/g;' $gnuplot_mother.mother.plot > tmp.$gnuplot_mother.$func.$file_name.exp$expnum..$block_size.$opt_dect.$opt_swap_mat.f1.plot";
                    `$cmd`;
                    open FH_GNU_F1, ">> tmp.$gnuplot_mother.$func.$file_name.exp$expnum..$block_size.$opt_dect.$opt_swap_mat.f1.plot" or die $!;


                    my $first_thresh = 1;
                    for my $thresh (5, 10, 15, 20, 30, 50, 70, 100, 150, 200, 250) {
                        print FH_OUT_2 "$thresh, ";

                        my $cnt = 0;
                        for my $rank (1, 2, 3, 5, 10, 20, 30) {
                            if(!(exists $best{TRACE}{"$file_name.exp$expnum."}{RANK}{$rank}{F1SCORE})) {
                                $best{TRACE}{"$file_name.exp$expnum."}{RANK}{$rank}{F1SCORE} = 0;
                            }


                            my $this_file_name = "$input_dir/$func.$file_name.exp$expnum..$num_frames.$width.$height.$block_size.$block_size.$rank.$thresh.$opt_dect.$opt_swap_mat.txt";

                            print "$this_file_name\n";
                            
                            open FH, $this_file_name or die $!;
                            while(<FH>) {
                                my @ret = split(/, /, $_);
                                my $tp = $ret[0] + 0;
                                my $tn = $ret[1] + 0;
                                my $fp = $ret[2] + 0;
                                my $fn = $ret[3] + 0;

                                my $precision = $ret[4] + 0;
                                my $recall = $ret[5] + 0;
                                my $f1score = $ret[6] + 0;

                                if($precision =~ /nan/) {
                                    $precision = 0;
                                }
                                if($f1score =~ /nan/) {
                                    $f1score = 0;
                                }

                                $data{TRACE}{"$file_name.exp$expnum."}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{"$block_size,$block_size"}{RANK}{$rank}{THRESH}{$thresh}{TP} = $tp;
                                $data{TRACE}{"$file_name.exp$expnum."}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{"$block_size,$block_size"}{RANK}{$rank}{THRESH}{$thresh}{TN} = $tn;
                                $data{TRACE}{"$file_name.exp$expnum."}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{"$block_size,$block_size"}{RANK}{$rank}{THRESH}{$thresh}{FP} = $fp;
                                $data{TRACE}{"$file_name.exp$expnum."}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{"$block_size,$block_size"}{RANK}{$rank}{THRESH}{$thresh}{FN} = $fn;

                                $data{TRACE}{"$file_name.exp$expnum."}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{"$block_size,$block_size"}{RANK}{$rank}{THRESH}{$thresh}{PRECISION} = $precision;
                                $data{TRACE}{"$file_name.exp$expnum."}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{"$block_size,$block_size"}{RANK}{$rank}{THRESH}{$thresh}{RECALL} = $recall;
                                $data{TRACE}{"$file_name.exp$expnum."}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{"$block_size,$block_size"}{RANK}{$rank}{THRESH}{$thresh}{F1SCORE} = $f1score;

                                my $buf = "$file_name, $expnum, $num_frames, $width, $height, $opt_swap_mat, $opt_dect, $rank, $block_size, $block_size, $thresh, $tp, $tn, $fp, $fn, $precision, $recall, $f1score\n";
                                print $buf;
                                print FH_OUT $buf;


                                ####################
                                if($f1score > $best{TRACE}{"$file_name.exp$expnum."}{OPT_DECT}{$opt_dect}{F1SCORE}) {
                                    $best{TRACE}{"$file_name.exp$expnum."}{OPT_DECT}{$opt_dect}{F1SCORE} = $f1score;
                                }
                                if($f1score > $best{TRACE}{"$file_name.exp$expnum."}{BLOCK_SIZE}{$block_size}{F1SCORE}) {
                                    $best{TRACE}{"$file_name.exp$expnum."}{BLOCK_SIZE}{$block_size}{F1SCORE} = $f1score;
                                }
                                if($f1score > $best{TRACE}{"$file_name.exp$expnum."}{OPT_SWAP_MAT}{$opt_swap_mat}{F1SCORE}) {
                                    $best{TRACE}{"$file_name.exp$expnum."}{OPT_SWAP_MAT}{$opt_swap_mat}{F1SCORE} = $f1score;
                                }
                                if($f1score > $best{TRACE}{"$file_name.exp$expnum."}{RANK}{$rank}{F1SCORE}) {
                                    $best{TRACE}{"$file_name.exp$expnum."}{RANK}{$rank}{F1SCORE} = $f1score;
                                }
                                

                                ####################
                                ## gnuplot - data
                                print FH_OUT_2 "$rank, $tp, $tn, $fp, $fn, $precision, $recall, $f1score, ";
                                
                                ## gnuplot - PR
                                if($first_thresh == 1 and $cnt < $NUM_CURVE){
                                    my $ind_p = 1 + $cnt * 8 + 6;
                                    my $ind_r = 1 + $cnt * 8 + 7;
                                    my $ls_cnt = $cnt % 8 + 1;
                                    print FH_GNU "," if($cnt != 0);
                                    print FH_GNU " \\\n";
                                    print FH_GNU "data_dir.file_name.\".txt\" using $ind_p:$ind_r with linespoints ls $ls_cnt title '{/Helvetica=28 rank=$rank}'";

                                    my $ind_f = 1 + $cnt * 8 + 8;
                                    print FH_GNU_F1 "," if($cnt != 0);
                                    print FH_GNU_F1 " \\\n";
                                    print FH_GNU_F1 "data_dir.file_name.\".txt\" using 1:$ind_f with linespoints ls $ls_cnt title '{/Helvetica=28 rank=$rank}'";
                                    
                                    $cnt ++;
                                    
                                }
                            }
                            close FH;
                        }
                        $first_thresh = 0;
                        print FH_OUT_2 "\n";
                    }
                    close FH_OUT_2;
                    close FH_GNU;
                    close FH_GNU_F1;

                    ## gnuplot
                    $cmd = "gnuplot tmp.$gnuplot_mother.$func.$file_name.exp$expnum..$block_size.$opt_dect.$opt_swap_mat.plot";
                    `$cmd`;

                    $cmd = "gnuplot tmp.$gnuplot_mother.$func.$file_name.exp$expnum..$block_size.$opt_dect.$opt_swap_mat.f1.plot";
                    `$cmd`;
                }  ## end of rank
            }
        }
    }
}
close FH_OUT;



#############
# Statistics
#############
## best - TRACE - [OPT_DECT | OPT_DELTA | BLOCK_SIZE] - [F1SCORE | SETTING | FP | ...]
foreach my $trace (sort {$a cmp $b} (keys %{ $best{TRACE} })) {
    foreach my $opt_dect (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{OPT_DECT} })) {
        print "$trace, opt_dect=$opt_dect, ".$best{TRACE}{$trace}{OPT_DECT}{$opt_dect}{F1SCORE}."\n";
    }

    foreach my $rank (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{RANK} })) {
        print "$trace, rank=$rank, ".$best{TRACE}{$trace}{RANK}{$rank}{F1SCORE}."\n";
    }

    foreach my $block_size (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{BLOCK_SIZE} })) {
        print "$trace, block_size=$block_size, ".$best{TRACE}{$trace}{BLOCK_SIZE}{$block_size}{F1SCORE}."\n";
    }

    foreach my $opt_swap_mat (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{OPT_SWAP_MAT} })) {
        print "$trace, opt_swap_mat=$opt_swap_mat, ".$best{TRACE}{$trace}{OPT_SWAP_MAT}{$opt_swap_mat}{F1SCORE}."\n";
    }
}
