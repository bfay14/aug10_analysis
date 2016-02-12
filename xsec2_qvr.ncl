load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

; get list of files to read
files = systemfunc("ls -1 " + "wrfout_d04*04_30_00 ")
numfiles = dimsizes(files) ; number of files

; Set up some basic plot resources
plot = new(1, graphic)
opts = True
plane = new(4,float)

lat0 = 38.9
lon0 = -98.2
lat1 = 37.6
lon1 = -96.3

qv_cmap = read_colormap_file("BlueGreen14")
FirstTime = True
if (FirstTime) then
   zmin = 0.
   zmax = 3.
   nz = floattoint(zmax+1)
end if
; Set some options here
qvres = True
qvres@tiYAxisString = "Height (km)"
qvres@AspectRatio = 0.5
qvres@tmYLMode = "Explicit"
qvres@Footer = False
qvres@cnFillOn = True
qvres@InitTime = False
qvres@cnFillPalette = qv_cmap
qvres@cnLevelSelectionMode = "ExplicitLevels" ; set equally spaced contours
qvres@cnLevels = fspan(0.002,0.013,12)
qvres@cnFillColors = ispan(1,13,1)
mpres = True
type = "png"
;ifil=0
do ifil=0,numfiles-1
   currentfile = files(ifil)
   filestr = tochar(currentfile)
   date = filestr(11:20)
   time = (filestr(22:23)+"_"+filestr(25:26))
   qvres@TimeLabel = date + " " + filestr(22:23) + ":" + filestr(25:26)

    wks = gsn_open_wks(type, "qvr_xsec_d04_"+date+"_"+time)
;   wks = gsn_open_wks(type, "qvr_cont_d04_"+date+"_"+time)
;   wks = gsn_open_wks(type, "test")
   
   a=addfile(files(ifil)+".nc","r") ; Open next file in sequence
; Now that I have the file, convert lat-lon to ij.
   plane0 = wrf_user_ll_to_ij(a,(/lon0,lon1/),(/lat0,lat1/),True)
   plane0 = plane0 - 1 ; to get it in NCL coordinate
   plane = reshape(plane0,(/1,4/))

   ; Start reading variables
   qv = wrf_user_getvar(a,"QVAPOR",0)
;   qv = qv*1000. ; convert to g/kg
   times = wrf_user_getvar(a, "times", -1)
   print("Working on time: " + times)
   z   = wrf_user_getvar(a,"z",0)
;   ter = wrf_user_getvar(a,"HGT",0)
;   p = wrf_user_getvar(a, "pressure", 0)
   theta = wrf_user_getvar(a, "th", 0)
;   www = wrf_user_getvar(a, "W", 0)
;   wwwu= wrf_user_unstagger(www,www@stagger)
   qv_plane   = wrf_user_intrp3d(qv,z,"v",plane,0.,opts)
   theta_plane = wrf_user_intrp3d(theta,z,"v",plane,0.,opts)
;   www_plane   = wrf_user_intrp3d(wwwu,z,"v",plane,0.,opts)
;   ter_plane = wrf_user_interp3d(ter,z,"v",plane,0.,opts)
    length = dimsizes(qv_plane)
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
;      qvres@tmXBLabelsOn = False
;      qvres@tmXBOn = False
      qvres@tiYAxisString = "Height (km)"
      qvres@tmYLMode = "Explicit"
      qvres@trYMinF  = zmin
      qvres@trYMaxF  = zspan
      qvres@tmYLValues = fspan(zmin,zspan,nz)
      qvres@tmYLLabels = fspan(zmin,zmax,nz)
      qvres@Footer = False
;      qvres@cnFillOn = True
;      qvres@InitTime = False
;      qvres@cnFillPalette = dbz_cmap
;      qvres@cnLevelSelectionMode = "ExplicitLevels" ; set equally spaced contours
;      qvres@cnLevels = ispan(0,65,5)
;      qvres@cnFillColors = (/ 14,0,1,2,3,4,5,6,7,8,9,10,11,12,13 /)
      qvres@lbOrientation = "vertical"
      qvres@pmLabelBarSide = "Right"
      qvres@lbTitleOn = False
;      qvres@pmLabelBarOrthogonalPosF = 10
      qvres@tmXBMode = "Explicit"
      qvres@tmXBValues = ispan(0,length(1),100)
      qvres@tmXBMinorValues = qvres@tmXBValues
      qvres@tmXBLabels = ispan(0,length(1)/5,20)

      thetares = True
      thetares@ContourParameters = (/ 1.0 /)
      thetares@cnLineLabelInterval = 10
      thetares@cnFillOn = False
      thetares@Footer = False
      thetares@InitTime = False
      thetares@cnInfoLabelOn = False


   contour_qv   = wrf_contour(a,wks,qv_plane(0:zspan,:),qvres)
   contour_theta = wrf_contour(a,wks,theta_plane(0:zmax_pos,:),thetares)
    pltres = True
;    pltres@FramePlot = False
;    pltres@PanelPlot = True
;   pltres@gsnFrame = False
;   pltres@lbOrientation = "vertical"
;   pltres@gsnPanelBottom = 0.5
;   plot(0) = wrf_overlays(a,wks,(/ contour_dbz,contour_theta /), pltres)
;   gsn_panel(wks,plot(0),(/1,1/),pltres)
;   pltres2 = True
;   pltres2@gsnPanelTop = 0.5
;   pltres2@gsnFrame = False
;   pltres2@lbOrientation = "vertical"
;   plot(1) = wrf_overlays(a,wks,(/ contour_www,contour_theta2 /), pltres)
    plot = wrf_overlays(a,wks,(/ contour_qv,contour_theta /), pltres)
;   gsn_panel(wks,plot(1),(/1,1/),pltres2)
;   pnlres = True
;   pnlres@tiMainOn = False
;   pnlres@tiAxisOn = False
;   pnlres@gsnPanelYWhiteSpacePercent = 2.0
;   pnlres@gsnPanelYF = (/-1,0.55/) ; I'm not sure what this does, but the secondd number controls the y-location of the lower plot.
;   gsn_panel(wks,(/plot/),(/2,1/),pnlres)
;    gsn_panel(wks,(/plot(1)/),(/1,1/),pnlres)
  ; frame(wks)

end do
end
