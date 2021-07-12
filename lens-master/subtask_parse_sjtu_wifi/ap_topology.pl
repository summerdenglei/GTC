#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2014.01.05 @ UT Austin
##
## - input:

## - output:
##
## - e.g.
##      perl ap_topology.pl
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


#############
# Constants
#############


#############
# Variables
#############
my $input_trace_dir  = "../processed_data/subtask_parse_sjtu_wifi/text";
my $all_ips_dir      = "../processed_data/subtask_parse_sjtu_wifi/ip_info";
my $table_dir        = "../processed_data/subtask_parse_sjtu_wifi/ip_info";
my $invalid_dir      = "../processed_data/subtask_parse_sjtu_wifi/ip_info";
my $account_dir      = "../data/sjtu_wifi/RADIUS";
my $ap_dir           = "../data/sjtu_wifi";
my $output_dir       = "../processed_data/subtask_parse_sjtu_wifi/sort_ips";

my $table_file   = "ip_geo_as_table.txt";
my $invalid_file = "ip_geo_as_invalid.txt";
my $all_ips_file = "all_ips.txt";
my $ap_file      = "AP_Location.csv";
my $output_name  = "sort_ips";

my $sjtu;
my $other;
my $res;
my $mask;
my $subset;

my %ip_table_info = ();
my %invalid_info = ();
my %account_info = ();
my %ap_info = ();
my %ip_info = ();
my %group_info = ();


my $cnt_sjtu = 0;
my $cnt_missing_sjtu_accnt = 0;
my $cnt_missing_sjtu = 0;
my $cnt_missing_other = 0;


#############
# check input
#############
$subset = "CN";

#############
# Main starts
#############

#############
## Read RADIUS account data
#############
print "Read RADIUS account data: $account_dir\n" if($DEBUG2);
%account_info = IPTool::read_account_info($account_dir);
print "  size=".scalar(keys %{ $account_info{USER_IP} })."\n" if($DEBUG1);

my %tmp;
foreach my $ip (keys %{ $account_info{USER_IP} }) {
    $tmp{$account_info{USER_IP}{$ip}{AP_IP}} = 1;
}
foreach my $ap (keys %tmp) {
    print "$ap\n";
}

%tmp = ();
foreach my $ip (keys %{ $account_info{USER_IP} }) {
    $tmp{$account_info{USER_IP}{$ip}{AP_MAC}} = 1;
}
foreach my $ap (keys %tmp) {
    print "$ap\n";
}
exit;

#############
## Read AP location
#############
print "Read AP location: $ap_dir/$ap_file\n" if($DEBUG2);
%ap_info = IPTool::read_ap_info("$ap_dir/$ap_file");
print "  size=".scalar(keys %{ $ap_info{AP_MAC} })."\n" if($DEBUG1);
foreach my $ap (keys %{ $ap_info{AP_MAC} }) {
    print "$ap\n";
}
    


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

##############################################################################

#############
## get all groups
#############
print "get all groups\n" if($DEBUG2);

open FH, "$all_ips_dir/$all_ips_file" or die $!;
while(<FH>) {
    chomp;
    my $ip = $_;
    next unless($ip =~ /\d+\.\d+\.\d+\.\d+/);
    

    ###################
    ## skip invalid IPs and unknown IPs
    ###################
    next if(exists $invalid_info{IP}{$ip});
    next unless(exists $ip_table_info{IP}{$ip});
    die "should not have duplicate IP\n" if(exists $ip_info{IP}{$ip});


    ###################
    ## skip if "sub" option is set
    ###################
    next if($ip_table_info{IP}{$ip}{COUNTRY_CODE} ne $subset);
    
    $ip_info{IP}{$ip} = $ip_table_info{IP}{$ip};


    ###################
    ## SJTU machines
    ###################
    if(exists $account_info{USER_IP}{$ip}) {
        $cnt_sjtu ++;

        print "  $ip\n" if($DEBUG0);
        if($sjtu eq "gps") {
            my $lat = $ip_info{IP}{$ip}{LAT} + 0;
            my $lng = $ip_info{IP}{$ip}{LNG} + 0;

            my $group = "".(int($lat / $res)).";".(int($lng / $res));
            print "($lat, $lng) = $group\n" if($DEBUG0);

            # $group_info{START_GRP} = $group unless(exists $group_info{START_GRP});
            $group_info{SJTU_GROUP}{$group}{LAT} = $lat;
            $group_info{SJTU_GROUP}{$group}{LNG} = $lng;
        }
        elsif($sjtu eq "ap") {
            my $ap_mac = $account_info{USER_IP}{$ip}{AP_MAC};
            unless(exists $ap_info{AP_MAC}{$ap_mac}) {
                ## cannot find the corresponding AP Name
                $cnt_missing_sjtu ++;
                next;
            }

            my $ap_name = $ap_info{AP_MAC}{$ap_mac}{AP_NAME};
            my $group = $ap_name;

            # $group_info{START_GRP} = $group unless(exists $group_info{START_GRP});
            $group_info{SJTU_GROUP}{$group}{IND} = 0;
        }
        elsif($sjtu eq "bgp") {
            unless(exists $ip_info{IP}{$ip}{BGP_PREFIX}) {
                ## this ip don't have BGP table
                $cnt_missing_sjtu ++;
                next;
            }
            my $group;

            my $bgp = $ip_info{IP}{$ip}{BGP_PREFIX};
            if($bgp =~ /(\d+)\.(\d+)\.(\d+)\.(\d+)\/(\d+)/) {
                # my @bgp_bytes = ($1, $2, $3, $4, $5);
                # $group = join(".", @bgp_bytes[0 .. int($mask/8)-1]);

                # $group = int(((($1 * 256 + $2) * 256 + $3) * 256 + $4) / (2**(32 - $mask)));
                $group = $bgp;
                print "  $bgp -> group=$group\n" if($DEBUG0);
            }
            else {
                die "wrong BGP format: $bgp\n";
            }

            $group_info{SJTU_GROUP}{$group}{LAT} = $ip_info{IP}{$ip}{LAT} + 0;
            $group_info{SJTU_GROUP}{$group}{LNG} = $ip_info{IP}{$ip}{LNG} + 0;
        }
        else {
            die "wrong other type: $sjtu\n";
        }
    }

    ###################
    ## other machines
    ###################
    else {

        ## this IP is supposed to be SJTU machine but cannot find it in Account info
        if($ip =~ /111\.186\.\d+\.\d+/) {
            $cnt_missing_sjtu_accnt ++;
        }

        if($other eq "gps") {
            my $lat = $ip_info{IP}{$ip}{LAT} + 0;
            my $lng = $ip_info{IP}{$ip}{LNG} + 0;

            my $group = "".(int($lat / $res)).";".(int($lng / $res));
            print "($lat, $lng) = $group\n" if($DEBUG0);

            $group_info{OTHER_GROUP}{$group}{LAT} = $lat;
            $group_info{OTHER_GROUP}{$group}{LNG} = $lng;
        }
        elsif($other eq "country") {
            my $group = $ip_info{IP}{$ip}{COUNTRY_CODE};
            if($group eq "") {
                ## does not have country code
                $cnt_missing_other ++;
                next;
            }

            next if(exists $group_info{OTHER_GROUP}{$group});
            my $lat = $ip_info{IP}{$ip}{LAT} + 0;
            my $lng = $ip_info{IP}{$ip}{LNG} + 0;
            $group_info{OTHER_GROUP}{$group}{LAT} = $lat;
            $group_info{OTHER_GROUP}{$group}{LNG} = $lng;
        }
        elsif($other eq "bgp") {
            unless(exists $ip_info{IP}{$ip}{BGP_PREFIX} and $ip_info{IP}{$ip}{BGP_PREFIX} ne "") {
                ## this ip don't have BGP table
                $cnt_missing_other ++;
                next;
            }
            my $group;

            my $bgp = $ip_info{IP}{$ip}{BGP_PREFIX};
            if($bgp =~ /(\d+)\.(\d+)\.(\d+)\.(\d+)\/(\d+)/) {
                # my @bgp_bytes = ($1, $2, $3, $4, $5);

                # $group = int(((($1 * 256 + $2) * 256 + $3) * 256 + $4) / (2**(32 - $mask)));
                $group = $bgp;
                print "  $bgp -> group=$group\n" if($DEBUG0);
            }
            else {
                die "wrong BGP format: \"$bgp\"\n";
            }

            $group_info{OTHER_GROUP}{$group}{LAT} = $ip_info{IP}{$ip}{LAT} + 0;
            $group_info{OTHER_GROUP}{$group}{LNG} = $ip_info{IP}{$ip}{LNG} + 0;
        }
        else {
            die "wrong other type: $other\n";
        }
    }
}
close FH;


print "  # sjtu devices: $cnt_sjtu\n";
print "  # sjtu missing devices account: $cnt_missing_sjtu_accnt\n";
print "  # sjtu missing ap: $cnt_missing_sjtu\n";
print "  # other missing devices: $cnt_missing_other\n";
print "  # sjtu group: ".scalar(keys %{ $group_info{SJTU_GROUP} } )."\n";
print "  # other group: ".scalar(keys %{ $group_info{OTHER_GROUP} } )."\n";


##############################################################################

################
## sort SJTU group
################
print "sort SJTU group\n" if($DEBUG2);

my $cur_ind = 1;
my $cur_lat = -1;
my $cur_lng = -1;
if($sjtu eq "gps" or $sjtu eq "bgp") {
    if($sjtu eq "gps") { $output_name .= ".$sjtu.$res"; }
    elsif($sjtu eq "bgp") { $output_name .= ".$sjtu"; }

    my @tmp_grps = keys %{ $group_info{SJTU_GROUP} };

    my $cur_grp = shift @tmp_grps;
    $cur_lat = $group_info{SJTU_GROUP}{$cur_grp}{LAT};
    $cur_lng = $group_info{SJTU_GROUP}{$cur_grp}{LNG};
    $group_info{SJTU_GROUP}{$cur_grp}{IND} = $cur_ind;
    $cur_ind ++;

    while(scalar(@tmp_grps) > 0) {
        
        my $min_dist = -1;
        my $min_grp;
        foreach my $this_grp (@tmp_grps) {
            my $this_lat = $group_info{SJTU_GROUP}{$this_grp}{LAT};
            my $this_lng = $group_info{SJTU_GROUP}{$this_grp}{LNG};

            my $this_dist = MyUtil::pos2dist($cur_lat, $cur_lng, $this_lat, $this_lng);
            if($this_dist < $min_dist or $min_dist == -1) {
                $min_dist = $this_dist;
                $min_grp = $this_grp;
            }
        }

        @tmp_grps = grep { $_ ne $min_grp } @tmp_grps;
        $cur_grp = $min_grp;
        $cur_lat = $group_info{SJTU_GROUP}{$min_grp}{LAT};
        $cur_lng = $group_info{SJTU_GROUP}{$min_grp}{LNG};

        $group_info{SJTU_GROUP}{$cur_grp}{IND} = $cur_ind;
        $cur_ind ++;
    }
}
elsif($sjtu eq "ap") {
    $output_name .= ".$sjtu";

    my @tmp_grps = keys %{ $group_info{SJTU_GROUP} };

    my @sorted_tmp_grps = sort {$a cmp $b} @tmp_grps;
    foreach my $this_grp (@sorted_tmp_grps) {
        $group_info{SJTU_GROUP}{$this_grp}{IND} = $cur_ind;
        $cur_ind ++;
    }
}

print "\n";
print "  # sjtu index = $cur_ind\n";

################
## sort other group
################
print "sort other group\n" if($DEBUG2);

$cur_ind = 1;
if($other eq "gps" or $other eq "country" or $other eq "bgp") {
    if   ($other eq "gps")     { $output_name .= ".$other.$res"; }
    elsif($other eq "country") { $output_name .= ".$other"; }
    elsif($other eq "bgp")     { $output_name .= ".$other"; }

    my @tmp_grps = keys %{ $group_info{OTHER_GROUP} };

    my $cur_grp;
    if($cur_lat == -1 and $cur_lng == -1) {
        $cur_grp = shift @tmp_grps;
        $cur_lat = $group_info{OTHER_GROUP}{$cur_grp}{LAT};
        $cur_lng = $group_info{OTHER_GROUP}{$cur_grp}{LNG};
        $group_info{OTHER_GROUP}{$cur_grp}{IND} = $cur_ind;
        $cur_ind ++;
    }

    while(scalar(@tmp_grps) > 0) {
        
        my $min_dist = -1;
        my $min_grp;
        foreach my $this_grp (@tmp_grps) {
            my $this_lat = $group_info{OTHER_GROUP}{$this_grp}{LAT};
            my $this_lng = $group_info{OTHER_GROUP}{$this_grp}{LNG};

            my $this_dist = MyUtil::pos2dist($cur_lat, $cur_lng, $this_lat, $this_lng);
            if($this_dist < $min_dist or $min_dist == -1) {
                $min_dist = $this_dist;
                $min_grp = $this_grp;
            }
        }

        @tmp_grps = grep { $_ ne $min_grp } @tmp_grps;
        $cur_grp = $min_grp;
        $cur_lat = $group_info{OTHER_GROUP}{$min_grp}{LAT};
        $cur_lng = $group_info{OTHER_GROUP}{$min_grp}{LNG};

        $group_info{OTHER_GROUP}{$cur_grp}{IND} = $cur_ind;
        $cur_ind ++;
    }
}

print "  # other index = $cur_ind\n";

if($subset ne "") {
    $output_name .= ".sub_$subset";
}

##############################################################################

################
## map sjtu ips to group
################
print "map sjtu ips to group\n" if($DEBUG2);

open FH, "> $output_dir/$output_name.txt" or die $!;
foreach my $ip (sort {$a cmp $b} (keys %{ $ip_info{IP} })) {
    ###################
    ## SJTU machines
    ###################
    if(exists $account_info{USER_IP}{$ip}) {
        if($sjtu eq "gps") {
            my $lat = $ip_info{IP}{$ip}{LAT} + 0;
            my $lng = $ip_info{IP}{$ip}{LNG} + 0;

            my $group = "".(int($lat / $res)).";".(int($lng / $res));
            die "wrong sjtu-gps group name: $group\n" unless(exists $group_info{SJTU_GROUP}{$group});

            my $index = $group_info{SJTU_GROUP}{$group}{IND};
            print FH "0, $ip, $index\n";
        }
        elsif($sjtu eq "ap") {
            my $ap_mac = $account_info{USER_IP}{$ip}{AP_MAC};
            next unless(exists $ap_info{AP_MAC}{$ap_mac});

            my $ap_name = $ap_info{AP_MAC}{$ap_mac}{AP_NAME};
            my $group = $ap_name;
            die "wrong sjtu-ap group name: $group\n" unless(exists $group_info{SJTU_GROUP}{$group});

            my $index = $group_info{SJTU_GROUP}{$group}{IND};
            print FH "0, $ip, $index\n";
        }
        elsif($sjtu eq "bgp") {
            next unless(exists $ip_info{IP}{$ip}{BGP_PREFIX} and $ip_info{IP}{$ip}{BGP_PREFIX} ne "");

            my $group;

            my $bgp = $ip_info{IP}{$ip}{BGP_PREFIX};
            if($bgp =~ /(\d+)\.(\d+)\.(\d+)\.(\d+)\/(\d+)/) {
                # my @bgp_bytes = ($1, $2, $3, $4, $5);

                # $group = int(((($1 * 256 + $2) * 256 + $3) * 256 + $4) / (2**(32 - $mask)));
                $group = $bgp;
                print "  $bgp -> group=$group\n" if($DEBUG0);
            }
            else {
                die "wrong BGP format: \"$bgp\"\n";
            }
            
            my $index = $group_info{SJTU_GROUP}{$group}{IND};
            print FH "0, $ip, $index\n";
        }
    }
    ###################
    ## other machines
    ###################
    else {
        if($other eq "gps") {
            my $lat = $ip_info{IP}{$ip}{LAT} + 0;
            my $lng = $ip_info{IP}{$ip}{LNG} + 0;

            my $group = "".(int($lat / $res)).";".(int($lng / $res));
            die "wrong other-gps group name: $group\n" unless(exists $group_info{OTHER_GROUP}{$group});

            my $index = $group_info{OTHER_GROUP}{$group}{IND};
            print FH "1, $ip, $index\n";
        }
        elsif($other eq "country") {
            my $group = $ip_info{IP}{$ip}{COUNTRY_CODE};
            next if($group eq "");

            my $index = $group_info{OTHER_GROUP}{$group}{IND};
            print FH "1, $ip, $index\n";
        }
        elsif($other eq "bgp") {
            next unless(exists $ip_info{IP}{$ip}{BGP_PREFIX} and $ip_info{IP}{$ip}{BGP_PREFIX} ne "");

            my $group;

            my $bgp = $ip_info{IP}{$ip}{BGP_PREFIX};
            if($bgp =~ /(\d+)\.(\d+)\.(\d+)\.(\d+)\/(\d+)/) {
                # my @bgp_bytes = ($1, $2, $3, $4, $5);

                # $group = int(((($1 * 256 + $2) * 256 + $3) * 256 + $4) / (2**(32 - $mask)));
                $group = $bgp;
                print "  $bgp -> group=$group\n" if($DEBUG0);
            }
            else {
                die "wrong BGP format: \"$bgp\"\n";
            }
            
            my $index = $group_info{OTHER_GROUP}{$group}{IND};
            print FH "1, $ip, $index\n";
        }
    }
}
close FH;

