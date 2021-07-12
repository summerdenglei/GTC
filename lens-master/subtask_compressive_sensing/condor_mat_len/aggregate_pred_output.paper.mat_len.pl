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

use List::Util qw(first max maxstr min minstr reduce shuffle sum);
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
my $input_dir  = "/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/condor_mat_len/output";
my $output_dir = "/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/output_mat_len";
my $figure_dir = "/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/figures_mat_len";

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

my $plot_file;

my $num_frames;
my @num_framess;
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

@files = ("tm_abilene.od.", "tm_totem.", "tm_sjtu_wifi.ap_load.all.bin600.top50.txt", "tm_3g.cell.bs.bs3.all.bin10.txt", "tm_ron1.latency.", "Mob-Recv1run1.dat0_matrix.mat_dB.txt", "tm_telos_rssi.txt", "tm_multi_loc_rssi.txt", "static_trace13.ant1.mag.txt", "tm_ucsb_meshnet.connected.txt", "tm_umich_rss.txt");


@seeds = (1 .. 1);
@opt_swap_mats = ("org");
@opt_dims = ("2d");

@num_anomalies = (0.05);
@sigma_mags = (1);
@sigma_noises = (0);
@threshs = (-1);


my $is_interpolation = 1;

if($is_interpolation) {
    ## Interpolation
    @opt_types = ("svd_base", "svd_base_knn", "srmf", "srmf_knn", "lens3"); 
    # @opt_types = ("lens3"); 
    $drop_ele_mode = "elem";
    $drop_mode = "ind";         ## Interpolation
    $elem_frac = 1;
    @loss_rates = (0.5);        ## Interpolation
    $burst_size = 1;
    $plot_file = "plot.pred.mother.plot";
}
else {
    ## Prediction
    @opt_types = ("base", "srmf", "lens3");  
    $drop_ele_mode = "elem";
    $drop_mode = "half";      ## Prediction
    $elem_frac = 1;
    # @loss_rates = (0.2);      ## Prediction
    @loss_rates = (0.05);      ## Prediction
    $burst_size = 1;
    $plot_file = "plot.pred2.mother.plot";
}



for my $file_name (@files) {    
    
    my ($group_size, $rank, $period);
    my ($num_frames_ref, $display_frames_ref);
    ($num_frames_ref, $display_frames_ref, $width, $height, $group_size, $rank, $period) = get_trace_param($file_name, "unknown");
    @num_framess = @$num_frames_ref;
    @group_sizes = ($group_size);
    @ranks = ($rank);
    @periods = ($period);


    # $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output";
    # $input_dir  = "/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/condor/output";



    for my $rank (@ranks) {
        for my $period (@periods) {
            for my $opt_swap_mat (@opt_swap_mats) {
                for my $opt_dim (@opt_dims) {

                    $drop_ele_mode;
                    $drop_mode;
                    $elem_frac;
                    $burst_size;
                    for my $loss_rate (@loss_rates) {
                    
                        for my $num_anomaly (@num_anomalies) {
                            for my $sigma_mag (@sigma_mags) {
                                for my $sigma_noise (@sigma_noises) {
                                    for my $thresh (@threshs) {

                                        plot_mat_len($func, $file_name, $num_frames_ref, $display_frames_ref, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh, \@opt_types);

                                        # my @tmp = ("srmf", "srmf_knn", "lens3");
                                        # plot_anomaly_size_pr($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_noise, $thresh, \@tmp);

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



######################
## another anomaly detection plot
######################
# my @files = ("tm_3g.cell.bs.bs3.all.bin10.txt", "tm_sjtu_wifi.ap_load.all.bin600.top50.txt", "tm_abilene.od.", "tm_totem.", "Mob-Recv1run1.dat0_matrix.mat_dB.txt", "static_trace13.ant1.mag.txt", "tm_telos_rssi.txt", "tm_multi_loc_rssi.txt", "tm_umich_rss.txt", "tm_ucsb_meshnet.connected.txt");
# my @sigma_mags = (0, 0.1, 0.5, 1, 1.5, 2, 2.5, 3, 5);
# foreach my $sigma_mag (@sigma_mags) {
#     plot_pred_bar_f1($sigma_mag, \@files);
# }


1;

sub plot_mat_len {
    my ($func, $file_name, $num_frames_ref, $display_frames_ref, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh, $opt_types_ref) = @_;

    my $DEBUG0 = 0;
    my $DEBUG1 = 1;
    my $DEBUG4 = 0;  ## missing files
    my $DEBUG5 = 0;  ## get results


    my @num_framess = @$num_frames_ref;
    my @display_framess = @$display_frames_ref;
    my @opt_types = @$opt_types_ref;

    
    my $output_file = "MatLen.$func.$file_name.$width.$height.r$rank.period$period.$opt_swap_mat.$opt_dim.$drop_ele_mode.$drop_mode.elem$elem_frac.lr$loss_rate.burst$burst_size.na$num_anomaly.anom$sigma_mag.noise$sigma_noise.thresh$thresh";
    open FH1, ">$output_dir/pred.$output_file.txt" or die $!;
    # open FH2, ">$output_dir/dect.$output_file.txt" or die $!;
    

    foreach my $nfi (0 .. @num_framess-1) {
        my $num_frames = $num_framess[$nfi];
        my $display_frames = $display_framess[$nfi];
        $group_size = $num_frames;

        print FH1 $display_frames;

        ## MSE
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];

            my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $sigma_mag, $thresh);
            print FH1 ", ".$rets{METRIC}{0}{AVG};
        }
        
        ## MAE
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];

            my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $sigma_mag, $thresh);
            print FH1 ", ".$rets{METRIC}{1}{AVG};
        }

        ## GAMMA
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];

            my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $sigma_mag, $thresh);
            print FH1 ", ".$rets{METRIC}{12}{AVG};
        }
        print FH1 "\n";

        ######################################

        # next if($sigma_mag <= 0.5);

        # print FH2 $sigma_mag;

        # ## prec
        # foreach my $ti (0 .. @opt_types-1) {
        #     my $opt_type = $opt_types[$ti];

        #     my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
        #     print FH2 ", ".$rets{METRIC}{8}{AVG};
        # }

        # ## recall
        # foreach my $ti (0 .. @opt_types-1) {
        #     my $opt_type = $opt_types[$ti];

        #     my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
        #     print FH2 ", ".$rets{METRIC}{9}{AVG};
        # }

        # ## f1
        # foreach my $ti (0 .. @opt_types-1) {
        #     my $opt_type = $opt_types[$ti];

        #     my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
        #     print FH2 ", ".$rets{METRIC}{10}{AVG};
        # }

        # ## jaccard
        # foreach my $ti (0 .. @opt_types-1) {
        #     my $opt_type = $opt_types[$ti];

        #     my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
        #     print FH2 ", ".$rets{METRIC}{11}{AVG};
        # }

        # ## best thresh
        # foreach my $ti (0 .. @opt_types-1) {
        #     my $opt_type = $opt_types[$ti];

        #     my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
        #     print FH2 ", ".$rets{METRIC}{12}{AVG};
        # }
        # print FH2 "\n";
    }

    close FH1;
    # close FH2;


    ## plot filling in results
    my $y_max = get_y_max("MatLen", $drop_mode, $file_name);
    my $cmd = "sed 's/FILE_NAME/pred.$output_file/g; s/FIG_NAME/pred.$output_file/g; s/X_RANGE_S/".min(@display_framess)."/g; s/X_RANGE_E/".max(@display_framess)."/g; s/Y_RANGE_E/$y_max/g; s/Y2_RANGE_E/10/g; s/X_LABEL/Number of Time Bins/g; s/Y_LABEL/NMAE/g; s/Y2_LABEL/gamma/g; ' $plot_file > tmp.plot.pred.plot";
    `$cmd`;

    open FH, ">>tmp.plot.pred.plot" or die $!;
    my $col = 2 + @opt_types;
    foreach my $oi (0 .. @opt_types-1) {
        my $opt_type = $opt_types[$oi];
        my $scheme_name = get_scheme_name($opt_type);
        print FH "\"\" " if($oi > 0);
        print FH "using 1:".($col+$oi)." with linespoints ls ".($oi%$NUM_CURVE+1)." title '{/Helvetica=28 $scheme_name}' axes x1y1";
        print FH ",\\" if($oi < @opt_types-1);
        # print FH ",\\";
        print FH "\n";
    }

    # $col = 2 + @opt_types + @opt_types;
    # foreach my $oi (0 .. @opt_types-1) {
    #     my $opt_type = $opt_types[$oi];
    #     my $scheme_name = get_scheme_name($opt_type);
    #     next if($opt_type ne "lens3");
    #     print FH "\"\" ";
    #     # print FH "\"\" " if($oi > 0);
    #     print FH "using 1:".($col+$oi)." with linespoints ls 13 title '{/Helvetica=28 LENS:gamma}'  axes x1y2";
    #     # print FH "using 1:".($col+$oi)." w boxes title '{/Helvetica=28 $scheme_name}' fs pattern ".($oi%$NUM_CURVE+2)." ls ".($oi%$NUM_CURVE+1);
    #     # print FH ",\\" if($oi < @opt_types-1);
    #     print FH "\n";
    #     last;
    # }
    close FH;

    $cmd = "gnuplot tmp.plot.pred.plot";
    `$cmd`;

    # if($drop_mode eq "ind") {
    #     ## plot detecting results
    #     # $cmd = "sed 's/FILE_NAME/dect.$output_file/g; s/FIG_NAME/dect.$output_file/g; ' plot.dect.mother.plot > tmp.plot.dect.plot";
    #     # `$cmd`;

    #     # $cmd = "gnuplot tmp.plot.dect.plot";
    #     # `$cmd`;
    #     my $cmd = "sed 's/FILE_NAME/dect.$output_file/g; s/FIG_NAME/dect.$output_file/g; s/X_RANGE_S//g; s/X_RANGE_E//g; s/Y_RANGE_E/1/g; s/X_LABEL/Anomaly Size k/g; s/Y_LABEL/F1-Score/g; ' plot.pred.mother.plot > tmp.plot.dect.plot";
    #     `$cmd`;

    #     open FH, ">>tmp.plot.dect.plot" or die $!;
    #     my $col = 2 + 2*@opt_types;
    #     my $lens_st_col;
    #     foreach my $oi (0 .. @opt_types-1) {
    #         my $opt_type = $opt_types[$oi];
    #         my $scheme_name = get_scheme_name($opt_type);

    #         my $this_col = $col+$oi;
    #         if($opt_type eq "lens_st") {
    #             $lens_st_col = $this_col;
    #         }
    #         if($opt_type eq "srmf_lens_st_knn") {
    #             $this_col = $lens_st_col;
    #         }

    #         print FH "\"\" " if($oi > 0);
    #         print FH "using 1:$this_col with linespoints ls ".($oi%$NUM_CURVE+1)." title '{/Helvetica=28 $scheme_name}'";
    #         print FH ",\\" if($oi < @opt_types-1);
    #         print FH "\n";
    #     }
    #     close FH;

    #     $cmd = "gnuplot tmp.plot.dect.plot";
    #     `$cmd`;
    # }
}



sub get_y_max {
    my ($type, $drop_mode, $file_name) = @_;
    my $y_max = 1.2;

    if($type eq "MatLen") {
        if($drop_mode eq "ind") {
            if   ($file_name eq "tm_abilene.od.")                            { $y_max = 1.5; }
            elsif($file_name eq "tm_totem.")                                 { $y_max = 2; }
            elsif($file_name eq "tm_3g.cell.bs.bs3.all.bin10.txt")           { $y_max = 3; }
            elsif($file_name eq "tm_sjtu_wifi.ap_load.all.bin600.top50.txt") { $y_max = 3; }
            elsif($file_name eq "Mob-Recv1run1.dat0_matrix.mat_dB.txt")      { $y_max = 0.14; }
            elsif($file_name eq "tm_telos_rssi.txt")                         { $y_max = 0.8; }
            elsif($file_name eq "tm_multi_loc_rssi.txt")                     { $y_max = 0.3; }
            elsif($file_name eq "tm_ron1.latency.")                          { $y_max = 1.8; }
            elsif($file_name eq "tm_ucsb_meshnet.connected.txt")             { $y_max = 2; }
            elsif($file_name eq "tm_umich_rss.txt")                          { $y_max = 0.1; }
            elsif($file_name eq "static_trace13.ant1.mag.txt")               { $y_max = 0.6; }
        }
        else {
            if   ($file_name eq "tm_abilene.od.")                            { $y_max = 1.2; }
            elsif($file_name eq "tm_totem.")                                 { $y_max = 1.6; }
            elsif($file_name eq "tm_3g.cell.bs.bs3.all.bin10.txt")           { $y_max = 1.5; }
            elsif($file_name eq "tm_sjtu_wifi.ap_load.all.bin600.top50.txt") { $y_max = 1.5; }
            elsif($file_name eq "Mob-Recv1run1.dat0_matrix.mat_dB.txt")      { $y_max = 1.0; }
            elsif($file_name eq "tm_telos_rssi.txt")                         { $y_max = 0.6; }
            elsif($file_name eq "tm_multi_loc_rssi.txt")                     { $y_max = 0.2; }
            elsif($file_name eq "tm_ron1.latency.")                          { $y_max = 0.9; }
            elsif($file_name eq "tm_ucsb_meshnet.connected.txt")             { $y_max = 1.9; }
            elsif($file_name eq "tm_umich_rss.txt")                          { $y_max = 0.3; }
            elsif($file_name eq "static_trace13.ant1.mag.txt")               { $y_max = 0.7; }
        }
    }

    return $y_max;
}


sub get_results {
    # srmf_based_pred.FILENAME.NUM_FRAMES.WIDTH.HEIGHT.GROUP_SIZE.rRANK.periodPERIOD.OPT_SWAP_MAT.OPT_TYPE.OPT_DIM.DROP_ELE_MODE.DROP_MODE.elemELEM_FRAC.lossLOSS_RATE.burstBURST_SIZE.naNUM_ANOM.anomSIGMA_MAG.noiseSIGMA_NOISE.threshTHRESH.seedSEED.txt
    my ($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $sigma_mag, $thresh) = @_;

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
    elsif($opt_types eq "lens3") {
        return "LENS";
    }
    elsif($opt_types eq "lens3_knn") {
        return "LENS+KNN";
    }
    elsif($opt_types eq "srmf_lens3_knn") {
        return "LENS+SRMF+KNN";
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



sub plot_anomaly_size_pr {
    my ($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_noise, $thresh, $opt_types_ref) = @_;

    my $DEBUG0 = 0;
    my $DEBUG1 = 1;
    my $DEBUG4 = 0;  ## missing files
    my $DEBUG5 = 0;  ## get results


    my @opt_types = @$opt_types_ref;
    # my @sigma_mags = (0, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.8, 1);
    my @sigma_mags = (0.1, 0.5, 1, 1.5, 2, 2.5, 3, 5);

    
    my $output_file = "AnomalySize.$func.$file_name.$num_frames.$width.$height.$group_size.r$rank.period$period.$opt_swap_mat.$opt_dim.$drop_ele_mode.$drop_mode.elem$elem_frac.lr$loss_rate.burst$burst_size.na$num_anomaly.noise$sigma_noise.thresh$thresh";
    

    foreach my $asi (0 .. @sigma_mags-1) {
        my $sigma_mag = $sigma_mags[$asi];

        my $cmd = "sed 's/FILE_NAME/pr.$output_file.anom$sigma_mag/g; s/FIG_NAME/pr.$output_file.anom$sigma_mag/g; s/X_RANGE_S/0/g; s/X_RANGE_E/1/g; s/Y_RANGE_E/1/g; s/X_LABEL/Precision/g; s/Y_LABEL/Recall/g; ' plot.pr.mother.plot > tmp.plot.pr.plot";
        `$cmd`;
        open FH_P, ">> tmp.plot.pr.plot" or die $!;

        
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];
            my $scheme_name = get_scheme_name($opt_type);

            open FHO, ">$output_dir/pr.$output_file.anom$sigma_mag.$opt_type.txt" or die $!;

            my %rets = get_pr_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh, 1);
            
            
            foreach my $lr (sort {$a <=> $b} (keys %rets)) {
                print FHO " ".$rets{$lr}{PREC}.", ".$rets{$lr}{RECALL}."\n";
            }

            close FHO;

            
            print FH_P "data_dir.file_name.\".$opt_type.txt\" using 1:2 with linespoints ls ".($ti%$NUM_CURVE+1)." title '{/Helvetica=28 $scheme_name}'";
            print FH_P ",\\" if($ti < @opt_types-1);
            print FH_P "\n";
        }

        close FH_P;


        $cmd = "gnuplot tmp.plot.pr.plot";
        `$cmd`;
    }

}


sub get_pr_results {
    my ($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh, $seed) = @_;

    my $input_dir = "/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/condor/pr";
    my $this_file_name = "$input_dir/$file_name.$num_frames.$width.$height.$group_size.r$rank.period$period.$opt_swap_mat.$opt_type.$opt_dim.$drop_ele_mode.$drop_mode.elem$elem_frac.loss$loss_rate.burst$burst_size.na$num_anomaly.anom$sigma_mag.noise$sigma_noise.thresh$thresh.seed$seed.txt";

    my $prev_pr = -1;
    my %ret;

    open FH, "$this_file_name" or die "\n$this_file_name\n".$!;
    while (<FH>) {
        chomp;
        my ($lr, $pr, $rc) = split(/,/, $_);
        
        if($pr eq "NaN") { $pr = 0; }
        else { $pr += 0; }

        if($rc eq "NaN") { $rc = 0; }
        else { $rc += 0; }

        last if($pr < $prev_pr);


        $prev_pr = $pr;

        $ret{$lr}{PREC} = $pr;
        $ret{$lr}{RECALL} = $rc;
    }
    close FH;

    return %ret;
}





# sub plot_pred_bar_f1 {
#     my ($sigma_mag, $ref_files) = @_;
#     my @files = @$ref_files;

#     my $seeds = 1;
#     my @opt_types = ("srmf_knn", "lens3");
#     my $opt_swap_mat = "org";
#     my $opt_dim = "2d";

#     my $loss_rate = 0.5;
#     my $num_anomaly = 0.05;
#     my $sigma_noise = 0;
#     my $thresh = -1;

#     my $drop_ele_mode = "elem";
#     my $drop_mode = "ind";
#     my $elem_frac = 1;
#     my $burst_size = 1;

#     my $output_file = "AnomalySize.$func.$opt_swap_mat.$opt_dim.$drop_ele_mode.$drop_mode.elem$elem_frac.lr$loss_rate.burst$burst_size.na$num_anomaly.noise$sigma_noise.thresh$thresh";

#     my $cmd = "sed 's/FILE_NAME/dect.bar.$output_file.anom$sigma_mag/g; s/FIG_NAME/dect.bar.$output_file.anom$sigma_mag/g; s/X_RANGE_S//g; s/X_RANGE_E//g; s/Y_RANGE_S/0/g; s/Y_RANGE_E/1/g; s/X_LABEL//g; s/Y_LABEL/F1-Score/g; ' plot.dect.bar.mother.plot > tmp.plot.dect.bar.plot";
#     `$cmd`;
#     open FH_P, ">> tmp.plot.dect.bar.plot" or die $!;

#     open FH3, ">$output_dir/dect.bar.$output_file.anom$sigma_mag.txt" or die $!;

#     my $first = 1;
#     for my $file_name (@files) {  
#         my $trace_name = get_trace_name($file_name);
#         print FH3 "\"$trace_name\"";

#         foreach my $ti (0 .. @opt_types-1) {
#             my $opt_type = $opt_types[$ti];
#             my $scheme_name = get_scheme_name($opt_type);

#             my ($num_frames, $width, $height, $group_size, $rank, $period) = get_trace_param($file_name, $opt_type);

#             my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
#             print FH3 "\t".$rets{METRIC}{10}{AVG};


#             if($first == 1) {
#                 my $this_col = 2 + $ti;
                
#                 print FH_P "'' " if($ti > 0);
#                 print FH_P "using $this_col:xtic(1) t '{/Helvetica=28 $scheme_name}' fs pattern ".($ti+2)." ls ".($ti%$NUM_CURVE+1);
#                 print FH_P ",\\" if($ti < @opt_types-1);
#                 print FH_P "\n";
#             }
#         }

#         $first = 0;
#         print FH3 "\n";
#     }
#     close FH3;
#     close FH_P;

#     $cmd = "gnuplot tmp.plot.dect.bar.plot";
#     `$cmd`;
# }


sub get_trace_name {
    my ($file_name) = @_;

    if($file_name eq "tm_abilene.od.") {
        return "Abilene";
    }
    elsif($file_name eq "tm_totem.") {
        return "GEANT";
    }
    elsif($file_name eq "tm_sjtu_wifi.ap_load.all.bin600.top50.txt") {
        return "WiFi";
    }
    elsif($file_name eq "tm_3g.cell.bs.bs3.all.bin10.txt") {
        return "3G";
    }
    elsif($file_name eq "Mob-Recv1run1.dat0_matrix.mat_dB.txt") {
        return "1-ch CSI";
    }
    elsif($file_name eq "static_trace13.ant1.mag.txt") {
        return "Multi-ch CSI";
    }
    elsif($file_name eq "tm_multi_loc_rssi.txt") {
        return "CU RSSI";
    }
    elsif($file_name eq "tm_telos_rssi.txt") {
        return "Cister RSSI";
    }
    elsif($file_name eq "tm_ucsb_meshnet.connected.txt") {
        return "UCSB Meshnet";
    }
    elsif($file_name eq "tm_ucsb_meshnet.") {
        return "UCSB Meshnet";
    }
    elsif($file_name eq "tm_umich_rss.txt") {
        return "UMich RSS";
    }
    elsif($file_name eq "tm_ron1.latency.") {
        return "Delay";
    }
    else {
        return "Unknown";
    }

}

sub get_trace_param {
    my ($file_name, $opt_type) = @_;

    my (@num_framess, @display_framess, $width, $height, $group_size, $rank, $period);
    
    #############
    ## WiFi
    if($file_name eq "tm_sjtu_wifi.ap_load.all.bin600.top50.txt") {
        @num_framess = (10, 20, 40, 60, 80, 100);
        @display_framess = (12, 24, 48, 72, 96, 118);
        $width = 50;
        $height = 1;

        $group_size = 100;
        $period = 1;

        # if($opt_type eq "lens3") { $rank = 32; }
        # else { $rank = 32; }
        $rank = 8;

        # $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.wifi";
    }
    ###############
    ## 3G
    elsif($file_name eq "tm_3g.cell.bs.bs3.all.bin10.txt") {
        # $num_frames = 100;
        @num_framess = (14, 28, 56, 84, 112, 144);
        @display_framess = (14, 28, 56, 84, 112, 144);
        $width = 472;
        $height = 1;

        $group_size = 144;
        $period = 1;

        # if($opt_type eq "lens3") { $rank = 32; }
        # else { $rank = 16; }
        $rank = 32;

        # $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.3g";
    }
    #############
    ## GEANT
    elsif($file_name eq "tm_totem.") {
        # $num_frames = 100;
        @num_framess = (67, 134, 268, 402, 536, 672);
        @display_framess = (67, 134, 268, 402, 536, 672);
        $width = 23;
        $height = 23;

        # $group_size = 100;
        $group_size = 672;
        $period = 1;

        # if($opt_type eq "lens3") { $rank = 64; }
        # else { $rank = 16; }
        $rank = 25;

        # $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.geant";
    }
    #############
    ## Abilene
    elsif($file_name eq "tm_abilene.od.") {
        # $num_frames = 100;
        @num_framess = (100, 200, 400, 600, 800, 1008);
        @display_framess = (100, 200, 400, 600, 800, 1008);
        $width = 11;
        $height = 11;

        # $group_size = 100;
        $group_size = 1008;
        $period = 1;

        # if($opt_type eq "lens3") { $rank = 64; }
        # else { $rank = 64; }
        $rank = 20;

        # $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.abilene";
    }
    #############
    ## CSI
    elsif($file_name eq "Mob-Recv1run1.dat0_matrix.mat_dB.txt") {
        @num_framess = (100, 200, 400, 600, 800, 1000);
        @display_framess = (900, 1800, 3600, 5400, 7200, 9000);
        $width = 90;
        $height = 1;

        $group_size = 1000;
        $period = 1;

        # if($opt_type eq "lens3") { $rank = 64; }
        # else { $rank = 64; }
        $rank = 16;

        # $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.csi";
    }
    #############
    ## RON
    elsif($file_name eq "tm_ron1.latency.") {
        @num_framess = (50, 100, 200, 300, 400, 494);
        @display_framess = (50, 100, 200, 300, 400, 494);
        $width = 12;
        $height = 12;

        $group_size = 494;
        $period = 1;

        # if($opt_type eq "lens3") { $rank = 32; }
        # else { $rank = 16; }
        $rank = 16;

        # $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.ron";
    }
    #############
    ## RSSI - telos
    elsif($file_name eq "tm_telos_rssi.txt") {
        @num_framess = (50, 100, 200, 300, 400, 500);
        @display_framess = (1000, 2000, 4000, 6000, 8000, 10000);
        $width = 16;
        $height = 1;

        $group_size = 500;
        $period = 1;

        # if($opt_type eq "lens3") { $rank = 12; }
        # else { $rank = 12; }
        $rank = 8;

        # $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.rssi.telos";
    }
    #############
    ## RSSI - multi location
    elsif($file_name eq "tm_multi_loc_rssi.txt") {
        @num_framess = (50, 100, 200, 300, 400, 500);
        @display_framess = (50, 100, 200, 300, 400, 500);
        $width = 895;
        $height = 1;

        $group_size = 500;
        $period = 1;

        # if($opt_type eq "lens3") { $rank = 32; }
        # else { $rank = 32; }
        $rank = 16;

        # $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output.rssi.multi";
    }
    #############
    ## Channel CSI
    elsif($file_name eq "static_trace13.ant1.mag.txt") {
        @num_framess = (50, 100, 120, 400, 440, 500);
        @display_framess = (500, 1000, 2000, 3000, 4000, 5000);
        $width = 270;
        $height = 1;

        $group_size = 500;
        $period = 1;

        # if($opt_type eq "lens3") { $rank = 64; }
        # else { $rank = 32; }
        $rank = 16;

        # $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output";
    }
    #############
    ## UCSB Meshnet
    elsif($file_name eq "tm_ucsb_meshnet.connected.txt") {
        @num_framess = (100, 200, 400, 600, 800, 1000);
        @display_framess = (153, 306, 712, 918, 1224, 1527);
        $width = 425;
        $height = 1;

        $group_size = 1000;
        $period = 1;

        # if($opt_type eq "lens3") { $rank = 64; }
        # else { $rank = 32; }
        $rank = 16;

        # $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output";
    }
    #############
    ## UMich RSS
    elsif($file_name eq "tm_umich_rss.txt") {
        @num_framess = (100, 200, 400, 600, 800, 1000);
        @display_framess = (313, 626, 1252, 1878, 2504, 3127);
        $width = 182;
        $height = 1;

        $group_size = 1000;
        $period = 1;

        # if($opt_type eq "lens3") { $rank = 64; }
        # else { $rank = 32; }
        $rank = 32;

        # $input_dir  = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output";
    }
    else {
        die "no such file: $file_name\n";
    }

    return (\@num_framess, \@display_framess, $width, $height, $group_size, $rank, $period);
}



