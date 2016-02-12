#!/bin/csh

#BSUB -P UIUC0002
#BSUB -n 1
#BSUB -R "span[ptile=1]"
#BSUB -q regular
#BSUB -W 02:30				# wallclock
#BSUB -J dbzplots

#BSUB -e ncl_%J.err
#BSUB -o ncl_%J.out

ncl dbzplots.ncl 

mv *.png /glade/p/work/bfay/images

