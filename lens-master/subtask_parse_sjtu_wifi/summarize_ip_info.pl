#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.10.27 @ UT Austin
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
my $DEBUG4 = 0; ## parse AP name
my $DEBUG5 = 0; ## parse RADIUS account info
my $DEBUG6 = 1; ## parse ip info


#############
# Constants
#############


#############
# Variables
#############
my $input_dir        = "../processed_data/subtask_parse_sjtu_wifi/ip_info";
my $input_radius_dir = "../data/sjtu_wifi/RADIUS";
my $input_ap_dir     = "../data/sjtu_wifi";
my $output_dir       = "../processed_data/subtask_parse_sjtu_wifi/ip_info";

my $output_file = "ip_info.txt";
my $ap_file     = "AP_Location.csv";

my %ip_info = ();  ## IP - MAC - [TX | RX | TX_CNT | RX_CNT | LAT | LNG | ASN | BGP_PREFIX | COUNTRY_CODE | COUNTRY_NAME | REGION_CODE | REGION_NAME | CITY | ZIP | AREA | METRO | REGISTRY]
my %account_info = ();
my %ap_info = ();

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
## Read AP location
#############
print "Read AP location\n" if($DEBUG2);

open FH, "$input_ap_dir/$ap_file" or die $!;
while(<FH>) {
    chomp;
    print $_."\n" if($DEBUG0);

    my @ret = split(",", $_);
    my $ap_mac  = $ret[0];
    my $ap_name = $ret[1];

    $ap_mac =~ s{\r}{}g;
    $ap_name =~ s{\r}{}g;

    if($DEBUG4) {
        print "ap_mac : $ap_mac\n";
        print "ap_name: $ap_name\n\n";
    }

    $ap_info{AP_MAC}{$ap_mac}{AP_NAME} = $ap_name;
}
close FH;


#############
## Read RADIUS account data
#############
print "Read RADIUS account data\n" if($DEBUG2);

my @files;
opendir(DIR, "$input_radius_dir") or die $!;
while (my $file = readdir(DIR)) {
    next if($file =~ /^\.+/);  ## don't show "." and ".."
    next if(-d "$input_radius_dir/$file");  ## don't show directories

    # print "$file\n";
    push(@files, $file);
}
closedir(DIR);

foreach my $file (sort {$a cmp $b} @files) {
    print "$input_radius_dir/$file\n" if($DEBUG2);

    #############
    ## parse the account file
    #############
    open FH, "$input_radius_dir/$file" or die $!;
    while(<FH>) {
        chomp;
        print "- ".$_."\n" if($DEBUG0);

        my @ret = split(/,/, $_);
        my $user_ip  = $ret[15-1]; ## Framed-IP-Address ; Login-IP-Host??
        my $user_mac = $ret[5-1];  ## Calling-Station-Id
        my $ap_ip    = $ret[17-1]; ## NAS-IP-Address
        my $ap_mac   = $ret[19-1]; ## Called-Station-Id
        # my $download = $ret[12-1]; ## Acct-Output-Octets
        # my $upload   = $ret[11-1]; ## Acct-Input-Octets 

        $user_mac =~ s{-}{:}g;
        $user_mac =~ s{\r}{}g;
        $ap_mac =~ s{-}{:}g;
        $ap_mac =~ s{\r}{}g;
        next unless($user_ip =~ /\d+\.\d+\.\d+\.\d+/);

        $account_info{USER_IP}{$user_ip}{USER_MAC} = $user_mac;
        $account_info{USER_IP}{$user_ip}{AP_IP}    = $ap_ip;
        $account_info{USER_IP}{$user_ip}{AP_MAC}   = $ap_mac;
        $account_info{USER_IP}{$user_ip}{AP_NAME}  = $ap_info{AP_MAC}{$ap_mac}{AP_NAME};

        if($DEBUG5) {
            print "user ip : \"$user_ip\"\n";
            print "user mac: \"$user_mac\"\n";
            print "ap ip   : \"$ap_ip\"\n";
            print "ap mac  : \"$ap_mac\"\n";
            print "ap_name : \"".$account_info{USER_IP}{$user_ip}{AP_NAME}."\"\n\n";
            # print "download: $download\n";
            # print "upload  : $upload\n\n";
        }
    }
    close FH;
}


#############
## Read IP Info
#############
print "Read IP info\n" if($DEBUG2);

@files = ();
opendir(DIR, "$input_dir") or die $!;
while (my $file = readdir(DIR)) {
    next if($file =~ /^\.+/);  ## don't show "." and ".."
    next if(-d "$input_dir/$file");  ## don't show directories

    # print "$file\n";
    push(@files, $file);
}
closedir(DIR);


foreach my $file (sort {$a cmp $b} @files) {
    print "$input_dir/$file\n" if($DEBUG2);

    #############
    ## open the file
    #############
    open FH, "$input_dir/$file" or die $!;
    while (<FH>) {
        chomp;
        print "- ".$_."\n" if($DEBUG0);
        
        my ($ip, $mac, $lat, $lng, $asn, $rx_cnt, $rx, $tx_cnt, $tx, $bgp_prefix, $country_code, $country_name, $region_code, $region_name, $city, $zip, $area, $metro, $registry) = split(", ", $_);
        $lat += 0; $lng += 0; $rx_cnt += 0; $rx += 0; $tx_cnt += 0; $tx += 0;

        if($DEBUG6) {
            # print "  > ".join("|", ($ip, $mac, $lat, $lng, $asn, $rx_cnt, $rx, $tx_cnt, $tx, $bgp_prefix, $country_code, $country_name, $region_code, $region_name, $city, $zip, $area, $metro, $registry))."\n";
            print "> $ip ($mac): ($lat, $lng), rx=$rx ($rx_cnt), tx=$tx ($tx_cnt), $asn, $bgp_prefix\n";
            if(exists $account_info{USER_IP}{$ip}) {
                print "  user mac=".
                        $account_info{USER_IP}{$ip}{USER_MAC}.", AP=".
                        $account_info{USER_IP}{$ip}{AP_IP}." (".
                        $account_info{USER_IP}{$ip}{AP_MAC}."): ".
                        $account_info{USER_IP}{$ip}{AP_NAME}."\n";
            }
            
       }
        


        if(exists $ip_info{IP}{$ip}) {
            $ip_info{IP}{$ip}{RX_CNT} += $rx_cnt;
            $ip_info{IP}{$ip}{RX} += $rx;
            $ip_info{IP}{$ip}{TX_CNT} += $tx_cnt;
            $ip_info{IP}{$ip}{TX} += $tx;
        }
        else {
            $ip_info{IP}{$ip}{RX_CNT} = $rx_cnt;
            $ip_info{IP}{$ip}{RX} = $rx;
            $ip_info{IP}{$ip}{TX_CNT} = $tx_cnt;
            $ip_info{IP}{$ip}{TX} = $tx;

            $ip_info{IP}{$ip}{MAC} = $mac;
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
    }
    close FH;
}


############
## output summary
############
open FH, "> $output_dir/$output_file" or die $!;
foreach my $this_ip (sort {$a cmp $b} (keys %{ $ip_info{IP} })) {
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
