#!/bin/perl

use strict;

my $RERUN = 1;

my $input_dir = "/u/yichao/anomaly_compression/processed_data/subtask_rank/rank_2d";
my $output_dir = "/u/yichao/anomaly_compression/processed_data/subtask_rank/rank_2d";

my $cmd;

my @mats = ("3G", "WiFi", "Abilene", "GEANT", "CSI (1 shannel)", "CSI (multi-channel)", "Cister RSSI", "CU RSSI", "UMich RSS", "UCSB Meshnet", "RON delay");

######################################################################################
## Made for Mobicom'14 slides
######################################################################################
my @num_anomalies  = (0, 0.05, 0.05, 0.1, 0.1);
my @sigma_mags     = (0, 0.5 , 1   , 0.5, 1);

foreach my $i (0 .. scalar(@num_anomalies)-1) {
    my $num_anomaly = $num_anomalies[$i];
    my $sigma_mag = $sigma_mags[$i];

    print "# anomalies = $num_anomaly, size = $sigma_mag\n";

    my %rank_info = ();
    
    if($RERUN) {
        ## GEANT
        $cmd = "matlab -r \"analyze_low_rank_2d_interp('../processed_data/subtask_parse_totem/tm/', 'tm_totem.', 672, 23, 23, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;

        open FH, "$input_dir/tm_totem..na$num_anomaly.anom$sigma_mag.cdf.poly.txt" or die $!;
        while(<FH>) {
            chomp;
            my @tmp = split(/\s+/, $_);
            $rank_info{$tmp[0]}{"GEANT"} = $tmp[1];
        }
        close FH;


        ## Abilene
        $cmd = "matlab -r \"analyze_low_rank_2d_interp('../condor_data/subtask_parse_abilene/tm/', 'tm_abilene.od.', 1008, 11, 11, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;

        open FH, "$input_dir/tm_abilene.od..na$num_anomaly.anom$sigma_mag.cdf.poly.txt" or die $!;
        while(<FH>) {
            chomp;
            my @tmp = split(/\s+/, $_);
            $rank_info{$tmp[0]}{"Abilene"} = $tmp[1];
        }
        close FH;


        ## 3G
        $cmd = "matlab -r \"analyze_low_rank_2d_interp('../processed_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.bs.bs3.all.bin10.txt', 144, 472, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;

        open FH, "$input_dir/tm_3g.cell.bs.bs3.all.bin10.txt.na$num_anomaly.anom$sigma_mag.cdf.poly.txt" or die $!;
        while(<FH>) {
            chomp;
            my @tmp = split(/\s+/, $_);
            $rank_info{$tmp[0]}{"3G"} = $tmp[1];
        }
        close FH;


        ## WiFi
        $cmd = "matlab -r \"analyze_low_rank_2d_interp('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_sjtu_wifi.ap_load.all.bin600.top50.txt', 110, 50, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;

        open FH, "$input_dir/tm_sjtu_wifi.ap_load.all.bin600.top50.txt.na$num_anomaly.anom$sigma_mag.cdf.poly.txt" or die $!;
        while(<FH>) {
            chomp;
            my @tmp = split(/\s+/, $_);
            $rank_info{$tmp[0]}{"WiFi"} = $tmp[1];
        }
        close FH;


        ## RON
        $cmd = "matlab -r \"analyze_low_rank_2d_interp('../processed_data/subtask_parse_ron/tm/', 'tm_ron1.latency.', 494, 12, 12, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;

        open FH, "$input_dir/tm_ron1.latency..na$num_anomaly.anom$sigma_mag.cdf.poly.txt" or die $!;
        while(<FH>) {
            chomp;
            my @tmp = split(/\s+/, $_);
            $rank_info{$tmp[0]}{"RON delay"} = $tmp[1];
        }
        close FH;


        ## CSI
        $cmd = "matlab -r \"analyze_low_rank_2d_interp('../condor_data/csi/mobile/', 'Mob-Recv1run1.dat0_matrix.mat_dB.txt', 1000, 90, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;

        open FH, "$input_dir/Mob-Recv1run1.dat0_matrix.mat_dB.txt.na$num_anomaly.anom$sigma_mag.cdf.poly.txt" or die $!;
        while(<FH>) {
            chomp;
            my @tmp = split(/\s+/, $_);
            $rank_info{$tmp[0]}{"CSI (1 shannel)"} = $tmp[1];
        }
        close FH;


        ## Cister RSSI
        $cmd = "matlab -r \"analyze_low_rank_2d_interp('../processed_data/subtask_parse_telos_rssi/tm/', 'tm_telos_rssi.txt', 10000, 16, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;

        open FH, "$input_dir/tm_telos_rssi.txt.na$num_anomaly.anom$sigma_mag.cdf.poly.txt" or die $!;
        while(<FH>) {
            chomp;
            my @tmp = split(/\s+/, $_);
            $rank_info{$tmp[0]}{"Cister RSSI"} = $tmp[1];
        }
        close FH;


        ## CU RSSI
        $cmd = "matlab -r \"analyze_low_rank_2d_interp('../processed_data/subtask_parse_multi_loc_rssi/tm/', 'tm_multi_loc_rssi.txt', 500, 895, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;

        open FH, "$input_dir/tm_multi_loc_rssi.txt.na$num_anomaly.anom$sigma_mag.cdf.poly.txt" or die $!;
        while(<FH>) {
            chomp;
            my @tmp = split(/\s+/, $_);
            $rank_info{$tmp[0]}{"CU RSSI"} = $tmp[1];
        }
        close FH;


        ## Channel CSI
        $cmd = "matlab -r \"analyze_low_rank_2d_interp('../processed_data/subtask_parse_csi_channel/csi/', 'static_trace13.ant1.mag.txt', 1000, 270, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;

        open FH, "$input_dir/static_trace13.ant1.mag.txt.na$num_anomaly.anom$sigma_mag.cdf.poly.txt" or die $!;
        while(<FH>) {
            chomp;
            my @tmp = split(/\s+/, $_);
            $rank_info{$tmp[0]}{"CSI (multi-channel)"} = $tmp[1];
        }
        close FH;


        ## UCSB Meshnet
        $cmd = "matlab -r \"analyze_low_rank_2d_interp('../processed_data/subtask_parse_ucsb_meshnet/tm/', 'tm_ucsb_meshnet.connected.txt', 1527, 425, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;

        open FH, "$input_dir/tm_ucsb_meshnet.connected.txt.na$num_anomaly.anom$sigma_mag.cdf.poly.txt" or die $!;
        while(<FH>) {
            chomp;
            my @tmp = split(/\s+/, $_);
            $rank_info{$tmp[0]}{"UCSB Meshnet"} = $tmp[1];
        }
        close FH;


        ## UMich RSS
        $cmd = "matlab -r \"analyze_low_rank_2d_interp('../processed_data/subtask_parse_umich_rss/tm/', 'tm_umich_rss.txt', 1000, 182, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;

        open FH, "$input_dir/tm_umich_rss.txt.na$num_anomaly.anom$sigma_mag.cdf.poly.txt" or die $!;
        while(<FH>) {
            chomp;
            my @tmp = split(/\s+/, $_);
            $rank_info{$tmp[0]}{"UMich RSS"} = $tmp[1];
        }
        close FH;

    }

    my $filename = "all.na$num_anomaly.anom$sigma_mag.txt";
    my $first = 1;
    open FH, ">$output_dir/$filename" or die $!;
    foreach my $x (sort {$a <=> $b} (keys %rank_info)) {
        if($first) {
            print FH "## ";
            # foreach my $mat (sort (keys %{ $rank_info{$x} })) {
            foreach my $mat (@mats) {
                print FH "$mat, ";
            }
            print FH "\n";
            $first = 0;
        }

        print FH "$x";
        foreach my $mat (@mats) {
            print FH ", ".$rank_info{$x}{$mat};
        }
        print FH "\n";
    }
    close FH;
}



