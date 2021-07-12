#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.12.28 @ UT Austin
##
## - input:
##
## - output:
##
## - e.g.
##   perl gen_tm.pl
##
##########################################

use strict;
use POSIX;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use lib "../utils";

#############
# Debug
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1; ## print progress
my $DEBUG3 = 1; ## print output
my $DEBUG4 = 0; ## parse tm


#############
# Constants
#############


#############
# Variables
#############
my $input_dir  = "../data/totem/traffic-matrices";
my $output_dir = "../processed_data/subtask_parse_totem/tm";

my %tm;


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
## read dir
#############
print "read dir\n" if($DEBUG2);

my @files;
opendir(my $dh, $input_dir) || die;
while(readdir $dh) {
    next if($_ =~ /^\./);

    print "$input_dir/$_\n" if($DEBUG0);
    push(@files, $_);
}
closedir $dh;


#############
## parse tm
#############
print "parse tm\n" if($DEBUG2);

my $frame = 0;
foreach my $file (sort {$a cmp $b} @files) {
    print "  $file\n" if($DEBUG4);


    #############
    ## parse file
    #############
    my $src;

    open FH, "$input_dir/$file" or die $!;
    while (<FH>) {
        chomp;

        if($_ =~ /<src id=\"(\d+)\"/) {
            $src = $1 + 0;
            # print "    src=$src\n" if($DEBUG4);

            next;
        }
        elsif($_ =~ /<dst id=\"(\d+)\">(\d+\.*\d*)<\/dst>/) {
            my $dst = $1 + 0;
            my $load = $2 + 0;
            $tm{FRAME}{$frame}{SRC}{$src}{DST}{$dst}{LOAD} = $load;
            $tm{ALL}{SRC}{$src} = 1;
            $tm{ALL}{DST}{$dst} = 1;

            print "    $src->$dst: $load\n" if($DEBUG4);

            next;
        }
    }
    close FH;

    $frame ++;
}

my $num_frames = scalar(keys %{ $tm{FRAME} });
my $num_src    = scalar(keys %{ $tm{ALL}{SRC} });
my $num_dst    = scalar(keys %{ $tm{ALL}{DST} });
print "  #frames: $num_frames\n";
print "  #src: $num_src:\n";
print "     ".join(", ", (sort {$a <=> $b} (keys %{ $tm{ALL}{SRC} })))."\n";
print "  #dst: $num_dst:\n";
print "     ".join(", ", (sort {$a <=> $b} (keys %{ $tm{ALL}{DST} })))."\n";


#############
## output tm
#############
print "output tm\n" if($DEBUG2);

foreach my $frame (0 .. $num_frames-1) {
    open FH, ">$output_dir/tm_totem.$frame.txt" or die $!;
    foreach my $src (1 .. $num_src) {
        foreach my $dst (1 .. $num_dst) {
            print FH ", " if($dst != 1);

            if(exists $tm{FRAME}{$frame}{SRC}{$src}{DST}{$dst}{LOAD}) {
                print FH "".$tm{FRAME}{$frame}{SRC}{$src}{DST}{$dst}{LOAD}."";
            }
            else {
                print FH "0";
            }
        }
        print FH "\n";
    }
    close FH;
}


