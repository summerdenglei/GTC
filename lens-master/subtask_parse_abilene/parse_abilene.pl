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
my $DEBUG4 = 1; ## read OD pair names
my $DEBUG5 = 1; ## read 2D TM


#############
# Constants
#############


#############
# Variables
#############
my $input_dir  = "../data/abilene";
my $output_dir = "../processed_data/subtask_parse_abilene/tm";

my $od_name_file = "odnames";
my $tm_file      = "X";

my %od_info;


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
## read OD pair names
#############
print "read OD pair names\n" if($DEBUG2);

my $ind = 0;

open FH, "$input_dir/$od_name_file" or die $!;
while(<FH>) {
    chomp;
    if($_ =~ /(\w+)-(\w+)/) {
        my $src = $1;
        my $dst = $2;
        
        print "  $ind: $src -> $dst\n" if($DEBUG4);
        $od_info{$ind}{SRC} = $src;
        $od_info{$ind}{DST} = $dst;
        $od_info{NODE}{$src} = 1;
        $od_info{NODE}{$dst} = 1;

        $ind ++;
    }
}
close FH;



#############
## parse 2D TM
#############
print "parse 2D TM\n" if($DEBUG2);

my $f = 0;

open FH, "$input_dir/$tm_file" or die $!;
while(<FH>) {
    chomp;

    my @values = split(/\s+/, $_);
    shift @values;
    print "  f$f: # OD pairs=".scalar(@values)."\n" if($DEBUG0);
    print "       ".join(",", @values)."\n" if($DEBUG0);

    my %tm;

    foreach my $ind (0 .. @values-1) {
        my $src = $od_info{$ind}{SRC};
        my $dst = $od_info{$ind}{DST};

        $tm{$src}{$dst} = $values[$ind] + 0;
    }
    
    #############
    ## write a snapshot to file
    #############
    print "write a snapshot to file\n" if($DEBUG0);

    open FH_OUT, "> $output_dir/tm_abilene.od.$f.txt" or die $!;
    foreach my $ni (sort {$a cmp $b} (keys %{ $od_info{NODE} })) {
        foreach my $nj (sort {$a cmp $b} (keys %{ $od_info{NODE} })) {
            if(exists $tm{$ni}{$nj}) {
                print FH_OUT "$tm{$ni}{$nj}\t";
                # print "$tm{$ni}{$nj}\t";
            }
            else {
                print FH_OUT "0\t";
                # print "0\t";
            }
        }
        print FH_OUT "\n";
        # print "\n";
    }
    close FH_OUT;

    $f ++;
    # exit;
}
close FH;








