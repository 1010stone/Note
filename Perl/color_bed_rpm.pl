#!/usr/bin/perl -w
use POSIX qw(strftime);
use Getopt::Std;
use File::Basename;

###############################################################################
#Get the parameter and provide the usage.
###############################################################################
my %opts;
getopts( 'i:o:d:h:n:r:t:', \%opts );
&usage unless ( exists $opts{i} && exists $opts{o} );
my $start_time=time;
print strftime("Start time is %Y-%m-%d %H:%M:%S\n", localtime(time));
print "Input file is $opts{i}\nOutput file is $opts{o}\n";
print "Database file is $opts{d}\n" if defined($opts{d});
$opts{h}=0 unless defined($opts{h});
$opts{n}=$opts{o} unless defined($opts{n});
$opts{r}=0 unless defined($opts{r});
$opts{t}=1000000 unless defined($opts{t});


###############################################################################
#Read the database in memory(opt)
###############################################################################
#open DATABASE,"<$opts{d}";
#my %database; #database in hash
#while (<DATABASE>) {
#	chomp;
#	my @tmp=split/\t/;
#	$database{$tmp[1]}=$tmp[2];
#}

#my (@tmp1,@tmp2); #database in array
#while (<DATABASE>) {
#	chomp;
#	my @tmp=split/\t/;
#	push @tmp1,$tmp[1];
#	push @tmp2,@tmp[2];
#}
#close DATABASE;

#open a list file
#my %list;
#my @filelist=glob "$opts{i}";
#foreach $file(@filelist){
#	open DATABASE,"<$file";
#	$file=basename($file);
#	while (<DATABASE>) {
#		my @tmp=split/\t/;
#		$list{$file}{nr}++;
#	}
#	close DATABASE;
#}

###############################################################################
#Main text.
###############################################################################
open INPUT,"<$opts{i}";
#IGS-A	22	43	3803659_1	255	+
#IGS-A	302	323	2831981_1	255	+
open OUTPUT,">$opts{o}";
#track name="AADD" description="21-nt red, 24-nt green, other blue" visibility=2 itemRgb="On"
#IGS-A	22	43	3803659_1	255	+	22	43	255,0,0 �� 21-nt
#IGS-A	22	44	3803659_1	255	+	22	44	0,255,0 �� 24-nt 
#IGS-A	22	45	3803659_1	255	+	22	45	0,0,255 �� other
while ($opts{h}>0) { #filter header
	<INPUT>;
	$opts{h}--;
}
print OUTPUT 'track name="',$opts{n},'" description="21-nt red, 24-nt green, other blue" visibility=2 itemRgb="On"',"\n";

while (<INPUT>) {
	chomp;
	my @tmp=split/\t/;
	@tmp1=split/_/,$tmp[3];
	next if $tmp1[1]/$opts{t}*1000000<=$opts{r};
	if ($tmp[2]-$tmp[1]>=21 && $tmp[2]-$tmp[1]<=22) {
		print OUTPUT "$_\t$tmp[1]\t$tmp[2]\t255,0,0\n";
	}elsif ($tmp[2]-$tmp[1]==24) {
		print OUTPUT "$_\t$tmp[1]\t$tmp[2]\t0,255,0\n";
	}elsif ($tmp[2]-$tmp[1]>=21 && $tmp[2]-$tmp[1]<=24){
		print OUTPUT "$_\t$tmp[1]\t$tmp[2]\t0,0,255\n";
	}else{
		next;
		print OUTPUT "$_\t$tmp[1]\t$tmp[2]\t255,255,0\n";
	}
	
}
close INPUT;
close OUTPUT;

###############################################################################
#Record the program running time!
###############################################################################
my $duration_time=time-$start_time;
print strftime("End time is %Y-%m-%d %H:%M:%S\n", localtime(time));
print "This compute totally consumed $duration_time s\.\n";

###############################################################################
#Scripts usage and about.
###############################################################################
sub usage {
    die(
        qq/
Usage:    color_bed_rpm.pl -i inpute_file -o output_file -n name
Function: add sRNA bed to three color, 21-nt red, 24-nt green, and other 20, 22, 23, 25 blue
Command:  -i input bed in 5 lines (Must)
          -o output bed in 8 lines (Must)
          -n tract name
		  -r RPM filter, default > 0.5
		  -t total reads, default 1000000
          -h header line number, default 0
Author:   Liu Yong-Xin, woodcorpse\@163.com, QQ:42789409
Version:  v1.0
Update:   2015-10-02
Notes:    
\n/
    )
}