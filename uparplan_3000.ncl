; This script creates plan views of vertical velocity at a given elevation.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

; get list of files to read
files = systemfunc("ls -1 " + "wrfout_d04*0{2,3}_*_00")
;files = systemfunc("ls -1 " + "wrfout_d04*02_30_00")
numfiles = dimsizes(files) ; number of files

elev = 3000.

lat0 = 39.8
lon0 = -99.4
lat1 = 38.5
lon1 = -97.3


FirstTime = True
; Set point to plot and get lat/lon for polymarker
x = 513
y = 879


; Read in colormap
upar_cmap = read_colormap_file("BlueWhiteOrangeRed")


; Plotting resources
uparres = True
uparres@cnFillOn = True
uparres@InitTime = False
uparres@Footer = False
uparres@cnFillPalette = upar_cmap
uparres@cnLevelSelectionMode = "ExplicitLevels" ; set equally spaced contours
uparres@cnLevels = ispan(-18,18,2)
uparres@cnSpanFillPalette = True
uparres@gsnFrame = False

dbzres = True ; resources for single dbz contour
dbzres@ContourParameters = (/50,90,40/)
dbzres@Footer = False
dbzres@InitTime = False
dbzres@cnInfoLabelOn = False
dbzres@cnFillOn = False
dbzres@cnLineLabelsOn = False
dbzres@cnLineColor = "Blue"
dbzres@cnLineThicknessF = 4
dbzres@gsnFrame = False

pltres = True
pltres@gsnFrame = False

mpres = True
mpres@gsnFrame = False

; Polymarker resources
polyres = True
polyres@gsMarkerIndex = 16
polyres@gsMarkerSizeF = 10

; Set file type for output files here
type = "png"

; Work through each wrfout file
;ifil=30;
do ifil=0,numfiles-1
   currentfile = files(ifil)
   filestr = tochar(currentfile)
   date = filestr(11:20)
   time = (filestr(22:23)+"_"+filestr(25:26))
   uparres@TimeLabel = date + " " + filestr(22:23) +":" + filestr(25:26)

   wks = gsn_open_wks(type, "upar_plansback_"+elev+"_d04_"+date+"_"+time) ; Open new workspace
   a=addfile(files(ifil)+".nc","r") ; Open next file in sequence
   ; Now that file is read, convert ij to lat-lon coordinates for polymarker & polyline
   point = wrf_user_ij_to_ll(a,x,y,True)
   plane0 = wrf_user_ll_to_ij(a,(/lon0,lon1/),(/lat0,lat1/),True)
   plane0 = plane0 - 1
   planetr = transpose(plane0)
   plane = reshape(planetr,(/4/))

   xpoints = (/lon0,lon1/)
   ypoints = (/lat0,lat1/)
   ; Print time being worked on to screen
   times = wrf_user_getvar(a,"times",-1)
   print("Working on times: " + times)
   
   ; Read in variables
   dbz = wrf_user_getvar(a,"REFL_10CM",0)
   uwind = wrf_user_getvar(a,"U",0)
   vwind = wrf_user_getvar(a,"V",0)
   ustag = wrf_user_unstagger(uwind,uwind@stagger)
   vstag = wrf_user_unstagger(vwind,vwind@stagger)
   slope = (plane(3)-plane(1))/(plane(2)-plane(0))
   angle = atan(slope)
   urot =  ustag*cos(angle) + vstag*sin(angle)
   vpar =  vstag*sin(angle) - ustag*sin(angle)
;   wind =  sqrt((ustag*ustag)+(vstag*vstag))
;   wind =  sqrt((upar*upar)+(vpar*vpar))
   z   = wrf_user_getvar(a,"z",0) ; height
   dbz_interp = wrf_user_intrp3d(dbz,z,"h",elev,0.,False) 
   wind_interp = wrf_user_intrp3d(urot,z,"h",elev,0.,False) ; interpolate to specific elevation (in this case 1 km)
   contour_upar = wrf_contour(a,wks,wind_interp,uparres)
   contour_dbz = wrf_contour(a,wks,dbz_interp,dbzres)
     ; Create map, plot line/marker over it
     final_map =  wrf_map_overlays(a,wks,(/contour_upar,contour_dbz/),pltres,mpres)
     gsn_polymarker(wks,final_map,point(0),point(1),polyres) ; plots a marker at the point specified
     gsn_polyline(wks,final_map,xpoints,ypoints,True) ; plots a line using start/end points specified
     frame(wks)
  end do
end
