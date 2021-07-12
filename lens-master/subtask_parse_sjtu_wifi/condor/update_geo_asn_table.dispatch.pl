#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.10.29 @ UT Austin
##
## - input:
##
## - output:
##
## - e.g.
##
##########################################

use strict;
use POSIX qw(ceil);
use lib "/u/yichao/anomaly_compression/utils";
use IPTool;

#############
# Debug
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1; ## print progress
my $DEBUG3 = 1; ## print output
my $DEBUG4 = 0; ## parse geo as table
my $DEBUG5 = 0; ## parse summary ip info
my $DEBUG6 = 0; ## parse all IPs
my $DEBUG7 = 0; ## parse invalid IPs


#############
# Constants
#############
my $READ_TABLE   = 1;
my $READ_INVALID = 1;
my $READ_SUMMARY = 1;
my $READ_IPS     = 1;

my $NUM_PART     = 500;


#############
# Variables
#############
my $sum_ip_dir  = "/u/yichao/anomaly_compression/condor_data/subtask_parse_sjtu_wifi/ip_info";
my $table_dir   = "/u/yichao/anomaly_compression/condor_data/subtask_parse_sjtu_wifi/ip_info";
my $invalid_dir = "/u/yichao/anomaly_compression/condor_data/subtask_parse_sjtu_wifi/ip_info";
my $ips_dir     = "/u/yichao/anomaly_compression/condor_data/subtask_parse_sjtu_wifi/ip_info";

my $sum_ip_info  = "ip_info.txt";
my $table_file   = "ip_geo_as_table.txt";
my $invalid_file = "ip_geo_as_invalid.txt";
# my $ips_file     = "all_ips_3g.txt";
my $ips_file     = "all_ips.txt";

my %ip_info = ();
my %invalid_info = ();


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
# partition all_ips.txt
#############
print "partition all_ips.txt\n" if($DEBUG2);

my $num_ips = `cat $ips_dir/$ips_file | wc -l` + 0;
print "num: $num_ips\n";
my $num_ips_per_share = ceil($num_ips / $NUM_PART);

for my $i (0 .. $NUM_PART-1) {
    my $start = $i * $num_ips_per_share + 1;
    my $end   = ($i+1) * $num_ips_per_share;
    print "> $start - $end\n";

    my $cmd = "cat $ips_dir/$ips_file | head -$end | tail -$num_ips_per_share > $ips_dir/$ips_file.$i.txt";
    `$cmd`;

    $cmd = "sed 's/INDEX/$i/g; s/ALL_IPS/$ips_file/g;' update_geo_asn_table.mother.condor > tmp.update_geo_asn_table.$i.condor";
    `$cmd`;

    $cmd = "condor_submit tmp.update_geo_asn_table.$i.condor";
    `$cmd`;
}




