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
my $input_trace_dir = "/u/yichao/anomaly_compression/condor_data/subtask_parse_sjtu_wifi/text";


#############
# check input
#############
if(@ARGV != 0) {
    print "wrong number of input: ".@ARGV."\n";
    exit;
}


#############
# Main starts
#############

#############
## for each file, get IP info
#############
print "read the trace in bz2: $input_trace_dir\n" if($DEBUG2);

my @files = ();
my $index = 0;
opendir(DIR, "$input_trace_dir") or die $!;
while (my $file = readdir(DIR)) {
    next if($file =~ /^\.+/);  ## don't show "." and ".."
    next if(-d "$input_trace_dir/$file");  ## don't show directories
    next unless($file =~ /bz2$/);

    my $full_path = "$input_trace_dir/$file";
    $full_path =~ s{\/}{\\\/}g;
    print $full_path."\n";

    my $cmd = "sed 's/FULL_PATH/$full_path/g; s/INDEX/$index/g;' gen_trace_summary.mother.condor > tmp.gen_trace_summary.$index.condor";
    `$cmd`;

    $cmd = "condor_submit tmp.gen_trace_summary.$index.condor";
    `$cmd`;

    $index ++;
    # last if($index > 0);
}


