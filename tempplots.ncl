load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

; get list of files to read
files = systemfunc("ls -1 " + "wrfout_d02*02_00_00")
numfiles = dimsizes(files) ; number of files

; Set point to plot and get lat/lon for polymarker; note that these start at 1 instead of 0!
x = 300
y = 200
; Set start and end points for polyline here 
linex = (/150,850/)
startij = (/419,189/)
endij   = (/739,34/)
liney = (/550,250/)
; Set up some basic plot resources
temp_cmap = read_colormap_file("NCV_jet")
mpres = True
mpres@InitTime = False
mpres@NoHeaderFooter = True

vres = True
vres@InitTime = False
vres@NoHeaderFooter = True
;vres@Footer = False
tempres = True
tempres@NoTitles = True
tempres@cnFillOn = True
tempres@InitTime = False
tempres@Footer = False
;tempres@NoHeaderFooter = True
tempres@cnFillPalette = temp_cmap
tempres@cnLevelSelectionMode = "ManualLevels" ; set equally spaced contours
tempres@cnMinLevelValF = 283
tempres@cnMaxLevelValF = 303
tempres@cnLevelSpacingF = 2
;tempres@cnMaxLevelCount = 15
;tempres@gsnDraw = False
tempres@gsnFrame = False
polyres = True
polyres@gsMarkerIndex = 16
polyres@gsMarkerSizeF = 10

lnres = True
lnres@gsLineThicknessF = 3.0
;lnres@
type = "png"
;ifil=3;
do ifil=0,numfiles-1
   currentfile = files(ifil)
   filestr = tochar(currentfile)
   date = filestr(11:20)
   time = (filestr(22:23)+"_"+filestr(25:26))
   tempres@TimeLabel = date + " " + filestr(22:23) + ":" + filestr(25:26)

   wks = gsn_open_wks(type, "temp_850_d02_"+date+"_"+time)
;   wks = gsn_open_wks(type, "test")
   a=addfile(files(ifil)+".nc","r") ; Open next file in sequence
   print ("Working on time: "+files(ifil))
   ; Now that file is read, convert ij to lat-lon coordinates
   point = wrf_user_ij_to_ll(a,x,y,True)
   startll = wrf_user_ij_to_ll(a,startij(0),startij(1),True)
   endll   = wrf_user_ij_to_ll(a,endij(0),endij(1),True)
   xpoints = (/startll(0),endll(0)/)
   ypoints = (/startll(1),endll(1)/)
   tempar = wrf_user_getvar(a,"T",0)
   theta = tempar + 300.
   p = wrf_user_getvar(a,"P",0)
   pb = wrf_user_getvar(a,"PB",0)
   pf = p + pb
   temp = wrf_tk(pf, theta)
   pf = pf * 0.01 

   temp850 = wrf_interp_3d_z(temp,pf,850.)
   u = wrf_user_getvar(a,"U",0)
   u_u = wrf_user_unstagger(u,u@stagger)
   v = wrf_user_getvar(a,"V",0)
   v_u = wrf_user_unstagger(v,v@stagger)
   u850 = wrf_interp_3d_z(u_u,pf,850.)
   v850 = wrf_interp_3d_z(v_u,pf,850.)
   vector = wrf_vector(a,wks,u850,v850,vres)
   contour_temp = wrf_contour(a,wks,temp850,tempres)
;   mpres@gsnFrame = False
;   map = wrf_map(wks,a,True)
   final_map =  wrf_map_overlays(a,wks,(/contour_temp,vector/),tempres,mpres)
;   final_map = gsn_csm_vector_scalar_map_ce(wks,u10_interp,v10_interp,contour_temp,True)
;   dum1      = gsn_add_polymarker(wks,final_map,364,624,polyres) 
;   final_map = gsn_contour(wks, temp_interp, tempres)
   gsn_polymarker(wks,final_map,point(0),point(1),polyres)
;   gsn_polyline(wks,final_map,xpoints,ypoints,lnres)
   draw(final_map)
   frame(wks)
 end do
end
