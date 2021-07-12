#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.10.27 @ UT Austin
##
## - input:
##     file_fullpath
##
## - output:
##
## - e.g.
##
##########################################

use strict;
use DateTime::Format::Strptime;

use lib "../utils";
use IPTool;

#############
# Debug
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1; ## print progress
my $DEBUG3 = 1; ## print output
my $DEBUG4 = 1; ## parse file


#############
# Constants
#############


#############
# Variables
#############
my $input_dir   = "../processed_data/subtask_parse_sjtu_wifi/text";
my $table_dir   = "../processed_data/subtask_parse_sjtu_wifi/ip_info";
my $invalid_dir = "../processed_data/subtask_parse_sjtu_wifi/ip_info";
my $output_dir  = "../processed_data/subtask_parse_sjtu_wifi/ip_info";

my $table_file   = "ip_geo_as_table.txt";
my $invalid_file = "ip_geo_as_invalid.txt";

my $file_fullpath;
my $filename;

my %ip_info = ();  ## IP - MAC - [TX | RX | TX_CNT | RX_CNT | LAT | LNG | ASN | BGP_PREFIX | COUNTRY_CODE | COUNTRY_NAME | REGION_CODE | REGION_NAME | CITY | ZIP | AREA | METRO | REGISTRY]

my %ip_table_info = ();
my %invalid_info = ();

#############
# check input
#############
if(@ARGV != 1) {
    print "wrong number of input: ".@ARGV."\n";
    exit;
}
$file_fullpath = $ARGV[0];
if($file_fullpath =~ /(.+)\/(.+)/) {
    $input_dir = $1;
    $filename = $2;
}
if($DEBUG2) {
    print "input dir: $input_dir\n";
    print "input file: $filename\n";
}


#############
# Main starts
#############
my $filename_parser = DateTime::Format::Strptime->new(
    pattern => '%B %d %H-%M-%S %Y',
    on_error => 'croak',
);
my $text_parser = DateTime::Format::Strptime->new(
    pattern => '%B %d, %Y %H:%M:%S.%N',
    on_error => 'croak',
);


#############
# read IP GEO/AS Info
#############
print "read IP GEO/AS Info\n" if($DEBUG2);
%ip_table_info = IPTool::read_geo_as_table("$table_dir/$table_file");


#############
# read invalid IPs
#############
print "read invalid IPs\n" if($DEBUG2);

open FH, "$invalid_dir/$invalid_file" or die $!;
while(<FH>) {
    chomp;
    
    my $ip = $_;
    next unless($ip =~ /\d+\.\d+\.\d+\.\d+/);

    print "- ".$ip."\n" if($DEBUG0);
    $invalid_info{IP}{$ip} = 1;
}
close FH;


#############
## for each file, get IP info
#############
foreach my $file ($filename) {
    print "$input_dir/$file\n" if($DEBUG2);

    my $dt = $filename_parser->parse_datetime($file);
    print "  ".$dt->year()."/".$dt->month()."/".$dt->day()." ".$dt->hour().":".$dt->minute().":".$dt->second()."\n" if($DEBUG1);


    #############
    ## parse the file
    #############
    print "  parse the file\n" if($DEBUG2);

    # open FH, "$input_dir/$file" or die $!;
    open FH, "| bzcat $input_dir/$file" or die $!;
    while(<FH>) {
        chomp;
        my ($ind, $time, $mac_src, $mac_dst, $len, $src, $dst) = split(/\|/, $_);

        ## parse time
        print "\n    - TIME: $time\n" if($DEBUG4);
        my $pkt_dt = $text_parser->parse_datetime($time);
        print "      = ".$pkt_dt->year()."/".$pkt_dt->month()."/".$pkt_dt->day()." ".$pkt_dt->hour().":".$pkt_dt->minute().":".$pkt_dt->second()."+0.".$pkt_dt->nanosecond()."\n" if($DEBUG4);


        ## parse len
        $len += 0;
        print "    - LEN: $len\n" if($DEBUG4);
        print "    - SRC MAC: $mac_src\n" if($DEBUG4);
        print "    - DST MAC: $mac_dst\n" if($DEBUG4);


        ## parse src
        print "    - SRC: $src\n" if($DEBUG4);
        my ($src_ip, $src_country_code, $src_country_name, $src_region_code, $src_region_name, $src_city, $src_zip, $src_lat, $src_lng, $src_metro_code, $src_area_code, $src_asn, $src_bgp_prefix, $src_registry);
        my $valid = 0;
        my @srcs = split(/,/, $src);
        foreach my $this_src (@srcs) {
            if(exists $ip_info{IP}{$this_src}) {
                unless(exists $ip_info{IP}{$this_src}{INVALID}) {
                    $valid = 1;
                    $src_ip = $this_src;
                    last;
                }
                next;
            }
            
            print "      = $this_src\n" if($DEBUG4);

            # ## ip2geo
            # my ($ret_ip, $country_code, $country_name, $region_code, $region_name, $city, $zip, $lat, $lng, $metro_code, $area_code) = IPTool::ip2geo($this_src);
            # $lat += 0; $lng += 0;

            # print "        geo: ".join("|", ($ret_ip, $country_code, $country_name, $region_code, $region_name, $city, $zip, $lat, $lng, $metro_code, $area_code) )."\n" if($DEBUG4);
            
            # ## ip2as
            # my $format = DateTime::Format::Strptime->new( pattern => '%Y-%m-%d %H-%M-%S %Z' );
            # my ($asn, $tmp2, $bgp_prefix, $country, $registry) = IPTool::ip2asn($this_src, $format->format_datetime($pkt_dt));
            # print "        as: ".join("|", ($asn, $bgp_prefix, $country, $registry))."\n" if($DEBUG4);


            # ## check if this IP is valid
            # if( ($lat != 0 or $lng != 0) and $asn ne "NA") {
            #     $valid = 1;
            #     ($src_ip, $src_country_code, $src_country_name, $src_region_code, $src_region_name, $src_city, $src_zip, $src_lat, $src_lng, $src_metro_code, $src_area_code, $src_asn, $src_bgp_prefix, $src_registry) = ($this_src, $country_code, $country_name, $region_code, $region_name, $city, $zip, $lat, $lng, $metro_code, $area_code, $asn+0, $bgp_prefix, $registry);
            # }
            # else {
            #     if($asn eq "NA") {
            #         $ip_info{IP}{$this_src}{INVALID} = 1;
            #     }
            # }

            if(exists $ip_table_info{IP}{$this_src}) {
                $valid = 1;
                ($src_ip, $src_lat, $src_lng, $src_asn, $src_bgp_prefix, $src_country_code, $src_country_name, $src_region_code, $src_region_name, $src_city, $src_zip, $src_area_code, $src_metro_code, $src_registry) = ($this_src, $ip_table_info{IP}{$this_src}{LAT}, $ip_table_info{IP}{$this_src}{LNG}, $ip_table_info{IP}{$this_src}{ASN}, $ip_table_info{IP}{$this_src}{BGP_PREFIX}, $ip_table_info{IP}{$this_src}{COUNTRY_CODE}, $ip_table_info{IP}{$this_src}{COUNTRY_NAME}, $ip_table_info{IP}{$this_src}{REGION_CODE}, $ip_table_info{IP}{$this_src}{REGION_NAME}, $ip_table_info{IP}{$this_src}{CITY}, $ip_table_info{IP}{$this_src}{ZIP}, $ip_table_info{IP}{$this_src}{AREA}, $ip_table_info{IP}{$this_src}{METRO}, $ip_table_info{IP}{$this_src}{REGISTRY});
                last;
            }
            else {
                $ip_info{IP}{$this_src}{INVALID} = 1;
            }

        }
        next unless($valid);


        ## parse dst
        print "    - DST: $dst\n" if($DEBUG4);
        my ($dst_ip, $dst_country_code, $dst_country_name, $dst_region_code, $dst_region_name, $dst_city, $dst_zip, $dst_lat, $dst_lng, $dst_metro_code, $dst_area_code, $dst_asn, $dst_bgp_prefix, $dst_registry);
        $valid = 0;
        my @dsts = split(/,/, $dst);
        foreach my $this_dst (@dsts) {
            if(exists $ip_info{IP}{$this_dst}) {
                unless(exists $ip_info{IP}{$this_dst}{INVALID}) {
                    $valid = 1;
                    $dst_ip = $this_dst;
                    last;
                }
                next;
            }
            
            print "      = $this_dst\n" if($DEBUG4);

            # ## ip2geo
            # my ($ret_ip, $country_code, $country_name, $region_code, $region_name, $city, $zip, $lat, $lng, $metro_code, $area_code) = IPTool::ip2geo($this_dst);
            # $lat += 0; $lng += 0;

            # print "        geo: ".join("|", ($ret_ip, $country_code, $country_name, $region_code, $region_name, $city, $zip, $lat, $lng, $metro_code, $area_code) )."\n" if($DEBUG4);
            
            # ## ip2as
            # my $format = DateTime::Format::Strptime->new( pattern => '%Y-%m-%d %H-%M-%S %Z' );
            # my ($asn, $tmp2, $bgp_prefix, $country, $registry) = IPTool::ip2asn($this_dst, $format->format_datetime($pkt_dt));
            # print "        as: ".join("|", ($asn, $bgp_prefix, $country, $registry))."\n" if($DEBUG4);


            # ## check if this IP is valid
            # if($lat != 0 and $lng != 0 and $asn ne "NA") {
            #     $valid = 1;
            #     ($dst_ip, $dst_country_code, $dst_country_name, $dst_region_code, $dst_region_name, $dst_city, $dst_zip, $dst_lat, $dst_lng, $dst_metro_code, $dst_area_code, $dst_asn, $dst_bgp_prefix, $dst_registry) = ($this_dst, $country_code, $country_name, $region_code, $region_name, $city, $zip, $lat, $lng, $metro_code, $area_code, $asn+0, $bgp_prefix, $registry);
            # }
            # else {
            #     $ip_info{IP}{$this_dst}{INVALID} = 1;
            # }

            if(exists $ip_table_info{IP}{$this_dst}) {
                $valid = 1;
                ($dst_ip, $dst_lat, $dst_lng, $dst_asn, $dst_bgp_prefix, $dst_country_code, $dst_country_name, $dst_region_code, $dst_region_name, $dst_city, $dst_zip, $dst_area_code, $dst_metro_code, $dst_registry) = ($this_dst, $ip_table_info{IP}{$this_dst}{LAT}, $ip_table_info{IP}{$this_dst}{LNG}, $ip_table_info{IP}{$this_dst}{ASN}, $ip_table_info{IP}{$this_dst}{BGP_PREFIX}, $ip_table_info{IP}{$this_dst}{COUNTRY_CODE}, $ip_table_info{IP}{$this_dst}{COUNTRY_NAME}, $ip_table_info{IP}{$this_dst}{REGION_CODE}, $ip_table_info{IP}{$this_dst}{REGION_NAME}, $ip_table_info{IP}{$this_dst}{CITY}, $ip_table_info{IP}{$this_dst}{ZIP}, $ip_table_info{IP}{$this_dst}{AREA}, $ip_table_info{IP}{$this_dst}{METRO}, $ip_table_info{IP}{$this_dst}{REGISTRY});
                last;
            }
            else {
                $ip_info{IP}{$this_dst}{INVALID} = 1;
            }
        }
        next unless($valid);


        ## update ip_info
        ##   IP - MAC - [TX | RX | TX_CNT | RX_CNT | LAT | LNG | ASN | BGP_PREFIX | COUNTRY_CODE | COUNTRY_NAME | REGION_CODE | REGION_NAME | CITY | ZIP | AREA | METRO | REGISTRY]
        $ip_info{IP}{$src_ip}{TX_CNT} += 1;
        $ip_info{IP}{$src_ip}{TX} += ($len/1024/1024);
        unless(exists $ip_info{IP}{$src_ip}{MAC}) {
            $ip_info{IP}{$src_ip}{MAC} = $mac_src;
            $ip_info{IP}{$src_ip}{LAT} = $src_lat;
            $ip_info{IP}{$src_ip}{LNG} = $src_lng;
            $ip_info{IP}{$src_ip}{ASN} = $src_asn;
            $ip_info{IP}{$src_ip}{BGP_PREFIX} = $src_bgp_prefix;
            $ip_info{IP}{$src_ip}{COUNTRY_CODE} = $src_country_code;
            $ip_info{IP}{$src_ip}{COUNTRY_NAME} = $src_country_name;
            $ip_info{IP}{$src_ip}{REGION_CODE} = $src_region_code;
            $ip_info{IP}{$src_ip}{REGION_NAME} = $src_region_name;
            $ip_info{IP}{$src_ip}{CITY} = $src_city;
            $ip_info{IP}{$src_ip}{ZIP} = $src_zip;
            $ip_info{IP}{$src_ip}{AREA} = $src_area_code;
            $ip_info{IP}{$src_ip}{METRO} = $src_metro_code;
            $ip_info{IP}{$src_ip}{REGISTRY} = $src_registry;
        }

        $ip_info{IP}{$dst_ip}{RX_CNT} += 1;
        $ip_info{IP}{$dst_ip}{RX} += ($len/1024/1024);
        unless(exists $ip_info{IP}{$dst_ip}{MAC}) {
            $ip_info{IP}{$dst_ip}{MAC} = $mac_dst;
            $ip_info{IP}{$dst_ip}{LAT} = $dst_lat;
            $ip_info{IP}{$dst_ip}{LNG} = $dst_lng;
            $ip_info{IP}{$dst_ip}{ASN} = $dst_asn;
            $ip_info{IP}{$dst_ip}{BGP_PREFIX} = $dst_bgp_prefix;
            $ip_info{IP}{$dst_ip}{COUNTRY_CODE} = $dst_country_code;
            $ip_info{IP}{$dst_ip}{COUNTRY_NAME} = $dst_country_name;
            $ip_info{IP}{$dst_ip}{REGION_CODE} = $dst_region_code;
            $ip_info{IP}{$dst_ip}{REGION_NAME} = $dst_region_name;
            $ip_info{IP}{$dst_ip}{CITY} = $dst_city;
            $ip_info{IP}{$dst_ip}{ZIP} = $dst_zip;
            $ip_info{IP}{$dst_ip}{AREA} = $dst_area_code;
            $ip_info{IP}{$dst_ip}{METRO} = $dst_metro_code;
            $ip_info{IP}{$dst_ip}{REGISTRY} = $dst_registry;
        }
        if($DEBUG4) {
            print "    > tx: ".$ip_info{IP}{$src_ip}{TX}."\n";
            print "    > rx: ".$ip_info{IP}{$dst_ip}{RX}."\n";
        }

        # last;
    }
    close FH;
    

    open FH, "> $output_dir/$file.ip_info.txt" or die $!;
    foreach my $this_ip (sort {$a cmp $b} (keys %{ $ip_info{IP} })) {
        next if(exists $ip_info{IP}{$this_ip}{INVALID});

        print FH join(", ", ($this_ip,
                             $ip_info{IP}{$this_ip}{MAC},
                             $ip_info{IP}{$this_ip}{LAT},
                             $ip_info{IP}{$this_ip}{LNG},
                             $ip_info{IP}{$this_ip}{ASN},
                             $ip_info{IP}{$this_ip}{RX_CNT}, 
                             $ip_info{IP}{$this_ip}{RX}, 
                             $ip_info{IP}{$this_ip}{TX_CNT}, 
                             $ip_info{IP}{$this_ip}{TX}, 
                             $ip_info{IP}{$this_ip}{BGP_PREFIX},
                             $ip_info{IP}{$this_ip}{COUNTRY_CODE},
                             $ip_info{IP}{$this_ip}{COUNTRY_NAME},
                             $ip_info{IP}{$this_ip}{REGION_CODE},
                             $ip_info{IP}{$this_ip}{REGION_NAME},
                             $ip_info{IP}{$this_ip}{CITY},
                             $ip_info{IP}{$this_ip}{ZIP},
                             $ip_info{IP}{$this_ip}{AREA},
                             $ip_info{IP}{$this_ip}{METRO},
                             $ip_info{IP}{$this_ip}{REGISTRY}) )."\n";
    }
    close FH;
}

