#!/bin/csh

#BSUB -P UIUC0002
#BSUB -n 1
#BSUB -R "span[ptile=1]"
#BSUB -q regular
#BSUB -W 06:00			# wallclock
#BSUB -J rhplots_1000

#BSUB -e ncl_%J.err
#BSUB -o ncl_%J.out

ncl rhplots_1000.ncl 

mv *.png /glade/p/work/bfay/images/rh

