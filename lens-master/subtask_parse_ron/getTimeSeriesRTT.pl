#!/bin/perl -w
# for the first 2 days only, drop the 3rd day for ron1

use strict;
use POSIX;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);


# my $interval = 3600;
my %srcs;
my %dsts;

# $intervals = getRTTTimeSeries ($fileName, $interval (in seconds), $intervalID);
sub getRTTTimeSeries ($$$) {
    my ($fileName, $interval, $stopInterval) = @_;

    print ("fileName = $fileName \n");
    
    open IN, "<$fileName-latency";
    my $first = 1;
    my $startTime = 0;
    my $startInterval = 0;
    my $intervalID = 0;
    my ($intervals);
    my (%latency) = ();
    my (%numLosses) = ();
    my (%numProbes) = ();
    
    while (<IN>) {
        chop $_;
        my ($src, $dst, $ron, $send1, $recv1, $send2, $recv2) = split " ", $_;

        if ($recv1 eq "NULL" or $recv2 eq "NULL") {
            $numLosses{$dst}{$src}++;
            next;
        }
        $send1 +=0; $recv1 += 0; $send2 += 0; $recv2 += 0;
        # print "  ".join(",", ($src, $dst, $ron, $send1, $recv1, $send2, $recv2))."\n";

        die "latency < 0\n" if($recv2 - $send1 < 0);
        

        if ($first) {
            $startTime = $send1 + 0;
            $startInterval = $startTime;
            $first = 0;
        }

        # only collect data for the first two days for ron1
        last if ($send1 - $startTime > 48 * 3600);

        $numProbes{$src}{$dst} ++;
        $latency{$src}{$dst} += ($recv2 - $send1);
        $srcs{$src} = 1;
        $dsts{$dst} = 1;
        # print "    latency=".$latency{$src}{$dst}."\n";
            
        
        if ($recv2 - $startInterval >= $interval) {
            # print "  time $intervalID\n";
            foreach my $f (keys %latency) {
                foreach my $t (keys %{$latency{$f}}) {
                    # my $avgL = "n/a";
                    my $avgL = 0;
                    if ($numProbes{$f}{$t} > 0) {
                        $avgL = $latency{$f}{$t} / $numProbes{$f}{$t};
                    }
                    # print "    $f->$t: avgL = $avgL \n";
                    $intervals->{$intervalID}{$f}{$t} = $avgL;
                    $numProbes{$f}{$t} = 0;
                    $latency{$f}{$t} = 0;
                }
            }

            $startInterval = $recv2;
            $intervalID ++;
        }
        last if ($intervalID >= $stopInterval);
    }
    close (IN);
    return $intervals;
}



my $intervals = getRTTTimeSeries ("../data/ron/ron1", 300, 494);

print "SRC:\n";
foreach my $f (sort {$a cmp $b} (keys %srcs)) {
    print "  $f\n";
}
print "DST:\n";
foreach my $t (sort {$a cmp $b} (keys %dsts)) {
    print "  $t\n";
}

foreach my $i (sort {$a <=> $b} (keys %$intervals)) {
    print "Interval $i: \n";

    open FH, "> ../processed_data/subtask_parse_ron/tm/tm_ron1.latency.$i.txt" or die $!;
    # foreach my $f (sort {$a cmp $b} (keys %{$intervals->{$i}})) {
    foreach my $f (sort {$a cmp $b} (keys %srcs)) {
        my $first = 1;
        foreach my $t (sort {$a cmp $b} (keys %dsts)) {
            print FH ", " unless($first); $first = 0;
            if(exists $intervals->{$i}{$f}{$t}) {
                print FH "".$intervals->{$i}{$f}{$t}."";
            }
            else {
                print FH "0";
            }
        }
        print FH "\n";
    }
    # print "\n";

    close FH;
}
