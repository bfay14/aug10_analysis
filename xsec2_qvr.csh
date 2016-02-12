#!/bin/csh

#BSUB -P UIUC0002
#BSUB -n 1
#BSUB -R "span[ptile=1]"
#BSUB -q regular
#BSUB -W 02:00				# wallclock
#BSUB -J ncl

#BSUB -e ncl_%J.err
#BSUB -o ncl_%J.out

ncl xsec2_qvr.ncl 

mv *.png /glade/p/work/bfay/images

