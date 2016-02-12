#!/bin/csh

#BSUB -P UIUC0002
#BSUB -n 1
#BSUB -R "span[ptile=1]"
#BSUB -q regular
#BSUB -W 5:00				# wallclock
#BSUB -J xsec_wind

#BSUB -e ncl_%J.err
#BSUB -o ncl_%J.out

ncl xsec_wind.ncl 

mv *.png /glade/p/work/bfay/images
