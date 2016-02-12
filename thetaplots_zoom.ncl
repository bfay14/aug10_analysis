load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

; get list of files to read
files = systemfunc("ls -1 " + "wrfout_d04*")
numfiles = dimsizes(files) ; number of files

elev = 1000. ; altitude at which to plot plan views, in meters.
; Set point to plot and get lat/lon for polymarker; note that these start at 1 instead of 0!
x = 974
y = 410

; Set start and end points for polyline here 
;x1lat0 = 38.9
;x1lon0 = -98.2
;x1lat1 = 37.6
;x1lon1 = -96.3

x1lat0 = 39.0
x1lon0 = -98.4
x1lat1 = 38.0
x1lon1 = -96.9

; Set up some basic plot resources
theta_cmap = read_colormap_file("NCV_jet")
mpres = True
mpres@InitTime = False
mpres@NoHeaderFooter = True

vres = True
vres@InitTime = False
vres@NoHeaderFooter = True
;vres@Footer = False
thetares = True
thetares@NoTitles = False
thetares@cnFillOn = True
thetares@InitTime = False
thetares@Footer = False
thetares@cnFillPalette = theta_cmap
thetares@cnLevelSelectionMode = "ExplicitLevels" ; set equally spaced contours
thetares@cnLevels = ispan(298,312,2)
;thetares@cnFillColors = (/ 4,7,10,11,12,13,14,15,16,17 /)
thetares@gsnSpreadColors = True
thetares@gsnFrame = False

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
   thetares@TimeLabel = date + " " + filestr(22:23) + ":" + filestr(25:26)

   wks = gsn_open_wks(type, "theta_planszoom_"+elev+"_d04_"+date+"_"+time)
;   wks = gsn_open_wks(type, "theta_cont_d04_"+date+"_"+time)
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
   lat2d = wrf_user_getvar(a,"XLAT",0)
   lon2d = wrf_user_getvar(a,"XLONG",0)
   theta = wrf_user_getvar(a,"th",0)
   z   = wrf_user_getvar(a,"z",0)
   u = wrf_user_getvar(a,"U",0)
   u_u = wrf_user_unstagger(u,u@stagger)
   v = wrf_user_getvar(a,"V",0)
   v_u = wrf_user_unstagger(v,v@stagger)
   theta_interp = wrf_user_intrp3d(theta,z,"h",elev,0.,False)
   u10_interp = wrf_user_intrp3d(u_u,z,"h",elev,0.,False)
   v10_interp = wrf_user_intrp3d(v_u,z,"h",elev,0.,False)
   thetares@sfXArray = lon2d
   thetares@sfYArray = lat2d  
   vres@vfXArray = thetares@sfXArray
   vres@vfYArray = thetares@sfYArray

   vector = wrf_vector(a,wks,u10_interp,v10_interp,vres)
   contour_theta = wrf_contour(a,wks,theta_interp,thetares)
   pltres = True
   pltres@LatLonOverlay = True
   pltres@gsnFrame = False
   mpres = True
   mpres@mpLeftCornerLatF = 38.0
   mpres@mpRightCornerLatF = 39.0
   mpres@mpLeftCornerLonF = -99.0
   mpres@mpRightCornerLonF = -96.9
   mpres@gsnFrame = False
;   map = wrf_map(wks,a,True)
   final_map =  wrf_map_overlays(a,wks,(/contour_theta,vector/),pltresres,mpres)
;   final_map = gsn_csm_vector_scalar_map_ce(wks,u10_interp,v10_interp,contour_theta,True)
;   dum1      = gsn_add_polymarker(wks,final_map,364,624,polyres) 
;   final_map = gsn_contour(wks, theta_interp, thetares)
;   gsn_polymarker(wks,final_map,point(0),point(1),polyres)
;   gsn_polymarker(wks,final_map,point1(0),point1(1),polyres)
;   gsn_polymarker(wks,final_map,point2(0),point2(1),polyres)
   gsn_polyline(wks,final_map,x1xpoints,x1ypoints,lnres)
;   gsn_polyline(wks,final_map,x2xpoints,x2ypoints,lnres)
   draw(final_map)
   frame(wks)
 end do
end
