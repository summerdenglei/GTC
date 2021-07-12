#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.12.27 @ UT Austin
##
## - input:
##   @top_k: only select top K IPs
##
## - output:
##
## - e.g.
##      perl sort_ips.pl 100
##
##########################################

use strict;
use Getopt::Long;

use lib "../utils";

use IPTool;
use MyUtil;

#############
# Debug
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1; ## print progress
my $DEBUG3 = 1; ## print output
my $DEBUG4 = 0; ## read trace summary
my $DEBUG5 = 1; ## sort


#############
# Constants
#############


#############
# Variables
#############
my $input_dir  = "../processed_data/subtask_parse_mawi/text_summary";
my $output_dir = "../processed_data/subtask_parse_mawi/sort_ips";
my $load_dir   = "../processed_data/subtask_parse_mawi/sort_ips/ip_load";

my $output_name  = "sort_ips";

my $top_k;

my %ip_info = ();  ## SRC - LOAD


#############
# check input
#############
if(@ARGV != 1) {
    print "wrong number of input: ".@ARGV."\n";
    print "  perl sort_ips.pl 100\n";
    exit;
}
$top_k = $ARGV[0] + 0;

if($DEBUG2) {
    print "top K: $top_k\n";
}


#############
# Main starts
#############

#############
## read trace dir
#############
print "read trace dir\n" if($DEBUG2);

opendir(DIR, "$input_dir") or die $!;
while (my $file = readdir(DIR)) {
    next if($file =~ /^\.+/);  ## don't show "." and ".."
    next if(-d "$input_dir/$file");  ## don't show directories
    
    print "  $file\n" if($DEBUG2);


    #############
    ## read trace summary
    #############
    print "read trace summary\n" if($DEBUG2);
    # open FH, "$input_dir/$file" or die $!;
    open FH, "bzcat $input_dir/$file |" or die $!;
    while(<FH>) {
        chomp;
        next if($_ =~ /TIME/);

        my ($src, $dst, $load) = split(/, /, $_);
        $load += 0;

        print "  '$src' -> '$dst': $load\n" if($DEBUG4);
        $ip_info{"$src-$dst"} += $load;
    }
    close FH;
    
}
closedir(DIR);


#############
## sort by load
#############
print "sort by load\n" if($DEBUG2);

my @sort_flows = sort { $ip_info{$b} <=> $ip_info{$a} } keys(%ip_info);
my @sort_loads = @ip_info{@sort_flows};
my %selected_ips = ();

foreach my $k (0 .. $top_k-1) {
    print "  ".$sort_flows[$k]." -> ".$sort_loads[$k]."\n" if($DEBUG5);

    my ($src, $dst) = split(/-/, $sort_flows[$k]);

    $selected_ips{IP}{$src} = 1;
    $selected_ips{IP}{$dst} = 1;

    $selected_ips{SRC}{$src} = 1;
    $selected_ips{DST}{$dst} = 1;
}

if($DEBUG3) {
    print "  # IPs : ".scalar(keys %{ $selected_ips{IP} })."\n";
    print "  # SRCs: ".scalar(keys %{ $selected_ips{SRC} })."\n";
    print "  # DSTs: ".scalar(keys %{ $selected_ips{DST} })."\n";
}


#############
## output sort ip
#############
print "output sort ip\n" if($DEBUG2);

open FH, "> $output_dir/$output_name.top$top_k.txt" or die $!;
my $ix = 0;
foreach my $src (keys %{ $selected_ips{SRC} }) {
    print FH "0, $src, $ix\n";
    $ix ++;
}

$ix = 0;
foreach my $dst (keys %{ $selected_ips{DST} }) {
    print FH "1, $dst, $ix\n";
    $ix ++;
}
close FH;


#############
## output flow loading
#############
print "output flow loading\n" if($DEBUG2);

open FH, "> $load_dir/$output_name.top$top_k.txt" or die $!;
foreach my $i (0 .. @sort_flows-1) {
    print FH "\"".$sort_flows[$i]."\", ".$sort_loads[$i]."\n";
}
close FH;





