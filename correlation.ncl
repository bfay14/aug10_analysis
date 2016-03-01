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
files = systemfunc (" ls -1 " + "wrfout_d04*0{2,3}_*_00 ")
numfiles = dimsizes(files)

wks=gsn_open_wks("png","v_correlation") 
; Initialize array for heights 
;z = new((/numfiles,99/),"double")

; Set point to draw time series
; Point2
;x = 520
;y = 400
; point3
x = 513
y = 879

; Set endpoints for wave movement vector (use ij points so no conversion is necessary)
startij = (/312.,1042./)
endij   = (/1149.,362./)
;print("rise/run = " + (r
slope = (endij(1)-startij(1))/(endij(0)-startij(0))
theta = atan(slope)

zmax = 1.0
; Set some basic resources
  res = True
  res@MainTitle = "REAL-TIME WRF"
  res@Footer = False

res@gsmLeftString = "tmXBMode = Explicit"
zfil=0;
;do zfil=0,numfiles-1
  c = addfile(files(zfil)+".nc","r")
  z = wrf_user_getvar(c,"z",0)
;end do
a = addfiles(files+".nc","r")
times = wrf_user_getvar(a,"times",-1) ; get all times in the file
ListSetType(a, "cat")
; Find model level corresponding to altitude of interest, in this case 1 km
zz = wrf_user_intrp3d(z,z,"v",(/500,500/),90.,False)
;print(zz)
       b = ind(zz(:,0) .gt. zmax*1000. )
;print(b(0))
       zmax_pos = b(0)-1
       if (abs(zz(zmax_pos,0)-zmax*1000.) .lt. abs(zz(zmax_pos+1,0)-zmax*1000.) ) then
         zspan = b(0) - 1
       else
         zspan = b(0)
       end if
       delete(zz)
       delete(b)

p=a[:]->P(:,zmax_pos,y-1,x-1)
p=p/100.
uwind = a[:]->U(:,zmax_pos,y-1,x-1)
vwind = a[:]->V(:,zmax_pos,y-1,x-1) 
;umag = sqrt((uwind*uwind)+(vwind*wvind))
upar = uwind*cos(theta) + vwind*sin(theta)
vpar = vwind*cos(theta) - uwind*sin(theta)
upardt = dtrend(upar,False)
vdt = dtrend(upar,False)
windpar = (uwind*cos(theta))+(vwind*sin(theta))
windpardt = dtrend(windpar,False)
pdt = dtrend(p,False)
;udeg = (udir*180.)/3.14159
  taus = ispan(0,90,10)       ; create a time reference
  preslevs = ispan(12,15,1)
  pltres=True
  mpres = True
  
  slpres = True
;  slpres@AspectRatio = 0.5
  slpres@tmXBMode	= "Explicit"
  slpres@trXMinF    = taus(0)
  slpres@trXMaxF    = taus(9)
  slpres@tmXBValues = taus
  slpres@tmXBMinorValues = ispan(0,30,1)
  slpres@tmXBLabels = (/ "2:00", "2:10", "2:20", "2:30", "2:40",\
                         "2:50", "3:00", "3:10", "3:20", "3:30", "3:40" /)
; slpres@tmYLMode   = "Explicit"
; slpres@trYMinF    = preslevs(0)
; slpres@trYMaxF    = preslevs(3)
 slpres@tmYLValues = preslevs
 slpres@tmYLLabels = preslevs
  ;slpres@tiYAxisString = ""
  slpres@tiMainString  = "Detrended P' (solid) and U' (dashed)"
  slpres@tmXTOn     = False
  slpres@xyLineThicknesses = 2
  slpres@xyLineColor = "blue"
  slpres@xyDashPattern = 0
;  slpres@gsnFrame = False
;  slpres@gsnDraw = False
;  slpres@vpHeightF = 0.20
;  slpres@vpWidthF  = 0.40
;  slpres@pmLegendDisplayMode = "Always"
;  slpres@pmLegendSide = "Right"
  ;slpres@pmLegendParallelPosF = .45
  ;slpres@pmLegendOrthogonalPosF = -0.4
;  slpres@xyExplicitLegendLabels = (/"P'","U'"/)
  delete(slpres@trYMinF)
  delete(slpres@trYMaxF)
  delete(slpres@tmYLValues)
  delete(slpres@tmYLLabels)
;  delete(slpres@xyDashPatterns)
;  delete(slpres@tiYAxisString)

  qres = slpres
;  qres@tiYAxisString = "Water Vapor Mixing Ratio (g/kg)"
  qres@tiMainString = "Water Vapor Mixing Ratio (g/kg)"
  qres@trYMinF = 12
  qres@trYMaxF = 14
;  qres@tmYLValues = fspan(12,14,5)
;  qres@tmYLLabels = fspan(12.,14.,5)

  thetares = slpres
;  thetares@tiYAxisString = "2 m Potential Temperature (K)"
  thetares@tiMainString = "2 m Potential Temperature (K)"
  thetares@trYMinF = 295
  thetares@trYMaxF = 299
  thetares@tmYLValues = ispan(295,299,1)
  thetares@tmYLLabels = thetares@tmYLValues

  umagres = slpres
  umagres@xyDashPattern = 1
;  umagres@pmLegendDisplayMode = "Always"
  umagres@tiYAxisString = "Wind Speed (m/s)"
; umagres@tiMainString = "10 m Wind Speed (m/s)"
;print(windpardt)
;ccr = escorc(vdt(45:89),pdt(45:89))
;ccr = escorc(vdt,pdt)
ccr = escorc(vdt(0:89),pdt(0:89))
printVarSummary(upardt)
print("ccr = " + ccr)
print("zmax = " + zmax)
;ccr = escorc(upar,p)
plot  = gsn_csm_xy2(wks,ispan(0,dimsizes(p)-1,1),vdt,pdt,umagres,slpres)
;  plot(1)  = gsn_csm_xy(wks,ispan(0,30,1),wvmr,qres)
;  plot(2)  = gsn_csm_xy(wks,ispan(0,30,1),theta2m,thetares)
;  plot(3)  = gsn_csm_xy(wks,ispan(0,30,1),umag,umagres)
;  gsn_panel(wks,plot,(/2,2/),pnlres)
end
