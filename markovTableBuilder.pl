#!c:/perl64/bin/perl

####
##
## (C) Marc Labelle 2018
##

BEGIN {
	unshift(@INC,"c:/perl64/site/lib");
}
use Data::Dumper;
use Storable;


my $hash2={};
my $hash3={};
my $hash4={};
if (-e 'hash2.tbl'){$hash2=retrieve("hash2.tbl");}
if (-e 'hash3.tbl'){$hash3=retrieve("hash3.tbl");}
if (-e 'hash4.tbl'){$hash4=retrieve("hash4.tbl");}
importTextToTable($ARGV[0],$hash2,2);
importTextToTable($ARGV[0],$hash3,3);
importTextToTable($ARGV[0],$hash4,4);

# store($hash2, $ARGV[0] . ".hash2.tbl");	
# store($hash3, $ARGV[0] . ".hash3.tbl");
# store($hash4, $ARGV[0] . ".hash4.tbl");
store($hash2, "hash2.tbl");	
store($hash3, "hash3.tbl");
store($hash4, "hash4.tbl");


sub importTextToTable{
	my ($filename,$tablePtr,$depth)=@_;
	print "working on file: $filename\n";
	unless (open (FILE,"$filename")){print "\tFailed.\n";return(0);}
	my @file=<FILE>;
	close(FILE);
	@file=split(/\s+/,join(' ',@file));
	while (checkNextElements(\@file,$tablePtr,$depth)){shift(@file);}
	print "\tDone\n";
	return(1);
}
sub checkNextElements{
	my ($aryPtr,$hashPtr,$num)=@_;
	if (scalar(@{$aryPtr}) < $num){return(0);}
	my $key=${$aryPtr}[0];
	for (my $i = 1;$i<$num;$i++){
		$key=join(' ',$key,${$aryPtr}[$i]);
	}
	if (exists($hashPtr->{$key})){
		if (exists($hashPtr->{$key}->{${$aryPtr}[$num]})){
			${$hashPtr}{$key}->{${$aryPtr}[$num]}++;
			return(1);
		}
		else{
			$hashPtr->{$key}->{${$aryPtr}[$num]}=1;
#			print "$key: $hashPtr->{$key}->{${$aryPtr}[$num]}\n";
		}
	}
	else{
		$hashPtr->{$key}->{${$aryPtr}[$num]}=1;
	}
	return(1);
}
