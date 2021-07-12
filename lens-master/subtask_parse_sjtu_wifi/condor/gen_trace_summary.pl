#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.11.02 @ UT Austin
##
## - input:
##   1. ip_map_fullpath
##      the file that maps IP to matrix index
##   2. period
##      period of each frame
##
## - output:
##
## - e.g.
##   perl gen_trace_summary.pl "../processed_data/subtask_parse_sjtu_wifi/text/Jan 04 08-52-40 2013.txt.bz2" 1
##
##########################################

use strict;

use lib "/u/yichao/anomaly_compression/utils";

use MyUtil;

#############
# Debug
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1; ## print progress
my $DEBUG3 = 1; ## print output
my $DEBUG4 = 0;
my $DEBUG5 = 0;


#############
# Constants
#############


#############
# Variables
#############
my $input_trace_dir = "";
my $invalid_dir     = "/u/yichao/anomaly_compression/condor_data/subtask_parse_sjtu_wifi/ip_info";
my $output_dir      = "/u/yichao/anomaly_compression/condor_data/subtask_parse_sjtu_wifi/text_summary";

my $trace_fullpath;
my $trace_file;
my $invalid_file = "ip_geo_as_invalid.txt";

my $period;

my %invalid_info = ();
my %ip_info = ();  ## SRC - DST - TRAFFIC
my $set_period_dt = 1;
my $period_end_dt = -1;
my $frame = 0;


#############
# check input
#############
if(@ARGV != 2) {
    $trace_fullpath = join(" ", @ARGV[0..@ARGV-2]);
    $period = $ARGV[-1] + 0;

    unless(-e $trace_fullpath) {
        print "wrong number of input: ".@ARGV."\n";
        print "  ".join("|||", @ARGV)."\n";
        print "  perl gen_trace_summary.pl \"../processed_data/subtask_parse_sjtu_wifi/text/Jan 04 08-52-40 2013.txt.bz2\" 1\n";
        exit;
    }
}
else{
    $trace_fullpath = $ARGV[0];
    $period = $ARGV[1] + 0;
}
if($trace_fullpath =~ /^(.*)\/(.*)$/){
    $input_trace_dir = $1;
    $trace_file = $2;
}

if($DEBUG2) {
    print "full path: $trace_fullpath\n";
    print "trace dir: $input_trace_dir\n";
    print "period: $period\n";
}

# exit;
#############
# Main starts
#############
if(-e "$output_dir/$trace_file.txt") {
    print "the output have been existed\n$output_dir/$trace_file.txt\n";
    `rm "$output_dir/$trace_file.txt"`;
}

#############
# read invalid IPs
#############
if(-e "$invalid_dir/$invalid_file") {
    print "read invalid IPs\n" if($DEBUG2);

    open FH, "$invalid_dir/$invalid_file" or die $!;
    while(<FH>) {
        chomp;
        
        my $ip = $_;
        next unless($ip =~ /\d+\.\d+\.\d+\.\d+/);

        print "- ".$ip."\n" if($DEBUG0);
        $invalid_info{IP}{$ip} = 1;
    }
    close FH;
}


#############
## parse the file
#############
print "  parse the file\n" if($DEBUG2);

open FH, "bzcat \"$trace_fullpath\" |" or die $!;
while(<FH>) {
    print $_ if($DEBUG0);
    chomp;
    my ($ind, $time, $mac_src, $mac_dst, $len, $src, $dst) = split(/\|/, $_);

    #############
    ## parse time
    #############
    print "\n    - TIME: $time\n" if($DEBUG4);

    my $this_time;
    if($time =~ /(\w*)\s+(\d+),\s+(\d+)\s+(\d+):(\d+):(\d+)\.(\d+)/) {
        my $tmp = $1;
        my $mon;
        my $day = $2 + 0;
        my $year = $3 + 0;
        my $hour = $4 + 0;
        my $min = $5 + 0;
        my $sec = $6 + 0 + $7 / 1000000000;

        if($tmp eq "Jan") { $mon = 1; }
        elsif($tmp eq "Feb") { $mon = 2; }
        elsif($tmp eq "Mar") { $mon = 3; }
        elsif($tmp eq "Apr") { $mon = 4; }
        elsif($tmp eq "May") { $mon = 5; }
        elsif($tmp eq "Jan") { $mon = 6; }
        elsif($tmp eq "Jul") { $mon = 7; }
        elsif($tmp eq "Aug") { $mon = 8; }
        elsif($tmp eq "Sep") { $mon = 9; }
        elsif($tmp eq "Oct") { $mon = 10; }
        elsif($tmp eq "Nov") { $mon = 11; }
        elsif($tmp eq "Dec") { $mon = 12; }
        else { die "wrong month: $tmp\n"; }

        # $this_time = (((($year * 12 + $mon) * 31 + $day) * 24 + $hour) * 60 + $min) * 60 + $sec;
        $this_time = MyUtil::to_seconds($year, $mon, $day, $hour, $min, $sec);
        print "      = ".join("|", ($year + 2013, $mon, $day, $hour, $min, $sec))."\n" if($DEBUG4);
        print "      = $this_time\n" if($DEBUG4);
    }
    else {
        die "wrong time format: $time\n";
    }
    
    if($set_period_dt == 1) {
        $set_period_dt = 0;

        $period_end_dt = $this_time;
        print "      start time = $period_end_dt\n" if($DEBUG5);
        
        $period_end_dt += $period;
        print "      end time   = $period_end_dt\n" if($DEBUG5);
    }

    while($this_time > $period_end_dt) {
        write_trace_summary("$output_dir/$trace_file.txt", \%ip_info, $period_end_dt);
        %ip_info = ();

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
    print "    - DST: $dst\n" if($DEBUG4);
    my @srcs = split(/,/, $src);
    foreach my $this_src (@srcs) {
        next if(exists $invalid_info{IP}{$this_src});
        print "      = $this_src\n" if($DEBUG4);
        
        #############
        ## parse dst
        #############
        my @dsts = split(/,/, $dst);
        foreach my $this_dst (@dsts) {
            next if(exists $invalid_info{IP}{$this_dst});
            print "      = $this_dst\n" if($DEBUG4);
            
            $ip_info{SRC}{$this_src}{DST}{$this_dst}{TRAFFIC} += $len;
        }
    }
}
close FH;

write_trace_summary("$output_dir/$trace_file.txt", \%ip_info, $period_end_dt);

1;



sub write_trace_summary {
    my ($output_fullpath, $ip_info_ref, $time) = @_;

    open FH_OUT, ">> $output_fullpath" or die $!;
    print FH_OUT "TIME: $time\n";
    if(exists $ip_info_ref->{SRC}) {
        foreach my $src (sort {$a <=> $b} (keys %{ $ip_info_ref->{SRC} })) {
            foreach my $dst (sort {$a <=> $b} (keys %{ $ip_info_ref->{SRC}{$src}{DST} })) {
                print FH_OUT "$src, $dst, ".$ip_info_ref->{SRC}{$src}{DST}{$dst}{TRAFFIC}."\n";
            }
        }
    }
    close FH_OUT;

}


