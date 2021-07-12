#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.09.27 @ UT Austin
##
## - input:
##   1. time_bin
##      time bin size in seconds
##
## - output:
##
## - e.g.
##   perl parse_sensor.pl 600
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
my $DEBUG4 = 0; ## parse


#############
# Constants
#############


#############
# Variables
#############
my $input_dir  = "../data/sensor-IntelLab";
my $output_dir = "../processed_data/subtask_parse_sensor/tm";

my $input_file = "data-matlab.txt";

my $time_bin;

my %data_info;


#############
# check input
#############
if(@ARGV != 1) {
    print "wrong number of input: ".@ARGV."\n";
    exit;
}
$time_bin = $ARGV[0] + 0;


#############
# Main starts
#############

#############
## parse raw file
#############
my $prev_time = 0;
my $time_str = -1;
my $time_end = -1;
my $frame = 0;
open FH, "$input_dir/$input_file" or die $!;
open FH_TEMP_OUT, ">$output_dir/tm_sensor.temp.bin$time_bin.txt" or die $!;
open FH_HUM_OUT, ">$output_dir/tm_sensor.humidity.bin$time_bin.txt" or die $!;
open FH_LIGHT_OUT, ">$output_dir/tm_sensor.light.bin$time_bin.txt" or die $!;
open FH_VOL_OUT, ">$output_dir/tm_sensor.voltage.bin$time_bin.txt" or die $!;
while(<FH>) {
    chomp;

    ## time(real), moteid(int), temperature(real), humidity(real), light(real), voltage(real)
    if($_ =~ /(\d+\.*\d*)\s+(\d+\.*\d*)\s+(\d+\.*\d*)\s+(\d+\.*\d*)\s+(\d+\.*\d*)\s+(\d+\.*\d*)/) {
        print "$_\n" if($DEBUG4);

        my $time  = $1 + 0; 
        my $node  = $2 + 0;
        my $temp  = $3 + 0;
        my $hum   = $4 + 0;
        my $light = $5 + 0;
        my $vol   = $6 + 0;
        next if($node < 1 or $node > 54);
        die "prev_time=$prev_time but new_time=$time\n" if($time < $prev_time);
        $prev_time = $time;

        print "> $time [$node]: temp=$temp, humidity=$hum, light=$light, vol=$vol\n" if($DEBUG4);

        ## first record
        if($time_str < 0) {
            $time_str = $time;
            $time_end = $time_str + $time_bin;
        }


        ## end of previous snapshot
        while($time > $time_end) {
            ## get mean
            foreach my $this_node (1 .. 54) {
                if(exists $data_info{FRAME}{$frame}{NODE}{$this_node}{TEMP}{VAL} and @{ $data_info{FRAME}{$frame}{NODE}{$this_node}{TEMP}{VAL} } > 0) {
                    $data_info{FRAME}{$frame}{NODE}{$this_node}{TEMP}{AVG} = MyUtil::average(\@{ $data_info{FRAME}{$frame}{NODE}{$this_node}{TEMP}{VAL} });
                }
                else {
                    $data_info{FRAME}{$frame}{NODE}{$this_node}{TEMP}{AVG} = 0;
                }

                if(exists $data_info{FRAME}{$frame}{NODE}{$this_node}{HUM}{VAL} and @{ $data_info{FRAME}{$frame}{NODE}{$this_node}{HUM}{VAL} } > 0) {
                    $data_info{FRAME}{$frame}{NODE}{$this_node}{HUM}{AVG} = MyUtil::average(\@{ $data_info{FRAME}{$frame}{NODE}{$this_node}{HUM}{VAL} });
                }
                else {
                    $data_info{FRAME}{$frame}{NODE}{$this_node}{HUM}{AVG} = 0;
                }

                if(exists $data_info{FRAME}{$frame}{NODE}{$this_node}{LIGHT}{VAL} and @{ $data_info{FRAME}{$frame}{NODE}{$this_node}{LIGHT}{VAL} } > 0) {
                    $data_info{FRAME}{$frame}{NODE}{$this_node}{LIGHT}{AVG} = MyUtil::average(\@{ $data_info{FRAME}{$frame}{NODE}{$this_node}{LIGHT}{VAL} });
                }
                else {
                    $data_info{FRAME}{$frame}{NODE}{$this_node}{LIGHT}{AVG} = 0;
                }

                if(exists $data_info{FRAME}{$frame}{NODE}{$this_node}{VOL}{VAL} and @{ $data_info{FRAME}{$frame}{NODE}{$this_node}{VOL}{VAL} } > 0) {
                    $data_info{FRAME}{$frame}{NODE}{$this_node}{VOL}{AVG} = MyUtil::average(\@{ $data_info{FRAME}{$frame}{NODE}{$this_node}{VOL}{VAL} });
                }
                else {
                    $data_info{FRAME}{$frame}{NODE}{$this_node}{VOL}{AVG} = 0;
                }

                @{ $data_info{FRAME}{$frame}{NODE}{$this_node}{TEMP}{VAL} } = ();
                @{ $data_info{FRAME}{$frame}{NODE}{$this_node}{HUM}{VAL} } = ();
                @{ $data_info{FRAME}{$frame}{NODE}{$this_node}{LIGHT}{VAL} } = ();
                @{ $data_info{FRAME}{$frame}{NODE}{$this_node}{VOL}{VAL} } = ();

                print FH_TEMP_OUT ", " if($this_node > 1);
                print FH_HUM_OUT ", " if($this_node > 1);
                print FH_LIGHT_OUT ", " if($this_node > 1);
                print FH_VOL_OUT ", " if($this_node > 1);

                print FH_TEMP_OUT $data_info{FRAME}{$frame}{NODE}{$this_node}{TEMP}{AVG};
                print FH_HUM_OUT $data_info{FRAME}{$frame}{NODE}{$this_node}{HUM}{AVG};
                print FH_LIGHT_OUT $data_info{FRAME}{$frame}{NODE}{$this_node}{LIGHT}{AVG};
                print FH_VOL_OUT $data_info{FRAME}{$frame}{NODE}{$this_node}{VOL}{AVG};

            }

            print FH_TEMP_OUT "\n";
            print FH_HUM_OUT "\n";
            print FH_LIGHT_OUT "\n";
            print FH_VOL_OUT "\n";

            $time_str += $time_bin;
            $time_end = $time_str + $time_bin;
            $frame ++;
        }


        push(@{ $data_info{FRAME}{$frame}{NODE}{$node}{TEMP}{VAL} }, $temp);
        push(@{ $data_info{FRAME}{$frame}{NODE}{$node}{HUM}{VAL} }, $hum);
        push(@{ $data_info{FRAME}{$frame}{NODE}{$node}{LIGHT}{VAL} }, $light);
        push(@{ $data_info{FRAME}{$frame}{NODE}{$node}{VOL}{VAL} }, $vol);

    }
}
close FH;
close FH_TEMP_OUT;
close FH_HUM_OUT;
close FH_LIGHT_OUT;
close FH_VOL_OUT;
