#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.11.26 @ UT Austin
##
## - input:
##   1. traffic_type
##      a) dl = downlink
##      b) up = uplink
##      c) all = both donwlink and uplink
##   2. time_bin
##      time bin size in minutes for a snapshot (frame)
##   
##
## - output:
##
## - e.g.
##   perl group_ip_by_cell.pl 60
##
##########################################

use strict;
use POSIX;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use lib "../utils";
use HuaweiTool;


#############
# Debug
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1; ## print progress
my $DEBUG3 = 1; ## print output
my $DEBUG4 = 0; ## read traffic file
my $DEBUG5 = 0; ## parse traffic


#############
# Constants
#############
my $INPUT_TIME_UNIT = 10;  ## in minutes


#############
# Variables
#############
my $input_dir  = "../data/huawei_cellular";
my $output_dir = "../processed_data/subtask_parse_huawei_3g/ip_traffic";

my $traffic_file = "IPLevel_per_10min_RNC2304.txt.bz2";
my $bs_loc_file  = "bs_location.txt";

my $time_bin;

my %bs_info;
my %cell_traffic;   ## CELL_ID - [UL | DL | ALL]
my $time_bin_size;
my $num_time_bin;


#############
# check input
#############
if(@ARGV != 1) {
    print "wrong number of input: ".@ARGV."\n";
    exit;
}
$time_bin = $ARGV[0] + 0;

$time_bin_size = $time_bin / $INPUT_TIME_UNIT;


#############
# Main starts
#############

#############
## read BS locations
#############
print "read BS locations\n" if($DEBUG2);

%bs_info = HuaweiTool::read_bs_location("$input_dir/$bs_loc_file");


#############
## read traffic file for the first time to get all cells
#############
print "read traffic file for the first time to get all cells\n" if($DEBUG2);

my %stat_cell_miss = ();
my %raw_traffic = ();     ## time - raw_line
open FH, "bzcat $input_dir/$traffic_file |" or die $!;
while(<FH>) {
    chomp;
    print "  $_\n" if($DEBUG4);

    my $line = $_;
    
    my ($cell_id, $calc_point, @tmp) = split(/\s+/, $line);
    $cell_id += 0; $calc_point += 0;
    
    
    ## skip if we don't have location of this base station
    my $bs_id = HuaweiTool::cell2bs($cell_id);
    unless(exists $bs_info{$bs_id}) {
        $stat_cell_miss{$cell_id} = 1;
        next;
    }

    %{ $cell_traffic{$cell_id} } = ();
    push(@{ $raw_traffic{$calc_point} }, $line);
}
close FH;
print "  there are ".scalar(keys %cell_traffic)." cells with location information\n";
print "  miss ".scalar(keys %stat_cell_miss)." cells: ".join(",", (keys %stat_cell_miss))."\n";


#############
## read traffic file again to get traffic
#############
print "## read traffic file again to get traffic\n" if($DEBUG2);

my $time_start = -1;
my $time_end   = -1;

# open FH, "bzcat $input_dir/$traffic_file |" or die $!;
# while(<FH>) {
foreach my $t (sort {$a <=> $b} (keys %raw_traffic)) {
    foreach my $line (@{ $raw_traffic{$t} }) {
        print "  $line\n" if($DEBUG5);

        my ($cell_id, $calc_point, $outerIP_src, $outerIP_dst, $innerIP_src, $innerIP_dst, $load) = split(/\s+/, $line);
        $cell_id += 0; $calc_point += 0; $load += 0;
        my $current_time = $calc_point * $INPUT_TIME_UNIT;


        ###########
        ## skip if we don't have location of this base station
        ###########
        my $bs_id = HuaweiTool::cell2bs($cell_id);
        next unless(exists $bs_info{$bs_id});


        ###########
        ## traffic type: DL, UL
        ###########
        my $traffic_type;
        if($outerIP_dst eq "220.206.144.33" or $outerIP_dst eq "220.206.144.34" ) {
            ## uplink
            print "  - uplink\n" if($DEBUG4);
            $traffic_type = "UL";
        }
        elsif($outerIP_src eq "220.206.144.33" or $outerIP_src eq "220.206.144.34" ) {
            ## downlink
            print "  - downlink\n" if($DEBUG4);
            $traffic_type = "DL";
        }
        else {
            next if($outerIP_dst eq "NULL");
            next if($outerIP_src eq "NULL");
            next if($innerIP_dst eq "NULL");
            next if($innerIP_src eq "NULL");

            die "unknown downlink or uplink\n".join(", ", ($cell_id, $calc_point, $outerIP_src, $outerIP_dst, $innerIP_src, $innerIP_dst, $load) );
        }


        ###########
        ## update the traffic
        ###########
        while($time_start == -1 or $current_time > $time_end) {
            ## initialize the new time bin
            foreach my $this_cell (keys %cell_traffic) {
                push(@{ $cell_traffic{$this_cell}{DL} }, 0);
                push(@{ $cell_traffic{$this_cell}{UL} }, 0);
                push(@{ $cell_traffic{$this_cell}{ALL} }, 0);
            }

            ## update start-end time of the new time bin
            if($time_start == -1) {
                ## the first record
                $time_start = $current_time;
            }
            else {
                $time_start = $time_end;
            }
            $time_end = $time_start + $time_bin;

            print "  $time_start:$time_end\n" if($DEBUG2);
        }

        ## update the time bin traffic load
        die "$cell_id not exists\n" unless(exists $cell_traffic{$cell_id});
        die "$cell_id, $traffic_type not exists\n" unless(exists $cell_traffic{$cell_id}{$traffic_type});
        
        $cell_traffic{$cell_id}{$traffic_type}[-1] += $load;
        $cell_traffic{$cell_id}{ALL}[-1] += $load;
    }
}


#############
## output the traffic
#############
print "output the traffic\n" if($DEBUG2);

open FH_DL, "> $output_dir/3g_cell_traffic_ts.dl.bin$time_bin.txt" or die $!;
open FH_UL, "> $output_dir/3g_cell_traffic_ts.ul.bin$time_bin.txt" or die $!;
open FH_ALL, "> $output_dir/3g_cell_traffic_ts.all.bin$time_bin.txt" or die $!;
foreach my $this_cell (sort {$a <=> $b} (keys %cell_traffic)) {
    my $this_bs = HuaweiTool::cell2bs($this_cell);
    my $lat     = $bs_info{$this_bs}{LAT};
    my $lng     = $bs_info{$this_bs}{LNG};

    print FH_DL "$this_cell, $lat, $lng, ".join(", ", @{ $cell_traffic{$this_cell}{DL} })."\n";
    print FH_UL "$this_cell, $lat, $lng, ".join(", ", @{ $cell_traffic{$this_cell}{UL} })."\n";
    print FH_ALL "$this_cell, $lat, $lng, ".join(", ", @{ $cell_traffic{$this_cell}{ALL} })."\n";
}
close FH_DL;
close FH_UL;
close FH_ALL;



