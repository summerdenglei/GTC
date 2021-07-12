#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.09.27 @ UT Austin
##
## - input:
##   1. traffic_type
##      a) dl = downlink
##      b) up = uplink
##      c) all = both donwlink and uplink
##   2. time_bin
##      time bin size in minutes for a snapshot (frame)
##   3. group_type
##      group traffic by network hierarchy
##      a) cell
##      b) bs
##      c) rnc
##      d) all
##      e) load: the top loaded BS
##      f) stable: the most stable BS
##   4. num_bs (optional)
##      number of BS to select when group_type is "load" or "stable"
##
## - output:
##
## - e.g.
##   perl gen_3g_cell_type_tm.pl all 10 bs
##   perl gen_3g_cell_type_tm.pl all 10 all
##   perl gen_3g_cell_type_tm.pl all 10 load 200
##   perl gen_3g_cell_type_tm.pl all 10 stable 200
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

my $DEBUG5 = 0; ## read traffic


#############
# Constants
#############
my $INPUT_TIME_BIN = 1;


#############
# Variables
#############
my $input_dir  = "../data/huawei_cellular";
my $output_dir = "../processed_data/subtask_parse_huawei_3g/bs_tm";

my $all_traffic_file = "TM_all_traffic.txt.bz2";
my $bs_file          = "RNC_BS_Cell_Lon_Lat_Type.txt";

my $traffic_type;
my $time_bin;
my $group_type;
my $num_bs = 0;

my %traffic_info;
my %sub_traffic_info;
my %bs_info;
my %has_rnc;
my %has_cell;
my %has_bs;
my %has_bs_type;

my $num_values;
my $time_bin_size;

#############
# check input
#############
if(@ARGV < 3 or @ARGV > 4) {
    print "wrong number of input: ".@ARGV."\n";
    exit;
}
$traffic_type = $ARGV[0];
$time_bin     = $ARGV[1] + 0;
$group_type   = $ARGV[2];
$num_bs       = $ARGV[3] + 0 if(@ARGV == 4);

$time_bin_size = $time_bin / $INPUT_TIME_BIN;

if(($group_type eq "load" or $group_type eq "stable") and $num_bs <= 0) {
    die "group type = $group_type, but # BS = $num_bs\n";
}


#############
# Main starts
#############

#############
## read cell info
#############
print "read BS locations\n" if($DEBUG2);

# $bs_info{CELL}{$cell_id}{RNC}
# $bs_info{CELL}{$cell_id}{BS}
# $bs_info{CELL}{$cell_id}{BS_TYPE}
# $bs_info{CELL}{$cell_id}{LAT}
# $bs_info{CELL}{$cell_id}{LNG}
%bs_info = HuaweiTool::read_bs_info("$input_dir/$bs_file");


#############
## read traffic
#############
print "read traffic\n" if($DEBUG2);
if($traffic_type eq "all") {
    
    ## read all traffic
    print "  all traffic\n" if($DEBUG2);

    ($num_values, %traffic_info) = HuaweiTool::read_traffic("$input_dir/$all_traffic_file");
    if($DEBUG5) {
        print "mat: $num_values time bins\n";
        foreach my $this_cell (sort {$a <=> $b} keys(%traffic_info)) {
            print "$this_cell: (".join(",", @{ $traffic_info{$this_cell}{TRAFFIC} } ).")\n";
        }
    }


    foreach my $cell_id (sort {$a <=> $b} keys(%traffic_info)) {
        next unless(exists $bs_info{CELL}{$cell_id});

        my $bs_id   = $bs_info{CELL}{$cell_id}{BS};
        my $bs_type = $bs_info{CELL}{$cell_id}{BS_TYPE};
        my $rnc_id  = $bs_info{CELL}{$cell_id}{RNC};

        $has_cell{ALL}{$cell_id} = 1;
        $has_cell{BS_TYPE}{$bs_type}{$cell_id} = 1;
        $has_bs{ALL}{$bs_id} = 1;
        $has_bs{BS_TYPE}{$bs_type}{$bs_id} = 1;
        $has_rnc{ALL}{$rnc_id} = 1;
        $has_rnc{BS_TYPE}{$bs_type}{$rnc_id} = 1;
        $has_bs_type{$bs_type} = 1;

        %{ $sub_traffic_info{BS_TYPE}{$bs_type}{$cell_id} } = %{ $traffic_info{$cell_id} };
    }
    
}
else {
    die "XXX: no UL/DL yet\n";
}

print "    num Cell   : ".scalar(keys %{ $has_cell{ALL} })."\n";
print "    num BS     : ".scalar(keys %{ $has_bs{ALL} })."\n";
print "    num RNC    : ".scalar(keys %{ $has_rnc{ALL} })."\n";
print "    num BS type: ".scalar(keys %has_bs_type)."\n";
foreach my $bs_type (sort {$a <=> $b} (keys %has_bs_type)) {
    print "      type '$bs_type': ";
    print "#Cell=".scalar(keys %{ $has_cell{BS_TYPE}{$bs_type} }).", ";
    print "#BS=".scalar(keys %{ $has_bs{BS_TYPE}{$bs_type} }).", ";
    print "#RNC=".scalar(keys %{ $has_rnc{BS_TYPE}{$bs_type} })."\n";

    # print "  ".join(",", (sort (keys %{ $has_bs{BS_TYPE}{$bs_type} })))."\n";
}
# exit;



if (($group_type eq "cell") or ($group_type eq "bs")) {
    #############
    ## for each BS type, generate a TM
    #############
    print "for each BS type, generate a TM\n" if($DEBUG2);

    foreach my $bs_type (sort {$a <=> $b} (keys %has_bs_type)) {
        print "  BS type '$bs_type'\n" if($DEBUG2);


        #############
        ## group traffic by network hierarchy
        #############
        print "    group traffic by network hierarchy\n" if($DEBUG2);
        my %group_traffic_info = group_traffic($group_type, $num_values, \%{ $sub_traffic_info{BS_TYPE}{$bs_type} }, \%bs_info);


        #############
        ## convert to TM
        #############
        print "    convert to TM\n" if($DEBUG2);
        my %tm = gen_tm($time_bin_size, $num_values, \%group_traffic_info);
        

        #############
        ## write TM
        #############
        print "    write TM\n" if($DEBUG2);
        write_tm("$output_dir/tm_3g.cell.$group_type.bs$bs_type.$traffic_type.bin$time_bin.txt", \%tm);
        
    }
}
elsif($group_type eq "rnc") {
    print "generate TM for RNC\n" if($DEBUG2);

    #############
    ## group traffic by network hierarchy
    #############
    print "  group traffic by network hierarchy\n" if($DEBUG2);
    my %group_traffic_info = group_traffic("rnc", $num_values, \%traffic_info, \%bs_info);


    #############
    ## convert to TM
    #############
    print "  convert to TM\n" if($DEBUG2);
    my %tm = gen_tm($time_bin_size, $num_values, \%group_traffic_info);
    

    #############
    ## write TM
    #############
    print "  write TM\n" if($DEBUG2);
    write_tm("$output_dir/tm_3g.cell.$group_type.$traffic_type.bin$time_bin.txt", \%tm);
}
elsif($group_type eq "all") {
    print "generate a TM for all BS\n" if($DEBUG2);

    #############
    ## group traffic by network hierarchy
    #############
    print "  group traffic by network hierarchy\n" if($DEBUG2);
    my %group_traffic_info = group_traffic("bs", $num_values, \%traffic_info, \%bs_info);


    #############
    ## convert to TM
    #############
    print "  convert to TM\n" if($DEBUG2);
    my %tm = gen_tm($time_bin_size, $num_values, \%group_traffic_info);
    

    #############
    ## write TM
    #############
    print "  write TM\n" if($DEBUG2);
    write_tm("$output_dir/tm_3g.cell.$group_type.$traffic_type.bin$time_bin.txt", \%tm);
}
elsif($group_type eq "load") {
    print "generate a TM for top loaded BS\n" if($DEBUG2);


    #############
    ## group traffic by network hierarchy
    #############
    print "  group traffic by network hierarchy\n" if($DEBUG2);
    my %group_traffic_info = group_traffic("bs", $num_values, \%traffic_info, \%bs_info);


    #############
    ## calculate load
    #############
    print "  calculate load\n" if($DEBUG2);
    my %load_info;
    foreach my $bs_id (sort {$a <=> $b} (keys %group_traffic_info)) {
        my @values = @{ $group_traffic_info{$bs_id}{TRAFFIC} };
        my $load   = 0;
        foreach my $i (0 .. $num_values-1) {
            $load += $values[$i];
        }

        $load_info{LOAD}{$load} = $bs_id;
    }
    print "    #BSs = ".scalar(keys %{ $load_info{LOAD} })."\n";


    my %top_group_traffic_info;
    my $cnt = 0;
    foreach my $load (sort {$b <=> $a} (keys %{ $load_info{LOAD} })) {
        last if($cnt >= $num_bs);
        $cnt ++;

        my $bs_id = $load_info{LOAD}{$load};

        @{ $top_group_traffic_info{$bs_id}{TRAFFIC} } = @{ $group_traffic_info{$bs_id}{TRAFFIC} };
    }


    #############
    ## convert to TM
    #############
    print "    convert to TM\n" if($DEBUG2);
    my %tm = gen_tm($time_bin_size, $num_values, \%top_group_traffic_info);
    

    #############
    ## write TM
    #############
    print "    write TM\n" if($DEBUG2);
    write_tm("$output_dir/tm_3g.cell.$group_type.top$num_bs.$traffic_type.bin$time_bin.txt", \%tm);
}
elsif($group_type eq "stable") {
    print "generate a TM for the most stable BSs\n" if($DEBUG2);


    #############
    ## group traffic by network hierarchy
    #############
    print "  group traffic by network hierarchy\n" if($DEBUG2);
    my %group_traffic_info = group_traffic("bs", $num_values, \%traffic_info, \%bs_info);


    #############
    ## calculate stdev
    #############
    print "  calculate stdev\n" if($DEBUG2);
    my %stdev_info;
    foreach my $bs_id (sort {$a <=> $b} (keys %group_traffic_info)) {
        my @values = @{ $group_traffic_info{$bs_id}{TRAFFIC} };
        my $max = max(@values);
        
        foreach my $i (0 .. $num_values-1) {
            $values[$i] /= $max;
        }

        my $std = MyUtil::stdev(\@values);
        $stdev_info{STD}{$std} = $bs_id;
    }
    print "    #BSs = ".scalar(keys %{ $stdev_info{STD} })."\n";


    my %top_group_traffic_info;
    my $cnt = 0;
    foreach my $std (sort {$a <=> $b} (keys %{ $stdev_info{STD} })) {
        last if($cnt >= $num_bs);
        $cnt ++;

        my $bs_id = $stdev_info{STD}{$std};

        @{ $top_group_traffic_info{$bs_id}{TRAFFIC} } = @{ $group_traffic_info{$bs_id}{TRAFFIC} };
    }


    #############
    ## convert to TM
    #############
    print "    convert to TM\n" if($DEBUG2);
    my %tm = gen_tm($time_bin_size, $num_values, \%top_group_traffic_info);
    

    #############
    ## write TM
    #############
    print "    write TM\n" if($DEBUG2);
    write_tm("$output_dir/tm_3g.cell.$group_type.top$num_bs.$traffic_type.bin$time_bin.txt", \%tm);
}
else {
    die "wrong group type: $group_type"
}






1;

sub group_traffic {
    my ($group_type, $num_values, $traffic_info_ref, $bs_info_ref) = @_;

    my %group_traffic_info;

    foreach my $cell_id (sort {$a <=> $b} (keys %$traffic_info_ref)) {
        next unless(exists $bs_info_ref->{CELL}{$cell_id});

        my $bs_id   = $bs_info_ref->{CELL}{$cell_id}{BS};
        my $bs_type = $bs_info_ref->{CELL}{$cell_id}{BS_TYPE};
        my $rnc_id  = $bs_info_ref->{CELL}{$cell_id}{RNC};

        my $target_id = $cell_id;
        if($group_type eq "cell") {
            $target_id = $cell_id;
        }
        elsif($group_type eq "bs") {
            $target_id = $bs_id;
        }
        elsif($group_type eq "rnc") {
            $target_id = $rnc_id;
        }
        else {
            die "wrong group type: $group_type\n";
        }


        if(exists $group_traffic_info{$target_id}) {
            my @values1 = @{ $group_traffic_info{$target_id}{TRAFFIC} };
            my @values2 = @{ $traffic_info_ref->{$cell_id}{TRAFFIC} };
            foreach my $i (0 .. $num_values-1) {
                $values1[$i] += $values2[$i];
            }
            @{ $group_traffic_info{$target_id}{TRAFFIC} } = @values1;
        }
        else {
            @{ $group_traffic_info{$target_id}{TRAFFIC} } = @{ $traffic_info_ref->{$cell_id}{TRAFFIC} };
        }
    }

    return %group_traffic_info;
}


sub gen_tm {
    my ($time_bin, $num_values, $traffic_info_ref) = @_;

    my %tm;

    my $nr = scalar(keys %$traffic_info_ref);
    my $nc = ceil($num_values / $time_bin);

    my $i = -1;
    foreach my $cell_id (sort {$a <=> $b} (keys %$traffic_info_ref)) {
        $i ++;
        foreach my $j (0 .. $nc-1) {
            my $std = $j * $time_bin;
            my $end = min( ($j+1) * $time_bin - 1 , $num_values-1 );

            my @values = @{ $traffic_info_ref->{$cell_id}{TRAFFIC} };
            for my $k ($std .. $end) {
                $tm{$i}{$j} += $values[$k];
            }
        }
    }

    return %tm;
}


sub write_tm {
    my ($filename, $tm_ref) = @_;

    open FH, ">$filename" or die $!;
    foreach my $j (sort {$a <=> $b} (keys %{ $tm_ref->{0} })) {
        foreach my $i (sort {$a <=> $b} (keys %$tm_ref)) {
            if($i > 0) {
                print FH ", ";
            }

            print FH "".$tm_ref->{$i}{$j}."";
        }

        print FH "\n";
    }
    close FH;
}











