
package HuaweiTool;

use strict;
use POSIX;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);


sub read_bs_location {
    my ($fullpath) = @_;

    my $DEBUG0 = 0;
    my $DEBUG1 = 1;

    my %bs_info = ();

    open FH, "$fullpath" or die $!;
    while(<FH>) {
        my ($bs_id, $lng, $lat) = split(/\s+/, $_);
        $bs_id += 0; $lat += 0; $lng += 0;

        print "bs=$bs_id, lat=$lat, lng=$lng\n" if($DEBUG0);

        $bs_info{$bs_id}{LAT} = $lat;
        $bs_info{$bs_id}{LNG} = $lng;
    }
    close FH;

    return %bs_info;
}


sub read_bs_info {
    ## <RNC_ID> <BS_ID> <Cell_ID> <Longitude> <Latitude> <BS_Type>
    my ($fullpath) = @_;

    my $DEBUG0 = 0;
    my $DEBUG1 = 1;

    my %bs_info = ();

    open FH, "$fullpath" or die $!;
    while(<FH>) {
        chomp;
        my ($rnc_id, $bs_id, $cell_id, $lng, $lat, $bs_type) = split(/\s+/, $_);
        $rnc_id += 0; $bs_id += 0; $cell_id += 0; $lat += 0; $lng += 0; $bs_type += 0;

        print "rnc=$rnc_id, bs=$bs_id (type=$bs_type), cell=$cell_id, lat=$lat, lng=$lng\n" if($DEBUG0);

        $bs_info{CELL}{$cell_id}{RNC} = $rnc_id;
        $bs_info{CELL}{$cell_id}{BS} = $bs_id;
        $bs_info{CELL}{$cell_id}{BS_TYPE} = $bs_type;
        $bs_info{CELL}{$cell_id}{LAT} = $lat;
        $bs_info{CELL}{$cell_id}{LNG} = $lng;
    }
    close FH;

    return %bs_info;
}


sub read_traffic {
    my ($fullpath) = @_;

    my $DEBUG0 = 0;
    my $DEBUG1 = 1;

    my %traffic_info = ();
    my $num_values;

    # open FH, "$fullpath" or die $!;
    open FH, "bzcat $fullpath |" or die $!;
    while(<FH>) {
        my ($cell_id, @val) = split(/\s+/, $_);
        $cell_id += 0;
        $num_values = scalar(@val);
        for my $i (0 .. @val-1) {
            $val[$i] += 0;
        }

        print "cell=$cell_id, val=".join(",", @val)."\n" if($DEBUG0);

        @{ $traffic_info{$cell_id}{TRAFFIC} } = @val;
    }
    close FH;

    return ($num_values, %traffic_info);
}


sub cell2bs {
    my ($cell_id) = @_;

    return floor($cell_id / 10);
}

1;