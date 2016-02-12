load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

files = systemfunc("ls -1 " + "wrfout_d04* ")
numfiles = dimsizes(files) ; number of files

type = "png"

; point at which to draw skew-t
;x = 575
;y = 375
lat = 38.5
lon = -96.5
;ifil = 1
do ifil=0,numfiles-1

  a = addfile(files(ifil)+".nc","r")
  currentfile = files(ifil)
  filestr = tochar(currentfile)
  date = filestr(11:20)
  time = (filestr(22:23)+"_"+filestr(25:26))
; convert lat/lon to ij to use for point
  print(lat)
  print(lon)
  point = wrf_user_ll_to_ij(a,lon,lat,True)
  point = point - 1 ; convert to NCL coordinates
  print(point)
; ok, let's get some variables
  times = wrf_user_getvar(a,"times",-1)
  tc  = wrf_user_getvar(a,"tc",0)
  td  = wrf_user_getvar(a,"td",0)
  p   = wrf_user_getvar(a,"pressure",0)
  z   = wrf_user_getvar(a,"z",0)
  uvm = wrf_user_getvar(a,"uvmet",0)
  u   = uvm(0,:,:,:)*1.94386
  v   = uvm(1,:,:,:)*1.94386
  
  print("Working on time: " + times)
  wks = gsn_open_wks(type, "skewt3_" + date + "_" + time)
  
  skewTres = True
  skewTres@DrawHeightScale = True
  skewTres@DrawHeightScaleFt = False
  skewTres@DrawFahrenheit = False
  skewTres@tiMainString   = lat + "N, " +  abs(lon) + "W"
  skewt_bkgd = skewT_BackGround(wks,skewTres)
  draw(skewt_bkgd)

  datares = True
  datares@WspdWdir = False
  datares@HspdHdir = True
  datares@PlotWindH = False
  datares@colTemperature = "Red"
  datares@Wthin = 5
  skewt_data = skewT_PlotData(wks,skewt_bkgd,p(:,point(1),point(0)),tc(:,point(1),point(0)),td(:,point(1),point(0)),z(:,point(1),point(0)),\
                             u(:,point(1),point(0)),v(:,point(1),point(0)),datares)

  frame(wks)
end do
end
