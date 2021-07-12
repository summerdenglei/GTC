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
##   2. resolution
##      specify the resolution of lat and lng to generate TM
##   3. time_bin
##      time bin size in minutes for a snapshot (frame)
##   4. sub_min_x
##   5. sub_min_y
##   6. sub_max_x
##   7. sub_max_y
##      only took a sub-region to generate TM.
##      -1 indicate all the complete region
##
## - output:
##
## - e.g.
##   perl gen_3g_geo_tm.pl all 0.004 60 -1 -1 -1 -1
##   perl gen_3g_geo_tm.pl all 0.004 60 230 380 290 440
##   perl gen_3g_geo_tm.pl all 0.002 60 -1 -1 -1 -1
##   perl gen_3g_geo_tm.pl all 0.002 60 460 770 580 870
##
##########################################

use strict;
use POSIX;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use lib "../utils";
use MyUtil;
use HuaweiTool;


#############
# Debug
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1; ## print progress
my $DEBUG3 = 1; ## print output
my $DEBUG4 = 0; ## bs info
my $DEBUG5 = 0; ## all traffic info
my $DEBUG6 = 0; ## uplink traffic info
my $DEBUG7 = 0; ## map cell to lat,lng
my $DEBUG8 = 0; ## generate TM


#############
# Constants
#############
my $INPUT_TIME_BIN = 1;


#############
# Variables
#############
my $input_dir  = "../data/huawei_cellular";
my $output_dir = "../processed_data/subtask_parse_huawei_3g/region_tm";

my $all_traffic_file = "TM_all_traffic.txt.bz2";
my $ul_traffic_file  = "TM_UL_traffic_RNC2304.txt";
my $bs_loc_file      = "bs_location.txt";

my $traffic_type;
my $resolution;
my $time_bin;
my ($sub_min_x, $sub_min_y, $sub_max_x, $sub_max_y);

my %bs_info;
my %traffic_info;

my %tm = ();
my $num_values;

#############
# check input
#############
if(@ARGV < 3) {
    print "wrong number of input: ".@ARGV."\n";
    exit;
}
$traffic_type = $ARGV[0];
$resolution   = $ARGV[1] + 0;
$time_bin     = $ARGV[2] + 0;
$sub_min_x    = $ARGV[3] + 0;
$sub_min_y    = $ARGV[4] + 0;
$sub_max_x    = $ARGV[5] + 0;
$sub_max_y    = $ARGV[6] + 0;


#############
# Main starts
#############

#############
## read BS locations
#############
print "read BS locations\n" if($DEBUG2);
%bs_info = HuaweiTool::read_bs_location("$input_dir/$bs_loc_file");
if($DEBUG4) {
    foreach my $this_bs (sort {$a <=> $b} keys(%bs_info)) {
        print "$this_bs: (".$bs_info{$this_bs}{LAT}.", ".$bs_info{$this_bs}{LNG}.")\n";
    }
}


#############
## read traffic
#############
print "read traffic\n" if($DEBUG2);
if($traffic_type eq "all") {
    #############
    ## read all traffic
    #############
    print "  all traffic\n" if($DEBUG2);
    ($num_values, %traffic_info) = HuaweiTool::read_traffic("$input_dir/$all_traffic_file");
    if($DEBUG5) {
        foreach my $this_cell (sort {$a <=> $b} keys(%traffic_info)) {
            print "$this_cell: (".join(",", @{ $traffic_info{$this_cell}{TRAFFIC} } ).")\n";
        }
    }
}
elsif($traffic_type eq "ul") {
    #############
    ## read uplink traffic
    #############
    print "  uplink traffic\n" if($DEBUG2);
    ($num_values, %traffic_info) = HuaweiTool::read_traffic("$input_dir/$ul_traffic_file");
    if($DEBUG6) {
        foreach my $this_cell (sort {$a <=> $b} keys(%traffic_info)) {
            print "$this_cell: (".join(",", @{ $traffic_info{$this_cell}{TRAFFIC} } ).")\n";
        }
    }
}
else {
    die "wrong traffic type: $traffic_type\n";
}


#############
## map traffic to lat,lng
#############
print "map traffic to lat,lng\n" if($DEBUG2);

my $stat_cell_no_match_bs = 0;
my $min_lat = -1;
my $max_lat = -1;
my $min_lng = -1;
my $max_lng = -1;
foreach my $this_cell (sort {$a <=> $b} keys(%traffic_info)) {
    my $this_bs = HuaweiTool::cell2bs($this_cell);

    unless(exists $bs_info{$this_bs}) {
        $stat_cell_no_match_bs ++;
        print "  miss cell: $this_cell\n" if($DEBUG7);
        next;
    }

    print "  cell=$this_cell, bs=$this_bs: (".$bs_info{$this_bs}{LAT}.",".$bs_info{$this_bs}{LNG}.")\n" if($DEBUG7);


    $traffic_info{$this_cell}{LAT} = $bs_info{$this_bs}{LAT};
    $traffic_info{$this_cell}{LNG} = $bs_info{$this_bs}{LNG};


    ## find the corner of region
    if($min_lat == -1 or $min_lat > $bs_info{$this_bs}{LAT}) {
        $min_lat = $bs_info{$this_bs}{LAT};
    }
    if($max_lat == -1 or $max_lat < $bs_info{$this_bs}{LAT}) {
        $max_lat = $bs_info{$this_bs}{LAT};
    }
    if($min_lng == -1 or $min_lng > $bs_info{$this_bs}{LNG}) {
        $min_lng = $bs_info{$this_bs}{LNG};
    }
    if($max_lng == -1 or $max_lng < $bs_info{$this_bs}{LNG}) {
        $max_lng = $bs_info{$this_bs}{LNG};
    }
}

print "  miss cells: $stat_cell_no_match_bs\n";
print "  num values: $num_values\n";
print "  region ($min_lat, $min_lng) - ($max_lat, $max_lng)\n";


#############
## generate TM
#############
print "generate TM\n" if($DEBUG2);

my %cell_mat;
my $frame_size = $time_bin / $INPUT_TIME_BIN;
my $num_frames = ceil($num_values / $frame_size);
my ($min_x, $max_x, $min_y, $max_y) = (-1, -1, -1, -1);

foreach my $this_cell (sort {$a <=> $b} keys(%traffic_info)) {
    my $this_bs = HuaweiTool::cell2bs($this_cell);
    next unless(exists $bs_info{$this_bs});


    my @values = @{ $traffic_info{$this_cell}{TRAFFIC} };
    my $lat    = $traffic_info{$this_cell}{LAT};
    my $lng    = $traffic_info{$this_cell}{LNG};

    #############
    ## convert lat,lng to grid
    #############
    my $x = floor(($lat - $min_lat) / $resolution);
    my $y = floor(($lng - $min_lng) / $resolution);

    if($min_x == -1 or $min_x > $x) {$min_x = $x;}
    if($max_x == -1 or $max_x < $x) {$max_x = $x;}
    if($min_y == -1 or $min_y > $y) {$min_y = $y;}
    if($max_y == -1 or $max_y < $y) {$max_y = $y;}


    #############
    ## calculate traffic of specified time bin
    #############
    print "  ".join(",", @values)."\n" if($DEBUG8);
    for my $f (0 .. $num_frames-1) {
        my $f_s = ($f-1) * $frame_size;
        my $f_e = min($f * $frame_size - 1, $num_values);
        my $traffic = sum(@values[$f_s..$f_e]);
        print "  $f ($f_s - $f_e) = $traffic\n" if($DEBUG8);

        $tm{$f}{$y}{$x} += $traffic;
        $cell_mat{$f}{$y}{$x} ++;
    }
}

print "  num frames: $num_frames\n";
print "  region ($min_x, $min_y) - ($max_x, $max_y)\n";


#############
## outpput TM
#############
print "output TM\n" if($DEBUG2);

my $output_file = "res$resolution.bin$time_bin";
$output_file .= ".sub" if($sub_min_x != -1);
if($sub_min_x != -1) {
    $min_x = $sub_min_x;
    $min_y = $sub_min_y;
    $max_x = $sub_max_x;
    $max_y = $sub_max_y;
}
print "  output region ($min_x, $min_y) - ($max_x, $max_y)\n";

for my $f (sort {$a <=> $b} (keys %tm)) {
    open FH, "> $output_dir/tm_3g_region_$traffic_type.$output_file.$f.txt";
    open FH_CELL, "> $output_dir/cells_3g_region_$traffic_type.$output_file.txt" if($f == 1);

    for my $y ($min_y .. $max_y) {
        for my $x ($min_x .. $max_x) {
            my $this_value;
            my $this_cells;
            if(exists $tm{$f}{$y}{$x}) {
                $this_value = $tm{$f}{$y}{$x};
                $this_cells = $cell_mat{$f}{$y}{$x};
            }
            else {
                $this_value = 0;
                $this_cells = 0;
            }

            print FH ", " if($x > 0);
            print FH $this_value;

            if($f == 1) {
                print FH_CELL ", " if($x > 0);
                print FH_CELL $this_cells;
            }
        }
        print FH "\n";
        print FH_CELL "\n" if($f == 1);
    }
    close FH;
    close FH_CELL if($f == 1);
}


1;

