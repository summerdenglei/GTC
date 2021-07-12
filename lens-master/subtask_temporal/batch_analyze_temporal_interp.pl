#!/bin/perl

use strict;

my $RERUN = 1;

my $input_dir = "/u/yichao/anomaly_compression/processed_data/subtask_temporal/temporal_stability";
my $output_dir = "/u/yichao/anomaly_compression/processed_data/subtask_temporal/temporal_stability";
my @mats = ("3G", "WiFi", "Abilene", "GEANT", "CSI (1 shannel)", "CSI (multi-channel)", "Cister RSSI", "CU RSSI", "UMich RSS", "UCSB Meshnet", "RON delay");

my $cmd;

# my @num_anomalies = (0.05, 0.1);
# my @sigma_mags    = (2, 4);
# my @itvls           = (1, 5, 10, 20, 50);
my @itvls           = (1, 10);
my $itvls           = "[";
foreach my $i (0..@itvls-1) {
    $itvls .= "," if($i > 0);
    $itvls .= $itvls[$i];
}
$itvls .= "]";
print $itvls."\n";
# my $itvls         = "[1,5,10]";



######################################################################################
## all 
######################################################################################
my $num_anomaly = 0;
my $sigma_mag = 0;

if($RERUN) {
    ## GEANT
    my $cmd = "matlab -r \"analyze_temporal_interp('../processed_data/subtask_parse_totem/tm/', 'tm_totem.', 672, 23, 23, $itvls, $num_anomaly, $sigma_mag);exit;\"";
    print $cmd."\n";
    `$cmd`;

    ## Abilene
    $cmd = "matlab -r \"analyze_temporal_interp('../condor_data/subtask_parse_abilene/tm/', 'tm_abilene.od.', 1008, 11, 11, $itvls, $num_anomaly, $sigma_mag);exit;\"";
    print $cmd."\n";
    `$cmd`;

    ## 3G
    $cmd = "matlab -r \"analyze_temporal_interp('../processed_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.bs.bs3.all.bin10.txt', 144, 472, 1, $itvls, $num_anomaly, $sigma_mag);exit;\"";
    print $cmd."\n";
    `$cmd`;

    ## WiFi
    $cmd = "matlab -r \"analyze_temporal_interp('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_sjtu_wifi.ap_load.all.bin600.top50.txt', 110, 50, 1, $itvls, $num_anomaly, $sigma_mag);exit;\"";
    print $cmd."\n";
    `$cmd`;

    ## CSI
    $cmd = "matlab -r \"analyze_temporal_interp('../condor_data/csi/mobile/', 'Mob-Recv1run1.dat0_matrix.mat_dB.txt', 1000, 90, 1, $itvls, $num_anomaly, $sigma_mag);exit;\"";
    print $cmd."\n";
    `$cmd`;

    ## RON
    $cmd = "matlab -r \"analyze_temporal_interp('../processed_data/subtask_parse_ron/tm/', 'tm_ron1.latency.', 494, 12, 12, $itvls, $num_anomaly, $sigma_mag);exit;\"";
    print $cmd."\n";
    `$cmd`;

    ## Cister RSSI
    $cmd = "matlab -r \"analyze_temporal_interp('../processed_data/subtask_parse_telos_rssi/tm/', 'tm_telos_rssi.txt', 10000, 16, 1, $itvls, $num_anomaly, $sigma_mag);exit;\"";
    print $cmd."\n";
    `$cmd`;

    ## CU RSSI
    $cmd = "matlab -r \"analyze_temporal_interp('../processed_data/subtask_parse_multi_loc_rssi/tm/', 'tm_multi_loc_rssi.txt', 500, 895, 1, $itvls, $num_anomaly, $sigma_mag);exit;\"";
    print $cmd."\n";
    `$cmd`;

    ## Channel CSI
    $cmd = "matlab -r \"analyze_temporal_interp('../processed_data/subtask_parse_csi_channel/csi/', 'static_trace13.ant1.mag.txt', 1000, 270, 1, $itvls, $num_anomaly, $sigma_mag);exit;\"";
    print $cmd."\n";
    `$cmd`;

    ## UCSB Meshnet
    $cmd = "matlab -r \"analyze_temporal_interp('../processed_data/subtask_parse_ucsb_meshnet/tm/', 'tm_ucsb_meshnet.connected.txt', 1527, 425, 1, $itvls, $num_anomaly, $sigma_mag);exit;\"";
    print $cmd."\n";
    `$cmd`;

    ## UMich RSS
    $cmd = "matlab -r \"analyze_temporal_interp('../processed_data/subtask_parse_umich_rss/tm/', 'tm_umich_rss.txt', 1000, 182, 1, $itvls, $num_anomaly, $sigma_mag);exit;\"";
    print $cmd."\n";
    `$cmd`;
}


foreach my $itvl (@itvls) {
    my %data_info = ();

    open FH, "$input_dir/tm_totem..na$num_anomaly.anom$sigma_mag.itvl$itvl.diff.interp.txt" or die $!;
    while(<FH>) {
        chomp;
        my @tmp = split(/\s+/, $_);
        $data_info{$tmp[0]}{"GEANT"} = $tmp[1];
    }
    close FH;

    open FH, "$input_dir/tm_abilene.od..na$num_anomaly.anom$sigma_mag.itvl$itvl.diff.interp.txt" or die $!;
    while(<FH>) {
        chomp;
        my @tmp = split(/\s+/, $_);
        $data_info{$tmp[0]}{"Abilene"} = $tmp[1];
    }
    close FH;

    open FH, "$input_dir/tm_3g.cell.bs.bs3.all.bin10.txt.na$num_anomaly.anom$sigma_mag.itvl$itvl.diff.interp.txt" or die $!;
    while(<FH>) {
        chomp;
        my @tmp = split(/\s+/, $_);
        $data_info{$tmp[0]}{"3G"} = $tmp[1];
    }
    close FH;

    open FH, "$input_dir/tm_sjtu_wifi.ap_load.all.bin600.top50.txt.na$num_anomaly.anom$sigma_mag.itvl$itvl.diff.interp.txt" or die $!;
    while(<FH>) {
        chomp;
        my @tmp = split(/\s+/, $_);
        $data_info{$tmp[0]}{"WiFi"} = $tmp[1];
    }
    close FH;

    open FH, "$input_dir/tm_ron1.latency..na$num_anomaly.anom$sigma_mag.itvl$itvl.diff.interp.txt" or die $!;
    while(<FH>) {
        chomp;
        my @tmp = split(/\s+/, $_);
        $data_info{$tmp[0]}{"RON delay"} = $tmp[1];
    }
    close FH;

    open FH, "$input_dir/Mob-Recv1run1.dat0_matrix.mat_dB.txt.na$num_anomaly.anom$sigma_mag.itvl$itvl.diff.interp.txt" or die $!;
    while(<FH>) {
        chomp;
        my @tmp = split(/\s+/, $_);
        $data_info{$tmp[0]}{"CSI (1 shannel)"} = $tmp[1];
    }
    close FH;

    open FH, "$input_dir/tm_telos_rssi.txt.na$num_anomaly.anom$sigma_mag.itvl$itvl.diff.interp.txt" or die $!;
    while(<FH>) {
        chomp;
        my @tmp = split(/\s+/, $_);
        $data_info{$tmp[0]}{"Cister RSSI"} = $tmp[1];
    }
    close FH;

    open FH, "$input_dir/tm_multi_loc_rssi.txt.na$num_anomaly.anom$sigma_mag.itvl$itvl.diff.interp.txt" or die $!;
    while(<FH>) {
        chomp;
        my @tmp = split(/\s+/, $_);
        $data_info{$tmp[0]}{"CU RSSI"} = $tmp[1];
    }
    close FH;

    open FH, "$input_dir/static_trace13.ant1.mag.txt.na$num_anomaly.anom$sigma_mag.itvl$itvl.diff.interp.txt" or die $!;
    while(<FH>) {
        chomp;
        my @tmp = split(/\s+/, $_);
        $data_info{$tmp[0]}{"CSI (multi-channel)"} = $tmp[1];
    }
    close FH;

    open FH, "$input_dir/tm_ucsb_meshnet.connected.txt.na$num_anomaly.anom$sigma_mag.itvl$itvl.diff.interp.txt" or die $!;
    while(<FH>) {
        chomp;
        my @tmp = split(/\s+/, $_);
        $data_info{$tmp[0]}{"UCSB Meshnet"} = $tmp[1];
    }
    close FH;

    open FH, "$input_dir/tm_umich_rss.txt.na$num_anomaly.anom$sigma_mag.itvl$itvl.diff.interp.txt" or die $!;
    while(<FH>) {
        chomp;
        my @tmp = split(/\s+/, $_);
        $data_info{$tmp[0]}{"UMich RSS"} = $tmp[1];
    }
    close FH;

    open FH, "$input_dir/tm_totem..na$num_anomaly.anom$sigma_mag.itvl$itvl.diff.interp.txt" or die $!;
    while(<FH>) {
        chomp;
        my @tmp = split(/\s+/, $_);
        $data_info{$tmp[0]}{"GEANT"} = $tmp[1];
    }
    close FH;


    # my $filename = "all.na$num_anomaly.anom$sigma_mag.itvl$itvl.diff.txt";
    # my $first = 1;
    # open FH, ">$output_dir/$filename" or die $!;
    # foreach my $x (sort {$a <=> $b} (keys %data_info)) {
    #     if($first) {
    #         print FH "## ";
    #         # foreach my $mat (sort (keys %{ $data_info{$x} })) {
    #         foreach my $mat (@mats) {
    #             print FH "$mat, ";
    #         }
    #         print FH "\n";
    #         $first = 0;
    #     }

    #     print FH "$x";
    #     foreach my $mat (@mats) {
    #         print FH ", ".$data_info{$x}{$mat};
    #     }
    #     print FH "\n";
    # }
    # close FH;
}

