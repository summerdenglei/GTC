#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.09.27 @ UT Austin
##
## - input:
##
## - output:
##
## - e.g.
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
my $DEBUG4 = 0; ## parse


#############
# Constants
#############
my $num_pkts = 500;
my $num_monitors = 5;


#############
# Variables
#############
my $input_dir  = "../data/multi_loc_rssi";
my $output_dir = "../processed_data/subtask_parse_multi_loc_rssi/tm";

my $filename = "omni_16dbm.txt";

my %data_info;
my %nodes;


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
## Read file
#############
print "Read file\n" if($DEBUG2);

open FH, "$input_dir/$filename" or die $!;
while(<FH>) {
    chomp;

    my ($x, $y, $dir, $tmp1, $tmp2, $pkt, $rssi1, $rssi2, $rssi3, $rssi4, $rssi5) = split(/\s+/, $_);
    $pkt += 0; $rssi1 += 0; $rssi2 += 0; $rssi3 += 0; $rssi4 += 0; $rssi5 += 0;
    print "$_\n" if($DEBUG4);
    print "  ".join(", ", ($x, $y, $pkt, $rssi1, $rssi2, $rssi3, $rssi4, $rssi5))."\n" if($DEBUG4);

    die "a positive rssi??\n" if($rssi1 > 0 or $rssi2 > 0 or $rssi3 > 0 or $rssi4 > 0 or $rssi5 > 0);


    $data_info{$pkt}{"$x.$y"}{1} = -$rssi1;
    $data_info{$pkt}{"$x.$y"}{2} = -$rssi2;
    $data_info{$pkt}{"$x.$y"}{3} = -$rssi3;
    $data_info{$pkt}{"$x.$y"}{4} = -$rssi4;
    $data_info{$pkt}{"$x.$y"}{5} = -$rssi5;
    $nodes{"$x.$y"} = 1;

}
close FH;


#############
## Write TM file
#############
print "write TM file\n" if($DEBUG2);

open FH, ">$output_dir/tm_multi_loc_rssi.txt" or die $!;
# foreach my $f (sort {$a <=> $b} (keys %data_info)) {
foreach my $f (0 .. $num_pkts-1) {
    die "no packet $f for all receiver\n" unless(exists $data_info{$f});

    my $first = 1;
    # foreach my $node (sort {$a cmp $b} (keys %{ $data_info{$f} })) {
    foreach my $node (sort {$a cmp $b} (keys %nodes)) {
        if(exists $data_info{$f}{$node}) {
            foreach my $monitor (sort {$a <=> $b} (keys %{ $data_info{$f}{$node} })) {
                print FH ", " unless($first); $first = 0;
                print FH "".$data_info{$f}{$node}{$monitor}."";
            }
        }
        else {
            foreach my $monitor (1..$num_monitors) {
                print FH ", " unless($first); $first = 0;
                print FH "100";
            }
        }
    }
    print FH "\n";
}
close FH;

