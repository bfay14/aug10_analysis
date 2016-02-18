load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; get list of files to read
;files = systemfunc("ls -1 " + "wrfout_d04*0{2,3}_*_00")
files = systemfunc("ls -1 " + "wrfout_d04*02_[0-3]*_00")
numfiles = dimsizes(files) ; number of files

; Set up some basic plot resources
theta_cmap = read_colormap_file("NCV_jet")
plot = new(2, graphic)

opts = True
plane = new(4,float)

lat0 = 39.75
lon0 = -99.2
lat1 = 39.5
lon1 = -97.4

thetares = True 
FirstTime = True
if (FirstTime) then
   zmin = 0.
   zmax = 3.
   nz = floattoint(zmax+1)
end if
; Set some options here
dbzres = True
dbzres@tiYAxisString = "Height (km)"
dbzres@AspectRatio = 0.5
dbzres@tmYLMode = "Explicit"
dbzres@Footer = False
dbzres@cnFillOn = True
dbzres@InitTime = False
;dbzres@cnFillPalette = dbz_cmap
dbzres@cnLevelSelectionMode = "ExplicitLevels" ; set equally spaced contours
;dbzres@cnLevels = ispan(0,65,5)
;dbzres@cnFillColors = (/ 14,0,1,2,3,4,5,6,7,8,9,10,11,12,13 /)
mpres = True
type = "png"
;ifil=6
do ifil=0,numfiles-1
   currentfile = files(ifil)
   filestr = tochar(currentfile)
   date = filestr(11:20)
   time = (filestr(22:23)+"_"+filestr(25:26))
   thetares@TimeLabel = date + " " + filestr(22:23) + ":" + filestr(25:26)

    wks = gsn_open_wks(type, "theta_xsecnorth_d04_"+date+"_"+time)
;   wks = gsn_open_wks(type, "theta_cont_d04_"+date+"_"+time)
;   wks = gsn_open_wks(type, "thetatest")
   
   a=addfile(files(ifil)+".nc","r") ; Open next file in sequence
; Now that I have the file, convert lat-lon to ij.
   if (FirstTime) then
     plane0 = wrf_user_ll_to_ij(a,(/lon0,lon1/),(/lat0,lat1/),True)
     plane0 = plane0 - 1 ; to get it in NCL coordinate
     planetr = transpose(plane0)
     plane = reshape(planetr,(/4/))
   end if
   dbz = wrf_user_getvar(a,"REFL_10CM",0)
   times = wrf_user_getvar(a, "times", -1)
   print("Working on time: " + times)
   z   = wrf_user_getvar(a,"z",0)
   p = wrf_user_getvar(a, "pressure", 0)
   theta = wrf_user_getvar(a, "th", 0)
   u = wrf_user_getvar(a,"U",0)
   uwind = wrf_user_unstagger(u,u@stagger)
   v = wrf_user_getvar(a,"V",0)
   vwind = wrf_user_unstagger(v,v@stagger)
   www = wrf_user_getvar(a,"W",0)
   wwind = wrf_user_unstagger(www,www@stagger)
   theta = wrf_user_getvar(a, "theta", 0)
   ; determine angle of cross section and compute wind component along line; plane array is 1x4:x0,y0,x1,y1
   slope = (plane(3)-plane(1))/(plane(2)-plane(0))
   angle = atan(slope)
   urot = uwind*cos(angle) + vwind*sin(angle)
   vrot = vwind*cos(theta) - uwind*sin(angle)
   dbz_plane   = wrf_user_intrp3d(dbz,z,"v",plane,0.,opts)
   theta_plane = wrf_user_intrp3d(theta,z,"v",plane,0.,opts)
   theta_plane   = wrf_user_intrp3d(theta,z,"v",plane,0.,opts)
   vrot_plane  = wrf_user_intrp3d(urot,z,"v",plane,0.,opts)
   www_plane = wrf_user_intrp3d(wwind,z,"v",plane,0.,opts)
   length = dimsizes(theta_plane)
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
      dbzres = True
      dbzres@tiYAxisString = "Height (km)"
      dbzres@tmYLMode = "Explicit"
      dbzres@trYMinF  = zmin
      dbzres@trYMaxF  = zspan
      dbzres@tmYLValues = fspan(zmin,zspan,nz)
      dbzres@tmYLLabels = fspan(zmin,zspan,nz)
      dbzres@Footer = False
      dbzres@cnFillOn = True
      dbzres@InitTime = False
;      dbzres@cnFillPalette = dbz_cmap
      dbzres@cnLevelSelectionMode = "ExplicitLevels" ; set equally spaced contours
      dbzres@cnLevels = ispan(0,65,5)
      dbzres@cnFillColors = (/ 14,0,1,2,3,4,5,6,7,8,9,10,11,12,13 /)
      dbzres@lbOrientation = "vertical"
      dbzres@pmLabelBarSide = "Right"
      dbzres@lbTitleOn = False

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
;      thetares@ContourParameters = (/296,325,1 /)
      thetares@cnFillOn = True
      thetares@Footer = False
      thetares@InitTime = False
      thetares@cnInfoLabelOn = False
      thetares@vpWidthF = 0.55
      thetares@vpHeightF = 0.27
      thetares@tiYAxisString = "Height (km)"
      thetares@tiXAxisString = "Distance (km)"
      thetares@tmYLMode = "Explicit"
      thetares@trYMinF  = zmin
      thetares@trYMaxF  = zspan
      thetares@tmYLValues = fspan(zmin,zspan,nz)
      thetares@tmYLLabels  = fspan(zmin,zmax,nz)
      thetares@cnFillPalette = theta_cmap
      thetares@cnLevelSelectionMode = "ExplicitLevels"
      thetares@cnLevels = ispan(292,312,1)
      thetares@cnSpanFillPalette = True
;      thetares@cnMaxLevelCount = 20
;      thetares@cnSpanFillPalette = True
;      thetares@lbOrientation = "vertical"
;      thetares@pmLabelBarSide = "Right"
      thetares@pmLabelBarOrthogonalPosF = 0.005
      thetares@pmLabelBarWidthF = 0.4
      thetares@lbTitleOn = False
      ;thetares@lbTitlePosition = "Right"
      ;thetares@cnLabelBarEndStyle = "IncludeMinMaxLabels"
      ;thetares@lbTitleAngleF = 270.0
      thetares@lbLabelAlignment = "InteriorEdges"
      thetares@tmXBMode = "Explicit"
;      thetares@trXMinF  = 0
;      thetares@trXMaxF  = length(1) ; length of cross section, too lazy to get this from dims
      thetares@cnInfoLabelOn = False
      thetares@tmXBValues = ispan(0,length(1),100)
       thetares@tmXBMinorValues =  ispan(0,length(1),100)
       thetares@tmXBLabels = ispan(0,length(1)/5,20)
;      thetares@gsnMaximize = True
   vres = True
   vres@gsnFrame = False
   contour_dbz    = wrf_contour(a,wks,dbz_plane(0:zspan,:),dbzres)
   contour_dbz2   = wrf_contour(a,wks,dbz_plane(0:zmax_pos,:),dbz2res)
   contour_theta  = wrf_contour(a,wks,theta_plane(0:zspan,:),thetares)
   contour_theta2 = wrf_contour(a,wks,theta_plane(0:zmax_pos,:),thetares)
   vector         = wrf_vector(a,wks,vrot_plane, www_plane,vres)
    pltres = True
    pltres@NoTitles = True
    pltres@tiMainString = ""
    pltres@gsnMaximize = True
;    pltres@FramePlot = False
;    pltres@PanelPlot = True
;   pltres@gsnFrame = False
;   pltres@lbOrientation = "vertical"
;   pltres@gsnPanelBottom = 0.5
;   plot(0) = wrf_overlays(a,wks,(/ contour_dbz,contour_theta,contour_dbz2 /), pltres)
;   gsn_panel(wks,plot(0),(/1,1/),pltres)
;   pltres2 = True
;   pltres2@gsnPanelTop = 0.5
;   pltres2@gsnFrame = False
;   pltres2@lbOrientation = "vertical"
;   plot(1) = wrf_overlays(a,wks,(/ contour_theta,contour_theta2 /), pltres)
    plot = wrf_overlays(a,wks,(/ contour_theta,contour_dbz2 /), pltres)
;   plot = wrf_overlays(a,wks,(/ contour_theta,contour_theta /), pltres)
;   gsn_panel(wks,plot(1),(/1,1/),pltres2)
   pnlres = True
   pnlres@tiMainOn = False
   pnlres@tiAxisOn = False
   pnlres@gsnPanelYWhiteSpacePercent = 2.0
   pnlres@gsnPanelYF = (/-1,0.55/) ; I'm not sure what this does, but the secondd number controls the y-location of the lower plot.
;   gsn_panel(wks,(/plot/),(/2,1/),pnlres)
;    gsn_panel(wks,(/plot(1)/),(/1,1/),pnlres)
  ; frame(wks)

end do
end
