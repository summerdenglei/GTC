#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.10.10 @ UT Austin
##
## - input:
##
## - output:
##
## - e.g.
##   perl parse.detect_anomaly.output.pl detect_anomaly.output
##
##########################################

use strict;

use lib "../utils";

use MyUtil;


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
my $input_dir  = "../processed_data/subtask_detect_anomaly/output";
my $output_dir = "../processed_data/subtask_detect_anomaly/output";
my $filename;
my $gnuplot_mother = "plot.pr";

## data - TRACE -| exp0 - METHOD -| MPEG      - THRESH -| 1   - VB -| 1   -| TP
##               | exp1           | PCA                 | 2         | 2    | TN
##               | ...            | 3DDCT               | ...       | ...  | FP
##                                | comp_sen                               | FN 
##                                                                         | ...
my %data = ();

#############
# check input
#############
if(@ARGV != 1) {
    print "wrong number of input: ".@ARGV."\n";
    exit;
}
$filename = $ARGV[0];


#############
# Main starts
#############
open FH, "$input_dir/$filename.txt" or die $!;
while(<FH>) {
    my ($trace, $method, @tmp) = split(/, /, $_);
    chomp;

    print "trace = $trace, method = $method\n" if($DEBUG1);

    if($method eq "MPEG") {
        my $vb     = $tmp[0] + 0;
        my $thresh = $tmp[1] + 0;
        my $tp     = $tmp[2] + 0;
        my $tn     = $tmp[3] + 0;
        my $fp     = $tmp[4] + 0;
        my $fn     = $tmp[5] + 0;

        my $precision = MyUtil::precision($tp, $fn, $fp, $tn);
        my $recall    = MyUtil::recall($tp, $fn, $fp, $tn);
        my $f1score   = MyUtil::f1_score($precision, $recall);

        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{TP} = $tp;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{TN} = $tn;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{FP} = $fp;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{FN} = $fn;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{PRECISION} = $precision;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{RECALL} = $recall;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{F1} = $f1score;

        if(!(exists $data{TRACE}{$trace}{METHOD}{$method}{MAX_F1}) or 
           $f1score > $data{TRACE}{$trace}{METHOD}{$method}{MAX_F1}) {
            $data{TRACE}{$trace}{METHOD}{$method}{MAX_F1} = $f1score;
        }
    }
    elsif($method eq "PCA") {
        my $gop    = $tmp[0] + 0;
        my $rank   = $tmp[1] + 0;
        my $thresh = $tmp[2] + 0;
        my $tp     = $tmp[3] + 0;
        my $tn     = $tmp[4] + 0;
        my $fp     = $tmp[5] + 0;
        my $fn     = $tmp[6] + 0;

        my $precision = MyUtil::precision($tp, $fn, $fp, $tn);
        my $recall    = MyUtil::recall($tp, $fn, $fp, $tn);
        my $f1score   = MyUtil::f1_score($precision, $recall);

        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{TP} = $tp;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{TN} = $tn;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{FP} = $fp;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{FN} = $fn;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{PRECISION} = $precision;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{RECALL} = $recall;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{F1} = $f1score;

        if(!(exists $data{TRACE}{$trace}{METHOD}{$method}{MAX_F1}) or 
           $f1score > $data{TRACE}{$trace}{METHOD}{$method}{MAX_F1}) {
            $data{TRACE}{$trace}{METHOD}{$method}{MAX_F1} = $f1score;
        }
    }
    elsif($method eq "3DDCT") {
        my $gop    = $tmp[0] + 0;
        my $chunk  = $tmp[1] + 0;
        my $thresh = $tmp[2] + 0;
        my $tp     = $tmp[3] + 0;
        my $tn     = $tmp[4] + 0;
        my $fp     = $tmp[5] + 0;
        my $fn     = $tmp[6] + 0;

        my $precision = MyUtil::precision($tp, $fn, $fp, $tn);
        my $recall    = MyUtil::recall($tp, $fn, $fp, $tn);
        my $f1score   = MyUtil::f1_score($precision, $recall);

        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{TP} = $tp;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{TN} = $tn;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{FP} = $fp;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{FN} = $fn;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{PRECISION} = $precision;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{RECALL} = $recall;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{F1} = $f1score;

        if(!(exists $data{TRACE}{$trace}{METHOD}{$method}{MAX_F1}) or 
           $f1score > $data{TRACE}{$trace}{METHOD}{$method}{MAX_F1}) {
            $data{TRACE}{$trace}{METHOD}{$method}{MAX_F1} = $f1score;
        }
    }
    elsif($method eq "comp_sen") {
        my $gop    = $tmp[0] + 0;
        my $rank   = $tmp[1] + 0;
        my $thresh = $tmp[2] + 0;
        my $tp     = $tmp[3] + 0;
        my $tn     = $tmp[4] + 0;
        my $fp     = $tmp[5] + 0;
        my $fn     = $tmp[6] + 0;

        my $precision = MyUtil::precision($tp, $fn, $fp, $tn);
        my $recall    = MyUtil::recall($tp, $fn, $fp, $tn);
        my $f1score   = MyUtil::f1_score($precision, $recall);

        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{TP} = $tp;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{TN} = $tn;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{FP} = $fp;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{FN} = $fn;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{PRECISION} = $precision;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{RECALL} = $recall;
        $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{F1} = $f1score;

        if(!(exists $data{TRACE}{$trace}{METHOD}{$method}{MAX_F1}) or 
           $f1score > $data{TRACE}{$trace}{METHOD}{$method}{MAX_F1}) {
            $data{TRACE}{$trace}{METHOD}{$method}{MAX_F1} = $f1score;
        }
    }
}
close FH;


foreach my $trace (keys %{ $data{TRACE} }) {
    foreach my $method (keys %{ $data{TRACE}{$trace}{METHOD} }) {
        ## max F1 score
        print "$trace, $method, ".$data{TRACE}{$trace}{METHOD}{$method}{MAX_F1}."\n";


        open FH_OUT, "> $output_dir/$filename.$trace.$method.txt" or die $!;

        ## gnuplot
        my $cmd = "sed 's/FILENAME/$filename.$trace.$method/g;s/FIGNAME/$filename.$trace.$method/g;s/X_RANGE_S/0/g;s/X_RANGE_E/1/g;s/Y_RANGE_S/0/g;s/Y_RANGE_E/1/g;s/X_LABEL/Precision/g;s/Y_LABEL/Recall/g;s/DEGREE/0/g;' $gnuplot_mother.mother.plot > tmp.$gnuplot_mother.$trace.$method.plot";
        `$cmd`;
        open FH_GNU, ">> tmp.$gnuplot_mother.$trace.$method.plot" or die $!;

        ## gnuplot
        my $cmd = "sed 's/FILENAME/$filename.$trace.$method/g;s/FIGNAME/$filename.$trace.$method.f1/g;s/X_RANGE_S//g;s/X_RANGE_E//g;s/Y_RANGE_S//g;s/Y_RANGE_E//g;s/X_LABEL/threshold/g;s/Y_LABEL/F1-Score/g;s/DEGREE/-45/g;' $gnuplot_mother.mother.plot > tmp.$gnuplot_mother.$trace.$method.f1.plot";
        `$cmd`;
        open FH_GNU_F1, ">> tmp.$gnuplot_mother.$trace.$method.f1.plot" or die $!;



        my $first_thresh = 1;
        foreach my $thresh (sort {$a <=> $b} (keys %{ $data{TRACE}{$trace}{METHOD}{$method}{THRESH} })) {
            print FH_OUT "$thresh, ";
            print "$thresh, " if($DEBUG0);

            if($method eq "MPEG") {
                print "$method\n" if($DEBUG0);
                my $cnt = 0;
                foreach my $vb (sort {$a <=> $b} (keys %{ $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB} })) {
                    print FH_OUT "$vb, ".
                          $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{TP}.", ".
                          $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{TN}.", ".
                          $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{FP}.", ".
                          $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{FN}.", ".
                          $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{PRECISION}.", ".
                          $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{RECALL}.", ".
                          $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{F1}.", ";
                    print "$vb, ".
                          $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{TP}.", ".
                          $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{TN}.", ".
                          $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{FP}.", ".
                          $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{FN}.", ".
                          $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{PRECISION}.", ".
                          $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{RECALL}.", ".
                          $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{VB}{$vb}{F1}.", " 
                          if($DEBUG0);

                    ## gnuplot
                    if($first_thresh == 1 and $cnt < $NUM_CURVE){
                        my $ind_p = 1 + $cnt * 8 + 6;
                        my $ind_r = 1 + $cnt * 8 + 7;
                        my $ls_cnt = $cnt % 8 + 1;
                        print FH_GNU "," if($cnt != 0);
                        print FH_GNU " \\\n";
                        print FH_GNU "data_dir.file_name.\".txt\" using $ind_p:$ind_r with linespoints ls $ls_cnt title '{/Helvetica=28 vbr=$vb}'";

                        my $ind_f = 1 + $cnt * 8 + 8;
                        print FH_GNU_F1 "," if($cnt != 0);
                        print FH_GNU_F1 " \\\n";
                        print FH_GNU_F1 "data_dir.file_name.\".txt\" using 1:$ind_f with linespoints ls $ls_cnt title '{/Helvetica=28 vbr=$vb}'";
                        
                        $cnt ++;
                        
                    }
                }
            }
            elsif($method eq "PCA") {
                print "$method\n" if($DEBUG0);
                my $cnt = 0;
                foreach my $gop (sort {$a <=> $b} (keys %{ $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP} })) {
                    foreach my $rank (sort {$a <=> $b} (keys %{ $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK} })) {
                        print FH_OUT "$rank, ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{TP}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{TN}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{FP}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{FN}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{PRECISION}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{RECALL}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{F1}.", ";
                        print "$rank, ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{TP}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{TN}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{FP}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{FN}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{PRECISION}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{RECALL}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{F1}.", " 
                              if($DEBUG0);

                        ## gnuplot
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
                }
            }
            elsif($method eq "3DDCT") {
                print "$method\n" if($DEBUG0);
                my $cnt = 0;
                foreach my $gop (sort {$a <=> $b} (keys %{ $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP} })) {
                    foreach my $chunk (sort {$a <=> $b} (keys %{ $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK} })) {
                        print FH_OUT "$chunk, ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{TP}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{TN}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{FP}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{FN}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{PRECISION}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{RECALL}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{F1}.", ";
                        print "$chunk, ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{TP}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{TN}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{FP}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{FN}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{PRECISION}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{RECALL}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{CHUNK}{$chunk}{F1}.", " 
                              if($DEBUG0);

                        ## gnuplot
                        if($first_thresh == 1 and $cnt < $NUM_CURVE){
                            my $ind_p = 1 + $cnt * 8 + 6;
                            my $ind_r = 1 + $cnt * 8 + 7;
                            my $ls_cnt = $cnt % 8 + 1;
                            print FH_GNU "," if($cnt != 0);
                            print FH_GNU " \\\n";
                            print FH_GNU "data_dir.file_name.\".txt\" using $ind_p:$ind_r with linespoints ls $ls_cnt title '{/Helvetica=28 #chunks=$chunk}'";

                            my $ind_f = 1 + $cnt * 8 + 8;
                            print FH_GNU_F1 "," if($cnt != 0);
                            print FH_GNU_F1 " \\\n";
                            print FH_GNU_F1 "data_dir.file_name.\".txt\" using 1:$ind_f with linespoints ls $ls_cnt title '{/Helvetica=28 #chunk=$chunk}'";
                            
                            $cnt ++;
                        }
                    }
                }
            }
            elsif($method eq "comp_sen") {
                print "$method\n" if($DEBUG0);
                my $cnt = 0;
                foreach my $gop (sort {$a <=> $b} (keys %{ $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP} })) {
                    foreach my $rank (sort {$a <=> $b} (keys %{ $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK} })) {
                        print FH_OUT "$rank, ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{TP}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{TN}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{FP}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{FN}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{PRECISION}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{RECALL}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{F1}.", ";
                        print "$rank, ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{TP}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{TN}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{FP}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{FN}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{PRECISION}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{RECALL}.", ".
                              $data{TRACE}{$trace}{METHOD}{$method}{THRESH}{$thresh}{GoP}{$gop}{RANK}{$rank}{F1}.", " 
                              if($DEBUG0);

                        ## gnuplot
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
                }
            }
            print FH_OUT "\n";
            print "\n" if($DEBUG0);

            $first_thresh = 0;
        }
        close FH_GNU;
        close FH_OUT;

        ## gnuplot
        $cmd = "gnuplot tmp.$gnuplot_mother.$trace.$method.plot";
        `$cmd`;

        $cmd = "gnuplot tmp.$gnuplot_mother.$trace.$method.f1.plot";
        `$cmd`;
        
    }
}
