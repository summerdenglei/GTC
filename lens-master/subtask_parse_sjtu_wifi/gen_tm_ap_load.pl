#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.09.27 @ UT Austin
##
## - input:
##   1. period
##      period of each snapshot
##   2. num_ap
##      select the top N APs
##
## - output:
##
## - e.g.
##   perl gen_tm_ap_load.pl 600 100
##
##########################################

use strict;

use lib "../utils";

use MyUtil;
use IPTool;


#############
# Debug
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1; ## print progress
my $DEBUG3 = 1; ## print output
my $DEBUG4 = 0;
my $DEBUG5 = 0;
my $DEBUG6 = 1;

#############
# Constants
#############


#############
# Variables
#############
my $input_trace_dir  = "../processed_data/subtask_parse_sjtu_wifi/text_summary";
my $input_radius_dir = "../data/sjtu_wifi/RADIUS";
my $output_dir       = "../processed_data/subtask_parse_sjtu_wifi/tm";

my @text_summary_days = ("Dec 30", "Dec 31");
# my @text_summary_days = ("Dec 30", "Dec 31", "Jan 04 09");
my @radius_days = ("RADIUS Accounting 2012-12-30_anonymous.csv.bz2", "RADIUS Accounting 2012-12-31_anonymous.csv.bz2");
# my @radius_days = ("RADIUS Accounting 2012-12-30_anonymous.csv.bz2", "RADIUS Accounting 2012-12-31_anonymous.csv.bz2", "RADIUS Accounting 2013-01-04_anonymous.csv.bz2");

my $period;
my $num_ap;


my %sjtu_ip_map = ();
my %other_ip_map = ();
my %tm_upload = ();  ## Dim1 - Dim2 - value
my %tm_download = ();  ## Dim1 - Dim2 - value
my $num_sjtu = 0;   ## number of sjtu groups
my $num_other = 0;   ## number of sjtu groups
my $set_period_dt = 1;
my $period_end_dt = -1;
my $frame = 0;

my $total_bytes = 0;



#############
# check input
#############
if(@ARGV != 2) {
    print "wrong number of input: ".@ARGV."\n";
    exit;
}
$period = $ARGV[0] + 0;
$num_ap = $ARGV[1] + 0;

if($DEBUG2) {
    print "period: $period\n";
    print "num ap: $num_ap\n";
}


#############
# Main starts
#############

#############
## read all APs
#############
print "read all APs\n" if($DEBUG2);

my %ap_info = ();
foreach my $radius_file (@radius_days) {
    print "  $radius_file\n";

    my %account_info = IPTool::read_account_info2("$input_radius_dir/$radius_file");
    foreach my $user_ip (keys %{ $account_info{USER_IP} }) {
        $ap_info{AP_MAC}{$account_info{USER_IP}{$user_ip}{AP_MAC}}{DL_LOAD} = 0;
        $ap_info{AP_MAC}{$account_info{USER_IP}{$user_ip}{AP_MAC}}{UL_LOAD} = 0;
        $ap_info{AP_MAC}{$account_info{USER_IP}{$user_ip}{AP_MAC}}{TOTAL} = 0;

        @{ $ap_info{AP_MAC}{$account_info{USER_IP}{$user_ip}{AP_MAC}}{DL_TS} } = ();
        @{ $ap_info{AP_MAC}{$account_info{USER_IP}{$user_ip}{AP_MAC}}{UL_TS} } = ();
        @{ $ap_info{AP_MAC}{$account_info{USER_IP}{$user_ip}{AP_MAC}}{ALL_TS} } = ();
    }
}

print "  # APs: ".scalar(keys %{ $ap_info{AP_MAC} })."\n" if($DEBUG2);


#############
## read text_summary of the specified dates
#############
print "read text_summary of the specified dates\n" if($DEBUG2);

foreach my $di (0 .. @text_summary_days-1) {
    my $date = $text_summary_days[$di];
    print "  $date\n" if($DEBUG2);

    ## for this date, read all text summary
    my @files = ();
    opendir(DIR, "$input_trace_dir") or die $!;
    while (my $file = readdir(DIR)) {
        next if($file =~ /^\.+/);  ## don't show "." and ".."
        next if(-d "$input_trace_dir/$file");  ## don't show directories
        next unless($file =~ /$date/);

        push(@files, $file);
    }


    ## read RADIUS file
    my $radius_file = $radius_days[$di];
    my %account_info = IPTool::read_account_info2("$input_radius_dir/$radius_file");


    ## sort by date
    my $time;
    for my $file (sort {$a cmp $b} @files) {
        
        #############
        ## parse the file
        #############
        print "    $file\n" if($DEBUG6);
        
        open FH, "bzcat \"$input_trace_dir/$file\" |" or die $!;
        # open FH, "$input_trace_dir/$file" or die $!;
        while(<FH>) {
            chomp;
            # my ($ind, $time, $mac_src, $mac_dst, $len, $src, $dst) = split(/\|/, $_);
            my ($src, $dst, $len);
            if($_ =~ /TIME: (\d+\.*\d*)/) {
                $time = $1 + 0;
                next;
            }
            else {
                ($src, $dst, $len) = split(/, /, $_);
            }

            #############
            ## parse time
            #############
            print "\n    - TIME: $time\n" if($DEBUG4);
            my $this_time = $time;
            
            if($set_period_dt == 1) {
                $set_period_dt = 0;

                $period_end_dt = $this_time;
                print "      start time = $period_end_dt\n" if($DEBUG5);
                
                $period_end_dt += $period;
                print "      end time   = $period_end_dt\n" if($DEBUG5);

                foreach my $ap_mac (keys %{ $ap_info{AP_MAC} }) {
                    $ap_info{AP_MAC}{$ap_mac}{LOAD} = 0;
                }
            }

            while($this_time > $period_end_dt) {
                ## new snapshot
                foreach my $ap_mac (sort {$a cmp $b} (keys %{ $ap_info{AP_MAC} })) {
                    push(@{ $ap_info{AP_MAC}{$ap_mac}{DL_TS} }, $ap_info{AP_MAC}{$ap_mac}{DL_LOAD});
                    push(@{ $ap_info{AP_MAC}{$ap_mac}{UL_TS} }, $ap_info{AP_MAC}{$ap_mac}{UL_LOAD});
                    push(@{ $ap_info{AP_MAC}{$ap_mac}{ALL_TS} }, $ap_info{AP_MAC}{$ap_mac}{DL_LOAD} + $ap_info{AP_MAC}{$ap_mac}{UL_LOAD});

                    $ap_info{AP_MAC}{$ap_mac}{DL_LOAD} = 0;
                    $ap_info{AP_MAC}{$ap_mac}{UL_LOAD} = 0;
                }

                $frame ++;
                
                print "\n      start time = $period_end_dt\n" if($DEBUG5);
                $period_end_dt += $period;
                print "      end time   = $period_end_dt\n" if($DEBUG5);
            }
            


            #############
            ## parse len
            #############
            $len += 0;
            print "    - LEN: $len\n" if($DEBUG4);


            #############
            ## parse src
            #############
            print "    - SRC: $src\n" if($DEBUG4);
            my $valid = 0;
            my $src_ip;
            my @srcs = split(/,/, $src);
            foreach my $this_src (@srcs) {
                # next unless(exists $ip_map{$this_src});
                if(exists $account_info{USER_IP}{$this_src}) {
                    ## upload
                    $valid = 1;
                    $src_ip = $this_src;
                    print "      sjtu src = $this_src\n" if($DEBUG4);
                    last;
                }
            }
            

            #############
            ## parse dst
            #############
            print "    - DST: $dst\n" if($DEBUG4);
            my $dst_ip;
            my $valid2 = 0;
            my @dsts = split(/,/, $dst);
            foreach my $this_dst (@dsts) {
                if(exists $account_info{USER_IP}{$this_dst}) {
                    ## download
                    $valid2 = 1;
                    $dst_ip = $this_dst;
                    print "      sjtu dst = $this_dst\n" if($DEBUG4);
                    last;
                }
            }
            next unless($valid + $valid2 == 1);


            $total_bytes += $len;


            ## update Traffic Matrix
            if($valid == 1) {
                ## upload
                print "      upload to ".$account_info{USER_IP}{$src_ip}{AP_MAC}."\n" if($DEBUG4);
                $ap_info{AP_MAC}{$account_info{USER_IP}{$src_ip}{AP_MAC}}{UL_LOAD} += $len;
                $ap_info{AP_MAC}{$account_info{USER_IP}{$src_ip}{AP_MAC}}{TOTAL} += $len;
            }
            elsif($valid2 == 1) {
                ## download
                print "      download to ".$account_info{USER_IP}{$dst_ip}{AP_MAC}."\n" if($DEBUG4);
                $ap_info{AP_MAC}{$account_info{USER_IP}{$dst_ip}{AP_MAC}}{DL_LOAD} += $len;
                $ap_info{AP_MAC}{$account_info{USER_IP}{$dst_ip}{AP_MAC}}{TOTAL} += $len;
            }
            else {
                die "unknown valid number: $valid\n";
            }
        }
        close FH;
    }
}

## last snapshot (may not be a complete snapshot, so can be ignored)
# foreach my $ap_mac (sort {$a cmp $b} (keys %{ $ap_info{AP_MAC} })) {
#     push(@{ $ap_info{AP_MAC}{$ap_mac}{DL_TS} }, $ap_info{AP_MAC}{$ap_mac}{DL_LOAD});
#     push(@{ $ap_info{AP_MAC}{$ap_mac}{UL_TS} }, $ap_info{AP_MAC}{$ap_mac}{UL_LOAD});
#     push(@{ $ap_info{AP_MAC}{$ap_mac}{ALL_TS} }, $ap_info{AP_MAC}{$ap_mac}{DL_LOAD} + $ap_info{AP_MAC}{$ap_mac}{UL_LOAD});

#     $ap_info{AP_MAC}{$ap_mac}{DL_LOAD} = 0;
#     $ap_info{AP_MAC}{$ap_mac}{UL_LOAD} = 0;
# }
# $frame ++;

print "  total bytes = $total_bytes\n" if($DEBUG2);
print "  # snapshots = $frame\n" if($DEBUG2);



#############
## DEBUG: sort APs by load
#############
foreach my $ap_mac (sort {$ap_info{AP_MAC}{$b}{TOTAL} <=> $ap_info{AP_MAC}{$a}{TOTAL}} (keys %{ $ap_info{AP_MAC} })) {
    print "$ap_mac: ".$ap_info{AP_MAC}{$ap_mac}{TOTAL}."\n";
}


#############
## output TM
##   rows: time
##   cols: APs
#############
print "output TM\n" if($DEBUG2);

open FH_DL, "> $output_dir/tm_sjtu_wifi2.ap_load.dl.bin$period.top$num_ap.txt" or die $!;
open FH_UL, "> $output_dir/tm_sjtu_wifi2.ap_load.ul.bin$period.top$num_ap.txt" or die $!;
open FH_ALL, "> $output_dir/tm_sjtu_wifi2.ap_load.all.bin$period.top$num_ap.txt" or die $!;
foreach my $time (0..$frame-1) {
    my $cnt = 0;
    foreach my $ap_mac (sort {$ap_info{AP_MAC}{$b}{TOTAL} <=> $ap_info{AP_MAC}{$a}{TOTAL}} (keys %{ $ap_info{AP_MAC} })) {
        last if($cnt == $num_ap);

        $cnt ++;
        my @dl_ts = @{ $ap_info{AP_MAC}{$ap_mac}{DL_TS} };
        my @ul_ts = @{ $ap_info{AP_MAC}{$ap_mac}{UL_TS} };
        my @all_ts = @{ $ap_info{AP_MAC}{$ap_mac}{ALL_TS} };

        print FH_DL ", " if($cnt > 1);
        print FH_DL $dl_ts[$time];
        print FH_UL ", " if($cnt > 1);
        print FH_UL $ul_ts[$time];
        print FH_ALL ", " if($cnt > 1);
        print FH_ALL $all_ts[$time];
    }
    print FH_DL "\n";
    print FH_UL "\n";
    print FH_ALL "\n";
}
close FH_DL;
close FH_UL;
close FH_ALL;

1;



sub write_tm {
    my ($output_fullpath, $tm_ref, $num_src, $num_dst) = @_;

    open FH_OUT, "> $output_fullpath" or die $!;
    for my $i (1 .. $num_src) {
        for my $j (1 .. $num_dst) {
            print FH_OUT ", " if($j != 1);
            if(!(exists $tm_ref->{SRC}{$i}) or !(exists $tm_ref->{SRC}{$i}{DST}{$j})) {
                print FH_OUT "0";
            }
            else {
                print FH_OUT $tm_ref->{SRC}{$i}{DST}{$j}{VALUE};
            }
        }
        print FH_OUT "\n";
    }
    close FH_OUT;
}


