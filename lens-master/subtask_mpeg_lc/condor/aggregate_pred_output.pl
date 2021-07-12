#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.11.08 @ UT Austin
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
my $input_dir  = "/u/yichao/anomaly_compression/condor_data/subtask_mpeg_lc/condor/output";
my $output_dir = "/u/yichao/anomaly_compression/condor_data/subtask_mpeg_lc/output";
my $figure_dir = "/u/yichao/anomaly_compression/condor_data/subtask_mpeg_lc/figures";
my $gnuplot_mother = "plot.pr";

## data - TRACE - OPT_DECT - OPT_DELTA - BLOCK_SIZE - THRESH - [TP, TN, FP, TN, ...]
my %data = ();
## best - TRACE - [OPT_DECT | OPT_DELTA | BLOCK_SIZE] - [F1SCORE | SETTING | FP | ...]
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
my $func = "mpeg_lc_based_pred";
open FH_OUT, "> $output_dir/$func.txt" or die $!;
open FH_MEAN_OUT, "> $output_dir/$func.mean.txt" or die $!;

my $num_frames;
my $width;
my $height;
my @opt_swap_mats;
my @block_ws;
my @block_hs;
my @seeds;
my @drop_rates;
my @opt_deltas;
my @opt_scopes;
my @opt_sel_methods;
my @num_sel_blocks1;
my @num_sel_blocks2;
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

    #     @block_sizes = (30);
    #     @num_sel_blocks2 = (10, 50, 100, 200);
    # }
    # elsif($file_name eq "TM_Airport_period5_") {
    #     $num_frames = 12;
    #     $width = 300;
    #     $height = 300;

    #     @block_sizes = (30);
    #     @num_sel_blocks2 = (10, 50, 100, 200);
    # }
    # #######################
    # elsif($file_name eq "tm.select_matrix_for_id-Assignment.txt.60.") {
    #     $num_frames = 12;
    #     $width = 28;
    #     $height = 28;

    #     @block_sizes = (10, 14, 28);
    #     @num_sel_blocks2 = (5, 10, 20);
    # }
    # #######################
    # elsif($file_name eq "tm.sort_ips.ap.country.txt.3600.") {
    #     $num_frames = 8;
    #     $width = 400;
    #     $height = 400;

    #     @block_sizes = (40, 100);
    #     # @num_sel_blocks2 = (4, 8, 16);
    #     @num_sel_blocks2 = (4, 16);
    # }
    # elsif($file_name eq "tm.sort_ips.ap.gps.5.txt.3600.") {
    #     $num_frames = 8;
    #     $width = 738;
    #     $height = 738;

    #     @block_sizes = (70, 125);
    #     # @num_sel_blocks2 = (4, 8, 16);
    #     @num_sel_blocks2 = (4, 16);
    # }
    # elsif($file_name eq "tm.sort_ips.ap.gps.1.sub_CN.txt.3600.") {
    #     $num_frames = 8;
    #     $width = 410;
    #     $height = 410;

    #     @block_sizes = (41, 103);
    #     # @num_sel_blocks2 = (4, 8, 16);
    #     @num_sel_blocks2 = (4, 16);
    # }
    # elsif($file_name eq "tm.sort_ips.ap.bgp.8.txt.3600.") {
    #     $num_frames = 8;
    #     $width = 421;
    #     $height = 421;

    #     @block_sizes = (43, 106);
    #     # @num_sel_blocks2 = (4, 8, 16);
    #     @num_sel_blocks2 = (4, 16);
    # }
    # elsif($file_name eq "tm.sort_ips.ap.bgp.10.sub_CN.txt.3600.") {
    #     $num_frames = 8;
    #     $width = 403;
    #     $height = 403;

    #     @block_sizes = (41, 101);
    #     # @num_sel_blocks2 = (4, 8, 16, 64);
    #     @num_sel_blocks2 = (4, 16);
    # }
    # #######################
    if($file_name eq "tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.") {
        $num_frames = 19;
        $width = 217;
        $height = 400;

        @block_ws = (22, 40, 55, 110);
        @block_hs = (40, 40, 100, 200);
        @num_sel_blocks2 = (4, 16, 32, 64, 128);
    }
    #######################
    if($file_name eq "tm_3g_region_all.res0.004.bin60.") {
        $num_frames = 24;
        $width = 324;
        $height = 475;

        @block_ws = (33, 66);
        @block_hs = (48, 96);
        @num_sel_blocks2 = (4, 16, 32, 64, 128);
    }
    if($file_name eq "tm_3g_region_all.res0.004.bin60.sub.") {
        $num_frames = 24;
        $width = 60;
        $height = 60;

        @block_ws = (6, 10);
        @block_hs = (6, 10);
        @num_sel_blocks2 = (4, 16, 32, 64, 128);
    }
    if($file_name eq "tm_3g_region_all.res0.002.bin60.") {
        $num_frames = 24;
        $width = 647;
        $height = 949;

        @block_ws = (65, 130);
        @block_hs = (95, 190);
        @num_sel_blocks2 = (4, 16, 32, 64, 128);
    }
    if($file_name eq "tm_3g_region_all.res0.002.bin60.sub.") {
        $num_frames = 24;
        $width = 120;
        $height = 100;

        @block_ws = (12, 24);
        @block_hs = (10, 20);
        @num_sel_blocks2 = (4, 16, 32, 64, 128);
    }


    @seeds = (1 .. 10);
    @opt_swap_mats = (0, 1, 3);
    @drop_rates = (0, 0.01, 0.05, 0.1, 0.2, 0.3);
    @opt_deltas = (1);
    @opt_scopes = (0, 1);
    @opt_sel_methods = (1, 3);
    @num_sel_blocks1 = (4, 8, 16);


    for my $drop_rate (@drop_rates) {

        for my $opt_swap_mat (@opt_swap_mats) {
            if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE})) {
                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = -1;
                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} = -1;
                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} = -1;
            }

            for my $opt_delta (@opt_deltas) {
                if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MSE})) {
                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MSE} = -1;
                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MAE} = -1;
                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{CC} = -1;
                }

                for my $block_size (0..@block_ws-1) {
                    my $block_width = $block_ws[$block_size];
                    my $block_height = $block_hs[$block_size];

                    if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MSE})) {
                        $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MSE} = -1;
                        $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MAE} = -1;
                        $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{CC} = -1;
                    }

                    for my $opt_scope (@opt_scopes) {
                        if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SCOPE}{$opt_scope}{MSE})) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SCOPE}{$opt_scope}{MSE} = -1;
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SCOPE}{$opt_scope}{MAE} = -1;
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SCOPE}{$opt_scope}{CC} = -1;
                        }

                        my @num_sel_blocks;
                        if($opt_scope == 0) {
                            @num_sel_blocks = @num_sel_blocks1;
                        }
                        elsif($opt_scope == 1) {
                            @num_sel_blocks = @num_sel_blocks2;
                        }

                        for my $opt_sel_method (@opt_sel_methods) {
                            if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SEL_METHOD}{$opt_sel_method}{MSE})) {
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SEL_METHOD}{$opt_sel_method}{MSE} = -1;
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SEL_METHOD}{$opt_sel_method}{MAE} = -1;
                                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SEL_METHOD}{$opt_sel_method}{CC} = -1;
                            }

                            for my $num_sel_block (@num_sel_blocks) {
                                if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{NUM_SEL_BLOCK}{$num_sel_block}{MSE})) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{NUM_SEL_BLOCK}{$num_sel_block}{MSE} = -1;
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{NUM_SEL_BLOCK}{$num_sel_block}{MAE} = -1;
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{NUM_SEL_BLOCK}{$num_sel_block}{CC} = -1;
                                }

                                my @mses;
                                my @maes;
                                my @ccs;
                                my @ratios;
                                for my $seed (@seeds) {
                                    my $this_file_name = "$input_dir/$func.$file_name.$num_frames.$width.$height.$block_width.$block_height.$num_sel_block.$opt_delta.$opt_scope.$opt_sel_method.$opt_swap_mat.$drop_rate.$seed.txt";
                                    die "cannot find the file: $this_file_name\n" unless(-e $this_file_name);
                                    # next unless(-e $this_file_name);

                                    print "$this_file_name\n";
                                    
                                    open FH, $this_file_name or die $!;
                                    while(<FH>) {
                                        chomp;
                                        my @ret = split(/, /, $_);
                                        my $mse = $ret[0] + 0;
                                        my $mae = $ret[1] + 0;
                                        my $cc = $ret[2] + 0;
                                        my $ratio = $ret[3] + 0;


                                        ## XXX: figure out why nan
                                        if($mse eq "nan") {
                                            die;
                                            $mse = 0;
                                        }
                                        if($mae eq "nan") {
                                            die;
                                            $mae = 0;
                                        }
                                        if($cc eq "nan") {
                                            $cc = 0;
                                        }

                                        push(@mses, $mse);
                                        push(@maes, $mae);
                                        push(@ccs, $cc);
                                        push(@ratios, $ratio);

                                        my $buf = "$file_name, $num_frames, $width, $height, $block_width, $block_height, $num_sel_block, $opt_delta, $opt_scope, $opt_sel_method, $opt_swap_mat, $drop_rate, $seed, $mse, $mae, $cc, $ratio\n";
                                        print $buf;
                                        print FH_OUT $buf;
                                    }
                                } ## end seeds
                                my $avg_mse = MyUtil::average(\@mses);
                                my $avg_mae = MyUtil::average(\@maes);
                                my $avg_cc = MyUtil::average(\@ccs);
                                my $avg_ratio = MyUtil::average(\@ratios);

                                my $buf = "$file_name, $num_frames, $width, $height, $block_width, $block_height, $num_sel_block, $opt_delta, $opt_scope, $opt_sel_method, $opt_swap_mat, $drop_rate, $avg_mse, $avg_mae, $avg_cc, $avg_ratio\n";
                                print FH_MEAN_OUT $buf;


                                ## MSE
                                if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = $avg_mse;
                                }
                                if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MSE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MSE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MSE} = $avg_mse;
                                }
                                if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MSE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MSE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MSE} = $avg_mse;
                                }
                                if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SCOPE}{$opt_scope}{MSE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SCOPE}{$opt_scope}{MSE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SCOPE}{$opt_scope}{MSE} = $avg_mse;
                                }
                                if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SEL_METHOD}{$opt_sel_method}{MSE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SEL_METHOD}{$opt_sel_method}{MSE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SEL_METHOD}{$opt_sel_method}{MSE} = $avg_mse;
                                }
                                if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{NUM_SEL_BLOCK}{$num_sel_block}{MSE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{NUM_SEL_BLOCK}{$num_sel_block}{MSE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{NUM_SEL_BLOCK}{$num_sel_block}{MSE} = $avg_mse;
                                }
                                ## MAE
                                if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} = $avg_mae;
                                }
                                if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MAE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MAE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MAE} = $avg_mae;
                                }
                                if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MAE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MAE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MAE} = $avg_mae;
                                }
                                if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SCOPE}{$opt_scope}{MAE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SCOPE}{$opt_scope}{MAE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SCOPE}{$opt_scope}{MAE} = $avg_mae;
                                }
                                if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SEL_METHOD}{$opt_sel_method}{MAE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SEL_METHOD}{$opt_sel_method}{MAE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SEL_METHOD}{$opt_sel_method}{MAE} = $avg_mae;
                                }
                                if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{NUM_SEL_BLOCK}{$num_sel_block}{MAE} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{NUM_SEL_BLOCK}{$num_sel_block}{MAE} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{NUM_SEL_BLOCK}{$num_sel_block}{MAE} = $avg_mae;
                                }
                                ## CC
                                if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} = $avg_cc;
                                }
                                if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{CC} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{CC} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{CC} = $avg_cc;
                                }
                                if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{CC} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{CC} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{CC} = $avg_cc;
                                }
                                if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SCOPE}{$opt_scope}{CC} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SCOPE}{$opt_scope}{CC} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SCOPE}{$opt_scope}{CC} = $avg_cc;
                                }
                                if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SEL_METHOD}{$opt_sel_method}{CC} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SEL_METHOD}{$opt_sel_method}{CC} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SEL_METHOD}{$opt_sel_method}{CC} = $avg_cc;
                                }
                                if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{NUM_SEL_BLOCK}{$num_sel_block}{CC} or 
                                   $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{NUM_SEL_BLOCK}{$num_sel_block}{CC} == -1) {
                                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{NUM_SEL_BLOCK}{$num_sel_block}{CC} = $avg_cc;
                                }

                            }  ## end num_sel_blocks
                        }  ## end opt_sel_methods
                    }  ## end opt_scopes
                }  ## end of block_sizes
            }  ## end of opt_deltas
        }  ## end of opt_swap_mats
    }
}
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
