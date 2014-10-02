#!/usr/bin/perl
# This is a translation of Alex Dobin's npIDR script (see funIDRnpFile.m) from matlab into Perl
# Done on Oct 1, 2014 Dmitri Pervouchine (dp@crg.eu)
#
# To run this script from commandline you call 
# perl npIDR.pl binSize poolType < fIn > fOut
# fIn is a tsv file (TABs, not spaces!), replicas are in columns (as many as you want)
#
# Note: this version supports more than two bioreplicates.

($binSize, $poolType) = @ARGV;

$binSize  = 1 unless($binSize);
$poolType = 2 unless($poolType);

while($line=<STDIN>) {
    chomp $line;
    @values = split /\t/, $line;
    $nzeroes = 0;					# number of zeros in a line
    $res = 0;						# output of a line
    for($j = $i = 0; $i < @values; $i++) {
	$values[$i] = int($values[$i]/$binSize);
	if($values[$i] == 0) {
	    $nzeroes++;					# count number of zeros in the line
	}
	else {
	    $j = $i;					# memorize non-zero value
	}
	$absolute{$values[$i]}++;			# absolute counter incremented always
	if($poolType==1) {
	    $res += $values[$i];			# pool type = sum
	}
	else {
	    $res = $values[$i] if($values[$i]>$res);	# pool type = max
	}
    }
    $conditional{$values[$j]}++ if($nzeroes == @values - 1); # conditional counter incremented if zeroes are in all replicas but one
    push @res, $res;
}

foreach $x(@res) {
    $idr = $absolute{$x} ? $conditional{$x}/$absolute{$x} : 0;
    print join("\t", $idr), "\n";
}

