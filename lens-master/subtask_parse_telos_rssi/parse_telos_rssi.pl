#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.09.27 @ UT Austin
##
## - input:
##   1. num_rssi
##
## - output:
##
## - e.g.
##   perl parse_telos_rssi.pl 100000
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


#############
# Constants
#############


#############
# Variables
#############
my $input_dir  = "../data/telos_rssi/";
my $output_dir = "../processed_data/subtask_parse_telos_rssi/tm";

my $num_rssi;

my %data_info;


#############
# check input
#############
if(@ARGV != 1) {
    print "wrong number of input: ".@ARGV."\n";
    exit;
}
$num_rssi = $ARGV[0] + 0;


#############
# Main starts
#############

#############
## read files
#############
my $num_nodes = 16;

for my $node (1..$num_nodes) {
    my $file_name = "node$node.txt";
    print "$file_name:\n";
    my $f = 0;

    open FH, "$input_dir/$file_name" or die $!;
    while(<FH>) {
        chomp;
        # print $_."\n";

        if($_ =~ /^(\d+)$/) {
            my $rssi = $1 + 0;
            $data_info{$f}{$node} = $rssi;
            # print "===> $rssi\n";

            $f ++;
            last if($f >= $num_rssi);
        }
    }
    close FH;

    print "  $f.\n";
}



#############
## output files
#############
open FH, "> $output_dir/tm_telos_rssi.txt" or die $!;
foreach my $f (sort {$a <=> $b} (keys %data_info)) {
    my $first = 1;

    foreach my $node (sort {$a <=> $b} (keys %{ $data_info{$f} })) {
        print FH ", " unless($first); $first = 0;
        print FH "".$data_info{$f}{$node}."";
    }
    print FH "\n";
}
close FH;

