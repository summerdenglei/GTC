#!/bin/perl

######################################################
## Author: Yi-Chao Chen
## 2013.11.01 @ UT Austin
##
## - Input:
##   1. tm_fullpath
##   2. matrix_size
##   3. max_color
##
## - e.g.
##   perl plot_TM.pl ../processed_data/subtask_parse_sjtu_wifi/tm/tm.sort_ips.ap.country.txt.3600 600 2000
##
######################################################

use strict;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);


#############
## DEBUG
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1;


#############
## Variables
#############
my $figure_dir = "../processed_data/subtask_plot_TM/figures_tm";

my $tm_fullpath;
my $matrix_size;
my $max_color;

my $tm_file;
my $tm_dir;

my %period_max_value = ();


#############
# check input
#############
if(@ARGV != 3) {
    print "wrong number of input: ".@ARGV."\n";
    print "e.g. \nperl plot_TM.pl ../processed_data/subtask_parse_sjtu_wifi/tm/tm.sort_ips.ap.country.txt.3600 600 2000\n";
    exit;
}
$tm_fullpath = $ARGV[0];
if($tm_fullpath =~ /^(.*)\/(.*)$/) {
    $tm_dir = $1;
    $tm_file = $2;
}
$matrix_size = $ARGV[1] + 0;
$max_color   = $ARGV[2] + 0;

if($DEBUG2) {
    print "tm dir: $tm_dir\n";
    print "tm file: $tm_file\n";
    print "matrix size: $matrix_size\n";
    print "max color value: $max_color\n";
}


#############
## Main starts here
#############

#############
## get all TM files
#############
print "get all TM files\n" if($DEBUG2);

my $num_frames = 0;
opendir (DIR, $tm_dir) or die $!;
while (my $file = readdir(DIR)) {
    next unless($file =~ /^$tm_file/);
    last if($num_frames > 10);
    $num_frames ++;
    
    print "$tm_dir/$file\n" if($DEBUG1);

    #####
    ## DEBUG
    # $num_venues = 1000;
    # if($period == 1) {
    #     $period_max_value{$period} = 5;
    # }
    # elsif($period == 5) {
    #     $period_max_value{$period} = 8;
    # }
    # elsif($period == 10) {
    #     $period_max_value{$period} = 100;
    # }
    # elsif($period == 20) {
    #     $period_max_value{$period} = 300;
    # }
    #####
    

    #############
    ## read the matrix and only output part of the matrix
    #############
    print "  read the matrix and only output part of the matrix\n" if($DEBUG2);
    
    my $line_cnt = 0;
    my $min_size = 0;
    open FH, "$tm_dir/$file" or die $!;
    open FH_W, ">$tm_dir/tmp.$file" or die $!;
    while(<FH>) {
        last if($line_cnt >= $matrix_size);
        next if($_ eq "\n");
        chomp;
        $line_cnt ++;

        my @tmp = split(/,/, $_);

        $min_size = scalar(@tmp);
        $min_size = $matrix_size if($matrix_size < $min_size);
        print FH_W join(", ", @tmp[0 .. $min_size-1])."\n";
    }
    close FH_W;
    close FH;
    print "  size = $min_size x $line_cnt\n" if($DEBUG1);


    my $escaped_tm_dir = $tm_dir."/";
    $escaped_tm_dir =~ s{\/}{\\\/}g;
    my $escaped_fig_dir = $figure_dir."/";
    $escaped_fig_dir =~ s{\/}{\\\/}g;
    my $cmd = "sed 's/DATA_DIR/$escaped_tm_dir/g; s/FIG_DIR/$escaped_fig_dir/g; s/FILE_NAME/tmp.$file/g; s/FIG_NAME/$file/g; s/X_LABEL/src/g; s/Y_LABEL/dst/g; s/DEGREE/-45/g; s/X_RANGE_S/0/g; s/X_RANGE_E/$min_size-1/g; s/Y_RANGE_S/0/g; s/Y_RANGE_E/$line_cnt-1/g; s/CBRANGE_S/0/g; s/CBRANGE_E/$max_color/g; s/CBLABEL//g; ' plot_TM.mother.plot > tmp.plot_TM.plot";
    `$cmd`;

    $cmd = "gnuplot tmp.plot_TM.plot";
    `$cmd`;

    $cmd = "rm $tm_dir/tmp.$file";
    `$cmd`;
}
closedir(DIR);

