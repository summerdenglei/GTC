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


#############
# Constants
#############


#############
# Variables
#############
my $input_dir  = "../data/ucsb_meshnet";
my $output_dir = "../processed_data/subtask_parse_ucsb_meshnet/tm";

my %data_info = ();


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
## read files
#############
print "read files\n" if($DEBUG2);

my $pre_time = 0;

opendir(my $dh, $input_dir) || die $!;
foreach my $subdir ( sort { $a <=> $b } readdir $dh ) {
    chomp;
    next if($subdir =~ /^\./);
    print "  $input_dir/$subdir\n";

    opendir(my $dh2, "$input_dir/$subdir") or die $!;
    while(readdir $dh2) {
        chomp;

        if($_ =~ /neighbortable-(\d+)/) {
            my $time = $1 + 0;
            die "wrong order: now $time < prev $pre_time\n" if($time < $pre_time);
            parse_file("$input_dir/$subdir/$_", $time, \%data_info);
            $pre_time = $time;
        }
    }
    closedir $dh2;
    # last;
}
closedir $dh;


#############
## statistics
#############
print "statistics\n" if($DEBUG2);

print "  # time = ".scalar(keys %{ $data_info{TIME} })."\n";
print "  # all nodes = ".scalar(keys %{ $data_info{ALL_NODE} })."\n";
print "  # nodes = ".scalar(keys %{ $data_info{NODE} })."\n";
print "  # neighbors = ".scalar(keys %{ $data_info{NEIGHBOR} })."\n";


#############
## output tm
#############
print "output tm: $output_dir/tm_ucsb_meshnet.txt\n" if($DEBUG2);

open FH, "> $output_dir/tm_ucsb_meshnet.txt" or die $!;
foreach my $time (sort {$a <=> $b} (keys %{ $data_info{TIME} })) {
    my $first = 1;
    foreach my $src (keys %{ $data_info{ALL_NODE} }) {
        foreach my $dst (keys %{ $data_info{ALL_NODE} }) {
            if($first == 1) { $first = 0; }
            else { print FH ","; }
            
            if(exists $data_info{TIME}{$time}{NODE}{$src}{NEIGHBOR}{$dst}) {
                print FH "".$data_info{TIME}{$time}{NODE}{$src}{NEIGHBOR}{$dst};
            }
            else {
                print FH "999";
            }
        }
    }
    print FH "\n";
}
close FH;


#############
## output 3d tm
#############
print "output 3D tm: $output_dir/tm_ucsb_meshnet\n" if($DEBUG2);

my $f = 0;
foreach my $time (sort {$a <=> $b} (keys %{ $data_info{TIME} })) {
    
    open FH, ">$output_dir/tm_ucsb_meshnet.$f.txt" or die $!;
    $f ++;
    foreach my $src (sort {$a cmp $b} (keys %{ $data_info{ALL_NODE} })) {
        my $first = 1;
        foreach my $dst (sort {$a cmp $b} (keys %{ $data_info{ALL_NODE} })) {
            if($first == 1) { $first = 0; }
            else { print FH ","; }
            
            if(exists $data_info{TIME}{$time}{NODE}{$src}{NEIGHBOR}{$dst}) {
                print FH "".$data_info{TIME}{$time}{NODE}{$src}{NEIGHBOR}{$dst};
            }
            else {
                print FH "999";
            }
        }
        print FH "\n";
    }
    close FH;
}



1;

sub parse_file {
    my ($filename, $time, $data_info_ref) = @_;

    open FH, "$filename" or die $!;
    while(<FH>) {
        chomp;
        next if($_ =~ /^#/);

        # 10.1.1.2 10.1.1.106 36.28401 10.1.1.60 0.4560859 10.1.1.9 4.6353765 10.1.1.100 1.678032 10.1.1.25 316.12903 10.1.1.103 19.597902
        my ($node, @pairs) = split(/\s+/, $_);
        $data_info_ref->{NODE}{$node} = 1;
        $data_info_ref->{ALL_NODE}{$node} = 1;

        my $neighbor;
        foreach my $pi (0 .. @pairs-1) {
            if($pi % 2 == 0) {
                $neighbor = $pairs[$pi];
                $data_info_ref->{NEIGHBOR}{$neighbor} = 1;
                $data_info_ref->{ALL_NODE}{$neighbor} = 1;
            }
            else {
                my $ett = $pairs[$pi] + 0;
                $data_info_ref->{TIME}{$time}{NODE}{$node}{NEIGHBOR}{$neighbor} = $ett;
            }
        }
    }
    close FH;

}