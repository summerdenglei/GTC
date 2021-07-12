#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.09.27 @ UT Austin
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
##   perl gen_tm.pl ../processed_data/subtask_parse_mawi/sort_ips/sort_ips.top100.txt 86400
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
my $DEBUG4 = 0;
my $DEBUG5 = 1;


#############
# Constants
#############


#############
# Variables
#############
my $input_trace_dir = "../processed_data/subtask_parse_mawi/text_summary";
my $output_dir      = "../processed_data/subtask_parse_mawi/tm";

my $ip_map_fullpath;
my $period;

my $input_map_dir;
my $ip_map_file;

my %src_ip_map = ();
my %dst_ip_map = ();
my %tm = ();  ## Dim1 - Dim2 - value

my $num_src = 0;   ## number of src
my $num_dst = 0;   ## number of dst

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
$ip_map_fullpath = $ARGV[0];
if($ip_map_fullpath =~ /^(.*)\/(.*)$/) {
    $input_map_dir = $1;
    $ip_map_file = $2;
}
$period = $ARGV[1] + 0;

if($DEBUG2) {
    print "ip map dir: $input_map_dir\n";
    print "ip map file: $ip_map_file\n";
    print "period: $period\n";
}


#############
# Main starts
#############

#############
## read the mapping
#############
print "read the mapping\n" if($DEBUG2);

open FH, "$ip_map_fullpath" or die $!;
while(<FH>) {
    chomp;

    my ($is_dst, $ip, $index) = split(/, /, $_);
    die "wrong format: $_\n  $is_dst: $ip => $index\n" unless($ip =~ /^\d+\.\d+\.\d+\.\d+$/);
    $index += 0; $is_dst += 0;
    print "  $ip => $index\n" if($DEBUG0);

    if($is_dst == 0) {
        $src_ip_map{$ip} = $index;
        $num_src = $index if($index > $num_src);
    }
    else {
        $dst_ip_map{$ip} = $index;
        $num_dst = $index if($index > $num_dst);
    }
    
    
}
close FH;


#############
## for each file, get IP info
#############
print "read the trace summary: $input_trace_dir\n" if($DEBUG2);

my @files = ();
opendir(DIR, "$input_trace_dir") or die $!;
while (my $file = readdir(DIR)) {
    next if($file =~ /^\.+/);  ## don't show "." and ".."
    next if(-d "$input_trace_dir/$file");  ## don't show directories

    push(@files, $file);
}

my $time;
## XXX: fix the order of file ....
for my $file (sort {$a cmp $b} @files) {
    print "  $input_trace_dir/$file\n" if($DEBUG2);


    #############
    ## parse the file
    #############
    print "  parse the file\n" if($DEBUG2);

    # open FH, "bzcat \"$input_trace_dir/$file\" |" or die $!;
    open FH, "bzcat $input_trace_dir/$file |" or die $!;
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
        }

        while($this_time > $period_end_dt) {
            write_tm("$output_dir/tm_mawi.$ip_map_file.$period.$frame.txt", \%tm, $num_src, $num_dst);
            
            $frame ++;
            %tm = ();
            
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
            if(exists $src_ip_map{$this_src}) {
                ## upload
                $valid = 1;
                $src_ip = $this_src;
                print "      src = $this_src -> ".$src_ip_map{$this_src}."\n" if($DEBUG4);
                last;
            }
        }
        next unless($valid > 0);


        #############
        ## parse dst
        #############
        print "    - DST: $dst\n" if($DEBUG4);
        my $dst_ip;
        my $valid2 = 0;
        my @dsts = split(/,/, $dst);
        foreach my $this_dst (@dsts) {
            if(exists $dst_ip_map{$this_dst}) {
                ## upload
                $valid2 = 1;
                $dst_ip = $this_dst;
                print "      dst = $this_dst -> ".$dst_ip_map{$this_dst}."\n" if($DEBUG4);
                last;
            }     
        }
        next unless($valid2 == $valid);


        $total_bytes += $len;


        ## update Traffic Matrix
        if($valid == 1) {
            ## upload
            $tm{SRC}{$src_ip_map{$src_ip}}{DST}{$dst_ip_map{$dst_ip}}{VALUE} += $len;
        }
        else {
            die "unknown valid number: $valid\n";
        }
    }
    close FH;
}
write_tm("$output_dir/tm_mawi.$ip_map_file.$period.$frame.txt", \%tm, $num_src, $num_dst);
$frame ++;

print "  total bytes = $total_bytes\n";
print "  total frame = $frame\n";


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
