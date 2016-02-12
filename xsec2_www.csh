#!/bin/csh

#BSUB -P UIUC0002
#BSUB -n 1
#BSUB -R "span[ptile=1]"
#BSUB -q regular
#BSUB -W 06:00				# wallclock
#BSUB -J xsec2_www

#BSUB -e ncl_%J.err
#BSUB -o ncl_%J.out

ncl xsec2_www.ncl 

mv *.png /glade/p/work/bfay/images
