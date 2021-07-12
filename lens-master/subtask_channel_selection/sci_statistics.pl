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
use POSIX;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use lib "../utils";
use MyUtil;


#############
# Debug
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1; ## print progress
my $DEBUG3 = 1; ## print output
my $DEBUG4 = 0; ## print SCI


#############
# Constants
#############


#############
# Variables
#############
my $input_dir  = "../processed_data/subtask_channel_selection/features";
my $output_dir = "";

my $num_channels = 9;
my @mobilities = ('static');
my @traces = (1,2, 4..9);
my @ants = (1..3);

my %sci_info = ();



#############
# check input
#############
if(@ARGV != 0) {
    print "wrong number of input: ".@ARGV."\n";
    exit;
}
# $ARGV[0];


#############
# Main starts
#############

#############
## Read feature files
#############
print "Read feature files\n" if($DEBUG2);

my $file_cnt = 0;
foreach my $mobility (@mobilities) {
    foreach my $tr (@traces) {
        foreach my $ant (@ants) {
            my $ch = 1;

            my $trace_name = "$mobility\_trace$tr.ant$ant.ch$ch.txt";
            print "  $trace_name\n" if($DEBUG0);
            
            $sci_info{IND}{$file_cnt}{NAME} = "tr$tr-$ant";
            foreach my $sci (1 .. $num_channels) {
                $sci_info{IND}{$file_cnt}{CH_CNT}{$sci} = 0;
            }

            open FH, "$input_dir/$trace_name" or die $!;
            while (<FH>) {
                chomp;
                my @tmp = split(" ", $_);
                my $this_sci = $tmp[0]+0;
                print "$this_sci, " if($DEBUG4);
                push(@{ $sci_info{IND}{$file_cnt}{SCI} }, $this_sci);

                $sci_info{IND}{$file_cnt}{CH_CNT}{$this_sci} ++;
                $sci_info{IND}{$file_cnt}{CH_ALL} ++;
            }
            close FH;
            print "\n" if($DEBUG4);


            ## statistics
            ## composition
            # print "".$sci_info{IND}{$file_cnt}{NAME};
            # foreach my $sci (1 .. $num_channels) {
            #     print ", ".($sci_info{IND}{$file_cnt}{CH_CNT}{$sci} / $sci_info{IND}{$file_cnt}{CH_ALL});
            # }
            # print "\n";

            ## entropy
            my $ent = MyUtil::cal_entropy(\%{ $sci_info{IND}{$file_cnt}{CH_CNT} });
            print "".$sci_info{IND}{$file_cnt}{NAME}.", $ent\n";

            $file_cnt ++;
        }
    }
}
