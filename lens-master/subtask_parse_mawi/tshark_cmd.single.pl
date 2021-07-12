#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.10.07 @ UT Austin
##
## - input:
##
## - output:
##   bz2 file w/ format:
##      <frame num> <time> <mac src> <mac dst> <frame length> <ip src> <ip dst>
##
## - e.g.
##     perl tshark_cmd.single.pl 201001141400.dump
##
##########################################

use strict;

# use DateTime::Format::Strptime;
# use DateTime;

use lib "../utils";
use IPTool;

#############
# Debug
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1; ## print progress
my $DEBUG3 = 1; ## print output


#############
## Test
#############
if(0) {
    my $ip = "111.186.61.118";
    # my $ip = "10.0.0.1";

    ## ip2geo
    my ($ret_ip, $country_code, $country_name, $region_code, $region_name, $city, $zip, $lat, $lng, $metro_code, $area_code) = IPTool::ip2geo($ip);
    print join("|", ($ret_ip, $country_code, $country_name, $region_code, $region_name, $city, $zip, $lat, $lng, $metro_code, $area_code) )."\n";
    
    ## ip2as
    my $now = DateTime->now(time_zone => 'local');
    # print $now."\n";
    my $format = DateTime::Format::Strptime->new( pattern => '%Y-%m-%d %H-%M-%S %Z' );
    # print $format->format_datetime($now)."\n";
    my ($asn, $tmp, $bgp_prefix, $country, $registry) = IPTool::ip2asn($ip, $format->format_datetime($now));
    print join("|", ($asn, $bgp_prefix, $country, $registry))."\n";
    exit;
}


#############
# Constants
#############


#############
# Variables
#############
my $input_dir = "../data/mawi/pcap";
my $output_dir = "../processed_data/subtask_parse_mawi/text";
# my $matrix_type;


#############
# check input
#############
if(@ARGV != 1) {
    print "wrong number of input: ".@ARGV."\n";
    exit;
}
my $file = $ARGV[0];


#############
# Main starts
#############

#############
# check if directories exist
#############
die "pcap trace directory does not exist: $input_dir\n" unless(-e $input_dir);
die "output directory does not exist: $output_dir\n" unless(-e $output_dir);


print $file."\n" if($DEBUG2);

my $cmd;
$cmd = "tshark -r \"$input_dir/$file\" -T fields -E separator=\"|\" -e frame.number -e frame.time -e eth.src -e eth.dst -e frame.len -e ip.src -e ip.dst";
# $cmd = "tshark -r \"$input_dir/$file\" -T fields -E separator=, -e eth.src | uniq | wc -l";
print "  ".$cmd."\n" if($DEBUG1);
`$cmd > "$output_dir/$file.txt"`;
# last;


$cmd = "bzip2 \"$output_dir/$file.txt\"";
`$cmd`;

$cmd = "rm \"$input_dir/$file\"";
`$cmd`;


