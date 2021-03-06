load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

; get list of files to read
files = systemfunc("ls -1 " + "wrfout_d04*0{2,3}_*_00")
;files = systemfunc("ls -1 " + "wrfout_d04*02_30_00")
numfiles = dimsizes(files) ; number of files

elev = 2000. ; altitude at which to plot plan views, in meters.
; Set point to plot and get lat/lon for polymarker; note that these start at 1 instead of 0!
x = 513
y = 879

; Set start and end points for polyline here 
;x1lat0 = 38.9
;x1lon0 = -98.2
;x1lat1 = 37.6
;x1lon1 = -96.3

;xsecback
x1lat0 = 39.8
x1lon0 = -99.4
x1lat1 = 38.5
x1lon1 = -97.3

; Set up some basic plot resources
pres_cmap = read_colormap_file("WhiteYellowOrangeRed")
mpres = True
mpres@InitTime = False
mpres@NoHeaderFooter = True
mpres@gsnFrame = False

vres = True
vres@InitTime = False
vres@NoHeaderFooter = True
;vres@Footer = False
presres = True
presres@NoTitles = False
presres@cnFillOn = True
presres@InitTime = False
presres@Footer = False
presres@cnFillPalette = pres_cmap
presres@cnLevelSelectionMode = "ManualLevels" ; set equally spaced contours
;presres@cnLevels = ispan(898,906,1)
;presres@ContourParameters = (/898.,906.,1./)
;levels = ispan(898,906,1)
;colind = get_color_index(pres_cmap,levels,904)
;print(colind)
presres@cnMinLevelValF = 900
presres@cnMaxLevelValF = 906
presres@cnLevelSpacingF = 1
;presres@cnFillColors = (/ 2,15,30,40,50,65,75,100,115,127 /)
;presres@gsnSpreadColors = True
presres@gsnFrame = False

; Set resources for single 50 dBZ contour here
dbzres = True
dbzres@ContourParameters = (/50,90,40/)
dbzres@Footer = False
dbzres@InitTime = False
dbzres@cnInfoLabelOn = False
dbzres@cnFillOn = False
dbzres@cnLineLabelsOn = False
dbzres@cnLineColor = "Blue"
dbzres@cnLineThicknessF = 3
dbzres@gsnFrame = False
 
polyres = True
polyres@gsMarkerIndex = 16
polyres@gsMarkerSizeF = 10

lnres = True
lnres@gsLineThicknessF = 3.0

pltres = True
pltres@gsnFrame = False

type = "png"
;ifil=3;
do ifil=0,numfiles-1
   currentfile = files(ifil)
   filestr = tochar(currentfile)
   date = filestr(11:20)
   time = (filestr(22:23)+"_"+filestr(25:26))
   presres@TimeLabel = date + " " + filestr(22:23) + ":" + filestr(25:26)

   wks = gsn_open_wks(type, "pres_plansback_"+elev+"_d04_"+date+"_"+time)
;   wks = gsn_open_wks(type, "pres_cont_d04_"+date+"_"+time)
;   wks = gsn_open_wks(type, "test")
   a=addfile(files(ifil)+".nc","r") ; Open next file in sequence
   print ("Working on time: "+files(ifil))
   
   ; Now that file is read, convert ij to lat-lon coordinates
   point = wrf_user_ij_to_ll(a,x,y,True)
;   point1 = wrf_user_ij_to_ll(a,x1,y1,True)
;   point2 = wrf_user_ij_to_ll(a,x2,y2,True)
   x1xpoints = (/x1lon0,x1lon1/)
   x1ypoints = (/x1lat0,x1lat1/)
;   x2xpoints = (/x2lon0,x2lon1/)
;   x2ypoints = (/x2lat0,x2lat1/)
   pres = wrf_user_getvar(a,"pressure",0) ; NCL diagnostic, model pressure in hPa
   z   = wrf_user_getvar(a,"z",0)
   u = wrf_user_getvar(a,"U",0)
   u_u = wrf_user_unstagger(u,u@stagger)
   v = wrf_user_getvar(a,"V",0)
   v_u = wrf_user_unstagger(v,v@stagger)
   dbz = wrf_user_getvar(a,"REFL_10CM",0)
   pres_interp = wrf_user_intrp3d(pres,z,"h",elev,0.,False)
   u10_interp = wrf_user_intrp3d(u_u,z,"h",elev,0.,False)
   v10_interp = wrf_user_intrp3d(v_u,z,"h",elev,0.,False)
   dbz_interp = wrf_user_intrp3d(dbz,z,"h",elev,0.,False)
   vector = wrf_vector(a,wks,u10_interp,v10_interp,vres)
   contour_pres = wrf_contour(a,wks,pres_interp,presres)
   contour_dbz = wrf_contour(a,wks,dbz_interp,dbzres)
   final_map =  wrf_map_overlays(a,wks,(/contour_pres,contour_dbz,vector/),pltres,mpres)
;   final_map = gsn_csm_vector_scalar_map_ce(wks,u10_interp,v10_interp,contour_pres,True)
;   dum1      = gsn_add_polymarker(wks,final_map,364,624,polyres) 
;   final_map = gsn_contour(wks, pres_interp, presres)
   gsn_polymarker(wks,final_map,point(0),point(1),polyres)
;   gsn_polymarker(wks,final_map,point1(0),point1(1),polyres)
;   gsn_polymarker(wks,final_map,point2(0),point2(1),polyres)
   gsn_polyline(wks,final_map,x1xpoints,x1ypoints,lnres)
;   gsn_polyline(wks,final_map,x2xpoints,x2ypoints,lnres)
   draw(final_map)
   frame(wks)
 end do
end
