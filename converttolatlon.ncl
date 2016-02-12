
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

; ij coordinates of point to convert
print("Enter i: ")
i = toint(systemfunc("read ANS; echo $ANS"))
print("Enter j: ")
j = toint(systemfunc("read ANS; echo $ANS"))
print("i: " + i)
print("j: " + j)

; Load list of wrfout files and open the first one in the list
files = systemfunc("ls -1 " + "wrfout_d04* ")
a = addfile(files(1)+".nc","r")
; Now that the file is read, convert ij to lat/lon
pointll = wrf_user_ij_to_ll(a,i,j,True)
print("Lat: " + pointll(1) + "   " + "Lon: " + pointll(0))
end
