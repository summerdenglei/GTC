
package IPTool;

use strict;


######################################
## ip2geo
##   http://freegeoip.net/
## - input
##   1. ip
## - output
##   $ret_ip, $CountryCode, $CountryName, $RegionCode, $RegionName, $city, $zip, $lat, $lng, $MetroCode, $AreaCode
######################################
sub ip2geo {
    my ($ip) = @_;

    my $DEBUG0 = 0;
    my $DEBUG1 = 0;

    my $result = `curl -s freegeoip.net/{csv}/{$ip}`;
    print $result if($DEBUG1);

    my @tmp = split(/,/, $result);
    my @ret;
    foreach my $ele (@tmp) {
        if($ele =~ /^"(.*)"$/) {
            push(@ret, $1);
        }
    }
    print join("|", @ret)."\n" if($DEBUG1);

    return @ret;
}


######################################
## ip2asn
##   http://www.team-cymru.org/Services/ip-to-asn.html
## - input
##   1. ip
##   2. time
## - output
##   ($asn, $query_ip, $bgp_prefix, $country, $registry
######################################
sub ip2asn {
    my ($ip, $time) = @_;

    my $DEBUG0 = 0;
    my $DEBUG1 = 0;

    # whois -h whois.cymru.com " -v 216.90.108.31 2005-12-25 13:23:01 GMT"
    my $result = `whois -h whois.cymru.com " -c -r -p -u -w -f -o -b $ip $time"`;
    print $result if($DEBUG1);

    my @tmp = split(/\|/, $result);
    my @ret;
    foreach my $ele (@tmp) {
        if($ele =~ /\s*([\w\d\.-\/]*)\s+/) {
            push(@ret, $1);
        }
    }
    print join("|", @ret)."\n" if($DEBUG1);

    return @ret;
}


######################################
## read_geo_as_table
##   read a file which contains pre-downloaded IP2GEO and IP2ASN information
## - input
##   1. full path to the table file
## - output
##   1. %ip_info: IP - [LAT | LNG | ...]
######################################
sub read_geo_as_table {
    my ($table_fullpath) = @_;

    my $DEBUG0 = 0;
    my $DEBUG1 = 0;


    my %ip_info = ();


    print "read geo asn table\n" if($DEBUG1);

    open FH, "$table_fullpath" or die $!;
    while(<FH>) {
        chomp;
        print "- ".$_."\n" if($DEBUG1);

        my ($ip, $lat, $lng, $asn, $bgp_prefix, $country_code, $country_name, $region_code, $region_name, $city, $zip, $area, $metro, $registry) = split(/, /, $_);

        if($DEBUG1) {
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

    return %ip_info;
}


#############
## read_account_info:
##   Read RADIUS account data
#############
sub read_account_info {
    my ($input_radius_dir) = @_;

    my $DEBUG0 = 0;
    my $DEBUG1 = 1;

    my %account_info = ();

    print "Read RADIUS account data\n" if($DEBUG0);

    my @files;
    ## XXX: should read file according to time
    # opendir(DIR, "$input_radius_dir") or die $!;
    # while (my $file = readdir(DIR)) {
    #     next if($file =~ /^\.+/);  ## don't show "." and ".."
    #     next if(-d "$input_radius_dir/$file");  ## don't show directories

    #     push(@files, $file);
    # }
    # closedir(DIR);
    ## XXX: hard coding
    @files = ("RADIUS Accounting 2013-01-04_anonymous.csv");

    
    foreach my $file (sort {$a cmp $b} @files) {
        print "$input_radius_dir/$file\n" if($DEBUG0);

        
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
            # $account_info{USER_IP}{$user_ip}{AP_NAME}  = $ap_info{AP_MAC}{$ap_mac}{AP_NAME};

            if($DEBUG0) {
                print "user ip : \"$user_ip\"\n";
                print "user mac: \"$user_mac\"\n";
                print "ap ip   : \"$ap_ip\"\n";
                print "ap mac  : \"$ap_mac\"\n";
                # print "ap_name : \"".$account_info{USER_IP}{$user_ip}{AP_NAME}."\"\n\n";
                # print "download: $download\n";
                # print "upload  : $upload\n\n";
            }
        }
        close FH;
    }

    return %account_info;
}


sub read_account_info2 {
    my ($full_path) = @_;

    my $DEBUG0 = 0;
    my $DEBUG1 = 1;

    my %account_info = ();

    print "Read RADIUS account data: $full_path\n" if($DEBUG0);

    #############
    ## parse the account file
    #############
    open FH, "bzcat \"$full_path\" |" or die $!;
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
        # $account_info{USER_IP}{$user_ip}{AP_NAME}  = $ap_info{AP_MAC}{$ap_mac}{AP_NAME};

        if($DEBUG0) {
            print "user ip : \"$user_ip\"\n";
            print "user mac: \"$user_mac\"\n";
            print "ap ip   : \"$ap_ip\"\n";
            print "ap mac  : \"$ap_mac\"\n";
            # print "ap_name : \"".$account_info{USER_IP}{$user_ip}{AP_NAME}."\"\n\n";
            # print "download: $download\n";
            # print "upload  : $upload\n\n";
        }
    }
    close FH;


    return %account_info;
}



#############
## Read AP location
#############
sub read_ap_info {
    my ($ap_fullpath) = @_;

    my $DEBUG0 = 0;
    my $DEBUG1 = 1;

    my %ap_info = ();


    print "Read AP location\n" if($DEBUG0);

    open FH, "$ap_fullpath" or die $!;
    while(<FH>) {
        chomp;
        print $_."\n" if($DEBUG0);

        my @ret = split(",", $_);
        my $ap_mac  = $ret[0];
        my $ap_name = $ret[1];

        $ap_mac =~ s{\r}{}g;
        $ap_name =~ s{\r}{}g;

        if($DEBUG0) {
            print "ap_mac : $ap_mac\n";
            print "ap_name: $ap_name\n\n";
        }

        $ap_info{AP_MAC}{$ap_mac}{AP_NAME} = $ap_name;
    }
    close FH;

    return %ap_info;
}


1;
