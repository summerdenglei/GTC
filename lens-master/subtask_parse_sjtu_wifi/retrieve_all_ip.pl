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
my $input_dir  = "../condor_data/subtask_parse_sjtu_wifi/text";
my $output_dir = "../processed_data/subtask_parse_sjtu_wifi/ip_info";

my %ip_info = ();

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
## Read IP Info
#############
print "Read IP info\n" if($DEBUG2);

my @files = ();
opendir(DIR, "$input_dir") or die $!;
while (my $file = readdir(DIR)) {
    next if($file =~ /^\.+/);  ## don't show "." and ".."
    next if(-d "$input_dir/$file");  ## don't show directories
    next unless($file =~ /\.bz2$/);  ## only bz2 files

    # print "$file\n";
    push(@files, $file);
}
closedir(DIR);


foreach my $file (sort {$a cmp $b} @files) {
    print "$input_dir/$file\n" if($DEBUG2);

    #############
    ## open the file
    #############
    # open FH, "$input_dir/$file" or die $!;
    open FH, "bzcat \"$input_dir/$file\" |" or die $!;
    while (<FH>) {
        chomp;
        my ($ind, $time, $mac_src, $mac_dst, $len, $src, $dst) = split(/\|/, $_);

        my @srcs = split(/,/, $src);
        foreach my $ip (@srcs) {
            if($ip =~ /^\d+\.\d+\.\d+\.\d+$/) {
                $ip_info{IP}{$ip} = 1;
            }
            else {
                die "$ip\n";
            }
        }
        
        my @dsts = split(/,/, $dst);
        foreach my $ip (@dsts) {
            if($ip =~ /^\d+\.\d+\.\d+\.\d+$/) {
                $ip_info{IP}{$ip} = 1;
            }
            else {
                die "$ip\n";
            }
        }
        
    }
    close FH;

    # last;
}


#############
## Write all IPs
#############
print "Write all IPs: \n" if($DEBUG2);

open FH, "> $output_dir/all_ips.txt";
foreach my $ip (sort {$a cmp $b} (keys %{ $ip_info{IP} })) {
    next unless($ip =~ /^\d+\.\d+\.\d+\.\d+$/);

    print $ip."\n" if($DEBUG0);
    print FH $ip."\n";
}
close FH;
