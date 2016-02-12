load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

; get list of files to read
files = systemfunc("ls -1 " + "wrfout_d04*0{2,3}_*_00")
;files = systemfunc("ls -1 " + "wrfout_d04*02_30_00")
numfiles = dimsizes(files) ; number of files

elev = 1500. ; altitude at which to plot plan views, in meters.
; Set point to plot and get lat/lon for polymarker; note that these start at 1 instead of 0!
x = 513
y = 879

; Set start and end points for polyline here 
;x1lat0 = 38.9
;x1lon0 = -98.2
;x1lat1 = 37.6
;x1lon1 = -96.3

x1lat0 = 39.8
x1lon0 = -99.4
x1lat1 = 38.5
x1lon1 = -97.3

; Set up some basic plot resources
rh_cmap = read_colormap_file("WhiteGreen")
mpres = True
mpres@InitTime = False
mpres@NoHeaderFooter = True

vres = True
vres@InitTime = False
vres@NoHeaderFooter = True
;vres@Footer = False
rhres = True
rhres@NoTitles = False
rhres@cnFillOn = True
rhres@InitTime = False
rhres@Footer = False
rhres@cnFillPalette = rh_cmap
rhres@cnLevelSelectionMode = "ManualLevels" ; set equally spaced contours
rhres@cnMinLevelValF = 35.
rhres@cnMaxLevelValF = 95.
rhres@cnLevelSpacingF = 5
rhres@gsnFrame = False

polyres = True
polyres@gsMarkerIndex = 16
polyres@gsMarkerSizeF = 10

lnres = True
lnres@gsLineThicknessF = 3.0
type = "png"
;ifil=3;
do ifil=0,numfiles-1
   currentfile = files(ifil)
   filestr = tochar(currentfile)
   date = filestr(11:20)
   time = (filestr(22:23)+"_"+filestr(25:26))
   rhres@TimeLabel = date + " " + filestr(22:23) + ":" + filestr(25:26)

   wks = gsn_open_wks(type, "rh_plansback_"+elev+"_d04_"+date+"_"+time)
;   wks = gsn_open_wks(type, "rh_cont_d04_"+date+"_"+time)
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
   rh = wrf_user_getvar(a,"rh",0)
   z   = wrf_user_getvar(a,"z",0)
   u = wrf_user_getvar(a,"U",0)
   u_u = wrf_user_unstagger(u,u@stagger)
   v = wrf_user_getvar(a,"V",0)
   v_u = wrf_user_unstagger(v,v@stagger)
   rh_interp = wrf_user_intrp3d(rh,z,"h",elev,0.,False)
   u10_interp = wrf_user_intrp3d(u_u,z,"h",elev,0.,False)
   v10_interp = wrf_user_intrp3d(v_u,z,"h",elev,0.,False)
   vector = wrf_vector(a,wks,u10_interp,v10_interp,vres)
   contour_rh = wrf_contour(a,wks,rh_interp,rhres)
;   mpres@gsnFrame = False
;   map = wrf_map(wks,a,True)
   final_map =  wrf_map_overlays(a,wks,(/contour_rh,vector/),rhres,mpres)
;   final_map = gsn_csm_vector_scalar_map_ce(wks,u10_interp,v10_interp,contour_rh,True)
;   dum1      = gsn_add_polymarker(wks,final_map,364,624,polyres) 
;   final_map = gsn_contour(wks, rh_interp, rhres)
   gsn_polymarker(wks,final_map,point(0),point(1),polyres)
;   gsn_polymarker(wks,final_map,point1(0),point1(1),polyres)
;   gsn_polymarker(wks,final_map,point2(0),point2(1),polyres)
   gsn_polyline(wks,final_map,x1xpoints,x1ypoints,lnres)
;   gsn_polyline(wks,final_map,x2xpoints,x2ypoints,lnres)
   draw(final_map)
   frame(wks)
 end do
end
