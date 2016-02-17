; This script creates plan views of vertical velocity at a given elevation.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

; get list of files to read
files = systemfunc("ls -1 " + "wrfout_d04*0{2,3}*_00" )
;files = systemfunc("ls -1 " + "wrfout_d04*02_30_00" )
numfiles = dimsizes(files) ; number of files

elev = 4000. ; Height at which to plot data, in meters
; Set point to plot and get lat/lon for polymarker
x = 513
y = 879
;xsecback
x1lat0 = 39.8
x1lon0 = -99.4
x1lat1 = 38.5
x1lon1 = -97.3

x2lat0 = 39.23
x2lon0 = -97.3
x2lat1 = 39.1
x2lon1 = -96.0

; Read in colormap
www_cmap = read_colormap_file("BlAqGrWh2YeOrReVi22") 

; Plotting resources
wwwres = True
wwwres@cnFillOn = True
wwwres@InitTime = False
wwwres@Footer = False
wwwres@cnFillPalette = www_cmap
wwwres@cnLevelSelectionMode = "ExplicitLevels" ; set equally spaced contours
wwwres@cnLevels = ispan(-10,10,1)
wwwres@cnFillColors = ispan(0,21,1)
wwwres@gsnFrame = False

; plot dbz contour for overall shape of 

dbz2res = True ; resources for single dbz contour
dbz2res@ContourParameters = (/50,90,40/)
dbz2res@Footer = False
dbz2res@InitTime = False
dbz2res@cnInfoLabelOn = False
dbz2res@cnFillOn = False
dbz2res@cnLineLabelsOn = False
dbz2res@cnLineColor = "Blue"
dbz2res@cnLineThicknessF = 3
dbz2res@gsnFrame = False

;Polymarker resources
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
   wwwres@TimeLabel = date + " " + filestr(22:23) + ":" + filestr(25:26)

   wks = gsn_open_wks(type, "www_plansback_"+elev+"_04_"+date+"_"+time)
;   wks = gsn_open_wks(type, "www_cont_d04_"+date+"_"+time)
;   wks = gsn_open_wks(type, "test")
   ; the next 3 lines prevent workspace memory from running out
   setvalues NhlGetWorkspaceObjectId() 
     "wsMaximumSize" : 300000000
   end setvalues
   a=addfile(files(ifil)+".nc","r") ; Open next file in sequence
   ; Now that file is read, convert ij to lat-lon coordinates for polymarker & polyline
   point = wrf_user_ij_to_ll(a,x,y,True)
   x1xpoints = (/x1lon0,x1lon1/)
   x1ypoints = (/x1lat0,x1lat1/)
   x2xpoints = (/x2lon0,x2lon1/)
   x2ypoints = (/x2lat0,x2lat1/)
   
;  Print time being worked on to screen
   times = wrf_user_getvar(a,"times",-1)
   print("Working on times: " + times)
   
   ; Read in variables
   www = wrf_user_getvar(a,"W",0) ; vertical velocity
   wwwu = wrf_user_unstagger(www,www@stagger) ; unstagger vertical velocity
   z   = wrf_user_getvar(a,"z",0) ; height
   www_interp = wrf_user_intrp3d(wwwu,z,"h",elev,0.,False) ; interpolate to specific elevation (elev, set at top)
   contour_www = wrf_contour(a,wks,www_interp,wwwres)

   dbz = wrf_user_getvar(a, "REFL_10CM",0) 
   dbz_interp = wrf_user_intrp3d(dbz,z,"h",elev,0.,False)
   contour_dbz = wrf_contour(a,wks,dbz_interp,dbz2res)
   
   lnres = True
   lnres@gsLineThicknessF = 3.0
   
   pltres = True
   pltres@gsnFrame = False
   mapres = True
   mapres@gsnFrame = False

     ; Create map, plot line/marker over it
     final_map =  wrf_map_overlays(a,wks,(/ contour_www,contour_dbz /),pltres,mapres)
;     final_map = wrf_map_overlays(a,wks,contour_www,True,True)
     gsn_polymarker(wks,final_map,point(0),point(1),polyres) ; plots a marker at the point specified
      gsn_polyline(wks,final_map,x1xpoints,x1ypoints,lnres) ; plots a line using start/end points specified
;     gsn_polyline(wks,final_map,x2xpoints,x2ypoints,lnres)
     frame(wks)
  end do
end
