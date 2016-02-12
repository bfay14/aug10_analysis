;mple series of plotting meteograms with WRF ARW model data
; First let's just get and plot t2 at a point


;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
;***********************************************
begin
;***********************************************
; set directory with wrfout files here
; datadir = /data/pecan/a/norris13/aug10_200m/0400/tests
files = systemfunc (" ls -1 " + "wrfout_d04* ")
numfiles = dimsizes(files)

wks=gsn_open_wks("png","point2_time_series")
plot = new(5, graphic)

; Set point to draw time series
; Point2
;x = 520
;y = 400
; point3
x = 513
y = 879
; Set some basic resources
  res = True
  res@MainTitle = "REAL-TIME WRF"
  res@Footer = False

res@gsmLeftString = "tmXBMode = Explicit"

a = addfiles(files+".nc","r")
times = wrf_user_getvar(a,"times",-1) ; get all times in the file
;times_in_file = a->Times
;dims = dimsizes(times_in_file)
;print("dims = " + dims)
;times = new((/ 3,19 /) ,string)
;times = chartostring(times_in_file(0,12:15))
;print(dimsizes(times))
;do i=0,2
;   times(:,i) = chartostring(times_in_file(i,12:15))
;end do
;print (times)
;slp=wrf_user_getvar(a,"slp",-1)
ListSetType(a, "cat")
p=a[:]->P(:,0,y-1,x-1)
p=p/100.
wvmr = a[:]->QVAPOR(:,0,y-1,x-1)
wvmr = wvmr*1000. ; convert to g/kg for plotting
rain = a[:]->RAINNC(:,y-1,x-1) ; is cumulative
uwind = a[:]->U10(:,y-1,x-1)
vwind = a[:]->V10(:,y-1,x-1) 
umag = sqrt((uwind*uwind)+(vwind*vwind))
udir = atan(uwind/vwind) + 3.14159/2
udeg = (udir*180.)/3.14159
theta2m   = a[:]->TH2(:,y-1,x-1)
t2m = a[:]->T2(:,y-1,x-1)
t2m = t2m - 273.15
;slp_point2=slp(:,400,520)
  taus = ispan(0,90,10)       ; create a time reference
  pltres=True
  mpres = True
  
  slpres = True
;  slpres@AspectRatio = 0.5
  slpres@tmXBMode	= "Explicit"
  slpres@trXMinF    = taus(0)
  slpres@trXMaxF    = taus(9)
  slpres@tmXBValues = taus
  ;slpres@tmXBMinorValues = ispan(0,30,1)
  slpres@tmXBLabels = (/"2:00","2:10","2:20","2:30","2:40","2:50","3:00", \
                      "3:10","3:20","3:30","3:40" /)
;  slpres@tmYLMode   = "Explicit"
;  slpres@trYMinF    = 13
;  slpres@trYMaxF    = 17
;  slpres@tmYLValues = ispan(slpres@trYMinF,slpres@trYMaxF,1)
;  slpres@tmYLLabels = slpres@tmYLValues
  ;slpres@tiYAxisString = "Pressure Perturbation (hPa)"
  slpres@tiMainString  = "Pressure Perturbation (hPa)"
  slpres@tmXTOn     = False
  slpres@xyLineThicknesses = 2
  slpres@xyLineColor = "blue"
  slpres@gsnFrame = False
  slpres@gsnDraw = False
  slpres@vpHeightF = 0.20
  slpres@vpWidthF  = 0.40
  plot(0)  = gsn_csm_xy(wks,ispan(0,dimsizes(p)-1,1),p,slpres)
  delete(slpres@trYMinF)
  delete(slpres@trYMaxF)
  delete(slpres@tmYLValues)
  delete(slpres@tmYLLabels)
;  delete(slpres@tiYAxisString)

  qres = slpres
;  qres@tiYAxisString = "Water Vapor Mixing Ratio (g/kg)"
  qres@tiMainString = "Water Vapor Mixing Ratio (g/kg)"
;  qres@trYMinF = 13
;  qres@trYMaxF = 18
;  qres@tmYLValues = ispan(qres@trYMinF,qres@trYMaxF,1)
;  qres@tmYLLabels = qres@tmYLValues

  thetares = slpres
;  thetares@tiYAxisString = "2 m Potential Temperature (K)"
  thetares@tiMainString = "2 m Potential Temperature (K)"
;  thetares@trYMinF = 294
;  thetares@trYMaxF = 304
;  thetares@tmYLValues = ispan(thetares@trYMinF,thetares@trYMaxF,2)
;  thetares@tmYLLabels = thetares@tmYLValues

  umagres = slpres
;  umagres@tiYAxisString = "Wind Speed (m/s)"
  umagres@tiMainString = "10 m Wind Speed (m/s)"
;  umagres@trYMinF = 0
;  umagres@trYMaxF = 16
;  umagres@tmYLValues = ispan(umagres@trYMinF,umagres@trYMaxF,2)
;  umagres@tmYLLabels = umagres@tmYLValues
  t2res = slpres
  t2res@tiMainString = "2 m Temperature (C)"  
  pnlres = True
  pnlres@PanelPlot = True
  pnlres@FramePlot = False
  pnlres@XWhiteSpacePercent = 3    
  plot(1)  = gsn_csm_xy(wks,ispan(0,dimsizes(wvmr)-1,1),wvmr,qres)
  plot(2)  = gsn_csm_xy(wks,ispan(0,dimsizes(theta2m)-1,1),theta2m,thetares)
  plot(3)  = gsn_csm_xy(wks,ispan(0,dimsizes(umag)-1,1),umag,umagres)
  plot(4)  = gsn_csm_xy(wks,ispan(0,dimsizes(t2m)-1,1),t2m,t2res)
  gsn_panel(wks,plot,(/3,2/),pnlres)
end
