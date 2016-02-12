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
dbz_cmap = read_colormap_file("radar")
rh_cmap = read_colormap_file("WhiteGreen")
plot = new(2, graphic)

opts = True
plane = new(4,float)

lat0 = 39.5
lon0 = -98.9
lat1 = 38.25
lon1 = -97.0

rhres = True 
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
;dbzres@trYMinF  = zmin
;dbzres@trYMaxF  = zmax
;dbzres@tmYLValues = fspan(zmin,zmax,7)
;dbzres@tmYLValues = ispan(
;dbzres@tmYLLabels = fspan(0.,6.,7)
;dbzres@tmYLLabels  = sprintf("%.1f",fspan(zmin,zmax,7))
dbzres@Footer = False
dbzres@cnFillOn = True
dbzres@InitTime = False
dbzres@cnFillPalette = dbz_cmap
dbzres@cnLevelSelectionMode = "ExplicitLevels" ; set equally spaced contours
dbzres@cnLevels = ispan(0,65,5)
dbzres@cnFillColors = (/ 14,0,1,2,3,4,5,6,7,8,9,10,11,12,13 /)
mpres = True
type = "png"
;ifil=6
do ifil=0,numfiles-1
   currentfile = files(ifil)
   filestr = tochar(currentfile)
   date = filestr(11:20)
   time = (filestr(22:23)+"_"+filestr(25:26))
   rhres@TimeLabel = date + " " + filestr(22:23) + ":" + filestr(25:26)

    wks = gsn_open_wks(type, "rh_xsecnew_d04_"+date+"_"+time)
;   wks = gsn_open_wks(type, "rh_cont_d04_"+date+"_"+time)
;   wks = gsn_open_wks(type, "rhtest")
   
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
   www = wrf_user_getvar(a,"W",0)
   wwind = wrf_user_unstagger(www,www@stagger)
   rh = wrf_user_getvar(a, "rh", 0)
   ; determine angle of cross section and compute wind component along line; plane array is 1x4:x0,y0,x1,y1
   slope = (plane(3)-plane(1))/(plane(2)-plane(0))
   angle = atan(slope)
   urot = uwind*cos(angle) + vwind*sin(angle)
   vrot = vwind*cos(theta) - uwind*sin(angle)
;   thsinglecontour = new((/100,253/),"float",getFillValue(theta))
   dbz_plane   = wrf_user_intrp3d(dbz,z,"v",plane,0.,opts)
   theta_plane = wrf_user_intrp3d(theta,z,"v",plane,0.,opts)
   rh_plane   = wrf_user_intrp3d(rh,z,"v",plane,0.,opts)
   vrot_plane  = wrf_user_intrp3d(urot,z,"v",plane,0.,opts)
   www_plane = wrf_user_intrp3d(wwind,z,"v",plane,0.,opts)
   length = dimsizes(rh_plane)
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
      dbzres = True
;      dbzres@tmXBLabelsOn = False
;      dbzres@tmXBOn = False
      dbzres@tiYAxisString = "Height (km)"
      ;dbzres@AspectRatio = 0.75
      dbzres@tmYLMode = "Explicit"
      dbzres@trYMinF  = zmin
      dbzres@trYMaxF  = zspan
      dbzres@tmYLValues = fspan(zmin,zspan,nz)
      ;dbzres@tmYLValues = ispan(
      dbzres@tmYLLabels = fspan(zmin,zspan,nz)
;      dbzres@tmYLLabels  = sprintf("%.1f",fspan(zmin,zmax,nz))
      dbzres@Footer = False
      dbzres@cnFillOn = True
      dbzres@InitTime = False
      dbzres@cnFillPalette = dbz_cmap
      dbzres@cnLevelSelectionMode = "ExplicitLevels" ; set equally spaced contours
      dbzres@cnLevels = ispan(0,65,5)
      dbzres@cnFillColors = (/ 14,0,1,2,3,4,5,6,7,8,9,10,11,12,13 /)
      dbzres@lbOrientation = "vertical"
      dbzres@pmLabelBarSide = "Right"
      dbzres@lbTitleOn = False
;      dbzres@pmLabelBarOrthogonalPosF = 10

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
      
      theta2res = True
      theta2res@ContourParameters = (/305,405,50/)
 
      rhres = True
;      rhres@AspectRatio = 0.5
      rhres@vpWidthF = 0.55
      rhres@vpHeightF = 0.27
      rhres@tiYAxisString = "Height (km)"
      rhres@tiXAxisString = "Distance (km)"
      rhres@tmYLMode = "Explicit"
      rhres@trYMinF  = zmin
      rhres@trYMaxF  = zspan
      rhres@tmYLValues = fspan(zmin,zspan,nz)
      rhres@tmYLLabels  = fspan(zmin,zmax,nz)
      rhres@Footer = False
      rhres@InitTime = False
      rhres@cnFillOn = True
      rhres@cnFillPalette = rh_cmap
      rhres@cnLevelSelectionMode = "ManualLevels"
      rhres@cnMinLevelValF = 35.
      rhres@cnMaxLevelValF = 95.
      rhres@cnLevelSpacingF = 5
;      rhres@cnMaxLevelCount = 20
;      rhres@cnSpanFillPalette = True
;      rhres@lbOrientation = "vertical"
;      rhres@pmLabelBarSide = "Right"
      rhres@pmLabelBarOrthogonalPosF = 0.005
      rhres@pmLabelBarWidthF = 0.4
      rhres@lbTitleOn = False
      ;rhres@lbTitlePosition = "Right"
      ;rhres@cnLabelBarEndStyle = "IncludeMinMaxLabels"
      ;rhres@lbTitleAngleF = 270.0
      rhres@lbLabelAlignment = "InteriorEdges"
      rhres@tmXBMode = "Explicit"
;      rhres@trXMinF  = 0
;      rhres@trXMaxF  = length(1) ; length of cross section, too lazy to get this from dims
      rhres@cnInfoLabelOn = False
      rhres@tmXBValues = ispan(0,length(1),100)
       rhres@tmXBMinorValues =  ispan(0,length(1),100)
       rhres@tmXBLabels = ispan(0,length(1)/5,20)
;      rhres@gsnMaximize = True
   vres = True
   vres@gsnFrame = False
   contour_dbz    = wrf_contour(a,wks,dbz_plane(0:zspan,:),dbzres)
   contour_dbz2   = wrf_contour(a,wks,dbz_plane(0:zmax_pos,:),dbz2res)
   contour_theta  = wrf_contour(a,wks,theta_plane(0:zspan,:),thetares)
   contour_theta2 = wrf_contour(a,wks,theta_plane(0:zmax_pos,:),thetares)
   contour_rh    = wrf_contour(a,wks,rh_plane(0:zspan,:),rhres)
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
;   plot(1) = wrf_overlays(a,wks,(/ contour_rh,contour_theta2 /), pltres)
    plot = wrf_overlays(a,wks,(/ contour_rh,contour_theta,contour_dbz2 /), pltres)
;   plot = wrf_overlays(a,wks,(/ contour_rh,contour_theta /), pltres)
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
