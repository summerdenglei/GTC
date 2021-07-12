
package MyUtil;

use strict;

use POSIX qw/floor/;
use Math::Trig;


#######
# find the name of /dfeed_8/uverse/stb/ban_rg_stb_mappings/2010/07/02/BAN_RG_STB_MAPPINGS.20100702.dat.gz
# @input $date: 2010 07 02
# @output $name: BAN_RG_STB_MAPPINGS.20100702.dat.gz
#######
sub name_BAN_RG_STB_MAPPINGS
{
	my ($year, $mon, $day) = @_;
	
	return "BAN_RG_STB_MAPPINGS.$year".(two_digit($mon)).(two_digit($day)).".dat.gz";
}

#######
# find the directory like 2011/05/11/
# @input $date: 2011 5 11
# @output $name: 2011/05/11/
#######
sub name_dir {
	my ($year, $mon, $day) = @_;
	
	my $ret = "$year/";
	
	$ret .= (two_digit($mon)."/");
	$ret .= (two_digit($day)."/");
	
	return $ret;
}

#######
# find the directory like 2011/05/11/
# @input $date: 2011 5 11
# @output $name: 2011/05/11/
#######
sub two_digit {
	my ($num) = @_;
	$num += 0;
	
	my $ret = "";
	
	$ret .= "0" if($num < 10);
	$ret .= $num;
	
	return $ret;
}



sub max_day {
	my ($year, $mon) = @_;
	
	if($mon == 1 || $mon == 3 || $mon == 5 || $mon == 7 || $mon == 8 || $mon == 10 || $mon == 12) {
		return 31;
	}
	elsif($mon == 2) {
		if($year % 4 == 0 && $year %100 != 0) {
			return 29;
		}
		else {
			return 28;
		}
	}
	else {
		return 30;
	}
}


#######
# change date time to seconds from 2010
# @input date time
# @output seconds
#######
sub to_seconds {
	my ($year, $mon, $day, $hour, $min, $sec) = @_;
	
	my $base_year = 2010;
	
	my $t_day = $day;
	if($year % 4 == 0) {
		$t_day += ($year - $base_year) * 366;
	}
	else {
		$t_day += ($year - $base_year) * 365;
	}
	for(my $i = 1; $i < $mon; $i ++) {
		if($i == 1 || $i == 3 || $i == 5 || $i == 7 || $i == 8 || $i == 10 || $i == 12) {
			$t_day += 31;
		}
		elsif($i == 2) {
			if($year != 0 && $year % 4 == 0) {
				$t_day += 29; 
			}
			else {
				$t_day += 28; 
			}
		}
		else {
			$t_day += 30;
		}
	}
	
	
	return (($t_day * 24 + $hour) * 60 + $min) * 60 + $sec;
}

#######
# change date time to seconds from 2010, only input format is different
# @input date time
# @output seconds
#######
sub to_seconds2 {
	my ($date_time) = @_;

	$date_time =~ /(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d+)/;
	return to_seconds($1, $2, $3, $4, $5, $6);
}


#######
# change seconds to date time from 2010
# @input seconds
# @output date time
#######
sub seconds_to_date {
	my ($seconds) = @_;
	my ($year, $mon, $day, $hour, $min, $sec);
	
	my $base_year = 2010;
	
	$sec = $seconds % 60;
	my $mins = int($seconds / 60);
	$min = $mins % 60;
	my $hours = int($mins / 60);
	$hour = $hours % 24;
	my $days = int($hours / 24);
	
	$year = $base_year;
	while(1) {
		if(to_seconds($year + 1, 1, 1, 0, 0, 0) > $seconds) {
			last;
		}
		$year ++;
	}
	
	for($mon = 1; $mon < 12; $mon ++) {
		if(to_seconds($year, $mon + 1, 1, 0, 0, 0) > $seconds) {
			last;
		}
	}
	$day = int(($seconds - to_seconds($year, $mon, 1, 0, 0, 0)) / (24 * 60 * 60) + 1);
	
	# print join(",", ($year, $mon, $day, $hour, $min, $sec))."\n";
	
	return ($year, $mon, $day, $hour, $min, $sec);
}

#######
# give start and end date, find intermediate months
# @input start_date, end_date
#######
sub intermediate_months {
	my ($start_date, $end_date) = @_;
	
	my ($s_year, $s_mon, $s_day) = split("-", $start_date);
	my ($e_year, $e_mon, $e_day) = split("-", $end_date);
	
	my $s_seconds = to_seconds($s_year, $s_mon, $s_day, 0, 0, 0);
	my $e_seconds = to_seconds($e_year, $e_mon, $e_day, 23, 59, 59);
	
	my @mons;
	my $pre = "";
	for(my $i = $s_seconds; $i <= $e_seconds; $i += 24*60*60) {
		my ($y, $m, $d, $h, $min, $s) = seconds_to_date($i);
		if("$y-$m" ne $pre) {
			push(@mons, "$y-$m");
			$pre = "$y-$m";
		}
	}
	
	return @mons;
}

#######
# give start and end date, find intermediate days
# @input start_date, end_date
#######
sub intermediate_days {
	my ($start_date, $end_date) = @_;
	
	my ($s_year, $s_mon, $s_day) = split("-", $start_date);
	my ($e_year, $e_mon, $e_day) = split("-", $end_date);
	
	my $s_seconds = to_seconds($s_year, $s_mon, $s_day, 0, 0, 0);
	my $e_seconds = to_seconds($e_year, $e_mon, $e_day, 23, 59, 59);
	
	my @days;
	my $pre = "aa";
	for(my $i = $s_seconds; $i <= $e_seconds; $i += 24*60*60) {
		my ($y, $m, $d, $h, $min, $s) = seconds_to_date($i);
		if("$y-$m-$d" ne $pre) {
			push(@days, "$y-$m-$d");
			$pre = "$y-$m-$d";
		}
	}
	
	return @days;
}

#######
# given a date, get the date of the previous n days
# @input $given_date
# @input $n: previous n days
#######
sub previous_n_days {
	my ($given_date, $n) = @_;
	
	my ($year, $mon, $day) = split("-", $given_date);
	
	my $pre_seconds = to_seconds($year, $mon, $day, 0, 0, 0) - $n * 24 * 60 * 60;
	
	my ($ret_y, $ret_m, $ret_d, $ret_h, $ret_min, $ret_s) = seconds_to_date($pre_seconds);
	
	return join("-", ($ret_y, two_digit($ret_m), two_digit($ret_d) ) );
	
}


####################################
## calculate for time series
# @input $s_year, $s_mon, $s_day: start date
# @input $ini: initial value of x tick, normally either 0 or 1
# @input $tunit: time unit (in seconds)
# @input $duration: the duration of x tick (in days)
####################################
sub get_xtick {
	my ($s_year, $s_mon, $s_day, $ini, $tunit, $duration) = @_;
	my $interval = 24 * 60 * 60;	# day
	my $start_secs = to_seconds($s_year, $s_mon, $s_day, 0, 0, 0);
	# set xtics (\"5/3\" 48, \"5/10\" 216, \"5/17\" 384, \"5/24\" 552, \"5/31\" 720, \"6/7\" 888, \"6/15\" 1080, \"6/23\" 1272)
	my $ret = "set xtics (";
	
	## hourly
	if($tunit == 3600) {
		$interval = 24 * 60 * 60;	# day
	}
	## daily
	if($tunit == 86400) {
		$interval = 24 * 60 * 60;	# day
	}
	
	for(my $i = $ini; $i < $duration * 24 * 60 * 60 / $tunit; $i += $interval / $tunit) {
		$ret .= ", " if($i != $ini);
		my ($year, $mon, $day, $hour, $min, $sec) = seconds_to_time($start_secs + ($i - $ini) * $tunit);
		$ret .= ("\"$mon/$day\" $i");
	}
	$ret .= ")";
}


####################################
## get all categories 
# @input $start_date, $end_date: now only 2010-05-01 ~ 2011-06-30 is available
# @input $n: top n categories, set to -1 to get all
# @input $level
####################################
sub get_top_n_topics {
	my ($start_date, $end_date, $n, $level) = @_;
	my @ret;
	
	my ($sy, $sm, $sd) = split("-", $start_date);
	$sm += 0;
	$sd += 0;
	my ($ey, $em, $ed) = split("-", $end_date);
	$em += 0;
	$ed += 0;
	
	my $dir = "/project2/yichao/mobility/custcare/task14/category/";
	my $file = "$sy$sm$sd.$ey$em$ed.$level.name.txt";
	
	open(FILE, $dir.$file) or die "cannot open\n";
	my $line = 0;
	while(<FILE>) {
		$line ++;
		$_ =~ /(.*?)\|/;
		push(@ret, $1);
		last if($line == $n);
	}
	close(FILE);
	
	return \@ret;
}



## might be useful ...
# for(my $year = $s_year; $year <= $e_year; $year ++) {
# 	for(my $mon = $s_mon; $mon <= 12; $mon ++) {
# 		my $max_day = MyUtil::max_day($year, $mon);
# 		for(my $day = $s_day; $day <= $max_day; $day ++) {
# 			
# 			my $subdir = MyUtil::name_dir($year, $mon, $day);
# 			my $input = MyUtil::name_BAN_RG_STB_MAPPINGS($year, $mon, $day);
# 			my $output = $input.".txt";
# 			
# 			print $input."\n";
# 			
# 			last if($day == $e_day && $mon == $e_mon && $year == $e_year);
# 		}
# 		last if($mon == $e_mon && $year == $e_year);
# 	}
# }


####################################
## map related
####################################

sub stb2rg {
	my $InputDir = "/project2/yichao/stb/task04/";
	my $STB2RG = "stb2rg.txt";

	my %stb;

	open(STB, "$InputDir$STB2RG") or die "Couldn 't open $STB2RG: $! ";
	while(<STB>) {
		if($_ =~ /(.*?), (.*?)\n/) {
			my ($stb, $rg) = (lc($1), lc($2));
			die "err: stb or rg empty!!\n" if($stb eq "" or $rg eq "");
			die "err: duplicate stb!!\n" if(exists $stb{$stb});

			$stb{$stb} = $rg;
		}
	}
	close STB;

	return %stb;
}

sub get_rg_from_stb {
	my ($target_stb) = @_;
	
	my $InputDir = "/project2/yichao/stb/task04/";
	my $STB2RG = "stb2rg.txt";
	
	open(STB, "$InputDir$STB2RG") or die "Couldn 't open $STB2RG: $! ";
	while(<STB>) {
		if($_ =~ /(.*?), (.*?)\n/) {
			my ($stb, $rg) = (lc($1), lc($2));
			
			if($stb eq lc($target_stb)) {
				close STB;
				return $rg ;
			}
		}
	}
	close STB;
	return "";
}

## if there is no record in database, then search in the file: stb2rg.txt
sub get_rg_from_stb_darkstar1 {
	my ($target_stb) = @_;
	
	$target_stb = "\U$target_stb\E";
	my $cmd = "run_query ./stb_rg2.X target_stb";
	my @data = `$cmd`;
	if(!defined $data[0] || $data[0] eq "") {
		return get_rg_from_stb($target_stb);
	}
	return $data[0];
}

## if there is no record in database, return ""
sub get_rg_from_stb_darkstar2 {
	my ($target_stb) = @_;
	
	$target_stb = "\U$target_stb\E";
	my $cmd = "run_query ./stb_rg2.X target_stb";
	my @data = `$cmd`;
	if(!defined $data[0] || $data[0] eq "") {
		return "";
	}
	return $data[0];
}


sub rg2ban {
	my $InputDir = "/project2/yichao/stb/task04/";
	my $RG2BAN = "rg2ban.txt";
	my %rg;

	open(RG, "$InputDir$RG2BAN") or die "Couldn 't open $RG2BAN: $! ";
	while(<RG>) {
		if($_ =~ /(.*?), (.*?)\n/) {
			my ($rg, $ban) = (lc($1), lc($2));
			die "err: ban or rg empty!!\n" if($ban eq "" or $rg eq "");
			die "err: duplicate rg!!\n" if(exists $rg{$rg});

			$rg{$rg} = $ban;
		}
	}
	close RG;
	
	return %rg;
}

sub ban2dslam {
	my $InputDir = "/project2/yichao/stb/task04/";
	my $BAN2DSLAM = "ban2dslam.txt";

	my %ban;

	open(BAN, "$InputDir$BAN2DSLAM") or die "Couldn 't open $BAN2DSLAM: $! ";
	while(<BAN>) {
		if($_ =~ /(.*?), (.*?)\n/) {
			my ($ban, $dslam) = (lc($1), lc($2));
			die "err: ban or dslam empty!!\n" if($ban eq "" or $dslam eq "");
			die "err: duplicate ban!!\n" if(exists $ban{$ban});

			$ban{$ban} = $dslam;
		}
	}
	close BAN;

	return %ban;
}

sub dslam2co {
	my $InputDir = "/project2/yichao/stb/task04/";
	my $DSLAM2CO = "dslam2co.txt";

	my %dslam;

	open(DSLAM, "$InputDir$DSLAM2CO") or die "Couldn 't open $DSLAM2CO: $! ";
	while(<DSLAM>) {
		if($_ =~ /(.*?), (.*?)\n/) {
			my ($dslam, $co) = (lc($1), lc($2));
			die "err: dslam or co empty!!\n" if($dslam eq "" or $co eq "");
			die "err: duplicate dslam!!\n" if(exists $dslam{$dslam});

			$dslam{$dslam} = $co;
		}
	}
	close DSLAM;
	
	return %dslam;
}

sub co2vho {
	my $InputDir = "/project2/yichao/stb/task04/";
	my $CO2VHO2CLLI = "co2vho2clli.clean.txt";

	my %co;

	open(CO, "$InputDir$CO2VHO2CLLI") or die "Couldn 't open $CO2VHO2CLLI: $! ";
	while(<CO>) {
		if($_ =~ /(.*?),(.*?),(.*?)\n/) {
			my ($co, $vho, $clli) = (lc($1), lc($2), lc($3));
			die "err: co or vho or clli empty!!\n" if($co eq "" or $vho eq "" or $clli eq "");
			print "err: duplicate co: $co <-> ".$co{$co}." and $vho!!\n" if(exists $co{$co});

			$co{$co} = $vho;
		}
	}
	close CO;	
	
	return %co;
}

sub vho2clli {	
	my $InputDir = "/project2/yichao/stb/task04/";
	my $CO2VHO2CLLI = "co2vho2clli.clean.txt";

	my %vho;

	open(CO, "$InputDir$CO2VHO2CLLI") or die "Couldn 't open $CO2VHO2CLLI: $! ";
	while(<CO>) {
		if($_ =~ /(.*?),(.*?),(.*?)\n/) {
			my ($co, $vho, $clli) = (lc($1), lc($2), lc($3));
			die "err: co or vho or clli empty!!\n" if($co eq "" or $vho eq "" or $clli eq "");
			
			$vho{$vho} = $clli if(!exists $vho{$vho});
		}
	}
	close CO;

	return %vho;
}

sub stb_done {
	my $InputDir = "/project2/yichao/stb/task04/";
	my $STB2RG = "stb_done.txt";

	my %stb;

	open(STB, "$InputDir$STB2RG") or die "Couldn 't open $STB2RG: $! ";
	while(<STB>) {
		if($_ =~ /(.*?), (.*?)\n/) {
			my ($stb, $stb_done) = (lc($1), lc($2));
		
			$stb{$stb} = $stb."|".$stb_done;
		}
	}
	close STB;

	return %stb;
}

sub add_stb_done {
	my ($stb, $stb_done) = @_;
	
	my $InputDir = "/project2/yichao/stb/task04/";
	my $STB2RG = "stb_done.txt";

	open(STB, ">> $InputDir$STB2RG") or die "Couldn 't open $STB2RG: $! ";
	print STB $stb.", ".$stb_done."\n";
	STB->autoflush(1);
	close STB;
}

####################################
## end of map related
####################################



sub cal_entropy {
	my ($var_ref) = (@_);
	
	my %var = %$var_ref;
	
	my $sum = 0;
	for (keys %var) {
		$sum += $var{$_};
	}
	return 0 if $sum == 0;
	
	my $H = 0;
	for (keys %var) {
		my $p = $var{$_} * 1.0 / $sum;
		
		$H += ($p * log($p)) if($p != 0);
	}
	
	return 0 - $H;
	
}

sub cal_unnormalized_entropy {
	my ($var_ref) = (@_);
	
	my %var = %$var_ref;
	
	my $sum = 0;
	for (keys %var) {
		$sum += $var{$_};
	}
	return 0 if $sum == 0;
	
	my $H = 0;
	for (keys %var) {
		my $p = $var{$_} * 1.0 / $sum;
		
		$H += ($var{$_} * log($p)) if($p != 0);
	}
	
	return 0 - $H;
	
}


sub cal_unnormalized_relative_entropy {
	my ($pre_var_ref, $var_ref) = (@_);

	my %pre_var = %$pre_var_ref;
	my %var = %$var_ref;


	my $H = 0;
	for (keys %var) {
		if(!exists $pre_var{$_} || $pre_var{$_} == 0 || $var{$_} == 0) {
			next;
		}
		
		## S(d | c) = \sum_i d_i log(d_i/c_i)
		$H += ($var{$_} * log($var{$_}/$pre_var{$_}));
	}

	return $H;

}


sub cal_relative_entropy {
	my ($pre_var_ref, $var_ref) = (@_);

	my %pre_var = %$pre_var_ref;
	my %var = %$var_ref;

	my $sum = 0;
	for (keys %var) {
		$sum += $var{$_};
	}
	return 0 if $sum == 0;
	
	my $pre_sum = 0;
	for (keys %pre_var) {
		$pre_sum += $pre_var{$_};
	}
	return 0 if $pre_sum == 0;

	my $H = 0;
	for (keys %var) {
		if(!exists $pre_var{$_} || $pre_var{$_} == 0 || $var{$_} == 0) {
			next;
		}
		
		my $p = $var{$_} * 1.0 / $sum;
		my $q = $pre_var{$_} * 1.0 / $pre_sum;
		
		$H += ($p * log($p/$q));
	}

	return $H;

}


sub cal_top_n_entropy {
	my ($var_ref, $list_ref) = (@_);
	
	
	my %var = %$var_ref;
	
	my $sum = 0;
	foreach(@$list_ref) {
		if(exists $var{$_}) {
			$sum += $var{$_};
		}
	}
	
	return 0 if $sum == 0;
	
	my $H = 0;
	foreach(@$list_ref) {
		if(exists $var{$_}) {
			my $p = $var{$_} * 1.0 / $sum;
			$H += ($p * log($p)) if($p != 0);
		}
	}
	
	return 0 - $H;
	
}

sub cal_top_n_unnormalized_entropy {
	my ($var_ref, $list_ref) = (@_);
	
	my %var = %$var_ref;
	
	my $sum = 0;
	foreach(@$list_ref) {
		if(exists $var{$_}) {
			$sum += $var{$_};
		}
	}
	return 0 if $sum == 0;
	
	my $H = 0;
	foreach(@$list_ref) {
		if(exists $var{$_}) {
			my $p = $var{$_} * 1.0 / $sum;
			$H += ($var{$_} * log($p)) if($p != 0);
		}
	}
	
	return 0 - $H;
}


sub cal_top_n_unnormalized_relative_entropy {
	my ($pre_var_ref, $var_ref, $list_ref) = (@_);

	my %pre_var = %$pre_var_ref;
	my %var = %$var_ref;


	my $H = 0;
	foreach(@$list_ref) {
		if(exists $var{$_} && exists $pre_var{$_}) {
			$H += ($var{$_} * log($var{$_}/$pre_var{$_})) if($pre_var{$_} != 0);
		}
	}

	return $H;

}


sub cal_top_n_relative_entropy {
	my ($pre_var_ref, $var_ref, $list_ref) = (@_);

	my %pre_var = %$pre_var_ref;
	my %var = %$var_ref;

	my $sum = 0;
	foreach(@$list_ref) {
		if(exists $var{$_}) {
			$sum += $var{$_};
		}
	}
	return 0 if $sum == 0;
	
	my $pre_sum = 0;
	foreach(@$list_ref) {
		if(exists $pre_var{$_}) {
			$pre_sum += $pre_var{$_};
		}
	}
	return 0 if $pre_sum == 0;

	my $H = 0;
	foreach(@$list_ref) {
		if(exists $var{$_} && exists $pre_var{$_}) {
			if($pre_var{$_} != 0) {
				my $p = $var{$_} * 1.0 / $sum;
				my $q = $pre_var{$_} * 1.0 / $pre_sum;

				$H += ($p * log($p/$q));
			}
		}
	}

	return $H;

}

sub cal_freq_among_top_n {
	my ($var_ref, $list_ref, $topic) = (@_);
	
	my $sum = 0;
	foreach(@$list_ref) {
		if(exists $var_ref->{$_}) {
			$sum += $var_ref->{$_};
		}
	}
	return 0 if $sum == 0;
	
	return $var_ref->{$topic} * 1.0 / $sum;
}

sub cal_self_ent_among_top_n {
	my ($var_ref, $list_ref, $topic) = (@_);
	
	return 0 if(!exists($var_ref->{$topic}));
	return 0 if($var_ref->{$topic} == 0);
	
	my $sum = 0;
	foreach(@$list_ref) {
		if(exists $var_ref->{$_}) {
			$sum += $var_ref->{$_};
		}
	}
	return 0 if $sum == 0;
	
	my $p = $var_ref->{$topic} * 1.0 / $sum;
	
	return 0 - ($p * log($p));
}

sub cal_self_relative_ent_among_top_n {
	my ($pre_var_ref, $var_ref, $list_ref, $topic) = (@_);

	return 0 if(!exists($var_ref->{$topic}) or !exists($pre_var_ref->{$topic}));
	return 0 if($var_ref->{$topic} == 0 or $pre_var_ref->{$topic} == 0);
	
	my $sum = 0;
	foreach(@$list_ref) {
		if(exists $var_ref->{$_}) {
			$sum += $var_ref->{$_};
		}
	}
	return 0 if $sum == 0;
	
	my $pre_sum = 0;
	foreach(@$list_ref) {
		if(exists $pre_var_ref->{$_}) {
			$pre_sum += $pre_var_ref->{$_};
		}
	}
	return 0 if $pre_sum == 0;

	my $p = $var_ref->{$topic} * 1.0 / $sum;
	my $q = $pre_var_ref->{$topic} * 1.0 / $pre_sum;
	
	return $p * log($p/$q);
}

sub average {
    my($data) = @_;
    if (not @$data) {
            die("Empty array\n");
    }
    my $total = 0;
    foreach (@$data) {
            $total += $_;
    }
    my $average = $total / @$data;
    return $average;
}

sub stdev {
    my($data) = @_;
    if(@$data == 1){
            return 0;
    }
    my $average = &average($data);
    my $sqtotal = 0;
    foreach(@$data) {
            $sqtotal += ($average-$_) ** 2;
    }
    my $std = ($sqtotal / (@$data-1)) ** 0.5;
    return $std;
}

sub median {
	my ($data) = @_;
    
    my @vals = sort {$a <=> $b} @$data;
    my $len = @vals;
    if($len%2) #odd?
    {
        return $vals[int($len/2)];
    }
    else #even
    {
        return ($vals[int($len/2)-1] + $vals[int($len/2)])/2;
    }
}



sub recall {
	my ($tp, $fn, $fp, $tn) = @_;

	return 1 if(($tp + $fn) == 0);
	return ( $tp / ($tp + $fn) );
}

sub precision {
	my ($tp, $fn, $fp, $tn) = @_;

	return 1 if(($tp + $fp) == 0);
	return ( $tp / ($tp + $fp) );
}

sub f1_score {
	my ($precision, $recall) = @_;

	return 0 if(($precision + $recall) == 0);
	return (2 * $precision * $recall / ($precision + $recall));
}

sub pos2dist {
	my ($lat1, $lng1, $lat2, $lng2) = @_;

	if($lng1 < 0) {
		$lng1 += 360;
	}
    if($lng2 < 0) {
    	$lng2 += 360;
    }

	my $R_aver = 6374;
    my $deg2rad = pi/180;
    
    $lat1 *= $deg2rad;
    $lng1 *= $deg2rad;
    $lat2 *= $deg2rad;
    $lng2 *= $deg2rad;

    my $dist = $R_aver * acos(cos($lat1)*cos($lat2)*cos($lng1-$lng2) + sin($lat1)*sin($lat2));
}



1;  		# 回傳一個真值
