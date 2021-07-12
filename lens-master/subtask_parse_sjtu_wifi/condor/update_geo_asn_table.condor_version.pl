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
my $READ_SUMMARY = 0;
my $READ_IPS     = 1;


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
my $ips_file; #     = "all_ips.txt";

my $index;

my %ip_info = ();
my %invalid_info = ();

my %new_ip_info = ();
my %new_invalid_info = ();


#############
# check input
#############
if(@ARGV != 2) {
    print "wrong number of input: ".@ARGV."\n";
    exit;
}
$index = $ARGV[0];
$ips_file = $ARGV[1];


#############
# Main starts
#############

#############
# read geo asn table
#############
if($READ_TABLE) {
    print "read geo asn table\n" if($DEBUG2);

    open FH, "$table_dir/$table_file" or die $!;
    while(<FH>) {
        chomp;
        print "- ".$_."\n" if($DEBUG4);

        my ($ip, $lat, $lng, $asn, $bgp_prefix, $country_code, $country_name, $region_code, $region_name, $city, $zip, $area, $metro, $registry) = split(/, /, $_);

        if($DEBUG4) {
            print "ip           = $ip\n";
            print "lat, lng     = ($lat, $lng)\n";
            print "asn          = $asn\n";
            print "bgp prefix   = $bgp_prefix\n";
            print "country code = $country_code\n";
            print "country name = $country_name\n";
            print "region code  = $region_code\n";
            print "region_name  = $region_name\n";
            print "city         = $city\n";
            print "zip          = $zip\n";
            print "area         = $area\n";
            print "metro        = $metro\n";
            print "registry     = $registry\n\n";
        }

        $ip_info{IP}{$ip}{LAT} = $lat;
        $ip_info{IP}{$ip}{LNG} = $lng;
        $ip_info{IP}{$ip}{ASN} = $asn;
        $ip_info{IP}{$ip}{BGP_PREFIX} = $bgp_prefix;
        $ip_info{IP}{$ip}{COUNTRY_CODE} = $country_code;
        $ip_info{IP}{$ip}{COUNTRY_NAME} = $country_name;
        $ip_info{IP}{$ip}{REGION_CODE} = $region_code;
        $ip_info{IP}{$ip}{REGION_NAME} = $region_name;
        $ip_info{IP}{$ip}{CITY} = $city;
        $ip_info{IP}{$ip}{ZIP} = $zip;
        $ip_info{IP}{$ip}{AREA} = $area;
        $ip_info{IP}{$ip}{METRO} = $metro;
        $ip_info{IP}{$ip}{REGISTRY} = $registry;
    }
    close FH;
}


#############
# read invalid IPs
#############
if($READ_INVALID) {
    print "read invalid IPs\n" if($DEBUG2);

    open FH, "$invalid_dir/$invalid_file" or die $!;
    while(<FH>) {
        chomp;
        
        my $ip = $_;
        next unless($ip =~ /\d+\.\d+\.\d+\.\d+/);

        print "- ".$ip."\n" if($DEBUG7);
        $invalid_info{IP}{$ip} = 1;
    }
    close FH;
}



#############
## read ip_info.txt
#############
if($READ_SUMMARY) {
    print "read summary of ip info\n" if($DEBUG2);

    open FH, "$sum_ip_dir/$sum_ip_info" or die $!;
    while(<FH>) {
        chomp;
        print "- ".$_."\n" if($DEBUG0);

        my @ret = split(/, /, $_);
        my ($ip, $lat, $lng, $asn, $bgp_prefix, $country_code, $country_name, $region_code, $region_name, $city, $zip, $area, $metro, $registry) = @ret[0, 2..4, 9..18];

        next if(exists $ip_info{IP}{$ip});
        next if(exists $invalid_info{IP}{$ip});


        if($DEBUG5) {
            print "ip           = $ip\n";
            print "lat, lng     = ($lat, $lng)\n";
            print "asn          = $asn\n";
            print "bgp prefix   = $bgp_prefix\n";
            print "country code = $country_code\n";
            print "country name = $country_name\n";
            print "region code  = $region_code\n";
            print "region_name  = $region_name\n";
            print "city         = $city\n";
            print "zip          = $zip\n";
            print "area         = $area\n";
            print "metro        = $metro\n";
            print "registry     = $registry\n\n";
        }

        $ip_info{IP}{$ip}{LAT} = $lat;
        $ip_info{IP}{$ip}{LNG} = $lng;
        $ip_info{IP}{$ip}{ASN} = $asn;
        $ip_info{IP}{$ip}{BGP_PREFIX} = $bgp_prefix;
        $ip_info{IP}{$ip}{COUNTRY_CODE} = $country_code;
        $ip_info{IP}{$ip}{COUNTRY_NAME} = $country_name;
        $ip_info{IP}{$ip}{REGION_CODE} = $region_code;
        $ip_info{IP}{$ip}{REGION_NAME} = $region_name;
        $ip_info{IP}{$ip}{CITY} = $city;
        $ip_info{IP}{$ip}{ZIP} = $zip;
        $ip_info{IP}{$ip}{AREA} = $area;
        $ip_info{IP}{$ip}{METRO} = $metro;
        $ip_info{IP}{$ip}{REGISTRY} = $registry;
    }
    close FH;
}


#############
## read ips
#############
if($READ_IPS) {
    print "read ips\n" if($DEBUG2);

    open FH, "$ips_dir/$ips_file.$index.txt" or die $!;
    my $cnt = 0;
    while(<FH>) {
        chomp;
        
        my $ip = $_;
        next unless($ip =~ /\d+\.\d+\.\d+\.\d+/);

        print "- ".$ip."\n" if($DEBUG6);


        ###################
        ## skip known IPs
        ###################
        next if(exists $new_ip_info{IP}{$ip});
        next if(exists $new_invalid_info{IP}{$ip});

        if(exists $ip_info{IP}{$ip}) {
            $new_ip_info{IP}{$ip} = $ip_info{IP}{$ip};
            next;
        }
        if(exists $invalid_info{IP}{$ip}) {
            $new_invalid_info{IP}{$ip} = $invalid_info{IP}{$ip};
            next;
        }


        ###################
        ## ip2geo
        ###################
        my ($ret_ip, $country_code, $country_name, $region_code, $region_name, $city, $zip, $lat, $lng, $metro_code, $area_code) = IPTool::ip2geo($ip);
        $lat += 0; $lng += 0;

        print "  geo: ".join("||", ($ret_ip, $country_code, $country_name, $region_code, $region_name, $city, $zip, $lat, $lng, $metro_code, $area_code) )."\n" if($DEBUG6);
        

        ###################
        ## ip2as
        ###################
        my ($asn, $tmp, $bgp_prefix, $country, $registry) = IPTool::ip2asn($ip, "");
        print "  as: ".join("||", ($asn, $bgp_prefix, $country, $registry))."\n" if($DEBUG6);


        ## check if this IP is valid
        if( ($lat != 0 or $lng != 0) and $asn ne "NA") {
            ## valid
            $new_ip_info{IP}{$ip}{LAT} = $lat;
            $new_ip_info{IP}{$ip}{LNG} = $lng;
            $new_ip_info{IP}{$ip}{ASN} = $asn;
            $new_ip_info{IP}{$ip}{BGP_PREFIX} = $bgp_prefix;
            $new_ip_info{IP}{$ip}{COUNTRY_CODE} = $country_code;
            $new_ip_info{IP}{$ip}{COUNTRY_NAME} = $country_name;
            $new_ip_info{IP}{$ip}{REGION_CODE} = $region_code;
            $new_ip_info{IP}{$ip}{REGION_NAME} = $region_name;
            $new_ip_info{IP}{$ip}{CITY} = $city;
            $new_ip_info{IP}{$ip}{ZIP} = $zip;
            $new_ip_info{IP}{$ip}{AREA} = $area_code;
            $new_ip_info{IP}{$ip}{METRO} = $metro_code;
            $new_ip_info{IP}{$ip}{REGISTRY} = $registry;
            print ".";

            $cnt ++;
            if($cnt % 2000 == 0) {
                $cnt = 0;

                print "\nupdate table..\n";
                #############
                ## update geo as table
                #############
                print "update geo as table\n" if($DEBUG2);
                open FH2, "> $table_dir/$table_file.$index.txt" or die $!;
                foreach my $ip (sort {$a cmp $b} (keys %{ $new_ip_info{IP} })) {
                    print FH2 join(", ", ($ip,
                                         $new_ip_info{IP}{$ip}{LAT},
                                         $new_ip_info{IP}{$ip}{LNG},
                                         $new_ip_info{IP}{$ip}{ASN},
                                         $new_ip_info{IP}{$ip}{BGP_PREFIX},
                                         $new_ip_info{IP}{$ip}{COUNTRY_CODE},
                                         $new_ip_info{IP}{$ip}{COUNTRY_NAME},
                                         $new_ip_info{IP}{$ip}{REGION_CODE},
                                         $new_ip_info{IP}{$ip}{REGION_NAME},
                                         $new_ip_info{IP}{$ip}{CITY},
                                         $new_ip_info{IP}{$ip}{ZIP},
                                         $new_ip_info{IP}{$ip}{AREA},
                                         $new_ip_info{IP}{$ip}{METRO},
                                         $new_ip_info{IP}{$ip}{REGISTRY}) )."\n";
                }
                close FH2;


                #############
                ## update invalid IPs
                #############
                print "update invalid IPs\n" if($DEBUG2);
                open FH2, "> $invalid_dir/$invalid_file.$index.txt" or die $!;
                foreach my $ip (sort {$a cmp $b} (keys %{ $new_invalid_info{IP} })) {
                    print FH2 "$ip\n";
                }
                close FH2;
            }
        }
        else {
            print "x";
            ## invalid
            if($asn eq "NA") {
                ## ensure the ip is invalid
                $cnt ++;
                $new_invalid_info{IP}{$ip} = 1;
            }
        }
    }
    close FH;
}


#############
## update geo as table
#############
print "update geo as table\n" if($DEBUG2);
open FH, "> $table_dir/$table_file.$index.txt" or die $!;
foreach my $ip (sort {$a cmp $b} (keys %{ $new_ip_info{IP} })) {
    print FH join(", ", ($ip,
                         $new_ip_info{IP}{$ip}{LAT},
                         $new_ip_info{IP}{$ip}{LNG},
                         $new_ip_info{IP}{$ip}{ASN},
                         $new_ip_info{IP}{$ip}{BGP_PREFIX},
                         $new_ip_info{IP}{$ip}{COUNTRY_CODE},
                         $new_ip_info{IP}{$ip}{COUNTRY_NAME},
                         $new_ip_info{IP}{$ip}{REGION_CODE},
                         $new_ip_info{IP}{$ip}{REGION_NAME},
                         $new_ip_info{IP}{$ip}{CITY},
                         $new_ip_info{IP}{$ip}{ZIP},
                         $new_ip_info{IP}{$ip}{AREA},
                         $new_ip_info{IP}{$ip}{METRO},
                         $new_ip_info{IP}{$ip}{REGISTRY}) )."\n";
}
close FH;


#############
## update invalid IPs
#############
print "update invalid IPs\n" if($DEBUG2);
open FH, "> $invalid_dir/$invalid_file.$index.txt" or die $!;
foreach my $ip (sort {$a cmp $b} (keys %{ $new_invalid_info{IP} })) {
    print FH "$ip\n";
}
close FH;


