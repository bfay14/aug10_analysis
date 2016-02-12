#!/bin/csh

#BSUB -P UIUC0002
#BSUB -n 1
#BSUB -R "span[ptile=1]"
#BSUB -q regular
#BSUB -W 04:00				# wallclock
#BSUB -J thetaplots_2000

#BSUB -e ncl_%J.err
#BSUB -o ncl_%J.out

ncl thetaplots_2000.ncl 

mv *.png /glade/p/work/bfay/images

