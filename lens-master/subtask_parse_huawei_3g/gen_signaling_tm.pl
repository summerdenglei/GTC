#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.11.02 @ UT Austin
##
## - input:
##     1. signaling_fullpath
##     2. period
##
## - output:
##
## - e.g.
##     perl gen_signaling_tm.pl ../data/huawei/signaling/select_matrix_for_id-Assignment.txt 60
##
##########################################

use strict;
use lib "../utils";

#############
# Debug
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1; ## print progress
my $DEBUG3 = 1; ## print output
my $DEBUG4 = 0; ## generate TM

#############
# Constants
#############


#############
# Variables
#############
my $signaling_fullpath;
my $period;

my $signaling_dir;
my $signaling_file;
my $output_tm_dir  = "../processed_data/subtask_parse_huawei_3g/signaling_tm";
my $output_ids_dir = "../processed_data/subtask_parse_huawei_3g/signaling_ids";

my %sig_info = ();  ## TIME - [SRC | DST]
my %ids = ();

#############
# check input
#############
if(@ARGV != 2) {
    print "wrong number of input: ".@ARGV."\n";
    print "perl gen_signaling_tm.pl ../data/huawei/signaling/select_matrix_for_id-Assignment.txt 60\n";
    exit;
}
my $signaling_fullpath = $ARGV[0];
my $period = $ARGV[1] + 0;
if($signaling_fullpath =~ /^(.*)\/(.*)$/) {
    $signaling_dir = $1;
    $signaling_file = $2;
}
if($DEBUG2) {
    print "signaling dir: $signaling_dir\n";
    print "signaling file: $signaling_file\n";
    print "period: $period\n";
}


#############
## Main starts
#############

#############
## open the signaling file
#############
print "open the signaling file\n" if($DEBUG2);

open FH, "$signaling_fullpath" or die $!;
while(<FH>) {
    chomp;
    print "$_\n" if($DEBUG0);

    my ($time, $src, $dst);
    if($_ =~ /(\d+\.*\d*) (\d+) -> (\d+)/) {
        $time = $1 + 0;
        $src = $2 + 0;
        $dst = $3 + 0;
        $sig_info{TIME}{$time}{SRC} = $src;
        $sig_info{TIME}{$time}{DST} = $dst;
        $ids{$src} = 1;
        $ids{$dst} = 1;

        print "$time: $src => $dst\n" if($DEBUG0);
    }
    else {
        die "wrong format: $_\n";
    }
}
close FH;

my @ids     = sort {$a <=> $b} (keys %ids);
my $num_ids = scalar(@ids);

print "  # ids = $num_ids\n";


#############
## generate TM
#############
print "generate TM\n" if($DEBUG2);
my $period_end_time = -1;
my %tm = ();  ## SRC - DST - VALUE
my $frame = 0;

foreach my $time (sort {$a <=> $b} (keys %{ $sig_info{TIME} })) {
    my $src = $sig_info{TIME}{$time}{SRC};
    my $dst = $sig_info{TIME}{$time}{DST};

    if($period_end_time == -1) {
        print "  frame $frame:\n" if($DEBUG4);
        
        $period_end_time = $time;
        print "    start = $period_end_time\n" if($DEBUG4);

        $period_end_time += $period;
        print "    end   = $period_end_time\n" if($DEBUG4);
    }

    while($time > $period_end_time) {
        write_tm("$output_tm_dir/tm.$signaling_file.$period.$frame.txt", \%tm, \@ids);
        %tm = ();
        $frame ++;
        print "  frame $frame:\n" if($DEBUG4);
        print "    start = $period_end_time\n" if($DEBUG4);

        $period_end_time += $period;
        print "    end   = $period_end_time\n" if($DEBUG4);
    }

    $tm{SRC}{$src}{DST}{$dst}{VALUE} ++;
}
write_tm("$output_tm_dir/tm.$signaling_file.$period.$frame.txt", \%tm, \@ids);
%tm = ();
$frame ++;


#############
## output ids
#############
print "output ids\n" if($DEBUG2);
open FH, ">$output_ids_dir/ids.$signaling_file.$period.txt" or die $!;
foreach my $i (@ids) {
    print FH "$i\n";
}
close FH;


1;

sub write_tm {
    my ($output_fullpath, $tm_ref, $ids_ref) = @_;

    open FH, "> $output_fullpath" or die $!;
    foreach my $i (@$ids_ref) {

        my $first = 1;
        foreach my $j (@$ids_ref) {
            if($first != 1) {
                print FH ", ";
            }
            else {
                $first = 0;
            }

            if(!(exists $tm_ref->{SRC}{$i}) or !(exists $tm_ref->{SRC}{$i}{DST}{$j})) {
                print FH "0";
            }
            else {
                print FH $tm_ref->{SRC}{$i}{DST}{$j}{VALUE};
            }
        }
        print FH "\n";
    }
    close FH;
}