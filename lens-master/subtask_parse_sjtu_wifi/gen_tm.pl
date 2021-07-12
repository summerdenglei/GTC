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
##   perl gen_tm.pl ../processed_data/subtask_parse_sjtu_wifi/sort_ips/sort_ips.ap.country.txt 3600
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
my $input_trace_dir = "../processed_data/subtask_parse_sjtu_wifi/text_summary";
my $output_dir      = "../processed_data/subtask_parse_sjtu_wifi/tm";

my $ip_map_fullpath;
my $period;

my $input_map_dir;
my $ip_map_file;

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

    my ($sjtu_dev, $ip, $index) = split(/, /, $_);
    die "wrong format: $_\n  $sjtu_dev: $ip => $index\n" unless($ip =~ /^\d+\.\d+\.\d+\.\d+$/);
    $index += 0; $sjtu_dev += 0;
    print "  $ip => $index\n" if($DEBUG0);

    if($sjtu_dev == 0) {
        $sjtu_ip_map{$ip} = $index;
        $num_sjtu = $index if($index > $num_sjtu);
    }
    else {
        $other_ip_map{$ip} = $index;
        $num_other = $index if($index > $num_other);
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
    open FH, "$input_trace_dir/$file" or die $!;
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
        # my $this_time;
        # if($time =~ /(\w*)\s+(\d+),\s+(\d+)\s+(\d+):(\d+):(\d+)\.(\d+)/) {
        #     my $tmp = $1;
        #     my $mon;
        #     my $day = $2 + 0;
        #     my $year = $3 + 0;
        #     my $hour = $4 + 0;
        #     my $min = $5 + 0;
        #     my $sec = $6 + 0 + $7 / 1000000000;

        #     if($tmp eq "Jan") { $mon = 1; }
        #     elsif($tmp eq "Feb") { $mon = 2; }
        #     elsif($tmp eq "Mar") { $mon = 3; }
        #     elsif($tmp eq "Apr") { $mon = 4; }
        #     elsif($tmp eq "May") { $mon = 5; }
        #     elsif($tmp eq "Jan") { $mon = 6; }
        #     elsif($tmp eq "Jul") { $mon = 7; }
        #     elsif($tmp eq "Aug") { $mon = 8; }
        #     elsif($tmp eq "Sep") { $mon = 9; }
        #     elsif($tmp eq "Oct") { $mon = 10; }
        #     elsif($tmp eq "Nov") { $mon = 11; }
        #     elsif($tmp eq "Dec") { $mon = 12; }
        #     else { die "wrong month: $tmp\n"; }

        #     # $this_time = (((($year * 12 + $mon) * 31 + $day) * 24 + $hour) * 60 + $min) * 60 + $sec;
        #     $this_time = MyUtil::to_seconds($year, $mon, $day, $hour, $min, $sec);
        #     print "      = ".join("|", ($year, $mon, $day, $hour, $min, $sec))."\n" if($DEBUG4);
        #     print "      = $this_time\n" if($DEBUG4);
        # }
        # else {
        #     die "wrong time format: $time\n";
        # }


        if($set_period_dt == 1) {
            $set_period_dt = 0;

            $period_end_dt = $this_time;
            print "      start time = $period_end_dt\n" if($DEBUG5);
            
            $period_end_dt += $period;
            print "      end time   = $period_end_dt\n" if($DEBUG5);
        }

        while($this_time > $period_end_dt) {
            write_tm("$output_dir/tm_download.$ip_map_file.$period.$frame.txt", \%tm_download, $num_other, $num_sjtu);
            write_tm("$output_dir/tm_upload.$ip_map_file.$period.$frame.txt", \%tm_upload, $num_sjtu, $num_other);
            $frame ++;
            %tm_download = ();
            %tm_upload = ();
            
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
            if(exists $sjtu_ip_map{$this_src}) {
                ## upload
                $valid = 1;
                $src_ip = $this_src;
                print "      sjtu = $this_src -> ".$sjtu_ip_map{$this_src}."\n" if($DEBUG4);
                last;
            }
            elsif(exists $other_ip_map{$this_src}) {
                ## download
                $valid = 2;
                $src_ip = $this_src;
                print "      other = $this_src -> ".$other_ip_map{$this_src}."\n" if($DEBUG4);
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
            if(exists $sjtu_ip_map{$this_dst}) {
                ## download
                $valid2 = 2;
                $dst_ip = $this_dst;
                print "      sjtu = $this_dst -> ".$sjtu_ip_map{$this_dst}."\n" if($DEBUG4);
                last;
            }
            elsif(exists $other_ip_map{$this_dst}) {
                ## upload
                $valid2 = 1;
                $dst_ip = $this_dst;
                print "      other = $this_dst -> ".$other_ip_map{$this_dst}."\n" if($DEBUG4);
                last;
            }     
        }
        next unless($valid2 == $valid);


        $total_bytes += $len;


        ## update Traffic Matrix
        if($valid == 1) {
            ## upload
            $tm_upload{SRC}{$sjtu_ip_map{$src_ip}}{DST}{$other_ip_map{$dst_ip}}{VALUE} += $len;
        }
        elsif($valid == 2) {
            ## download
            $tm_download{SRC}{$other_ip_map{$src_ip}}{DST}{$sjtu_ip_map{$dst_ip}}{VALUE} += $len;
        }
        else {
            die "unknown valid number: $valid\n";
        }
    }
    close FH;
}
write_tm("$output_dir/tm_upload.$ip_map_file.$period.$frame.txt", \%tm_upload, $num_sjtu, $num_other);
write_tm("$output_dir/tm_download.$ip_map_file.$period.$frame.txt", \%tm_download, $num_other, $num_sjtu);
$frame ++;

print "total bytes = $total_bytes\n";


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
