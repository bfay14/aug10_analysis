#!/bin/csh

#BSUB -P UIUC0002
#BSUB -n 1
#BSUB -R "span[ptile=1]"
#BSUB -q regular
#BSUB -W 01:00				# wallclock
#BSUB -J pplots

#BSUB -e ncl_%J.err
#BSUB -o ncl_%J.out

ncl pplots.ncl 

mv *.png /glade/p/work/bfay/images

