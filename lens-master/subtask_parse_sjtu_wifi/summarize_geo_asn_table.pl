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
# Constants
#############


#############
# Variables
#############
my $input_dir  = "../condor_data/subtask_parse_sjtu_wifi/ip_info";
my $output_dir = "../processed_data/subtask_parse_sjtu_wifi/ip_info";

my $table_file   = "ip_geo_as_table.txt";
my $invalid_file = "ip_geo_as_invalid.txt";

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
## search all table files
#############
print "search all table files\n" if($DEBUG2);

opendir(DIR, "$input_dir") or die $!;
while (my $file = readdir(DIR)) {
    next if($file =~ /^\.+/);  ## don't show "." and ".."
    next if(-d "$input_dir/$file");  ## don't show directories
    next unless($file =~ /$table_file/);

    print "$file\n";
    

    #############
    ## open file
    #############
    my %tmp = IPTool::read_geo_as_table("$input_dir/$file");
    foreach my $ip (keys %{ $tmp{IP} }) {
        next if(exists $ip_info{IP}{$ip});

        $ip_info{IP}{$ip} = $tmp{IP}{$ip};
    }
    
    print "  ".scalar(keys %{ $tmp{IP} })."/".scalar(keys %{ $ip_info{IP} })."\n";
}
closedir(DIR);

open FH, "> $output_dir/$table_file" or die $!;
foreach my $ip (sort {$a cmp $b} (keys %{ $ip_info{IP} })) {
    print FH join(", ", ($ip,
                         $ip_info{IP}{$ip}{LAT},
                         $ip_info{IP}{$ip}{LNG},
                         $ip_info{IP}{$ip}{ASN},
                         $ip_info{IP}{$ip}{BGP_PREFIX},
                         $ip_info{IP}{$ip}{COUNTRY_CODE},
                         $ip_info{IP}{$ip}{COUNTRY_NAME},
                         $ip_info{IP}{$ip}{REGION_CODE},
                         $ip_info{IP}{$ip}{REGION_NAME},
                         $ip_info{IP}{$ip}{CITY},
                         $ip_info{IP}{$ip}{ZIP},
                         $ip_info{IP}{$ip}{AREA},
                         $ip_info{IP}{$ip}{METRO},
                         $ip_info{IP}{$ip}{REGISTRY}) )."\n";
}
close FH;



#############
## search all invalid IP files
#############
print "search all invalid IP files\n" if($DEBUG2);

opendir(DIR, "$input_dir") or die $!;
while (my $file = readdir(DIR)) {
    next if($file =~ /^\.+/);  ## don't show "." and ".."
    next if(-d "$input_dir/$file");  ## don't show directories
    next unless($file =~ /$invalid_file/);

    print "$file\n";
    

    #############
    ## open file
    #############
    # my %tmp = IPTool::read_geo_as_table("$input_dir/$file");
    open FH, "$input_dir/$file" or die $!;
    while(<FH>) {
        chomp;
        
        my $ip = $_;
        next unless($ip =~ /\d+\.\d+\.\d+\.\d+/);

        print "- ".$ip."\n" if($DEBUG0);
        $invalid_info{IP}{$ip} = 1;
    }
    close FH;

    print "  ".scalar(keys %{ $invalid_info{IP} })."\n";
}
closedir(DIR);

open FH, "> $output_dir/$invalid_file" or die $!;
foreach my $ip (sort {$a cmp $b} (keys %{ $invalid_info{IP} })) {
    print FH "$ip\n";
}
close FH;

