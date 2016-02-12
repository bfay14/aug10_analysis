load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; get list of files to read
files = systemfunc("ls -1 " + "wrfout_d04*0{2,3}_*_00")
;files = systemfunc("ls -1 " + "wrfout_d04*02_30_00")
numfiles = dimsizes(files) ; number of files

; Set up some basic plot resources
wind_cmap = read_colormap_file("BlueWhiteOrangeRed")
plot = new(2, graphic)

; Set storm velocity vector components here! (units m/s)
stormMotion_x = 13.41
stormMotion_y = -9.48

; Use storm-relative motion or absolute motion? 
stormRelative = True

opts = True
plane = new(4,float)

lat0 = 39.8
lon0 = -99.4
lat1 = 38.5
lon1 = -97.3

windres = True 
FirstTime = True
if (FirstTime) then
   zmin = 0.
   zmax = 3.
   nz = floattoint(zmax+1)
end if

mpres = True
type = "png"
;ifil=6
do ifil=0,numfiles-1
   currentfile = files(ifil)
   filestr = tochar(currentfile)
   date = filestr(11:20)
   time = (filestr(22:23)+"_"+filestr(25:26))
   windres@TimeLabel = date + " " + filestr(22:23) + ":" + filestr(25:26)

   if (stormRelative) then 
     wks = gsn_open_wks(type, "srwind_xsecback_d04_"+date+"_"+time)
   else
     wks = gsn_open_wks(type, "wind_xsecback_d04_"+date+"_"+time)
   end if
;   wks = gsn_open_wks(type, "vectortest")
   
   a=addfile(files(ifil)+".nc","r") ; Open next file in sequence
; Now that I have the file, convert lat-lon to ij.
   if (FirstTime) then
     plane0 = wrf_user_ll_to_ij(a,(/lon0,lon1/),(/lat0,lat1/),True)
     plane0 = plane0 - 1 ; to get it in NCL coordinate
     planetr = transpose(plane0)
     plane = reshape(planetr,(/4/))
   end if
   ;plane = (/ 625,687 , 1445,22 /)
;   plane = (/530,765 , 1195,225 /)
;    plane = (/312,1042 , 1149,362 /)
   ; plane = (/531,711 , 1197,169 /)
   dbz = wrf_user_getvar(a,"REFL_10CM",0)
   times = wrf_user_getvar(a, "times", -1)
   print("Working on time: " + times)
   z   = wrf_user_getvar(a,"z",0)
;   ter = wrf_user_getvar(a,"HGT",0)
   p = wrf_user_getvar(a, "pressure", 0)
   theta = wrf_user_getvar(a, "th", 0)
   u = wrf_user_getvar(a,"U",0)
   uwind = wrf_user_unstagger(u,u@stagger)
   v = wrf_user_getvar(a,"V",0)
   vwind = wrf_user_unstagger(v,v@stagger)
   ; Compute storm relative velocities if desired
   if (stormRelative) then
     sr_uwind = uwind - stormMotion_x
     sr_vwind = vwind - stormMotion_y
   end if
   ; determine angle of cross section and compute wind component along line; plane array is 1x4:x0,y0,x1,y1
   slope = (plane(3)-plane(1))/(plane(2)-plane(0))
   angle = atan(slope)
   ; Storm relative urot, vrot
   if (stormRelative) then 
     sr_urot = sr_uwind*cos(angle) + sr_vwind*sin(angle)
     sr_vrot = sr_vwind*cos(angle) - sr_uwind*sin(angle)
   else
     urot = uwind*cos(angle) + vwind*sin(angle)
     vrot = vwind*cos(angle) - uwind*sin(angle)
   end if
;   thsinglecontour = new((/100,253/),"float",getFillValue(theta))
   dbz_plane   = wrf_user_intrp3d(dbz,z,"v",plane,0.,opts)
   theta_plane = wrf_user_intrp3d(theta,z,"v",plane,0.,opts)
   if (stormRelative) then
     wind_plane  = wrf_user_intrp3d(sr_urot,z,"v",plane,0.,opts)
   else
     wind_plane  = wrf_user_intrp3d(urot,z,"v",plane,0.,opts)
   end if
   length = dimsizes(wind_plane)
;   ter_plane = wrf_user_interp3d(ter,z,"v",plane,0.,opts)
    if (FirstTime) then 
       zz = wrf_user_intrp3d(z,z,"v",plane,0.,opts)
       b = ind(zz(:,0) .gt. zmax*1000. )
       zmax_pos = b(0)-1
       if (abs(zz(zmax_pos,0)-zmax*1000.) .lt. abs(zz(zmax_pos+1,0)-zmax*1000.) ) then
         zspan = b(0) - 1
       else
         zspan = b(0)
       end if
       delete(zz)
       delete(b)
       FirstTime = False
       end if

      dbz2res = True ; resources for single dbz contour
      dbz2res@ContourParameters = (/50,90,40/)
      dbz2res@Footer = False
      dbz2res@InitTime = False
      dbz2res@cnInfoLabelOn = False
      dbz2res@cnFillOn = False
      dbz2res@cnLineLabelsOn = False
      dbz2res@cnLineColor = "Blue"
      dbz2res@cnLineThicknessF = 4

      thetares = True
      thetares@ContourParameters = (/296,325,1 /)
      ;thetares@cnLineLabelsOn = False
      thetares@cnFillOn = False
      thetares@Footer = False
      thetares@InitTime = False
      thetares@cnInfoLabelOn = False
      thetares@cnMonoLineThickness = False
      thetares@cnLineThicknesses = (/0.5,0.5,0.5,0.5,0.5,0.5,0.5,4,0.5,0.5,0.5,\
               0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,\
               0.5,0.5,0.5/)
      
 
      windres = True
      windres@vpWidthF = 0.55
      windres@vpHeightF = 0.27
      windres@tiYAxisString = "Height (km)"
      windres@tiXAxisString = "Distance (km)"
      windres@tmYLMode = "Explicit"
      windres@trYMinF  = zmin
      windres@trYMaxF  = zspan
      windres@tmYLValues = fspan(zmin,zspan,nz)
      windres@tmYLLabels  = fspan(zmin,zmax,nz)
      windres@Footer = False
      windres@InitTime = False
      windres@cnFillOn = True
      windres@cnFillPalette = wind_cmap
      windres@cnLevelSelectionMode = "ExplicitLevels"
      windres@cnLevels = ispan(-24,16,4)
      icol = span_color_indexes(wind_cmap(0:200,:),11)
      windres@cnFillColors = icol 
;      windres@cnSpanFillPalette = True
      windres@pmLabelBarOrthogonalPosF = 0.005
      windres@pmLabelBarWidthF = 0.4
      windres@lbTitleOn = False
      ;windres@lbTitlePosition = "Right"
      ;windres@cnLabelBarEndStyle = "IncludeMinMaxLabels"
      ;windres@lbTitleAngleF = 270.0
      windres@lbLabelAlignment = "InteriorEdges"
      windres@tmXBMode = "Explicit"
      windres@cnInfoLabelOn = False
      windres@tmXBValues = ispan(0,length(1),100)
       windres@tmXBMinorValues =  ispan(0,length(1),100)
       windres@tmXBLabels = ispan(0,length(1)/5,20)
;      windres@gsnMaximize = True
   vres = True
   vres@gsnFrame = False
   contour_dbz2   = wrf_contour(a,wks,dbz_plane(0:zmax_pos,:),dbz2res)
   contour_theta  = wrf_contour(a,wks,theta_plane(0:zspan,:),thetares)
   contour_theta2 = wrf_contour(a,wks,theta_plane(0:zmax_pos,:),thetares)
   contour_wind    = wrf_contour(a,wks,wind_plane(0:zspan,:),windres)
;   vector         = wrf_vector(a,wks,vrot_plane,wind_plane,vres)
    pltres = True
    pltres@NoTitles = True
    pltres@tiMainString = ""
    pltres@gsnMaximize = True
    plot = wrf_overlays(a,wks,(/ contour_wind,contour_theta,contour_dbz2/), pltres)
   pnlres = True
   pnlres@tiMainOn = False
   pnlres@tiAxisOn = False
   pnlres@gsnPanelYWhiteSpacePercent = 2.0
   pnlres@gsnPanelYF = (/-1,0.55/) ; I'm not sure what this does, but the secondd number controls the y-location of the lower plot.

end do
end
