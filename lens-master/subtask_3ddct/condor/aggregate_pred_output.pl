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


#############
# Constants
#############
my $NUM_CURVE = 8;


#############
# Variables
#############
my $input_dir  = "/u/yichao/anomaly_compression/condor_data/subtask_3ddct/condor/output";
my $output_dir = "/u/yichao/anomaly_compression/condor_data/subtask_3ddct/output";
my $figure_dir = "/u/yichao/anomaly_compression/condor_data/subtask_3ddct/figures";
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
my $func = "dct_based_pred";
open FH_OUT, "> $output_dir/$func.txt" or die $!;
open FH_MEAN_OUT, "> $output_dir/$func.mean.txt" or die $!;

my $num_frames;
my $width;
my $height;
my @opt_swap_mats;
my @chunk_ws;
my @chunk_hs;
my @sel_chunks;
my @seeds;
my @drop_rates;
my @group_sizes;
my @opt_types;
my @quantizations;
my @files;

# @files = ("TM_Airport_period5_");
# @files = ("tm.sort_ips.ap.gps.1.sub_CN.txt.3600.");
# @files = ("tm.sort_ips.ap.country.txt.3600.");
# @files = ("tm.sort_ips.ap.bgp.8.txt.3600.");
# @files = ("tm.sort_ips.ap.bgp.10.sub_CN.txt.3600.");

# @files = ("tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.");

# @files = ("tm_3g_region_all.res0.004.bin60.", "tm_3g_region_all.res0.004.bin60.sub.", "tm_3g_region_all.res0.002.bin60.sub.");

@files = ("tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.", "tm_3g_region_all.res0.004.bin60.sub.");

for my $file_name (@files) {
    

    # #######################
    # if($file_name eq "TM_Manhattan_period5_") {
    #     $num_frames = 12;
    #     $width = 500;
    #     $height = 500;

    #     @chunk_sizes = (30, 50, 100);
    #     @sel_chunks = (1, 5, 10, 20, 30);
    # }
    # elsif($file_name eq "TM_Airport_period5_") {
    #     $num_frames = 12;
    #     $width = 300;
    #     $height = 300;

    #     @chunk_sizes = (30, 50, 100);
    #     @sel_chunks = (1, 5, 10, 20, 30);
    # }
    # #######################
    # elsif($file_name eq "tm.select_matrix_for_id-Assignment.txt.60.") {
    #     $num_frames = 12;
    #     $width = 28;
    #     $height = 28;

    #     @chunk_sizes = (10, 14);
    #     @sel_chunks = (1, 2, 3, 5, 10);
    # }
    # #######################
    # elsif($file_name eq "tm.sort_ips.ap.country.txt.3600.") {
    #     $num_frames = 8;
    #     $width = 400;
    #     $height = 400;

    #     @chunk_sizes = (40, 100, 200);
    #     @sel_chunks = (1, 5, 10, 20, 30);
    # }
    # elsif($file_name eq "tm.sort_ips.ap.gps.5.txt.3600.") {
    #     $num_frames = 8;
    #     $width = 738;
    #     $height = 738;

    #     @chunk_sizes = (70, 125, 247);
    #     @sel_chunks = (1, 5, 10, 20, 30);
    # }
    # elsif($file_name eq "tm.sort_ips.ap.gps.1.sub_CN.txt.3600.") {
    #     $num_frames = 8;
    #     $width = 410;
    #     $height = 410;

    #     @chunk_sizes = (41, 103, 205);
    #     @sel_chunks = (1, 5, 10, 20, 30);
    # }
    # elsif($file_name eq "tm.sort_ips.ap.bgp.8.txt.3600.") {
    #     $num_frames = 8;
    #     $width = 421;
    #     $height = 421;

    #     @chunk_sizes = (43, 106, 211);
    #     @sel_chunks = (1, 5, 10, 20, 30);
    # }
    # elsif($file_name eq "tm.sort_ips.ap.bgp.10.sub_CN.txt.3600.") {
    #     $num_frames = 8;
    #     $width = 403;
    #     $height = 403;

    #     @chunk_sizes = (41, 101, 202);
    #     @sel_chunks = (1, 5, 10, 20, 30);
    # }
    # #######################
    if($file_name eq "tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.") {
        $num_frames = 19;
        $width = 217;
        $height = 400;

        @chunk_ws = (22, 40);
        @chunk_hs = (40, 40);
    }
    #######################
    if($file_name eq "tm_3g_region_all.res0.004.bin60.") {
        $num_frames = 24;
        $width = 324;
        $height = 475;

        @chunk_ws = (33, 66);
        @chunk_hs = (48, 96);
    }
    if($file_name eq "tm_3g_region_all.res0.004.bin60.sub.") {
        $num_frames = 24;
        $width = 60;
        $height = 60;

        @chunk_ws = (6, 10);
        @chunk_hs = (6, 10);
    }
    if($file_name eq "tm_3g_region_all.res0.002.bin60.") {
        $num_frames = 24;
        $width = 647;
        $height = 949;

        @chunk_ws = (65, 130);
        @chunk_hs = (95, 190);
    }
    if($file_name eq "tm_3g_region_all.res0.002.bin60.sub.") {
        $num_frames = 24;
        $width = 120;
        $height = 100;

        @chunk_ws = (12, 24);
        @chunk_hs = (10, 20);
    }
    

    @seeds = (1 .. 10);
    @opt_swap_mats = (0, 1, 3);
    @drop_rates = (0, 0.01, 0.05, 0.1, 0.2, 0.3);
    @group_sizes = (4);
    @opt_types = (0, 1);
    @sel_chunks = (1, 5, 10, 20, 30);
    @quantizations = (10, 30, 50, 100);


    for my $drop_rate (@drop_rates) {

        for my $opt_swap_mat (@opt_swap_mats) {
            if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE})) {
                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = -1;
                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} = -1;
                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} = -1;
            }

            for my $group_size (@group_sizes) {
                if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MSE})) {
                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MSE} = -1;
                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MAE} = -1;
                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{CC} = -1;
                }
                
                for my $opt_type (@opt_types) {
                    if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MSE})) {
                        $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MSE} = -1;
                        $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MAE} = -1;
                        $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{CC} = -1;
                    }

                    ##############
                    if($opt_type == 0) {
                        my $chunk_width = 0;
                        my $chunk_height = 0;
                        my $sel_chunks = 0;

                        for my $quantization (@quantizations) {
                            if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{QUANTIZATION}{$quantization}{MSE})) {
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{QUANTIZATION}{$quantization}{MSE} = -1;
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{QUANTIZATION}{$quantization}{MAE} = -1;
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{QUANTIZATION}{$quantization}{CC} = -1;
                            }


                            my @mses;
                            my @maes;
                            my @ccs;
                            my @ratios;
                            for my $seed (@seeds) {
                                my $this_file_name = "$input_dir/$func.$file_name.$num_frames.$width.$height.$group_size.$opt_swap_mat.$opt_type.$chunk_width.$chunk_height.$sel_chunks.$quantization.$drop_rate.$seed.txt";
                                die "cannot find the file: $this_file_name\n" unless(-e $this_file_name);

                                print "$this_file_name\n";
                                
                                open FH, $this_file_name or die $!;
                                while(<FH>) {
                                    my @ret = split(/, /, $_);
                                    my $mse   = $ret[0] + 0;
                                    my $mae   = $ret[1] + 0;
                                    my $cc    = $ret[2] + 0;
                                    my $ratio = $ret[3] + 0;

                                    ## XXX: figure out why nan
                                    if($mse eq "nan") {
                                        $mse = 0;
                                    }
                                    if($mae eq "nan") {
                                        $mae = 0;
                                    }
                                    if($cc eq "nan") {
                                        $cc = 0;
                                    }

                                    push(@mses, $mse);
                                    push(@maes, $mae);
                                    push(@ccs, $cc);
                                    push(@ratios, $ratio);

                                    my $buf = "$file_name, $num_frames, $width, $height, $opt_swap_mat, $group_size, $opt_type, $chunk_width, $chunk_height, $sel_chunks, $quantization, $drop_rate, $seed, $mse, $mae, $cc, $ratio\n";
                                    print $buf;
                                    print FH_OUT $buf;
                                }
                            } ## end seeds
                            my $avg_mse = MyUtil::average(\@mses);
                            my $avg_mae = MyUtil::average(\@maes);
                            my $avg_cc = MyUtil::average(\@ccs);
                            my $avg_ratio = MyUtil::average(\@ratios);

                            my $buf = "$file_name, $num_frames, $width, $height, $opt_swap_mat, $group_size, $opt_type, $chunk_width, $chunk_height, $sel_chunks, $quantization, $drop_rate, $avg_mse, $avg_mae, $avg_cc, $avg_ratio\n";
                            print FH_MEAN_OUT $buf;


                            ## MSE
                            if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} or 
                               $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} == -1) {
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = $avg_mse;
                            }
                            if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MSE} or 
                               $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MSE} == -1) {
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MSE} = $avg_mse;
                            }
                            if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MSE} or 
                               $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MSE} == -1) {
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MSE} = $avg_mse;
                            }
                            if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{QUANTIZATION}{$quantization}{MSE} or 
                               $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{QUANTIZATION}{$quantization}{MSE} == -1) {
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{QUANTIZATION}{$quantization}{MSE} = $avg_mse;
                            }
                            ## MAE
                            if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} or 
                               $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} == -1) {
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} = $avg_mae;
                            }
                            if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MAE} or 
                               $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MAE} == -1) {
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MAE} = $avg_mae;
                            }
                            if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MAE} or 
                               $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MAE} == -1) {
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MAE} = $avg_mae;
                            }
                            if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{QUANTIZATION}{$quantization}{MAE} or 
                               $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{QUANTIZATION}{$quantization}{MAE} == -1) {
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{QUANTIZATION}{$quantization}{MAE} = $avg_mae;
                            }
                            ## CC
                            if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} or 
                               $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} == -1) {
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} = $avg_cc;
                            }
                            if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{CC} or 
                               $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{CC} == -1) {
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{CC} = $avg_cc;
                            }
                            if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{CC} or 
                               $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{CC} == -1) {
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{CC} = $avg_cc;
                            }
                            if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{QUANTIZATION}{$quantization}{CC} or 
                               $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{QUANTIZATION}{$quantization}{CC} == -1) {
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{QUANTIZATION}{$quantization}{CC} = $avg_cc;
                            }
                        }  ## end quantizations
                    }  ## end if opt_type == 0
                    elsif($opt_type == 1) {
                        my $quantization = 0;   

                        for my $chunk_size (0..@chunk_ws-1) {
                            my $chunk_width = $chunk_ws[$chunk_size];
                            my $chunk_height = $chunk_hs[$chunk_size];

                            if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{CHUNK_SIZE}{$chunk_size}{MSE})) {
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{CHUNK_SIZE}{$chunk_size}{MSE} = -1;
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{CHUNK_SIZE}{$chunk_size}{MAE} = -1;
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{CHUNK_SIZE}{$chunk_size}{CC} = -1;
                            }

                            for my $sel_chunks (@sel_chunks) {
                                if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{SEL_CHUNKS}{$sel_chunks}{MSE})) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{SEL_CHUNKS}{$sel_chunks}{MSE} = -1;
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{SEL_CHUNKS}{$sel_chunks}{MAE} = -1;
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{SEL_CHUNKS}{$sel_chunks}{CC} = -1;
                                }


                                my @mses;
                                my @maes;
                                my @ccs;
                                my @ratios;
                                for my $seed (@seeds) {
                                    my $this_file_name = "$input_dir/$func.$file_name.$num_frames.$width.$height.$group_size.$opt_swap_mat.$opt_type.$chunk_width.$chunk_height.$sel_chunks.$quantization.$drop_rate.$seed.txt";
                                    die "cannot find the file: $this_file_name\n" unless(-e $this_file_name);

                                    print "$this_file_name\n";
                                    
                                    open FH, $this_file_name or die $!;
                                    while(<FH>) {
                                        my @ret = split(/, /, $_);
                                        my $mse = $ret[0] + 0;
                                        my $mae = $ret[1] + 0;
                                        my $cc  = $ret[2] + 0;
                                        my $ratio  = $ret[3] + 0;

                                        ## XXX: figure out why nan
                                        if($mse eq "nan") {
                                            $mse = 0;
                                        }
                                        if($mae eq "nan") {
                                            $mae = 0;
                                        }
                                        if($cc eq "nan") {
                                            $cc = 0;
                                        }

                                        push(@mses, $mse);
                                        push(@maes, $mae);
                                        push(@ccs, $cc);
                                        push(@ratios, $ratio);

                                        my $buf = "$file_name, $num_frames, $width, $height, $opt_swap_mat, $group_size, $opt_type, $chunk_width, $chunk_height, $sel_chunks, $quantization, $drop_rate, $seed, $mse, $mae, $cc, $ratio\n";
                                        print $buf;
                                        print FH_OUT $buf;
                                    }
                                } ## end seeds
                                my $avg_mse = MyUtil::average(\@mses);
                                my $avg_mae = MyUtil::average(\@maes);
                                my $avg_cc = MyUtil::average(\@ccs);
                                my $avg_ratio = MyUtil::average(\@ratios);

                                my $buf = "$file_name, $num_frames, $width, $height, $opt_swap_mat, $group_size, $opt_type, $chunk_width, $chunk_height, $sel_chunks, $quantization, $drop_rate, $avg_mse, $avg_mae, $avg_cc, $avg_ratio\n";
                                print FH_MEAN_OUT $buf;


                                ## MSE
                                if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = $avg_mse;
                                }
                                if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MSE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MSE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MSE} = $avg_mse;
                                }
                                if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MSE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MSE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MSE} = $avg_mse;
                                }
                                if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{CHUNK_SIZE}{$chunk_size}{MSE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{CHUNK_SIZE}{$chunk_size}{MSE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{CHUNK_SIZE}{$chunk_size}{MSE} = $avg_mse;
                                }
                                if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{SEL_CHUNKS}{$sel_chunks}{MSE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{SEL_CHUNKS}{$sel_chunks}{MSE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{SEL_CHUNKS}{$sel_chunks}{MSE} = $avg_mse;
                                }
                                ## MAE
                                if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} = $avg_mae;
                                }
                                if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MAE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MAE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MAE} = $avg_mae;
                                }
                                if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MAE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MAE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MAE} = $avg_mae;
                                }
                                if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{CHUNK_SIZE}{$chunk_size}{MAE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{CHUNK_SIZE}{$chunk_size}{MAE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{CHUNK_SIZE}{$chunk_size}{MAE} = $avg_mae;
                                }
                                if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{SEL_CHUNKS}{$sel_chunks}{MAE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{SEL_CHUNKS}{$sel_chunks}{MAE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{SEL_CHUNKS}{$sel_chunks}{MAE} = $avg_mae;
                                }
                                ## CC
                                if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} = $avg_cc;
                                }
                                if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{CC} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{CC} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{CC} = $avg_cc;
                                }
                                if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{CC} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{CC} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{CC} = $avg_cc;
                                }
                                if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{CHUNK_SIZE}{$chunk_size}{CC} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{CHUNK_SIZE}{$chunk_size}{CC} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{CHUNK_SIZE}{$chunk_size}{CC} = $avg_cc;
                                }
                                if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{SEL_CHUNKS}{$sel_chunks}{CC} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{SEL_CHUNKS}{$sel_chunks}{CC} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{SEL_CHUNKS}{$sel_chunks}{CC} = $avg_cc;
                                }

                            }  ## end sel_chunks
                        }  ## end chunk_sizes
                    }  ## end if opt_type == 1
                    else {
                        die "wrong opt_type: $opt_type\n";
                    }
                }  ## end opt_types
            }  ## end group_sizes
        }  ## end opt_swap_mat
    }  ## end drop_rates
}  ## end files
close FH_OUT;
close FH_MEAN_OUT;


#############
# Statistics
#############
open FH_BEST_OUT, "> $output_dir/$func.best.txt" or die $!;
foreach my $trace (sort {$a cmp $b} (keys %{ $best{TRACE} })) {
    foreach my $drop_rate (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE} })) {

        foreach my $metric ("MSE", "MAE", "CC") {
            foreach my $param (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate} }) {
                foreach my $param_val (sort {$a cmp $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{$param} }) ) {

                    print "$trace (drop $drop_rate), $param=$param_val, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{$param}{$param_val}{$metric}."\n";
                    print FH_BEST_OUT "$trace (drop $drop_rate), $param=$param_val, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{$param}{$param_val}{$metric}."\n";
                }
            }
        }

    }
    print "\n";
}
close FH_BEST_OUT;
