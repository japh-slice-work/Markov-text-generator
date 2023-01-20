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
else{
	importTextToTable('0100011.txt',$hash2,2);
	importTextToTable('0100021.txt',$hash2,2);
	importTextToTable('0200011.txt',$hash2,2);
	importTextToTable('0200141.txt',$hash2,2);
	importTextToTable('0200151.txt',$hash2,2);
	importTextToTable('0201111.txt',$hash2,2);
	store($hash2, "hash2.tbl");
}
if (-e 'hash3.tbl'){$hash3=retrieve("hash3.tbl");}
else{
	importTextToTable('0100011.txt',$hash3,3);
	importTextToTable('0100021.txt',$hash3,3);
	importTextToTable('0200011.txt',$hash3,3);
	importTextToTable('0200141.txt',$hash3,3);
	importTextToTable('0200151.txt',$hash3,3);
	importTextToTable('0201111.txt',$hash3,3);
	store($hash3, "hash3.tbl");
}
if (-e 'hash4.tbl'){$hash4=retrieve("hash4.tbl");}
else{
	importTextToTable('0100011.txt',$hash4,4);
	importTextToTable('0100021.txt',$hash4,4);
	importTextToTable('0200011.txt',$hash4,4);
	importTextToTable('0200141.txt',$hash4,4);
	importTextToTable('0200151.txt',$hash4,4);
	importTextToTable('0201111.txt',$hash4,4);
	store($hash4, "hash4.tbl");
}
# importTextToTable('short.txt',$hash2,2);
# importTextToTable('short.txt',$hash3,3);
# importTextToTable('short.txt',$hash4,4);

my $run=100;
my @output=qw(it was said that);


##Detect if command line args were provided.
# first arg *may* be a number, if so, that's the number of words to produce
# if not a number or if second arg exists then use that as the seed words.
if ($ARGV[0]=~/\d+/){$run=shift(@ARGV);}
if ($ARGV[0]){@output=@ARGV;}


open (TESTLOG,">>markov.test.log");

while($run){
	$run--;
	# my @table=([[$output[-2],$output[-1]],$hash2],[[$output[-3],$output[-2],$output[-1]],$hash3],[[$output[-4],$output[-3],$output[-2],$output[-1]],$hash4]);
	# my @table=();
	# if (scalar(@output)>3){
		# @table=([makeAryRefByDepth(\@output,2),$hash2],
					# [makeAryRefByDepth(\@output,3),$hash3],
					# [makeAryRefByDepth(\@output,4),$hash4]);
	# } elsif (scalar(@output)>2){
		# @table=([makeAryRefByDepth(\@output,2),$hash2],
					# [makeAryRefByDepth(\@output,3),$hash3]);
	# } else {
		# @table=([makeAryRefByDepth(\@output,2),$hash2]);
	# }
	my @table=([makeAryRefByDepth(\@output,2),$hash2],
	[makeAryRefByDepth(\@output,3),$hash3],
	[makeAryRefByDepth(\@output,4),$hash4]);
	
	push(@output,getElementByProbabilityMultiTableSet(\@table));	
}
print "Here ya go:\n@output\n";

if (open (OUTPUT, ">>markov.out.log")){
	my $i=0;
	foreach my $word (@output){
		print OUTPUT "$word ";
		if (!($i % 15) && ($i > 14)){print OUTPUT "\n";}
		$i++;
	}
	print OUTPUT "\n*************************************************\n";
	close (OUTPUT);
}

sub makeAryRefByDepth{
	my ($aryRef,$depth)=@_;
	my @ary=();
	for (my $i=$depth;$i>0;$i--){
		push(@ary,${$aryRef}[($i*-1)]);
	}	
#	print Dumper \@ary;
	return(\@ary);
}
sub getElementByProbabilityMultiTableSet{
	my ($aryOfSets)=@_;
	my @finalArray=();
	my @simpleArray=();
	my $i=1;
	foreach $pair(@{$aryOfSets}){
		push(@simpleArray,getProbabilityListFromHash(${$pair}[0],${$pair}[1]));
		for(my $j=0;$j<$i;$j++){
			push(@finalArray,getProbabilityListFromHash(${$pair}[0],${$pair}[1]));
		}
		$i++;
	}
	return($finalArray[int(rand(scalar(@simpleArray)))]);
}
sub getProbabilityListFromHash{
	my ($aryPtr,$hash)=@_;
	my $sampleKey=join(' ',@{$aryPtr});
	if (exists($hash->{$sampleKey})){
		my @outputArray=();
		foreach my $key(keys(%{$hash->{$sampleKey}})){
			for (my $i=0;$i<$hash->{$sampleKey}->{$key};$i++){
				push (@outputArray,$key);
			}
		}
		return(@outputArray);
	}
	return(undef);
}

sub getElementByProbabilityN{
	my ($aryPtr,$hash)=@_;
	my $sampleKey=join(' ',@{$aryPtr});
	if (exists($hash->{$sampleKey})){
		my @outputArray=();
		foreach my $key(keys(%{$hash->{$sampleKey}})){
			for (my $i=0;$i<$hash->{$sampleKey}->{$key};$i++){
				push (@outputArray,$key);
			}
		}
		return($outputArray[int(rand(scalar(@outputArray)))]);
	}
	return(undef);
}


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
