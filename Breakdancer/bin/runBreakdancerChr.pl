#!/usr/bin/perl
use Getopt::Long;

GetOptions (\%opt,"bam:s","help");


my $help=<<USAGE;
perl $0 --bam
Prepare shell for breakdancer run on biocluster using pbs
qsub -q js bd.sh
USAGE


if ($opt{help} or keys %opt < 0){
    print "$help\n";
    exit();
}

$opt{bam} ||= "../input";

my $Shell=<<CMD;
#!/bin/sh
#PBS -l nodes=12:ppn=12
#PBS -l mem=10gb
#PBS -t 1-12
#PBS -l walltime=100:00:00

NUM=12

cd \$PBS_O_WORKDIR

date
if [ ! -e HEG4.\$PBS_ARRAYID.config ]; then
echo "Config"
/rhome/cjinfeng/software/tools/SVcaller/breakdancer-1.1.2/bin/bam2cfg.pl -c 7 -n 10000 $opt{bam}/HEG4.MSU7_BWA.Chr\$PBS_ARRAYID.bam > HEG4.\$PBS_ARRAYID.config
fi
date
echo "Max"
/rhome/cjinfeng/software/tools/SVcaller/breakdancer-1.1.2/bin/breakdancer-max -o Chr\$PBS_ARRAYID -c 7 -m 1000000 -q 20 HEG4.\$PBS_ARRAYID.config > HEG4.Chr\$PBS_ARRAYID.max
date
echo "Done"

CMD


open OUT, ">bd.sh" or die "$!";
     print OUT "$Shell\n";
close OUT;
 
