#!/bin/csh

#BSUB -P UIUC0002
#BSUB -n 1
#BSUB -R "span[ptile=1]"
#BSUB -q regular
#BSUB -W 02:00				# wallclock
#BSUB -J xsecperp_www

#BSUB -e ncl_%J.err
#BSUB -o ncl_%J.out

ncl xsecperp_www.ncl 

mv *.png /glade/p/work/bfay/images
