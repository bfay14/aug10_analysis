
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

; lat/lon coordinates of point to convert
print("Enter lat: ")
lat = tofloat(systemfunc("read ANS; echo $ANS"))
print("Enter lon: ")
lon = tofloat(systemfunc("read ANS; echo $ANS"))
print("lat: " + lat)
print("lon: " + lon)

; Load list of wrfout files and open the first one in the list
files = systemfunc("ls -1 " + "wrfout_d04* ")
a = addfile(files(1)+".nc","r")
; Now that the file is read, convert lat/lon to ij.
pointll = wrf_user_ll_to_ij(a,lon,lat,True)
pointll = pointll - 1
print("i: " + pointll(0) + "   " + "j: " + pointll(1))
end
