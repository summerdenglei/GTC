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
use POSIX;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use lib "../utils";
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
my $num_channels = 9;

#############
# Variables
#############
my $input_dir  = "../processed_data/subtask_channel_selection/results";
my $output_dir = "";

my @mobilities = ("static");
my @traces = (1, 2, 4..9);
# my @traces = (1, 2, 4..7);
my @ants = (1..3);
my @sample_modes = ("know_all", "rand_fix", "equal_fix");
# my @sample_modes = ("know_all", "base_rand_fix", "base_equal_fix");
# my @sample_modes = ("know_all", "rand", "equal");
my $rank = 16;
my @num_known_chs = (0,8,7,6,5,4,3,2,1);
my @pred_methods = ("srmf_knn", "lens3_knn");


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
## MSE
##   rows: sample modes
##   cols: traces
#############
print "MSE\n";
foreach my $pred_method (@pred_methods) {
    print "  - $pred_method\n";

    ## title
    foreach my $mobility (@mobilities) {
        foreach my $tr (@traces) {
            foreach my $ant (@ants) {
                print ", tr$tr-$ant";
            }
        }
    }
    print "\n";

    ## rows
    foreach my $sample_mode (@sample_modes) {
        foreach my $num_known_ch (@num_known_chs) {
            next if($sample_mode eq "know_all" and $num_known_ch > 0);
            next if($sample_mode ne "know_all" and $num_known_ch == 0);

            ## cols
            my $first_col = 1;
            foreach my $mobility (@mobilities) {
                foreach my $tr (@traces) {
                    foreach my $ant (@ants) {
                        my $trace_name = "$mobility\_trace$tr.ant$ant";

                        # print "> ".join(",", ($trace_name, $rank, $sample_mode, $num_known_ch, $pred_method))."\n";
                        my ($mse, $mae, $cc, $pred_sci_accuracy, $pred_tput_accuracy, $pred_tput_fp, $avg_pred_tput, $rand_sci_accuracy, $rand_tput_accuracy, $rand_tput_fp, $avg_rand_tput, $avg_real_tput, $cspy_sci_accuracy_ref, $cspy_tput_accuracy_ref, $cspy_tput_fp_ref, $avg_cspy_tput_ref) = get_results($trace_name, $rank, $sample_mode, $num_known_ch, $pred_method);
                        if($first_col) {
                            print $sample_mode."-".$num_known_ch."ch, ";
                            $first_col = 0;
                        }
                        else {
                            print ", ";
                        }
                        
                        print "$mse";
                    }
                }
            }
            ##
            print "\n";
        }
    }
}
print "\n";



#############
## SCI accuracy 1 : know_all
##   rows: files
##   cols: our scheme, rand, cspy
#############
print "SCI accuracy 1 : know_all\n";

my $sample_mode = "know_all";
my $num_known_ch = 0;

foreach my $pred_method (@pred_methods) {
    print "  - $pred_method\n";

    ## title
    print "Traces, Our Scheme, Random";
    foreach my $ch (1..$num_channels) {
        print ", CSpy CH$ch";
    }
    print "\n";

    ## rows
    foreach my $mobility (@mobilities) {
        foreach my $tr (@traces) {
            foreach my $ant (@ants) {
                my $trace_name = "$mobility\_trace$tr.ant$ant";

                my ($mse, $mae, $cc, $pred_sci_accuracy, $pred_tput_accuracy, $pred_tput_fp, $avg_pred_tput, $rand_sci_accuracy, $rand_tput_accuracy, $rand_tput_fp, $avg_rand_tput, $avg_real_tput, $cspy_sci_accuracy_ref, $cspy_tput_accuracy_ref, $cspy_tput_fp_ref, $avg_cspy_tput_ref) = get_results($trace_name, $rank, $sample_mode, $num_known_ch, $pred_method);
                
                print "tr$tr-$ant, $pred_sci_accuracy, $rand_sci_accuracy";
                foreach my $ch (1..$num_channels) {
                    print ", ".$cspy_sci_accuracy_ref->{$ch};
                }
                print "\n";
            }
        }
    }
}
print "\n";




#############
## SCI accuracy 2 : sample mode
##   rows: files
##   cols: our scheme, rand, cspy
#############
print "SCI accuracy 2 : sample mode\n";

foreach my $pred_method (@pred_methods) {
    print "  - $pred_method\n";

    ## title
    # print "Sampling Mode, Our Scheme, Random";
    # foreach my $ch (1..$num_channels) {
    #     print ", CSpy CH$ch";
    # }
    # print "\n";

    ## rows
    my %info = ();

    foreach my $sample_mode (@sample_modes) {
        foreach my $num_known_ch (@num_known_chs) {
            next if($sample_mode eq "know_all" and $num_known_ch > 0);
            next if($sample_mode ne "know_all" and $num_known_ch == 0);

            foreach my $mobility (@mobilities) {
                foreach my $tr (@traces) {
                    foreach my $ant (@ants) {
                        my $trace_name = "$mobility\_trace$tr.ant$ant";
            
                        my ($mse, $mae, $cc, $pred_sci_accuracy, $pred_tput_accuracy, $pred_tput_fp, $avg_pred_tput, $rand_sci_accuracy, $rand_tput_accuracy, $rand_tput_fp, $avg_rand_tput, $avg_real_tput, $cspy_sci_accuracy_ref, $cspy_tput_accuracy_ref, $cspy_tput_fp_ref, $avg_cspy_tput_ref) = get_results($trace_name, $rank, $sample_mode, $num_known_ch, $pred_method);

                        push(@{ $info{MODE}{"$sample_mode ".$num_known_ch."ch"} }, $pred_sci_accuracy);
                        push(@{ $info{MODE}{"Random"} }, $rand_sci_accuracy);
                        foreach my $ch (1..$num_channels) {
                            push(@{ $info{MODE}{"CSpy ch$ch"} }, $cspy_sci_accuracy_ref->{$ch});
                        }

                    }
                }
            }
            my $avg = MyUtil::average(\@{ $info{MODE}{"$sample_mode ".$num_known_ch."ch"} });
            my $std = MyUtil::stdev(\@{ $info{MODE}{"$sample_mode ".$num_known_ch."ch"} });
            print $sample_mode."-".$num_known_ch."ch, $avg, $std\n";
        }
    }
    my $avg_rand = MyUtil::average(\@{ $info{MODE}{"Random"} });
    my $std_rand = MyUtil::stdev(\@{ $info{MODE}{"Random"} });
    print "Random, $avg_rand, $std_rand\n";
    foreach my $ch (1..$num_channels) {
        my $avg_cspy = MyUtil::average(\@{ $info{MODE}{"CSpy ch$ch"} });
        my $std_cspy = MyUtil::stdev(\@{ $info{MODE}{"CSpy ch$ch"} });
        print "CSpy ch$ch, $avg_cspy, $std_cspy\n";
    }

}
print "\n";



#############
## Tput accuracy 1 : know_all
##   rows: files
##   cols: our scheme, rand
#############
print "Tput accuracy 1 : know_all\n";

my $sample_mode = "know_all";
my $num_known_ch = 0;

foreach my $pred_method (@pred_methods) {
    print "  - $pred_method\n";

    ## title
    print "Traces, Our Scheme, Random";
    foreach my $ch (1..$num_channels) {
        print ", CSpy CH$ch";
    }
    print "\n";

    ## rows
    foreach my $mobility (@mobilities) {
        foreach my $tr (@traces) {
            foreach my $ant (@ants) {
                my $trace_name = "$mobility\_trace$tr.ant$ant";

                my ($mse, $mae, $cc, $pred_sci_accuracy, $pred_tput_accuracy, $pred_tput_fp, $avg_pred_tput, $rand_sci_accuracy, $rand_tput_accuracy, $rand_tput_fp, $avg_rand_tput, $avg_real_tput, $cspy_sci_accuracy_ref, $cspy_tput_accuracy_ref, $cspy_tput_fp_ref, $avg_cspy_tput_ref) = get_results($trace_name, $rank, $sample_mode, $num_known_ch, $pred_method);
                
                print "tr$tr-$ant, $pred_tput_accuracy, $rand_tput_accuracy";
                foreach my $ch (1..$num_channels) {
                    print ", ".$cspy_tput_accuracy_ref->{$ch};
                }
                print "\n";
            }
        }
    }
}
print "\n";




#############
## Tput accuracy 2 : sample mode
##   rows: files
##   cols: our scheme, rand
#############
print "Tput accuracy 2 : sample mode\n";

foreach my $pred_method (@pred_methods) {
    print "  - $pred_method\n";

    ## title
    # print "Sampling Mode, Our Scheme, Random";
    # foreach my $ch (1..$num_channels) {
    #     print ", CSpy CH$ch";
    # }
    # print "\n";

    ## rows
    my %info = ();

    foreach my $sample_mode (@sample_modes) {
        foreach my $num_known_ch (@num_known_chs) {
            next if($sample_mode eq "know_all" and $num_known_ch > 0);
            next if($sample_mode ne "know_all" and $num_known_ch == 0);

            foreach my $mobility (@mobilities) {
                foreach my $tr (@traces) {
                    foreach my $ant (@ants) {
                        my $trace_name = "$mobility\_trace$tr.ant$ant";
            
                        my ($mse, $mae, $cc, $pred_sci_accuracy, $pred_tput_accuracy, $pred_tput_fp, $avg_pred_tput, $rand_sci_accuracy, $rand_tput_accuracy, $rand_tput_fp, $avg_rand_tput, $avg_real_tput, $cspy_sci_accuracy_ref, $cspy_tput_accuracy_ref, $cspy_tput_fp_ref, $avg_cspy_tput_ref) = get_results($trace_name, $rank, $sample_mode, $num_known_ch, $pred_method);

                        push(@{ $info{MODE}{"$sample_mode ".$num_known_ch."ch"} }, $pred_tput_accuracy);
                        push(@{ $info{MODE}{"Random"} }, $rand_tput_accuracy);
                        foreach my $ch (1..$num_channels) {
                            push(@{ $info{MODE}{"CSpy ch$ch"} }, $cspy_tput_accuracy_ref->{$ch});
                        }

                    }
                }
            }
            my $avg = MyUtil::average(\@{ $info{MODE}{"$sample_mode ".$num_known_ch."ch"} });
            my $std = MyUtil::stdev(\@{ $info{MODE}{"$sample_mode ".$num_known_ch."ch"} });
            print $sample_mode."-".$num_known_ch."ch, $avg, $std\n";
        }
    }
    my $avg_rand = MyUtil::average(\@{ $info{MODE}{"Random"} });
    my $std_rand = MyUtil::stdev(\@{ $info{MODE}{"Random"} });
    print "Random, $avg_rand, $std_rand\n";
    foreach my $ch (1..$num_channels) {
        my $avg_cspy = MyUtil::average(\@{ $info{MODE}{"CSpy ch$ch"} });
        my $std_cspy = MyUtil::stdev(\@{ $info{MODE}{"CSpy ch$ch"} });
        print "CSpy ch$ch, $avg_cspy, $std_cspy\n";
    }

}
print "\n";



#############
## Tput false positive 1 : know_all
##   rows: files
##   cols: our scheme, rand
#############
print "Tput false positive 1 : know_all\n";

my $sample_mode = "know_all";
my $num_known_ch = 0;

foreach my $pred_method (@pred_methods) {
    print "  - $pred_method\n";

    ## title
    print "Traces, Our Scheme, Random";
    foreach my $ch (1..$num_channels) {
        print ", CSpy CH$ch";
    }
    print "\n";

    ## rows
    foreach my $mobility (@mobilities) {
        foreach my $tr (@traces) {
            foreach my $ant (@ants) {
                my $trace_name = "$mobility\_trace$tr.ant$ant";

                my ($mse, $mae, $cc, $pred_sci_accuracy, $pred_tput_accuracy, $pred_tput_fp, $avg_pred_tput, $rand_sci_accuracy, $rand_tput_accuracy, $rand_tput_fp, $avg_rand_tput, $avg_real_tput, $cspy_sci_accuracy_ref, $cspy_tput_accuracy_ref, $cspy_tput_fp_ref, $avg_cspy_tput_ref) = get_results($trace_name, $rank, $sample_mode, $num_known_ch, $pred_method);
                
                print "tr$tr-$ant, $pred_tput_fp, $rand_tput_fp";
                foreach my $ch (1..$num_channels) {
                    print ", ".$cspy_tput_fp_ref->{$ch};
                }
                print "\n";
            }
        }
    }
}
print "\n";




#############
## Tput false positive 2 : sample mode
##   rows: files
##   cols: our scheme, rand
#############
print "Tput false positive 2 : sample mode\n";

#############
## Tput accuracy 2 : sample mode
##   rows: files
##   cols: our scheme, rand
#############
print "Tput accuracy 2 : sample mode\n";

foreach my $pred_method (@pred_methods) {
    print "  - $pred_method\n";

    ## title
    # print "Sampling Mode, Our Scheme, Random";
    # foreach my $ch (1..$num_channels) {
    #     print ", CSpy CH$ch";
    # }
    # print "\n";

    ## rows
    my %info = ();

    foreach my $sample_mode (@sample_modes) {
        foreach my $num_known_ch (@num_known_chs) {
            next if($sample_mode eq "know_all" and $num_known_ch > 0);
            next if($sample_mode ne "know_all" and $num_known_ch == 0);

            foreach my $mobility (@mobilities) {
                foreach my $tr (@traces) {
                    foreach my $ant (@ants) {
                        my $trace_name = "$mobility\_trace$tr.ant$ant";
            
                        my ($mse, $mae, $cc, $pred_sci_accuracy, $pred_tput_accuracy, $pred_tput_fp, $avg_pred_tput, $rand_sci_accuracy, $rand_tput_accuracy, $rand_tput_fp, $avg_rand_tput, $avg_real_tput, $cspy_sci_accuracy_ref, $cspy_tput_accuracy_ref, $cspy_tput_fp_ref, $avg_cspy_tput_ref) = get_results($trace_name, $rank, $sample_mode, $num_known_ch, $pred_method);

                        push(@{ $info{MODE}{"$sample_mode ".$num_known_ch."ch"} }, $pred_tput_fp);
                        push(@{ $info{MODE}{"Random"} }, $rand_tput_fp);
                        foreach my $ch (1..$num_channels) {
                            push(@{ $info{MODE}{"CSpy ch$ch"} }, $cspy_tput_fp_ref->{$ch});
                        }

                    }
                }
            }
            my $avg = MyUtil::average(\@{ $info{MODE}{"$sample_mode ".$num_known_ch."ch"} });
            my $std = MyUtil::stdev(\@{ $info{MODE}{"$sample_mode ".$num_known_ch."ch"} });
            print $sample_mode."-".$num_known_ch."ch, $avg, $std\n";
        }
    }
    my $avg_rand = MyUtil::average(\@{ $info{MODE}{"Random"} });
    my $std_rand = MyUtil::stdev(\@{ $info{MODE}{"Random"} });
    print "Random, $avg_rand, $std_rand\n";
    foreach my $ch (1..$num_channels) {
        my $avg_cspy = MyUtil::average(\@{ $info{MODE}{"CSpy ch$ch"} });
        my $std_cspy = MyUtil::stdev(\@{ $info{MODE}{"CSpy ch$ch"} });
        print "CSpy ch$ch, $avg_cspy, $std_cspy\n";
    }

}
print "\n";



#############
## Tput : know_all
##   rows: files
##   cols: oracle, our scheme, rand
#############
print "Tput : know_all\n";

my $sample_mode = "know_all";
my $num_known_ch = 0;

foreach my $pred_method (@pred_methods) {
    print "  - $pred_method\n";

    ## title
    print "Traces, Oracle, Our Scheme, Random";
    foreach my $ch (1..$num_channels) {
        print ", CSpy CH$ch";
    }
    print "\n";

    ## rows
    foreach my $mobility (@mobilities) {
        foreach my $tr (@traces) {
            foreach my $ant (@ants) {
                my $trace_name = "$mobility\_trace$tr.ant$ant";

                my ($mse, $mae, $cc, $pred_sci_accuracy, $pred_tput_accuracy, $pred_tput_fp, $avg_pred_tput, $rand_sci_accuracy, $rand_tput_accuracy, $rand_tput_fp, $avg_rand_tput, $avg_real_tput, $cspy_sci_accuracy_ref, $cspy_tput_accuracy_ref, $cspy_tput_fp_ref, $avg_cspy_tput_ref) = get_results($trace_name, $rank, $sample_mode, $num_known_ch, $pred_method);
                
                print "tr$tr-$ant, $avg_real_tput, $avg_pred_tput, $avg_rand_tput";
                foreach my $ch (1..$num_channels) {
                    print ", ".$avg_cspy_tput_ref->{$ch};
                }
                print "\n";
            }
        }
    }
}
print "\n";




#############
## Tput : sample mode
##   rows: files
##   cols: oracle, our scheme, rand
#############
print "Tput : sample mode\n";

foreach my $pred_method (@pred_methods) {
    print "  - $pred_method\n";

    ## title
    # print "Sampling Mode, Our Scheme, Random";
    # foreach my $ch (1..$num_channels) {
    #     print ", CSpy CH$ch";
    # }
    # print "\n";

    ## rows
    my %info = ();
    my $first = 1;
    foreach my $sample_mode (@sample_modes) {
        foreach my $num_known_ch (@num_known_chs) {
            next if($sample_mode eq "know_all" and $num_known_ch > 0);
            next if($sample_mode ne "know_all" and $num_known_ch == 0);

            foreach my $mobility (@mobilities) {
                foreach my $tr (@traces) {
                    foreach my $ant (@ants) {
                        my $trace_name = "$mobility\_trace$tr.ant$ant";
            
                        my ($mse, $mae, $cc, $pred_sci_accuracy, $pred_tput_accuracy, $pred_tput_fp, $avg_pred_tput, $rand_sci_accuracy, $rand_tput_accuracy, $rand_tput_fp, $avg_rand_tput, $avg_real_tput, $cspy_sci_accuracy_ref, $cspy_tput_accuracy_ref, $cspy_tput_fp_ref, $avg_cspy_tput_ref) = get_results($trace_name, $rank, $sample_mode, $num_known_ch, $pred_method);

                        push(@{ $info{MODE}{"Oracle"} }, $avg_real_tput);
                        push(@{ $info{MODE}{"$sample_mode ".$num_known_ch."ch"} }, $avg_pred_tput);
                        push(@{ $info{MODE}{"Random"} }, $avg_rand_tput);
                        foreach my $ch (1..$num_channels) {
                            push(@{ $info{MODE}{"CSpy ch$ch"} }, $avg_cspy_tput_ref->{$ch});
                        }

                    }
                }
            }
            if($first) {
                my $avg_real = MyUtil::average(\@{ $info{MODE}{"Oracle"} });
                my $std_real = MyUtil::stdev(\@{ $info{MODE}{"Oracle"} });
                print "Oracle, $avg_real, $std_real\n";

                $first = 0;
            }
            my $avg = MyUtil::average(\@{ $info{MODE}{"$sample_mode ".$num_known_ch."ch"} });
            my $std = MyUtil::stdev(\@{ $info{MODE}{"$sample_mode ".$num_known_ch."ch"} });
            print $sample_mode."-".$num_known_ch."ch, $avg, $std\n";
        }
    }
    my $avg_rand = MyUtil::average(\@{ $info{MODE}{"Random"} });
    my $std_rand = MyUtil::stdev(\@{ $info{MODE}{"Random"} });
    print "Random, $avg_rand, $std_rand\n";
    foreach my $ch (1..$num_channels) {
        my $avg_cspy = MyUtil::average(\@{ $info{MODE}{"CSpy ch$ch"} });
        my $std_cspy = MyUtil::stdev(\@{ $info{MODE}{"CSpy ch$ch"} });
        print "CSpy ch$ch, $avg_cspy, $std_cspy\n";
    }

}
print "\n";


sub get_results {
    my $DEBUG1 = 1;
    my $num_channels = 9;

    my ($trace_name, $rank, $sample_mode, $num_known_ch, $pred_method) = @_;

    my ($mse, $mae, $cc, $pred_sci_accuracy, $pred_tput_accuracy, $pred_tput_fp, $avg_pred_tput, $rand_sci_accuracy, $rand_tput_accuracy, $rand_tput_fp, $avg_rand_tput, $avg_real_tput, %cspy_sci_accuracy, %cspy_tput_accuracy, %cspy_tput_fp, %avg_cspy_tput);

    my $filename = "$trace_name.r$rank.$sample_mode.ch$num_known_ch.$pred_method";


    ## mse
    my $this_filename = "$filename.mse.txt";
    if(-e "$input_dir/$this_filename") {
        open FH, "$input_dir/$this_filename" or die $!;
        while(<FH>) {
            chomp;
            ($mse, $mae, $cc) = split(",", $_);
            $mse += 0; $mae += 0; $cc += 0;
        }
        close FH;
    }
    else {
        print STDERR "missing: $this_filename\n" if($DEBUG1);
        $mse = 0; $mae = 0; $cc = 0; $pred_sci_accuracy = 0; $pred_tput_accuracy = 0; $pred_tput_fp = 0; $avg_pred_tput = 0; $rand_sci_accuracy = 0; $rand_tput_accuracy = 0; $rand_tput_fp = 0; $avg_rand_tput = 0; $avg_real_tput = 0; 
        foreach my $ch (1..$num_channels) {
            $cspy_sci_accuracy{$ch} = 0; $cspy_tput_accuracy{$ch} = 0; $cspy_tput_fp{$ch} = 0; $avg_cspy_tput{$ch} = 0;
        }
        return ($mse, $mae, $cc, $pred_sci_accuracy, $pred_tput_accuracy, $pred_tput_fp, $avg_pred_tput, $rand_sci_accuracy, $rand_tput_accuracy, $rand_tput_fp, $avg_rand_tput, $avg_real_tput, \%cspy_sci_accuracy, \%cspy_tput_accuracy, \%cspy_tput_fp, \%avg_cspy_tput);
    }


    ## accuracy
    $this_filename = "$filename.accuracy.txt";
    if(-e "$input_dir/$this_filename") {
        open FH, "$input_dir/$this_filename" or die $!;
        while(<FH>) {
            chomp;
            ($pred_sci_accuracy, $pred_tput_accuracy, $pred_tput_fp, $avg_pred_tput, $rand_sci_accuracy, $rand_tput_accuracy, $rand_tput_fp, $avg_rand_tput, $avg_real_tput) = split(",", $_);
            $pred_sci_accuracy += 0; $pred_tput_accuracy += 0; $pred_tput_fp += 0; $avg_pred_tput += 0; $rand_sci_accuracy += 0; $rand_tput_accuracy += 0; $rand_tput_fp += 0; $avg_rand_tput += 0; $avg_real_tput += 0;
        }
        close FH;
    }
    else {
        print STDERR "missing: $this_filename\n" if($DEBUG1);
        $mse = 0; $mae = 0; $cc = 0; $pred_sci_accuracy = 0; $pred_tput_accuracy = 0; $pred_tput_fp = 0; $avg_pred_tput = 0; $rand_sci_accuracy = 0; $rand_tput_accuracy = 0; $rand_tput_fp = 0; $avg_rand_tput = 0; $avg_real_tput = 0; 
        foreach my $ch (1..$num_channels) {
            $cspy_sci_accuracy{$ch} = 0; $cspy_tput_accuracy{$ch} = 0; $cspy_tput_fp{$ch} = 0; $avg_cspy_tput{$ch} = 0;
        }
        return ($mse, $mae, $cc, $pred_sci_accuracy, $pred_tput_accuracy, $pred_tput_fp, $avg_pred_tput, $rand_sci_accuracy, $rand_tput_accuracy, $rand_tput_fp, $avg_rand_tput, $avg_real_tput, \%cspy_sci_accuracy, \%cspy_tput_accuracy, \%cspy_tput_fp, \%avg_cspy_tput);
    }


    ## cspy
    $this_filename = "$trace_name.cspy.txt";
    if(-e "$input_dir/$this_filename") {
        open FH, "$input_dir/$this_filename" or die $!;
        my $ch = 1;
        while(<FH>) {
            chomp;
            ($cspy_sci_accuracy{$ch}, $cspy_tput_accuracy{$ch}, $cspy_tput_fp{$ch}, $avg_cspy_tput{$ch}) = split(",", $_);
            $cspy_sci_accuracy{$ch} += 0; $cspy_tput_accuracy{$ch} += 0; $cspy_tput_fp{$ch} += 0; $avg_cspy_tput{$ch} += 0;
            $ch ++;
        }
        close FH;
    }
    else {
        print STDERR "missing: $this_filename\n" if($DEBUG1);
        $mse = 0; $mae = 0; $cc = 0; $pred_sci_accuracy = 0; $pred_tput_accuracy = 0; $pred_tput_fp = 0; $avg_pred_tput = 0; $rand_sci_accuracy = 0; $rand_tput_accuracy = 0; $rand_tput_fp = 0; $avg_rand_tput = 0; $avg_real_tput = 0; 
        foreach my $ch (1..$num_channels) {
            $cspy_sci_accuracy{$ch} = 0; $cspy_tput_accuracy{$ch} = 0; $cspy_tput_fp{$ch} = 0; $avg_cspy_tput{$ch} = 0;
        }
        return ($mse, $mae, $cc, $pred_sci_accuracy, $pred_tput_accuracy, $pred_tput_fp, $avg_pred_tput, $rand_sci_accuracy, $rand_tput_accuracy, $rand_tput_fp, $avg_rand_tput, $avg_real_tput, \%cspy_sci_accuracy, \%cspy_tput_accuracy, \%cspy_tput_fp, \%avg_cspy_tput);
    }


    return ($mse, $mae, $cc, $pred_sci_accuracy, $pred_tput_accuracy, $pred_tput_fp, $avg_pred_tput, $rand_sci_accuracy, $rand_tput_accuracy, $rand_tput_fp, $avg_rand_tput, $avg_real_tput, \%cspy_sci_accuracy, \%cspy_tput_accuracy, \%cspy_tput_fp, \%avg_cspy_tput);
}













