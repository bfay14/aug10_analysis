load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

files = systemfunc("ls -1 " + "wrfout_d03*02_00_00 ")
numfiles = dimsizes(files) ; number of files

type = "png"

; point at which to draw skew-t
x = 575
y = 375

;ifil = 1
do ifil=0,numfiles-1

  a = addfile(files(ifil)+".nc","r")
  currentfile = files(ifil)
  filestr = tochar(currentfile)
  date = filestr(11:20)
  time = (filestr(22:23)+"_"+filestr(25:26))

  times = wrf_user_getvar(a,"times",-1)
  tc  = wrf_user_getvar(a,"tc",0)
  td  = wrf_user_getvar(a,"td",0)
  p   = wrf_user_getvar(a,"pressure",0)
  z   = wrf_user_getvar(a,"z",0)
  uvm = wrf_user_getvar(a,"uvmet",0)
  u   = uvm(0,:,:,:)*1.94386
  v   = uvm(1,:,:,:)*1.94386
  
  print("Working on time: " + times)
;  wks = gsn_open_wks(type, "skewt1_" + date + "_" + time)
  wks = gsn_open_wks(type, "test")
  point = wrf_user_ij_to_ll(a,x,y,True)

  ; change xy to NCL coordinates
  
  x = x-1
  y = y-1
  print("x: "+ x)
  print("y: "+ y)
  skewTres = True
  skewTres@DrawHeightScale = True
  skewTres@DrawHeightScaleFt = False
  skewTres@DrawFahrenheit = False
  
  skewt_bkgd = skewT_BackGround(wks,skewTres)
  draw(skewt_bkgd)

  datares = True
  datares@WspdWdir = False
  datares@HspdHdir = True
  datares@PlotWindH = False
  datares@colTemperature = "Red"
  datares@Wthin = 5
  skewt_data = skewT_PlotData(wks,skewt_bkgd,p(:,y,x),tc(:,y,x),td(:,y,x),z(:,y,x),\
                             u(:,y,x),v(:,y,x),datares)

  frame(wks)
end do
end
