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

use lib "/u/yichao/anomaly_compression/utils";
use MyUtil;

#############
# Debug
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1; ## print progress
my $DEBUG3 = 1; ## print output

my $PLOT_PURE_RAND1 = 1;
my $PLOT_ELEM_RAND1 = 1;
my $PLOT_ELEM_SYN1  = 1;
my $PLOT_PRED1      = 1;
my $PLOT_TIME_RAND1 = 1;
my $PLOT_ROW_RAND1  = 1;
my $PLOT_COL_RAND1  = 1;


#############
# Constants
#############
my $NUM_CURVE = 12;


#############
# Variables
#############
my $input_dir  = "/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/condor/output.internet";
my $output_dir = "/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/output";
my $figure_dir = "/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/figures";
my $gnuplot_mother = "plot.pr";

## data - TRACE - OPT_DECT - OPT_DELTA - BLOCK_SIZE - THRESH - [TP, TN, FP, TN, ...]
my %data = ();
## best - TRACE - [OPT_DECT | OPT_DELTA | BLOCK_SIZE] - [MSE | SETTING | FP | ...]
my %best = ();


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
my $func = "srmf_based_pred";

my $num_frames;
my $width;
my $height;
my @seeds;
my @group_sizes;
my @ranks;
my @periods;
my @opt_swap_mats;
my @opt_types;
my @opt_dims;
my @num_anomalies;
my @sigma_mags;
my @sigma_noises;
my @threshs;
my @files;
my $drop_ele_mode;
my $drop_mode;
my @elem_fracs;
my $elem_frac;
my @loss_rates;
my $burst_size;



# @files = ("tm_abilene.od.");
# @files = ("tm_totem.");
# @files = ("tm_3g.cell.bs.bs3.all.bin10.txt");
# @files = ("tm_3g.cell.rnc.all.bin10.txt");
# @files = ("tm_3g.cell.load.top200.all.bin10.txt");
# @files = ("tm_sjtu_wifi.ap_load.all.bin600.top50.txt");
# @files = ("128.83.158.127_file.dat0_matrix.mat.txt");
# @files = ("128.83.158.50_file.dat0_matrix.mat.txt");
# @files = ("Mob-Recv1run1.dat0_matrix.mat_dB.txt");
# @files = ("Mob-Recv1run1.dat1_matrix.mat_dB.txt");
# @files = ("tm_ron1.latency.");
# @files = ("tm_telos_rssi.txt");
# @files = ("tm_multi_loc_rssi.txt");

# @files = ("tm_abilene.od.", "tm_totem.", "tm_3g.cell.bs.bs3.all.bin10.txt", "tm_3g.cell.rnc.all.bin10.txt", "tm_sjtu_wifi.ap_load.all.bin600.top50.txt", "Mob-Recv1run1.dat0_matrix.mat_dB.txt", "tm_sensor.temp.bin600.txt", "tm_sensor.light.bin600.txt");
@files = ("tm_abilene.od.", "tm_totem.", "tm_3g.cell.bs.bs3.all.bin10.txt", "tm_sjtu_wifi.ap_load.all.bin600.top50.txt", "Mob-Recv1run1.dat0_matrix.mat_dB.txt", "tm_ron1.latency.", "tm_telos_rssi.txt", "tm_multi_loc_rssi.txt");


@seeds = (1 .. 1);
@opt_swap_mats = ("org");
# "srmf_knn" "lens_knn2" "srmf_lens_knn2" "lens_st_knn2" "srmf_lens_st_knn" "srmf" "lens" "lens_st" "knn"
# @opt_types = ("srmf", "srmf_knn", "lens", "lens_knn2", "srmf_lens_knn2", "lens_st", "lens_st_knn2", "srmf_lens_st_knn");
@opt_types = ("svd_base", "svd_base_knn", "srmf", "srmf_knn", "lens_st", "lens_st_knn2", "srmf_lens_st_knn");
@opt_dims = ("2d");

@num_anomalies = (0.05);
@sigma_mags = (0.4);
@sigma_noises = (0);
@threshs = (0);

$drop_ele_mode = "elem";
$drop_mode = "ind";
@elem_fracs = (0.5);
$burst_size = 1;


for my $file_name (@files) {    
    
    #############
    ## WiFi
    if($file_name eq "tm_sjtu_wifi.ap_load.all.bin600.top50.txt") {
        $num_frames = 100;
        $width = 50;
        $height = 1;

        @group_sizes = (100);
        # @ranks = (16);
        @ranks = (8);
        @periods = (1);

        $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.wifi";
    }
    ###############
    ## 3G
    # elsif($file_name eq "tm_3g_region_all.res0.006.bin10.sub.") {
    #     $num_frames = 100;
    #     $width = 21;
    #     $height = 26;

    #     @group_sizes = (100);
    #     @ranks = (100);
    #     @periods = (1);

    #     $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.3g";
    # }
    # elsif($file_name eq "tm_3g.cell.bs.bs0.all.bin10.txt") {
    #     $num_frames = 100;
    #     $width = 1074;
    #     $height = 1;

    #     @group_sizes = (100);
    #     @ranks = (64);
    #     @periods = (1);

    #     $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.3g";
    # }
    # elsif($file_name eq "tm_3g.cell.bs.bs1.all.bin10.txt") {
    #     $num_frames = 100;
    #     $width = 458;
    #     $height = 1;

    #     @group_sizes = (100);
    #     @ranks = (64);
    #     @periods = (1);

    #     $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.3g";
    # }
    elsif($file_name eq "tm_3g.cell.bs.bs3.all.bin10.txt") {
        # $num_frames = 100;
        $num_frames = 144;
        $width = 472;
        $height = 1;

        # @group_sizes = (100);
        @group_sizes = (144);
        @ranks = (64);
        @periods = (1);

        $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.3g";
    }
    # elsif($file_name eq "tm_3g.cell.bs.bs3.all.bin60.txt") {
    #     $num_frames = 24;
    #     $width = 472;
    #     $height = 1;

    #     @group_sizes = (24);
    #     @ranks = (8);
    #     @periods = (1);

    #     $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.3g";
    # }
    # elsif($file_name eq "tm_3g.cell.bs.bs6.all.bin10.txt") {
    #     $num_frames = 100;
    #     $width = 240;
    #     $height = 1;

    #     @group_sizes = (100);
    #     @ranks = (64);
    #     @periods = (1);

    #     $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.3g";
    # }
    # elsif($file_name eq "tm_3g.cell.load.top200.all.bin10.txt") {
    #     $num_frames = 100;
    #     $width = 200;
    #     $height = 1;

    #     @group_sizes = (100);
    #     @ranks = (64);
    #     @periods = (1);

    #     $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.3g";
    # }
    # elsif($file_name eq "tm_3g.cell.rnc.all.bin10.txt") {
    #     # $num_frames = 100;
    #     $num_frames = 144;
    #     $width = 13;
    #     $height = 1;

    #     # @group_sizes = (100);
    #     @group_sizes = (144);
    #     @ranks = (8);
    #     @periods = (1);

    #     $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.3g";
    # }
    #############
    ## GEANT
    elsif($file_name eq "tm_totem.") {
        # $num_frames = 100;
        $num_frames = 672;
        $width = 23;
        $height = 23;

        # @group_sizes = (100);
        @group_sizes = (672);
        @ranks = (8);
        @periods = (1);

        $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.geant";
    }
    #############
    ## Abilene
    elsif($file_name eq "X") {
        $num_frames = 1008;
        $width = 121;
        $height = 1;

        @group_sizes = (1008);
        @ranks = (8);
        @periods = (1);

        $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.abilene";
    }
    elsif($file_name eq "tm_abilene.od.") {
        # $num_frames = 100;
        $num_frames = 1008;
        $width = 11;
        $height = 11;

        # @group_sizes = (100);
        @group_sizes = (1008);
        @ranks = (8);
        @periods = (1);

        $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.abilene";
    }
    #############
    ## CSI
    elsif($file_name eq "128.83.158.127_file.dat0_matrix.mat.txt") {
        $num_frames = 1000;
        $width = 90;
        $height = 1;

        @group_sizes = (1000);
        @ranks = (32);
        @periods = (1);

        $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.csi";
    }
    elsif($file_name eq "128.83.158.50_file.dat0_matrix.mat.txt") {
        $num_frames = 2000;
        $width = 90;
        $height = 1;

        @group_sizes = (2000);
        @ranks = (32);
        @periods = (1);

        $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.csi";
    }
    elsif($file_name eq "Mob-Recv1run1.dat0_matrix.mat_dB.txt") {
        $num_frames = 1000;
        $width = 90;
        $height = 1;

        @group_sizes = (1000);
        @ranks = (32);
        @periods = (1);

        $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.csi";
    }
    elsif($file_name eq "Mob-Recv1run1.dat1_matrix.mat_dB.txt") {
        $num_frames = 1000;
        $width = 90;
        $height = 1;

        @group_sizes = (1000);
        @ranks = (32);
        @periods = (1);

        $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.csi";
    }
    #############
    ## Sensor
    elsif($file_name eq "tm_sensor.temp.bin600.txt") {
        # $num_frames = 100;
        $num_frames = 144;
        $width = 54;
        $height = 1;

        # @group_sizes = (100);
        @group_sizes = (144);
        @ranks = (8);
        @periods = (1);

        $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.sensor";
    }
    elsif($file_name eq "tm_sensor.light.bin600.txt") {
        # $num_frames = 100;
        $num_frames = 144;
        $width = 54;
        $height = 1;

        # @group_sizes = (100);
        @group_sizes = (144);
        @ranks = (8);
        @periods = (1);

        $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.sensor";
    }
    elsif($file_name eq "tm_sensor.humidity.bin600.txt") {
        # $num_frames = 100;
        $num_frames = 144;
        $width = 54;
        $height = 1;

        # @group_sizes = (100);
        @group_sizes = (144);
        @ranks = (8);
        @periods = (1);

        $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.sensor";
    }
    elsif($file_name eq "tm_sensor.voltage.bin600.txt") {
        # $num_frames = 100;
        $num_frames = 144;
        $width = 54;
        $height = 1;

        # @group_sizes = (100);
        @group_sizes = (144);
        @ranks = (8);
        @periods = (1);

        $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.sensor";
    }
    #############
    ## RON
    elsif($file_name eq "tm_ron1.latency.") {
        $num_frames = 494;
        $width = 12;
        $height = 12;

        @group_sizes = (494);
        @ranks = (8);
        @periods = (1);

        $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.ron";
    }
    #############
    ## RSSI - telos
    elsif($file_name eq "tm_telos_rssi.txt") {
        $num_frames = 1000;
        $width = 16;
        $height = 1;

        @group_sizes = (1000);
        @ranks = (8);
        @periods = (1);

        $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.rssi.telos";
    }
    #############
    ## RSSI - multi location
    elsif($file_name eq "tm_multi_loc_rssi.txt") {
        $num_frames = 500;
        $width = 895;
        $height = 1;

        @group_sizes = (500);
        @ranks = (32);
        @periods = (1);

        $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.rssi.multi";
    }
    else {
        die "no such file: $file_name\n";
    }


    $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output";
    # $input_dir  = "/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/condor/output";



    for my $group_size (@group_sizes) {
        for my $rank (@ranks) {
            for my $period (@periods) {
                for my $opt_swap_mat (@opt_swap_mats) {
                    for my $opt_dim (@opt_dims) {

                        $drop_ele_mode;
                        $drop_mode;
                        $burst_size;
                        for my $elem_frac (@elem_fracs) {
                        
                            for my $num_anomaly (@num_anomalies) {
                                for my $sigma_mag (@sigma_mags) {
                                    for my $sigma_noise (@sigma_noises) {
                                        for my $thresh (@threshs) {

                                            plot_elem_rand($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh, \@opt_types);

                                        }
                                    }
                                }
                            }

                        }
                        
                    }
                }
            }
        }
    }
}



1;

sub plot_elem_rand {
    my ($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh, $opt_types_ref) = @_;

    my $DEBUG0 = 0;
    my $DEBUG1 = 1;
    my $DEBUG4 = 0;  ## missing files
    my $DEBUG5 = 0;  ## get results


    my @opt_types = @$opt_types_ref;
    # my @loss_rates = (0.05, 0.1, 0.2, 0.4, 0.6, 0.8, 0.9, 0.93, 0.95, 0.97, 0.98, 0.99);
    my @loss_rates = (0.05, 0.1, 0.2, 0.4, 0.6, 0.8, 0.9, 0.95);

    
    my $output_file = "ElemRandLoss.$func.$file_name.$num_frames.$width.$height.$group_size.r$rank.period$period.$opt_swap_mat.$opt_dim.$drop_ele_mode.$drop_mode.elem$elem_frac.burst$burst_size.na$num_anomaly.anom$sigma_mag.noise$sigma_noise.thresh$thresh";
    open FH1, ">$output_dir/pred.$output_file.txt" or die $!;
    open FH2, ">$output_dir/dect.$output_file.txt" or die $!;
    

    foreach my $lri (0 .. @loss_rates-1) {
        my $loss_rate = $loss_rates[$lri];

        print FH1 $loss_rate;

        ## MSE
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];

            my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
            print FH1 ", ".$rets{METRIC}{0}{AVG};
        }
        
        ## MAE
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];

            my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
            print FH1 ", ".$rets{METRIC}{1}{AVG};
        }
        print FH1 "\n";

        ######################################

        print FH2 $loss_rate;

        ## prec
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];

            my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
            print FH2 ", ".$rets{METRIC}{8}{AVG};
        }

        ## recall
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];

            my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
            print FH2 ", ".$rets{METRIC}{9}{AVG};
        }

        ## f1
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];

            my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
            print FH2 ", ".$rets{METRIC}{10}{AVG};
        }

        ## jaccard
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];

            my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
            print FH2 ", ".$rets{METRIC}{11}{AVG};
        }

        ## best thresh
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];

            my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
            print FH2 ", ".$rets{METRIC}{12}{AVG};
        }
        print FH2 "\n";
    }

    close FH1;
    close FH2;


    ## plot filling in results
    my $y_max = get_y_max("ElemRandLoss", $file_name);
    my $cmd = "sed 's/FILE_NAME/pred.$output_file/g; s/FIG_NAME/pred.$output_file/g; s/X_RANGE_S/0/g; s/X_RANGE_E//g; s/Y_RANGE_E/$y_max/g; s/X_LABEL/Data Loss Probability/g; s/Y_LABEL/NMAE/g; ' plot.pred.mother.plot > tmp.plot.pred.plot";
    `$cmd`;

    open FH, ">>tmp.plot.pred.plot" or die $!;
    my $col = 2 + @opt_types;
    foreach my $oi (0 .. @opt_types-1) {
        my $opt_type = $opt_types[$oi];
        my $scheme_name = get_scheme_name($opt_type);
        print FH "\"\" " if($oi > 0);
        print FH "using 1:".($col+$oi)." with linespoints ls ".($oi%$NUM_CURVE+1)." title '{/Helvetica=28 $scheme_name}'";
        print FH ",\\" if($oi < @opt_types-1);
        print FH "\n";
    }
    close FH;

    $cmd = "gnuplot tmp.plot.pred.plot";
    `$cmd`;

    ## plot detecting results
    # $cmd = "sed 's/FILE_NAME/dect.$output_file/g; s/FIG_NAME/dect.$output_file/g; ' plot.dect.mother.plot > tmp.plot.dect.plot";
    # `$cmd`;

    # $cmd = "gnuplot tmp.plot.dect.plot";
    # `$cmd`;
    my $cmd = "sed 's/FILE_NAME/dect.$output_file/g; s/FIG_NAME/dect.$output_file/g; s/X_RANGE_S/0/g; s/X_RANGE_E//g; s/Y_RANGE_E/1/g; s/X_LABEL/Data Loss Probability/g; s/Y_LABEL/F1-Score/g; ' plot.pred.mother.plot > tmp.plot.dect.plot";
    `$cmd`;

    open FH, ">>tmp.plot.dect.plot" or die $!;
    my $col = 2 + 2*@opt_types;
    my $lens_st_col;
    foreach my $oi (0 .. @opt_types-1) {
        my $opt_type = $opt_types[$oi];
        my $scheme_name = get_scheme_name($opt_type);

        my $this_col = $col+$oi;
        if($opt_type eq "lens_st") {
            $lens_st_col = $this_col;
        }
        if($opt_type eq "srmf_lens_st_knn") {
            $this_col = $lens_st_col;
        }

        print FH "\"\" " if($oi > 0);
        print FH "using 1:$this_col with linespoints ls ".($oi%$NUM_CURVE+1)." title '{/Helvetica=28 $scheme_name}'";
        print FH ",\\" if($oi < @opt_types-1);
        print FH "\n";
    }
    close FH;

    $cmd = "gnuplot tmp.plot.dect.plot";
    `$cmd`;
}



sub get_y_max {
    my ($drop_mode, $file_name) = @_;
    my $y_max = 1.2;

    if($drop_mode eq "ElemRandLoss") {
        if   ($file_name eq "tm_abilene.od.")                            { $y_max = 1.6; }
        elsif($file_name eq "tm_totem.")                                 { $y_max = 2; }
        elsif($file_name eq "tm_3g.cell.bs.bs3.all.bin10.txt")           { $y_max = 1.8; }
        elsif($file_name eq "tm_sjtu_wifi.ap_load.all.bin600.top50.txt") { $y_max = 2.5; }
        elsif($file_name eq "Mob-Recv1run1.dat0_matrix.mat_dB.txt")      { $y_max = 0.25; }
        elsif($file_name eq "tm_telos_rssi.txt")                         { $y_max = 0.7; }
        elsif($file_name eq "tm_multi_loc_rssi.txt")                     { $y_max = 0.255; }
        elsif($file_name eq "tm_ron1.latency.")                          { $y_max = 0.8; }
    }

    return $y_max;
}


sub get_results {
    # srmf_based_pred.FILENAME.NUM_FRAMES.WIDTH.HEIGHT.GROUP_SIZE.rRANK.periodPERIOD.OPT_SWAP_MAT.OPT_TYPE.OPT_DIM.DROP_ELE_MODE.DROP_MODE.elemELEM_FRAC.lossLOSS_RATE.burstBURST_SIZE.naNUM_ANOM.anomSIGMA_MAG.noiseSIGMA_NOISE.threshTHRESH.seedSEED.txt
    my ($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh) = @_;

    my $DEBUG0 = 0;
    my $DEBUG1 = 1;
    my $DEBUG4 = 1;  ## missing files
    my $DEBUG5 = 1;  ## get results

    my %rets;
    my $num_ret = 15;
    # my @seeds = (1 .. 5);

    
    for my $seed (@seeds) {
        my $this_file_name = "$input_dir/$func.$file_name.$num_frames.$width.$height.$group_size.r$rank.period$period.$opt_swap_mat.$opt_type.$opt_dim.$drop_ele_mode.$drop_mode.elem$elem_frac.loss$loss_rate.burst$burst_size.na$num_anomaly.anom$sigma_mag.noise$sigma_noise.thresh$thresh.seed$seed.txt";
        
        unless(-e $this_file_name) {
            print "$this_file_name\n" if($DEBUG4);
            next;
        }


        # print "$this_file_name\n" if($DEBUG5);

        open FH, $this_file_name or die $!;
        while(<FH>) {
            chomp;
            my @tmp = split(/, /, $_);
            
            for my $mi (0 .. @tmp-1) {
                if($tmp[$mi] =~ /nan/i) { $tmp[$mi] = 0;  }
                else                    { $tmp[$mi] += 0; }

                push(@{ $rets{METRIC}{$mi}{VAL} }, $tmp[$mi]);

                print "'".$tmp[$mi]."', " if($DEBUG5);
            }
            print "\n" if($DEBUG5);
        }
        close FH;
    }


    ## get avg
    for my $mi (0 .. $num_ret-1) {
        if(exists $rets{METRIC}{$mi}{VAL}) {
            $rets{METRIC}{$mi}{AVG} = MyUtil::median(\@{ $rets{METRIC}{$mi}{VAL} });

        }
        else {
            $rets{METRIC}{$mi}{AVG} = 0;
        }
    }

    return %rets;

}

sub get_scheme_name {
    my ($opt_types) = @_;

    if($opt_types eq "srmf") {
        return "SRMF";
    }
    elsif($opt_types eq "srmf_knn") {
        return "SRMF+KNN";
    }
    elsif($opt_types eq "srmf_knn2") {
        return "SRMF+KNN";
    }
    elsif($opt_types eq "lens") {
        return "LENS";
    }
    elsif($opt_types eq "lens_knn") {
        return "LENS+KNN";
    }
    elsif($opt_types eq "lens_knn2") {
        return "LENS+KNN";
    }
    elsif($opt_types eq "srmf_lens_knn") {
        return "LENS+SRMF+KNN";
    }
    elsif($opt_types eq "srmf_lens_knn2") {
        return "LENS+SRMF+KNN";
    }
    elsif($opt_types eq "lens_st") {
        return "LENS ST";
    }
    elsif($opt_types eq "lens_st_knn") {
        return "LENS ST+KNN";
    }
    elsif($opt_types eq "lens_st_knn2") {
        return "LENS ST+KNN";
    }
    elsif($opt_types eq "srmf_lens_st_knn") {
        return "LENS ST+SRMF+KNN";
    }
    elsif($opt_types eq "lens_no_st") {
        return "LENS No ST";
    }
    elsif($opt_types eq "svd") {
        return "SVD";
    }
    elsif($opt_types eq "svd_base") {
        return "SVD base";
    }
    elsif($opt_types eq "svd_base_knn") {
        return "SVD base+KNN";
    }
    elsif($opt_types eq "knn") {
        return "KNN";
    }
    elsif($opt_types eq "nmf") {
        return "NMF";
    }
    else {
        return "$opt_types";
    }
}

