;----------------------------------------------------------------------

pro phast_batch

  ;batch processing dialogue window

  common phast_state
  
  state.batch_source = -1
  
  if (not (xregistered('phast_batch', /noshow))) then begin
  
    batch_base = $
      widget_base(/base_align_left, $
      group_leader = state.base_id, $
      /column, $
      title = 'Process FITS files', $
      uvalue = 'batch_base')
      
    state.batch_image_toggle = widget_button(batch_base,value='Select images',uvalue='batch_image_toggle')
    state.batch_image_base  = widget_base(batch_base,frame=4,/column,xsize=600,ysize=190)
    state.batch_cal_toggle = widget_button(batch_base,value='Calibration settings',uvalue='batch_cal_toggle')
    state.batch_calibrate_base = widget_base(batch_base,frame=4,/column,xsize=600,ysize=170)
    state.batch_astrometry_toggle = widget_button(batch_base,value='Astrometry settings',uvalue='batch_astrometry_toggle')
    state.batch_astrometry_base = widget_base(batch_base,frame=4,/column,xsize=600,ysize=300)
    astrometry_choice_box = widget_base(state.batch_astrometry_base,/nonexclusive)
    astrometry_choice = widget_button(astrometry_choice_box,value='Compute astrometry',uvalue='astrometry_choice')
    sex_label = widget_label(state.batch_astrometry_base,value='SExtractor settings')
    sextractor_base = widget_base(state.batch_astrometry_base,frame=4,/row,xsize=600)
    scamp_label = widget_label(state.batch_astrometry_base,value='SCAMP settings')
    scamp_base = widget_base(state.batch_astrometry_base,frame=4,/row,xsize=600)
    missfits_label = widget_label(state.batch_astrometry_base,value='missFITS settings')
    missfits_base = widget_base(state.batch_astrometry_base,frame=4,/row,xsize=600)
    swarp_label = widget_label(state.batch_astrometry_base,value='SWarp settings')
    swarp_base = widget_base(state.batch_astrometry_base,frame=4,/row,xsize=600)
    
    ;image base
    number_select_base = widget_base(state.batch_image_base,/exclusive,/column)
    multi_image_toggle = widget_button(number_select_base,value='Process multiple images', uvalue='multi_image_toggle')
    single_image_toggle = widget_button(number_select_base,value='Process a single image', uvalue='single_image_toggle')
    line = widget_label(state.batch_image_base, value='-------------------------------------------------------------------------------------------------')

    state.batch_multi_image_base = widget_base(state.batch_image_base,/row)
    image_toggles = widget_base(state.batch_multi_image_base,/row,/exclusive)
    state.batch_current_toggle = widget_button(image_toggles,value='Current images',uvalue='current_toggle')
    dir_toggle = widget_button(image_toggles,value='Directory',uvalue='dir_toggle')
    dirname_base = widget_base(state.batch_multi_image_base,/row)
    state.batch_select_dir = widget_button(dirname_base,value='Select directory',uvalue='select_dir',sensitive=0)
    state.batch_dir_id = widget_label(dirname_base,value=' No directory selected',/dynamic_resize,sensitive=0)

    state.batch_single_image_base = widget_base(state.batch_image_base,/row,sensitive=0)
    image_toggles = widget_base(state.batch_single_image_base,/row,/exclusive)
    state.batch_single_current_toggle = widget_button(image_toggles,value='Current image',uvalue='single_current_toggle')
    ext_toggle = widget_button(image_toggles,value='External image',uvalue='external_toggle')
    extname_base = widget_base(state.batch_single_image_base,/row)
    state.batch_select_image = widget_button(extname_base,value='Select image',uvalue='select_image',sensitive=0)
    state.batch_image_id = widget_label(extname_base,value=' No image selected',/dynamic_resize, sensitive=0)

    mef_toggle_box = widget_base(state.batch_image_base,/row,/nonexclusive)
    state.batch_mef_toggle_id = widget_button(mef_toggle_box,value='Treat multi-extension FITS files as mosaics', uvalue='mef_toggle')

    
    ;calibrate base
    cal_select_box = widget_base(state.batch_calibrate_base,/row)
    overscan_base = widget_base(state.batch_calibrate_base,/nonexclusive,/column)
    over_correct = widget_button(overscan_base,value='Overscan correction',uvalue='over_correct')
    bin_box = widget_base(state.batch_calibrate_base,/row)
    x_label = widget_label(bin_box,value='Bin x:')
    state.bin_x_widget = widget_text(bin_box,value=strtrim(string(state.x_bin),1),uvalue='bin_x_widget',xsize=5,/all_events,/editable)
    y_label = widget_label(bin_box,value='Bin y:')
    state.bin_y_widget = widget_text(bin_box,value=strtrim(string(state.y_bin),1),uvalue='bin_y_widget',xsize=5,/all_events,/editable)
    state.bin_label = widget_label(bin_box,value='',xsize=400,ysize=15)
    button_box1 = widget_base(cal_select_box,/nonexclusive,/column)
    bias_toggle = widget_button(button_box1,value='Bias',uvalue='bias_toggle')
    flat_toggle = widget_button(button_box1,value='Flat',uvalue='flat_toggle')
    dark_toggle = widget_button(button_box1,value='Dark',uvalue='dark_toggle')
    button_box2 = widget_base(cal_select_box,/column)
    state.bias_select_id = widget_button(button_box2,value='Select a bias',uvalue='bias_select',sensitive=0)
    state.flat_select_id = widget_button(button_box2,value='Select a flat',uvalue='flat_select',sensitive=0)
    state.dark_select_id = widget_button(button_box2,value='Select a dark',uvalue='dark_select',sensitive=0)
    label_box1 = widget_base(cal_select_box,/column)
    spacer_1 = widget_label(label_box1,value='')
    state.bias_label_id = widget_label(label_box1,value=state.bias_filename, /align_left, /dynamic_resize)
    spacer_2  = widget_label(label_box1,value='')
    state.flat_label_id = widget_label(label_box1,value=state.flat_filename, /align_left, /dynamic_resize)
    spacer_3 = widget_label(label_box1,value='')
    state.dark_label_id = widget_label(label_box1,value=state.dark_filename, /align_left, /dynamic_resize)


    ;SExtractor base
    sex_flags_label = widget_label(sextractor_base,value='Flags:')
    state.sex_flags_widget_id = widget_text(sextractor_base,value=state.sex_flags,uvalue='sex_flags',xsize=50,/all_events,/editable)
    
    ;SCAMP base
    scamp_flags_label = widget_label(scamp_base,value='Flags:')
    state.scamp_flags_widget_id = widget_text(scamp_base,value=state.scamp_flags,uvalue='scamp_flags',xsize=50,/all_events,/editable)
    
    ;missFITS base
    missfits_flags_label = widget_label(missfits_base,value='Flags:')
    state.missfits_flags_widget_id = widget_text(missfits_base,value=state.missfits_flags,uvalue='missfits_flags',xsize=50,/all_events,/editable)

    ;SWarp base
    swarp_flags_label = widget_label(swarp_base,value='Flags:')
    state.swarp_flags_widget_id = widget_text(swarp_base,value=state.swarp_flags,uvalue='swarp_flags',xsize=50,/all_events,/editable)
    
    tmp_base = widget_base(batch_base,/row)
    start = widget_button(tmp_base,value='Start',uvalue='start')
    done = widget_button(tmp_base,value='Done',uvalue='done')
    
    widget_control, batch_base, /realize
    
    xmanager, 'phast_batch', batch_base, /no_block
    
    ;set intial button states
    widget_control, state.batch_current_toggle, set_button=1  &  state.batch_source = 0
    widget_control, state.batch_single_current_toggle, set_button=1

    if state.bias_toggle eq 1 then begin
      widget_control,bias_toggle,set_button=1
      widget_control,state.bias_select_id,sensitive=1
    end
    if state.dark_toggle eq 1 then begin
      widget_control,dark_toggle,set_button=1
      widget_control,state.dark_select_id,sensitive=1
    end
    if state.flat_toggle eq 1 then begin
      widget_control,flat_toggle,set_button=1
      widget_control,state.flat_select_id,sensitive=1
    end
    if state.over_toggle eq 1 then widget_control,over_correct,set_button=1
    if state.astrometry_toggle eq 1 then widget_control,astrometry_choice,set_button=1
    if state.batch_image_toggle_state eq 0 then widget_control,state.batch_image_base, ysize=1
    if state.batch_cal_toggle_state eq 0 then widget_control,state.batch_calibrate_base, ysize=1
    if state.batch_astrometry_toggle_state eq 0 then widget_control,state.batch_astrometry_base, ysize=1
    if state.batch_mef_toggle eq 1 then widget_control,state.batch_mef_toggle_id,set_button=1
    
    phast_resetwindow
  endif
end

;----------------------------------------------------------------------

pro phast_batch_event,event

  ;event handler for batch processing dialog window

  common phast_state
  common phast_images
  
  widget_control, event.id, get_uvalue = uvalue
  
  case uvalue of
  
    ;image base
     'batch_image_toggle': begin
        while (1 eq 1) do begin ;choose one
           if state.batch_image_toggle_state eq 1 then begin
              widget_control, state.batch_image_base,ysize=1
              state.batch_image_toggle_state = 0
              break
           endif
           if state.batch_image_toggle_state eq 0 then begin
              widget_control, state.batch_image_base,ysize=190
              state.batch_image_toggle_state = 1
              break
           endif
        endwhile
     end
     'multi_image_toggle': begin
        widget_control, state.batch_multi_image_base, sensitive=1
        widget_control, state.batch_single_image_base, sensitive=0
        widget_control, state.batch_current_toggle, set_button=1
        state.batch_source = 0
     end
     'single_image_toggle': begin
        widget_control, state.batch_multi_image_base, sensitive=0
        widget_control, state.batch_single_image_base, sensitive=1
        widget_control, state.batch_single_current_toggle, set_button=1
        state.batch_source = 2
        
     end
     'mef_toggle': state.batch_mef_toggle = event.select

     ;calibrate base
     'batch_cal_toggle': begin
        while (1 eq 1) do begin ;choose one
           if state.batch_cal_toggle_state eq 1 then begin
              widget_control, state.batch_calibrate_base,ysize=1
              state.batch_cal_toggle_state = 0
              break
           endif
           if state.batch_cal_toggle_state eq 0 then begin
              widget_control, state.batch_calibrate_base,ysize=170
              state.batch_cal_toggle_state = 1
              break
           endif
        endwhile
     end
     'dark_toggle': begin
        if state.dark_toggle eq 0 then begin
           widget_control,state.dark_select_id,/sensitive
           state.dark_toggle = 1
        endif else begin
           widget_control,state.dark_select_id,sensitive=0
           state.dark_toggle = 0
        endelse
     end
     'flat_toggle': begin
        if state.flat_toggle eq 0 then begin
           widget_control,state.flat_select_id,/sensitive
           state.flat_toggle = 1
        endif else begin
           widget_control,state.flat_select_id,sensitive=0
           state.flat_toggle = 0
        endelse
     end
     'bias_toggle': begin
        if state.bias_toggle eq 0 then begin
           widget_control,state.bias_select_id,/sensitive
           state.bias_toggle = 1
        endif else begin
           widget_control,state.bias_select_id,sensitive=0
           state.bias_toggle = 0
        endelse
     end
     'dark_select': begin
        state.dark_filename = dialog_pickfile(/must_exist,/read,filter='*.fits')
        if state.dark_filename ne '' then begin
           widget_control,state.dark_label_id,set_value=state.dark_filename
           fits_read,state.dark_filename,cal_dark,cal_dark_head
        endif
     end
     'flat_select': begin
        state.flat_filename = dialog_pickfile(/must_exist,/read,filter='*.fits')
        if state.flat_filename ne '' then begin
           widget_control,state.flat_label_id,set_value=state.flat_filename
           fits_read,state.flat_filename,cal_flat,cal_flat_head
        endif
     end
     'bias_select': begin
        state.bias_filename = dialog_pickfile(/must_exist,/read,filter='*.fits')
        if state.bias_filename ne '' then begin
           widget_control,state.bias_label_id,set_value=state.bias_filename
           fits_read,state.bias_filename,cal_bias,cal_bias_head
        endif
     end
     'select_dir': begin
        state.batch_dirname = dialog_pickfile(/dir)
        if state.batch_dirname ne '' then begin
           widget_control,state.batch_dir_id,set_value=state.batch_dirname
           widget_control,state.batch_dir_id,sensitive=1
        endif
     end
     'select_image': begin
        state.batch_imagename = dialog_pickfile(filter='*.fits',/must_exist)
       if state.batch_imagename ne '' then begin
           widget_control,state.batch_image_id,set_value=state.batch_imagename
           widget_control,state.batch_image_id,sensitive=1
        endif
     end
     'current_toggle': begin
        widget_control,state.batch_select_dir,sensitive=0
        widget_control,state.batch_dir_id,sensitive=0
        state.batch_source = 0
        state.batch_dirname = ''
        widget_control,state.batch_dir_id,set_value=' No Directory selected'
     end
     'dir_toggle': begin
        widget_control,state.batch_select_dir,sensitive=1
        widget_control,state.batch_dir_id,sensitive=1
        state.batch_source = 1
     end
     'single_current_toggle': begin
        widget_control, state.batch_select_image, sensitive=0
        widget_control,state.batch_image_id,sensitive=0
        state.batch_source = 2
        state.batch_imagename = ''
        widget_control,state.batch_image_id,set_value=' No image selected'
     end
     'external_toggle': begin
        widget_control,state.batch_select_image,sensitive=1
        widget_control,state.batch_image_id,sensitive=1
        state.batch_source = 3
     end
     'over_correct': begin
        if state.over_toggle eq 0 then begin
           state.over_toggle = 1
        endif else begin
           state.over_toggle = 0
        endelse
     end
     'bin_x_widget': begin
        widget_control, state.bin_x_widget,get_value=value
        state.x_bin = float(value)
        widget_control, state.bin_label,set_value='Warning: new plate scale must be set in SExtractor confiiguration.'
     end
     'bin_y_widget': begin
        widget_control, state.bin_y_widget,get_value=value
        state.y_bin = float(value)
        widget_control, state.bin_label,set_value='Warning: new plate scale must be set in SExtractor confiiguration.'
     end    
     ;astrometry base
     'batch_astrometry_toggle': begin
        while (1 eq 1) do begin ;choose one
           if state.batch_astrometry_toggle_state eq 1 then begin
              widget_control, state.batch_astrometry_base,ysize=1
              state.batch_astrometry_toggle_state = 0
              break
           endif
           if state.batch_astrometry_toggle_state eq 0 then begin
              widget_control, state.batch_astrometry_base,ysize=300
              state.batch_astrometry_toggle_state = 1
              break
           endif
        endwhile
     end
                                ;compute astrometry?
     'astrometry_choice': begin
        if state.astrometry_toggle eq 0 then begin
           state.astrometry_toggle = 1
        endif else begin
           state.astrometry_toggle = 0
        endelse
     end
                                ;SExtractor base
     'sex_flags': begin
        widget_control,state.sex_flags_widget_id,get_value=value
        state.sex_flags = value
     end
     
                                ;SCAMP base
     'scamp_flags': begin
        widget_control,state.scamp_flags_widget_id,get_value=value
        state.scamp_flags = value
     end
     
                                ;missFITS base
     'missfits_flags': begin
        widget_control,state.missfits_flags_widget_id,get_value=value
        state.missfits_flags = value
     end

                                ;SWarp base
     'swarp_flags': begin
        widget_control,state.swarp_flags_widget_id,get_value=value
        state.swarp_flags = value
     end
     
                                ;other
     'start': begin
        while 1 eq 1 do begin
           if state.batch_source eq -1 then begin
              result = dialog_message('Science images must be loaded!',/center)
              break
           endif
           if state.batch_source eq 1 and state.batch_dirname eq '' then begin
              result = dialog_message('Image directory must be selected!',/center)
              break
           endif
           if state.batch_source eq 0 and state.num_images eq 0 then begin
              result = dialog_message('No images are loaded!',/center)
              break
           endif
           if state.x_bin eq 0 or state.y_bin eq 0 then begin
              result = dialog_message('Bin size cannot be zero!',/center)
              break
           endif
           phast_do_batch
           break
        endwhile
     end
     'done': widget_control,event.top,/destroy
     
     else: print,'uvalue not found'
     
  endcase
end

;---------------------------------------------------------------------------
pro phast_calculate_zeropoint,fitsfile,msgarr,external=external

  ; routine to calculate the photometric zero-point.  this routine saves the
  ; zeropoint values to fits header only when they are successfully determined.
  ;set /external is this procedure is called with an image not loaded

  common phast_state
  common phast_filters
  common phast_images
  
  ; 1) determine filter and exposure for image
  fits_read, fitsfile, image, head  ; patch: these should be placed somewhere else

  ;get image size
  size = size(image)
  image_width = size[1]
  image_height = size[2]

  ;get astrometry pointer
  extast, head, astr, noparams

  xsize = sxpar(head, 'NAXIS1')
  ysize = sxpar(head, 'NAXIS2')
  xscale = sxpar(head, 'CDELT1',count=count)
  if count eq 0 then xscale = sxpar(head,'CD1_1',count=count)
  if count eq 0 then begin
     print, 'Error: No plate scale found in FITS header.  Defaulting to slow mode for zero-point computation...'
     fast_mode = 0
     xscale = 0
  endif
  yscale = sxpar(head, 'CDELT2',count=count)
  if count eq 0 then yscale = sxpar(head,'CD2_2',count=count)
  if count eq 0 then begin
     print, 'Error: No plate scale found in FITS header.  Defaulting to slow mode for zero-point computation...'
     fast_mode = 0
     yscale = 0
  endif

  area = (xsize*abs(xscale))*(ysize*abs(yscale)) ;in degrees^2
  growth_factor = sqrt(area/0.0278) ;amount over the standard image size

  exposure  = sxpar(head,'EXPTIME')
  posFilter = sxpar(head,filters.fitsKey)
  pixelscale = sxpar(head,'PIXELSCALE')/0.000277777777777778d
  fitColor  = filters.fitcolor[posFilter]
  fitTerm   = strmid(filters.fitTerm[posFilter],0,3) & if ~fitColor then magztrm = '   '
  imgBand   = strtrim(filters.nameFilter[posFilter])
  magBand   = strtrim(filters.magBand[posFilter])
  
  ; default values in absence of zeropoint calculations
  magzero =  0.0
  magzerr =  0.0
  magzbnd = 'Instr'
  magzclr =  0.0
  mabgtrm =  '   '
  magznum =  0
  
  ; zeropoint pre-determined by user
  if filters.doZeroPt[posFilter] EQ 0 then begin
    magzero = filters.Zeropoint[posFilter]
    magzerr = filters.errZeroPt[posFilter]
    magzbnd = filters.nameFilter[posFilter]
    magzclr =  0.0
    mabztrm =  '   '
    magznum =  0
    phast_phot_updateFits, image, head, magzero, magzerr, magzbnd, magzclr, magztrm, magznum,imagename=fitsfile
    if not keyword_set(external) then phast_refresh_image, state.current_image_index, state.imagename
    msgarr = strarr(2)
    msgarr(0) = 'Photometric zeropoint was input for filter ' + magzbnd
    msgarr(1) = 'as ' + string(magzero,'(F6.3)') + ' ' + string(177b) + ' ' + string(magzerr,'(F5.3)')
    return
  endif
  
  ; zeropoint cannot be calculated for some filters
  if strlowcase(magBand) EQ 'x' then begin
    phast_phot_updateFits, image, head, magzero, magzerr, magzbnd, magzclr, magztrm, magznum,imagename=fitsfile
    if not keyword_set(external) then phast_refresh_image, state.current_image_index, state.imagename
    msgarr = strarr(2)
    msgarr(0) = 'Photometric zeropoint cannot be determined for filter ' + imgBand
    msgarr(1) = 'No matching catalog magnitude.'
    return
  endif
  
  ; must have astrometric solution to match to catalog
  if n_elements(astr) eq 0 then begin
    msgarr = strarr(2)
    msgarr(0) = 'Photometric zeropoint cannot be determined'
    msgarr(1) = 'Perform astrometric calibration first'
    return
  endif
  
  ; begin zeropoint determination
  widget_control,/hourglass     ;this could be slow
  
  match_tol = (2.0 / 3600.)^2   ; astrometric matching tolerance (arcsecs converted to degrees) (squared for less compute time in comparing)
  sigmaClip = 3.0           ; outlier rejection (about 1-300 chance < |t|)
  minSNR    = 10.0          ; minimum detection SNR to use in calibration
  
  ; 2) obtain catalog for matching area on the sky
  expand = 1.25
  phast_getFieldEpoch, a, d, radius, X, obsDate, astr=astr,header=head,image_width=image_width,image_height=image_height,pixelscale=pixelscale
  star_catalog = phast_get_stars(a,d,radius*expand,AsOf=obsDate,catalog_name=state.photcatalog_name)
  
  phast_getCatMags, star_catalog, magBand, cat_RA, cat_Dec, cat_Mag, err_Mag
  
  if fitcolor then begin
    phast_getCatMags, star_catalog, strmid(fitTerm,0,1), null, null, Color1, colErr1
    phast_getCatMags, star_catalog, strmid(fitTerm,2,1), null, null, Color2, colErr2
    cat_ColorFit = Color1 - Color2
    err_ColorFit = sqrt( colErr1*colErr1 + colErr2*colErr2 )
  endif else begin
    cat_ColorFit = replicate(0.0, n_elements(cat_RA))
    err_ColorFit = replicate(0.0, n_elements(cat_RA))
  endelse
  
  ; get color to evaluate extinction terms
  phast_getCatMags, star_catalog, 'V', null, null, Color1, colErr1
  phast_getCatMags, star_catalog, 'R', null, null, Color2, colErr2
  cat_ColorExt = Color1 - Color2
  err_ColorExt = sqrt( colErr1*colErr1 + colErr2*colErr2 )
  
   ; get color to evaluate color transformation
  if filters.transCoeff[posFilter] ne 0.00 and filters.transTerm[posFilter] ne 'n/a' then begin
     phast_getCatMags, star_catalog, strmid(filters.transTerm[posFilter],0,1), null, null, Color1, colErr1
     phast_getCatMags, star_catalog, strmid(filters.transTerm[posFilter],2,1), null, null, Color2, colErr2
     cat_ColorTrm = Color1 - Color2
     err_ColorTrm = sqrt( colErr1*colErr1 + colErr2*colErr2 )
  endif else begin
     cat_ColorTrm = replicate(0.0, n_elements(cat_RA))
     err_ColorTrm = replicate(0.0, n_elements(cat_RA))
  endelse
   
  good = where( finite(cat_Mag) and finite(err_Mag) and finite(cat_ColorFit) and finite(err_ColorFit)  $
                                                                             and finite(cat_ColorExt)  $
                                                                             and finite(cat_ColorTrm) )  ; reduce to surviving catalog entries
  if n_elements(good) lt n_elements(cat_ColorFit) then begin
    index = indgen(n_elements(cat_ColorFit),/ulong)
    remove, good, index ; index is now bad points
    pntrx = where(finite(cat_ColorFit),countColor)
    if countColor gt 0 then begin
      remove, index, cat_RA, cat_Dec, cat_Mag, err_Mag, cat_ColorFit, err_ColorFit, cat_ColorExt, err_ColorExt
    endif
  endif
  
  ; 3) Use SExtractor to determine instrumental magnitudes
  textstr = '-CATALOG_TYPE ASCII_HEAD -PARAMETERS_NAME zeropoint.param'                              $
    +       ' -PHOT_AUTOPARAMS ' + strcompress( string(state.sex_PHOT_AUTOPARAMS[0],'(F6.3)') + ','  $
    +                                           string(state.sex_PHOT_AUTOPARAMS[1],'(F6.3)'),       $
    /REMOVE_ALL )
  phast_do_sextractor, image=fitsfile, flags=textstr, cat_name=state.phast_dir+'/output/catalogs/zeropoint.cat'
  
  readcol, state.phast_dir+'/output/catalogs/zeropoint.cat', im_RA, im_Dec, Instr, errInstr, flags, comment='#', Format='D,D,D,D,I', /silent


  
   ; qualify SExtractor detections
  Instr( where(   flags gt  0  ) ) = !values.F_NAN  ; avoid complicated/corrupted detections
  Instr( where(   Instr ge 99.0) ) = !values.F_NAN  ; avoid sextractor missing value code (99.0)
  Instr( where(errInstr ge 99.0) ) = !values.F_NAN  ; avoid sextractor missing value code (99.0)

  signal = 10^(-0.4*Instr)  &  sigma = 10^(-0.4*errInstr)  &  SNR = signal/sigma 
  Instr( where( SNR lt minSNR) ) = !values.F_NAN  ; avoid low SNR detections
      
  ; scale to 1 sec (assumes that photon noise dominates read noise and other sources)
  Instr = -2.5*alog10(signal /      exposure )
  errInstr = -2.5*alog10(sigma  / sqrt(exposure))   ; patch.  is this the right thing to do?
  
  good = where( finite(Instr) and finite(errInstr) )  ; reduce to surviving detections
  if n_elements(good) LT 3 then begin
    msgarr = strarr(2)
    msgarr(0) = 'Photometric zeropoint can not be determined'
    msgarr(1) = 'Only ' + string(n_elements(good),'I1') + ' detections with SNR > ' + string(minSNR<99.9,'(F4.1)')
    return
  endif else begin 
    if n_elements(good) lt n_elements(Instr) then begin
      index = indgen(n_elements(Instr))
      remove, good, index ; index is now bad points
      remove, index, im_RA, im_Dec, Instr, errInstr, flags
    endif
 endelse

  min_count =  fix(50*growth_factor) ;want more stars than this
  max_count = fix(100*growth_factor) ;don't need more stars than this

  if state.fast_zeropoint eq 1 and n_elements(im_RA) gt max_count then begin ;need to further reduce star count
     print, "Large number of sources detected.  Reducing this to improve speed..."
     signal = 10^(-0.4*Instr)
     sigma = 10^(-0.4*errInstr)
     SNR = signal/sigma
     if n_elements(Instr(where( SNR lt 15))) ge min_count then begin ;don't want too few
        Instr(where( SNR lt 15)) = !values.F_NAN 
        good = where( finite(Instr)) ; reduce to surviving detections
        index = indgen(n_elements(Instr))
        remove, good, index     ; index is now bad points
        remove, index, im_RA, im_Dec, Instr, errInstr, flags
        if n_elements(im_RA) gt max_count then begin ;STILL need to reduce count
           signal = 10^(-0.4*Instr)
           sigma = 10^(-0.4*errInstr)
           SNR = signal/sigma
           if n_elements(Instr(where( SNR lt 20))) ge min_count then begin ;don't want too few
              Instr(where( SNR lt 20)) = !values.F_NAN 
              good = where( finite(Instr)) ; reduce to surviving detections
              index = indgen(n_elements(Instr))
              remove, good, index ; index is now bad points
              remove, index, im_RA, im_Dec, Instr, errInstr, flags
              if n_elements(im_ra) gt max_count then begin ;choose randomly
                 temp_ra = list()
                 temp_dec = list()
                 temp_instr = list()
                 temp_errinstr = list()
                 rand_percent = float(max_count)/n_elements(im_ra)
                 for cutdown=0, n_elements(im_ra)-1 do begin
                    rand = randomu(undef) ;generate a random numbner in range [0,1]
                    if rand lt rand_percent then begin ;reduce array to approximately max_count
                       temp_ra.add,im_ra[cutdown]
                       temp_dec.add, im_dec[cutdown]
                       temp_instr.add, instr[cutdown]
                       temp_errinstr.add, errinstr[cutdown]
                    endif
                 endfor
                 im_ra = temp_ra.toarray()
                 im_dec = temp_dec.toarray()
                 instr = temp_instr.toarray()
                 errinstr = temp_errinstr.toarray()
              endif              
           endif
        endif
     endif
  endif 
  
  ; 4) Match catalog objects to image
  Cat = make_array(1,n_elements(im_RA),/DOUBLE,VALUE=!VALUES.f_nan) ; will hold cat magnitude of matching star
  errCat = make_array(1,n_elements(im_RA),/DOUBLE,VALUE=!VALUES.f_nan)
  ColorFit = make_array(1,n_elements(im_RA),/DOUBLE,VALUE=!VALUES.f_nan) ; will hold cat color index to fit color term
  errColorFit = make_array(1,n_elements(im_RA),/DOUBLE,VALUE=!VALUES.f_nan)
  ColorExt = make_array(1,n_elements(im_RA),/DOUBLE,VALUE=!VALUES.f_nan) ; will hold cat color index for extinction
  errColorExt = make_array(1,n_elements(im_RA),/DOUBLE,VALUE=!VALUES.f_nan)
  ColorTrm = make_array(1,n_elements(im_RA),/DOUBLE,VALUE=!VALUES.f_nan) ; will hold cat color index for input color term
  errColorTrm = make_array(1,n_elements(im_RA),/DOUBLE,VALUE=!VALUES.f_nan)
  cosDec = cos(im_Dec*!PI/180.0)

  num_instr=n_elements(instr)-1
  num_cat = n_elements(cat_RA)-1
  for i=0, num_instr do begin
     match_dist = 1.0       ;(in deg)
     match_index = -1       ; will be set to catalog index j when a match is found
     for j=0, num_cat do begin
        dist = (cosDec[i]*(cat_RA[j]-im_RA[i]))^2 + (cat_Dec[j]-im_Dec[i])^2
        ; match must be within match_tol with valid instrumental Mag and catalog magnitudes
        if (dist lt match_tol) then if (dist lt match_dist) then if finite(Instr[i]) then if finite(cat_ColorFit[j]) then begin
           match_dist  = dist
           match_index = j
        endif
     endfor
    if match_index ne -1 then begin
              Cat[i] = cat_Mag[match_index]
           errCat[i] = err_Mag[match_index]
         ColorFit[i] = cat_ColorFit[match_index]
      errColorFit[i] = err_ColorFit[match_index]
         ColorExt[i] = cat_ColorExt[match_index]
      errColorExt[i] = err_ColorExt[match_index]
         ColorTrm[i] = cat_ColorTrm[match_index]
      errColorTrm[i] = err_ColorTrm[match_index]
    endif
  endfor

 ; adjust instrumental magnitude for extinction
  extMethod = 1 ; adjust for extinction color
  magType   = 2 ; (std) catalog magnitude
  Instr = phast_ExtAdjust(extMethod, magType, Instr, ColorExt,header=head,astr=astr,image_width=image_width,image_height=image_height,pixelscale=pixelscale)
  
  ; transform from local to standard passband
  Instr = phast_StdAdjust(Instr, posFilter, ColorTrm)
  
  ; define dependent variable
  Y = Cat - Instr ; dependent variable
  errY = sqrt( errCat^2 + errInstr^2 )
  
  ;reduce to matching and non-missing data
  good = where( finite(Instr) And finite(Cat) and finite(ColorFit) )
  if n_elements(good) LT 3 then begin
    msgarr = strarr(3)
    msgarr(0) = 'Photometric zeropoint can not be determined'
    msgarr(1) = 'Only ' + string(n_elements(good),'I1') + ' detections matched to catalog'
    msgarr(2) = 'and have known color indices'
    return
  endif else begin
    if n_elements(good) lt n_elements(Cat) then begin
      index = indgen(n_elements(Cat))
      remove, good, index ; index is now bad points
      if n_elements(index) gt 0 then begin
        remove, index, im_RA, im_Dec, flags, Y, errY, Instr, errInstr, Cat, errCat, ColorFit, errColorFit
      endif
    endif
  endelse
  
  openw, 1, state.phast_dir+'output/photoZeroPointF.csv'  ; dataset at start of solution
  for i=0, n_elements(Instr)-1 do begin
    printf, 1, Cat[i], errCat[i], ColorFit[i], errColorFit[i], Instr[i], errInstr[i], Y[i], errY[i], FORMAT='(8F8.3)'
  endfor
  close, 1
  
  ; 5) Solve in <= maxPass passes with outlier rejection at sigmaClip level after each pass (except last)
  maxpass = 3
  if ~fitColor then begin
  
    ipass = 0
    repeat begin
      ipass = ipass + 1
      
      phast_meanerr, Y, errY, meanValue, sigmaMean, sigmaData
      if ipass lt maxpass then begin ; reject outliers
        outliers = abs(Y-meanValue) gt replicate(sigmaClip*sigmaData, n_elements(Y))
        index = indgen(n_elements(outliers))
        index =  index(where(outliers eq 1, count))
        if count GT 0 then remove, index, Cat, errCat, ColorFit, errColorFit, Instr, errInstr, Y, errY
      endif
      
      magzero = meanValue
      magzerr = sigmaData
      magzbnd = magBand
      magzclr = 0.0
      magztrm = fitTerm
      magznum = 999 < n_elements(Y)
      msgarr = strarr(4) ; construct return message text
      msgarr(0) = 'Zero-point = ' + string(magzero,'(F6.3)') + ' ' + string(177b) + ' ' + string(magzerr,'(F5.3)') + ' ' + magzbnd
      msgarr(1) = 'N = ' + string(magznum,'(I3)')
      msgarr(2) = ' '
      msgarr(3) = 'Zeropoint determination was successful'
      
    endrep until (total(outliers) eq 0) or (ipass eq maxpass)
  endif else begin
  
    ipass = 0
    
    repeat begin
      ipass = ipass + 1
      
      B0 = regress( ColorFit, Y, MEASURE_ERRORS=errY, CONST=A0, SIGMA=errB0, /Double, $
        STATUS=retCode, YFIT=Yfit, CORRELATION=corrVec, CHISQ=chisq, FTEST=Ftest, MCORRELATION=corrR )
        
      if ipass lt maxpass then begin ; reject outliers
        sigmaY = stddev(Y-Yfit) ; approximation
        outliers = abs(Y-Yfit) gt replicate(sigmaClip*sigmaY, n_elements(Y))
        index = indgen(n_elements(outliers))
        index =  index(where(outliers eq 1, count))
        if count GT 0 then remove, index, Cat, errCat, ColorFit, errColorFit, Instr, errInstr, Y, errY
      endif
      
    endrep until (total(outliers) eq 0) or (ipass eq maxpass)
    
    if retCode eq 0 then begin
      magzero = float(A0[0])
      magzerr = float(sigmaY[0])
      magzbnd = magBand
      magzclr = float(B0[0])
      magztrm = fitTerm
      magznum = 999 < n_elements(Y)
      ;
      msgarr = strarr(5) ; construct return message text
      msgarr(0) = 'Zero-point = ' + string(magzero,'(F6.3)') + ' ' + string(177b) + ' ' + string(magzerr,'(F5.3)') + ' ' + magzbnd
      msgarr(1) = '           + ' + string(magzclr,'(F6.3)') + ' ' + string(177b) + ' ' + string(errB0,'(F5.3)')+ ' * (' + fitTerm + ')'
      msgarr(2) = 'N = ' + string(magznum,'(I3)')
      msgarr(3) = ' '
      msgarr(4) = 'Zeropoint determination was successful'
      if retCode NE 0 then msgarr(4) = '' ; 'warning: matrix near-singular'
      
    endif else begin
      msgarr = strarr(2)
      msgarr(0) = 'Zeropoint determination failed'
      msgarr(1) = 'Check output/photoZeroPoint.csv for data'
    endelse
    
  endelse
  
  openw, 1, state.phast_dir+'/output/photoZeroPoint.csv'
  for i=0, n_elements(Instr)-1 do begin
    printf, 1, Cat[i], errCat[i], ColorFit[i], errColorFit[i], Instr[i], errInstr[i], Y[i], errY[i], FORMAT='(8F8.3)'
  endfor
  close, 1
  
  phast_phot_updateFits, image, head, magzero, magzerr, magzbnd, magzclr, magztrm, magznum,imagename=fitsfile
end

;----------------------------------------------------------------------

pro phast_calibrate, input_file=input_file,output_file=output_file,mosaic=mosaic

  ;routine to calibrate an image based on any or all of dark/flat/bias
  ;and trim any image overscan

  common phast_state
  common phast_images

  if not keyword_set(input_file) then input_file = state.cal_file_name
  if not keyword_set(output_file) then output_file = state.cal_file_name



  if keyword_set(mosaic) then begin
     fits_info,input_file,n_ext=num_ext,/silent
     ;spawn, 'cp '+input_file+' '+output_file
  endif else begin
     num_ext = 1
  end

  for cal_index=1, num_ext do begin

     if keyword_set(mosaic) then begin
        fits_read,input_file,cal_science,cal_science_head,exten_no=cal_index
     endif else fits_read,input_file,cal_science,cal_science_head

     ;copy images so that originals are not modified
     main = float(cal_science)
     bias = float(cal_bias)
     flat = float(cal_flat)
     dark = float(cal_dark)
  
     ;correct overscan
     if state.over_toggle ne 0 then begin
        
        ;size of current file
        row_length = n_elements(main[*,0])
        column_length = n_elements(main[0,*])

        ;find main image region.  rest is overscan
        while (1 eq 1) do begin ;choose only one option
           value = sxpar(cal_science_head,'DATASEC',count=count)
           if count ne 0 then begin
              split = strsplit(value,'[,:]',/extract)
              image_region = fix(split)-1 ;convert to 0-index
              if ( row_length -1 - image_region[1] + image_region[0]) ne 0 then begin ;bias region is on left/right of image
                 type = 0 ;bias region is column
                 if image_region[0] eq 0 then begin
                    x_min = image_region[1]+1
                    x_max = row_length - 1
                 endif else begin
                    x_min = 0
                    x_max = image_region[0]-1    
                 endelse
                 region = [x_min,x_max,0,column_length-1]
                 break
              endif else if (column_length - 1 - image_region[3] + image_region[2]) ne 0 then begin ;bias region is on top/bottom of image
                 type = 1 ;bias region is row
                  if image_region[2] eq 0 then begin
                    y_min = image_region[3]+1
                    y_max = column_length -1
                 endif else begin
                    y_min = 0
                    y_max = image_region[2] - 1
                 endelse
                 region = [0,row_length-1,y_min,y_max]
                 break
              endif else begin ;no bias region
                 result = dialog_message('Error encountered.  No overscan region present?',/error,/center)
                 return
              endelse
           endif
           result = dialog_message('Error encountered.  No overscan region present?',/error,/center)
           return
        endwhile
        
        ;remove overscan from each image

        if type eq 0 then begin            ;bias region is made up of columns
           for i=0, column_length-1 do begin ;cycle the rows
              med_main = median(main[region[0]:region[1],i])
              main[*,i] -= med_main
              if state.dark_toggle ne 0 then begin
                 med_dark = median(dark[region[0]:region[1],i])
                 dark[*,i] -= med_dark
              endif
              if state.flat_toggle ne 0 then begin
                 med_flat = median(flat[region[0]:region[1],i])
                 flat[*,i] -= med_flat
              endif
              if state.bias_toggle ne 0 then begin
                 med_bias = median(bias[region[0]:region[1],i])
                 bias[*,i] -= med_bias
              endif
           endfor
        endif else begin                ;bias region is made up of rows
           for i=0, row_length-1 do begin ;cycle the columns
              med_main = median(main[i,region[2]:region[3]])
              main[i,*] -= med_main
              if state.dark_toggle ne 0 then begin
                 med_dark = median(dark[i,region[2]:region[3]])
                 dark[i,*] -= med_dark
              endif
              if state.flat_toggle ne 0 then begin
                 med_flat = median(flat[i,region[2]:region[3]])
                 flat[i,*] -= med_flat
              endif
              if state.bias_toggle ne 0 then begin
                 med_bias = median(bias[i,region[2]:region[3]])
                 bias[i,*] -= med_bias
              endif
           endfor
        endelse

    ;trim overscan region from each image
  
        main = main[image_region[0]:image_region[1],image_region[2]:image_region[3]]
        if state.dark_toggle ne 0 then dark = dark[image_region[0]:image_region[1],image_region[2]:image_region[3]]
        if state.flat_toggle ne 0 then flat = flat[image_region[0]:image_region[1],image_region[2]:image_region[3]]
        if state.bias_toggle ne 0 then bias = bias[image_region[0]:image_region[1],image_region[2]:image_region[3]]

        ;remove superfluous header entries
        sxdelpar, cal_science_head, 'BIASSEC'
        sxdelpar, cal_science_head, 'TRIMSEC'    
     endif
  ;subtract bias
     if state.bias_toggle ne 0 then begin
        main = (main-bias)>0
     endif
  
  ;subtract dark
     if state.dark_toggle ne 0 then begin
    ;subtract bias
        dark = dark-bias
    ;normalize dark to science image exposure length
        dark_exp = sxpar(cal_dark_head,'EXPTIME')
        sci_exp = sxpar(cal_science_head,'EXPTIME')
        scale_factor = sci_exp/dark_exp
        dark = scale_factor*dark
    ;subtract dark from science image
        main = main-dark
     endif
  
  ;divide by flat
     if state.flat_toggle ne 0 then begin
    ;subtract bias from flat
        flat = (flat - bias)>1
    ;scale dark to match flat exposure time
        if state.dark_toggle ne 0 then begin
           dark = cal_dark
           flat_exp = sxpar(cal_flat_head,'EXPTIME')
           scale_factor = flat_exp/dark_exp
           dark = scale_factor*dark
           flat = flat - dark
        endif
    
    ;find median value in middle 50% of image
        size = size(flat)
        h_seg = .25*size[1]
        v_seg = .25*size[2]
        med=median(flat[h_seg : 3*h_seg,v_seg : 3*v_seg])
    
    ;create flat map
        map = flat/med
    ;divide by map
        main = main/map
     endif
  ;bin resulting image
     if state.x_bin ne 1 or state.y_bin ne 1 then begin
        size = size(main)
        main = frebin(main,float(size[1])/state.x_bin, float(size[2])/state.y_bin,/total)
     endif

     size = size(main)                ;get image size

  
  ;write header values required for plate solution
     if not keyword_set(mosaic) then begin
        temp = sxpar(cal_science_head,'CTYPE1',count=count)
        if count eq 0 then begin
           print, 'CTYPE keywords not found.  Setting to TAN projection...'
           sxaddpar,cal_science_head,'CTYPE1','RA---TAN'
           sxaddpar,cal_science_head,'CTYPE2','DEC--TAN'
        endif
        temp = sxpar(cal_science_head,'CUNIT1',count=count)
        if count eq 0 then begin
           print, 'CUNIT keywords not found.  Setting to degrees...'
           sxaddpar,cal_science_head,'CUNIT1','deg'
           sxaddpar,cal_science_head,'CUNIT2','deg'
        endif
        temp = sxpar(cal_science_head,'CRPIX1',count=count)
        if count eq 0 then begin
           print, 'CRPIX keywords not found.  Setting to image center...'
           sxaddpar,cal_science_head,'CRPIX1',size[1]/2,format='E11.5'
           sxaddpar,cal_science_head,'CRPIX2',size[2]/2,format='E11.5'
        endif
        temp = sxpar(cal_science_head,'CRVAL1',count=count)
        if count eq 0 then begin
           print, 'CRVAL keywords not found.  Trying to add approximate RA and Dec...'
           ra = sxpar(cal_science_head,'RA') ;get approx ra
           dec = sxpar(cal_science_head,'DEC') ;get approx dec
                                ;convert to degrees
           ra = 15*ten(ra)
           dec = ten(dec)
           sxaddpar,cal_science_head,'CRVAL1',ra,format='E12.5'
           sxaddpar,cal_science_head,'CRVAl2',dec,format='E12.5'
        endif
        temp = sxpar(cal_science_head,'CDELT1',count=count)
        if count eq 0 then begin
           print, 'CDELT keywords not found.  Setting to user-supplied pixelscale...'
           sxaddpar,cal_science_head,'CDELT1',state.fits_cdelt1,format='E14.7'
           sxaddpar,cal_science_head,'CDELT2',state.fits_cdelt2,format='E14.7'
        endif
        temp = sxpar(cal_science_head,'CROTA1',count=count)
        if count eq 0 then begin
           print, 'CROTA keywords not found.  Setting to user-supplied values...'
           sxaddpar,cal_science_head,'CROTA1',state.fits_crota1,format='E11.5'
           sxaddpar,cal_science_head,'CROTA2',state.fits_crota2,format='E11.5'
        endif
        temp = sxpar(cal_science_head,'EQUINOX',count=count)
        if count eq 0 or state.force_j2000 ne 0 then begin
           print, 'EQUINOX keyword not found.  Setting to 2000.0...'
           sxaddpar,cal_science_head,'EQUINOX',2000.0
        endif
        temp = sxpar(cal_science_head,'EPOCH',count=count)
        if count eq 0 or state.force_j2000 ne 0 then begin
           print, 'EPOCH keyword not found.  Setting to 2000.0...'
           sxaddpar,cal_science_head,'EPOCH',2000.0
        endif
     endif else begin ;remove any TNX parameters presetnt
        sxaddpar,cal_science_head,'CTYPE1','RA---TAN'
        sxaddpar,cal_science_head,'CTYPE2','DEC--TAN'        
        sxdelpar,cal_science_head, 'WAT0_001'
        sxaddpar,cal_science_head, 'WAT1_001'
        sxdelpar,cal_science_head, 'WAT1_002'
        sxdelpar,cal_science_head, 'WAT1_003'
        sxdelpar,cal_science_head, 'WAT1_004'
        sxdelpar,cal_science_head, 'WAT1_005'
        sxdelpar,cal_science_head, 'WAT2_001'
        sxdelpar,cal_science_head, 'WAT2_002'
        sxdelpar,cal_science_head, 'WAT2_003'
        sxdelpar,cal_science_head, 'WAT2_004'
        sxdelpar,cal_science_head, 'WAT2_005'
        sxdelpar,cal_science_head, 'CHECKSUM'
        sxdelpar,cal_science_head, 'DATASUM'
        if state.over_toggle eq 1 then begin ;update NAXIS keywords
           print, 'Updating NAXIS keywords after trimming overscan region...'
           sxaddpar,cal_science_head, 'NAXIS1',n_elements(main[*,0])
           sxaddpar,cal_science_head, 'NAXIS2',n_elements(main[0,*])
        endif
     endelse
     sxdelpar,cal_science_head,'' ;trim whitespace entries
     sxaddpar,cal_science_header, 'END',''
     if not keyword_set(mosaic) then begin
        fits_write,output_file,main,cal_science_head
     endif else writefits, output_file,long(main),cal_science_head,/append
  endfor
end

;---------------------------------------------------------------------

pro phast_calibrate_image

  ;image calibration dialog window

  common phast_state
  
  if (not (xregistered('phast_calibrate', /noshow))) then begin
  
    cal_base = $
      widget_base(/base_align_left, $
      group_leader = state.base_id, $
      /column, $
      title = 'Calibrate an image', $
      uvalue = 'apphot_base')
    desc_label = widget_label(cal_base,value='Calibrate an image with a dark, flat, or bias frame.')
    main_box = widget_base(cal_base,/row)
    left_box = widget_base(main_box,/column,frame=4)
    science_select_label = widget_label(left_box,value='Select an image to be calibrated:')
    sci_select_box = widget_base(left_box, /row)
    sci_select = widget_button(sci_select_box,value='Select a science image',uvalue='sci_select')
    state.sci_label_id = widget_label(sci_select_box,value='No science image loaded',/dynamic_resize)
    cal_select_label = widget_label(left_box,value='Select calibration images:')
    cal_select_box = widget_base(left_box,/row)
    button_box1 = widget_base(cal_select_box,/nonexclusive,/column)
    bias_toggle = widget_button(button_box1,value='Bias',uvalue='bias_toggle')
    flat_toggle = widget_button(button_box1,value='Flat',uvalue='flat_toggle')
    dark_toggle = widget_button(button_box1,value='Dark',uvalue='dark_toggle')
    button_box2 = widget_base(cal_select_box,/column)
    state.bias_select_id = widget_button(button_box2,value='Select a bias',uvalue='bias_select',sensitive=0)
    state.flat_select_id = widget_button(button_box2,value='Select a flat',uvalue='flat_select',sensitive=0)
    state.dark_select_id = widget_button(button_box2,value='Select a dark',uvalue='dark_select',sensitive=0)
    label_box1 = widget_base(cal_select_box,/column)
    spacer_1  = widget_label(label_box1,value='')
    state.bias_label_id = widget_label(label_box1,value=state.bias_filename,/dynamic_resize)
    spacer_2 = widget_label(label_box1,value='')
    state.flat_label_id = widget_label(label_box1,value=state.flat_filename,/dynamic_resize)
    spacer_3 = widget_label(label_box1,value='')
    state.dark_label_id = widget_label(label_box1,value=state.dark_filename,/dynamic_resize)

    ;right_box = widget_base(main_box,/column,frame=4)
    ;parem_label = widget_label(right_box,value='Parameters')
    
    
    overscan_base = widget_base(left_box,/nonexclusive,/row)
    over_correct = widget_button(overscan_base,value='Correct overscan',uvalue='over_correct')
    filename_box = widget_base(left_box,/row)
    filename_label = widget_label(filename_box,value='Output filename:')
    state.cal_name_box_id = widget_text(filename_box,value=state.cal_file_name,uvalue='filename_text',/all_events,xsize=30,/editable)
    
    buttonbox = widget_base(cal_base,/row)
    calibrate = widget_button(buttonbox,value='Start',uvalue='calibrate')
    done = widget_button(buttonbox,value='Done',uvalue='done')
    
    widget_control, cal_base, /realize
    
    xmanager, 'phast_calibrate_image', cal_base, /no_block
    
    ;set intial button states
    if state.dark_toggle eq 1 then begin
      widget_control,dark_toggle,set_button=1
      widget_control,state.dark_select_id,sensitive=1
    end
    if state.flat_toggle eq 1 then begin
      widget_control,flat_toggle,set_button=1
      widget_control,state.flat_select_id,sensitive=1
    end
    if state.bias_toggle eq 1 then begin
      widget_control,bias_toggle,set_button=1
      widget_control,state.bias_select_id,sensitive=1
    end
    if state.over_toggle eq 1 then widget_control,over_correct,set_button=1
    
    phast_resetwindow
  endif
end

;----------------------------------------------------------------------

pro phast_calibrate_image_event,event

  ;event handler for image calibration front end

  common phast_state
  common phast_images
  
  widget_control, event.id, get_uvalue = uvalue
  
  case uvalue of
    'sci_select': begin
      filename = dialog_pickfile(/must_exist,/read,filter='*.fits')
      if filename ne '' then begin
        widget_control,state.sci_label_id,set_value=filename
        fits_read,filename,cal_science,cal_science_head
      endif
    end
    'dark_toggle': begin
      if state.dark_toggle eq 0 then begin
        widget_control,state.dark_select_id,/sensitive
        state.dark_toggle = 1
      endif else begin
        widget_control,state.dark_select_id,sensitive=0
        state.dark_toggle = 0
      endelse
    end
    'flat_toggle': begin
      if state.flat_toggle eq 0 then begin
        widget_control,state.flat_select_id,/sensitive
        state.flat_toggle = 1
      endif else begin
        widget_control,state.flat_select_id,sensitive=0
        state.flat_toggle = 0
      endelse
    end
    'bias_toggle': begin
      if state.bias_toggle eq 0 then begin
        widget_control,state.bias_select_id,/sensitive
        state.bias_toggle = 1
      endif else begin
        widget_control,state.bias_select_id,sensitive=0
        state.bias_toggle = 0
      endelse
    end
    'dark_select': begin
      state.dark_filename = dialog_pickfile(/must_exist,/read,filter='*.fits')
      if state.dark_filename ne '' then begin
        widget_control,state.dark_label_id,set_value=state.dark_filename
        fits_read,state.dark_filename,cal_dark,cal_dark_head
      endif
    end
    'flat_select': begin
      state.flat_filename = dialog_pickfile(/must_exist,/read,filter='*.fits')
      if state.flat_filename ne '' then begin
        widget_control,state.flat_label_id,set_value=state.flat_filename
        fits_read,state.flat_filename,cal_flat,cal_flat_head
      endif
    end
    'bias_select': begin
      state.bias_filename = dialog_pickfile(/must_exist,/read,filter='*.fits')
      if state.bias_filename ne '' then begin
        widget_control,state.bias_label_id,set_value=state.bias_filename
        fits_read,state.bias_filename,cal_bias,cal_bias_head
      endif
    end
    
    'over_correct': begin
      if state.over_toggle eq 0 then begin
        state.over_toggle = 1
      endif else begin
        state.over_toggle = 0
      endelse
    end
    'filename_text': begin
      widget_control,state.cal_name_box_id,get_value=string
      state.cal_file_name = string
    end
    'calibrate': begin
      if n_elements(cal_science) gt 1 then begin
         if state.cal_file_name ne '' then begin 
            phast_calibrate
            result = dialog_message('Calibration complete!',/center,/information)
         endif else result = dialog_message('You must specify an output filename!',/center) ;warn if no filename specified
      endif else begin ;warn if no science image is loaded
        result = dialog_message('Science image must be loaded!',/center)
      endelse
    end
    'done': widget_control,event.top,/destroy
    
    else: print,'uvalue not recognized'
  endcase
end

;----------------------------------------------------------------------

pro phast_combine

;routine to combine files in a directory into one master file using a
;median combine

  common phast_state

  file_list = findfile(state.combine_dir+'*.fits')
  
  image_1 = readfits(file_list[0])
  dim = size(image_1)
  loaded_files = dblarr(dim[1],dim[2],n_elements(file_list))
  loaded_files[0,0,0] = image_1
  
  for i=1, n_elements(file_list)-1 do loaded_files[0,0,i] = readfits(file_list[i])

  output_image = dblarr(dim[1],dim[2])
  medarr, loaded_files, output_image

  writefits, state.phast_dir+'/output/images/phast_combined.fits', output_image
end
;----------------------------------------------------------------------


pro phast_combine_gui

;front end for combining files

  common phast_state

  if (not (xregistered('phast_combine', /noshow))) then begin
  
     combine_base = $
        widget_base(/base_align_left, $
                    /column, $
                    title = 'Combine FITS files', $
                    xsize = 500)
     desc_label = widget_label(combine_base,value='Perform a median combine on a directory of FITS files')
     temp_base = widget_base(combine_base,/row)
     dir_select = widget_button(temp_base,value='Choose Directory',uvalue='dir_select')
     dir_name = widget_label(temp_base,value='No directory selected',/dynamic_resize)
     buttonbox = widget_base(combine_base,/row)
     start_combine = widget_button(buttonbox,value='Start', uvalue='start_combine')
     done = widget_button(buttonbox,value='Done',uvalue='done')
     
     state.combine_dir_widget_id = dir_name
     widget_control, combine_base, /realize
     
     xmanager, 'phast_combine_gui', combine_base, /no_block
     
     phast_resetwindow
  endif
end
;----------------------------------------------------------------------

pro phast_combine_gui_event,event

  common phast_state
  
  widget_control, event.id, get_uvalue = uvalue
  
  case uvalue of
    'dir_select': begin
      state.combine_dir = dialog_pickfile(/directory,/read)
      widget_control,state.combine_dir_widget_id,set_value=state.combine_dir
    end
    'start_combine': phast_combine
    'done':widget_control,event.top,/destroy    
  endcase
end

;----------------------------------------------------------------------

pro phast_detect_moving_objects

;routine to detect a moving object in a series of images

  common phast_state
  common phast_images
  common phast_pdata

  widget_control,/hourglass

;create array to hold data
  x_data_array = ptrarr(state.num_images,/allocate)
  y_data_array = ptrarr(state.num_images,/allocate)
  size_data_array = ptrarr(state.num_images,/allocate)

;run SExtractor on each image
  for moving_index=0, state.num_images-1 do begin
     phast_do_sextractor, image=image_archive[moving_index]->get_name(), flags=' -CATALOG_TYPE ASCII_HEAD -PARAMETERS_NAME moving.param',cat_name=state.phast_dir+'/output/catalogs/moving'+strtrim(string(moving_index),2)+'.cat'
     readcol, state.phast_dir+'/output/catalogs/moving'+strtrim(string(moving_index),2)+'.cat', *(x_data_array[moving_index]),*(y_data_array[moving_index]),*(size_data_array[moving_index]),skipline=3  
  endfor
  
;find objects that appear in multiple images
  thresh = 2.0 ;must be within x pixels
  size_thresh = 1.1 ;semi-major axis must be larger than x pixels
  same_array = ptrarr(state.num_images,/allocate)
  for moving_index=0, state.num_images-2 do begin ;compare successive pairs of images
     *(same_array[moving_index]) = list()
     for points_index=0, n_elements(*(x_data_array[moving_index]))-1 do begin
        match = where((abs((*(x_data_array[moving_index]))[points_index]-*(x_data_array[moving_index+1])) lt thresh and abs((*(y_data_array[moving_index]))[points_index]-*(y_data_array[moving_index+1])) lt thresh) or ((*(size_data_array[moving_index]))[points_index] lt size_thresh) ,/null)
        if  n_elements(match) ne 0 then *(same_array[moving_index]).add, points_index
     endfor
  endfor
  *(same_array[-1]) = list()
  for points_index=0, n_elements(*(x_data_array[-1]))-1 do begin
     if  n_elements(where(abs((*(x_data_array[-1]))[points_index]-*(x_data_array[-2])) lt thresh and abs((*(y_data_array[-1]))[points_index]-*(y_data_array[-2])) lt thresh or ((*(size_data_array[-1]))[points_index] lt size_thresh),/null)) ne 0 then *(same_array[-1]).add, points_index
  endfor
  
;remove these objects
  for moving_index=0, state.num_images-1 do begin
     remove,(*(same_array[moving_index]))->toarray(),*(x_data_array[moving_index]),*(y_data_array[moving_index]), *(size_data_array[moving_index])
  endfor

;eliminate points without a nearby point in the prevoius or next image
  match_thresh = 50
  iso_points_array = ptrarr(state.num_images,/allocate) ;isolated points

  ;handle first image
  (*(iso_points_array[0])) = list()
  for j=0, n_elements(*(x_data_array[0]))-1 do begin ;cycle points
     nearby = where((abs((*(x_data_array[0]))[j] - *(x_data_array[1])) lt match_thresh and abs((*(y_data_array[0]))[j] - *(y_data_array[1])) lt match_thresh),/null)
     if n_elements(nearby) eq 0 then (*(iso_points_array[0])).add, j
  endfor  
  for i=1, state.num_images-2 do begin ;cycle images
     (*(iso_points_array[i])) = list()
     for j=0, n_elements(*(x_data_array[i]))-1 do begin ;cycle points
        nearby = where((abs((*(x_data_array[i]))[j] - *(x_data_array[i-1])) lt match_thresh and abs((*(y_data_array[i]))[j] - *(y_data_array[i-1])) lt match_thresh) or (abs((*(x_data_array[i]))[j] - *(x_data_array[i+1])) lt match_thresh and abs((*(y_data_array[i]))[j] - *(y_data_array[i+1])) lt match_thresh),/null)
        if n_elements(nearby) eq 0 then (*(iso_points_array[i])).add, j
     endfor
  endfor
  ;handle last image
  (*(iso_points_array[-1])) = list()
  for j=0, n_elements(*(x_data_array[-1]))-1 do begin ;cycle points
     nearby = where((abs((*(x_data_array[-1]))[j] - *(x_data_array[-2])) lt match_thresh and abs((*(y_data_array[-1]))[j] - *(y_data_array[-2])) lt match_thresh),/null)
     if n_elements(nearby) eq 0 then (*(iso_points_array[-1])).add, j
  endfor  

  ;remove these points
  for moving_index=0, state.num_images-1 do begin
     remove,(*(iso_points_array[moving_index]))->toarray(),*(x_data_array[moving_index]),*(y_data_array[moving_index]), *(size_data_array[moving_index])
  endfor

  ;compute lines through remaining points
  min_chi = 9999
  image1_point = -9999
  image2_point = -9999
  image3_point = -9999
  for i=0, n_elements(*(x_data_array[0]))-1 do begin ;first image points
     for J=0, n_elements(*(x_data_array[1]))-1 do begin ;second image points
        for k=0, n_elements(*(x_data_array[2]))-1 do begin ;third image points
           temp = linfit([(*(x_data_array[0]))[i],(*(x_data_array[1]))[j],(*(x_data_array[2]))[k]],[(*(y_data_array[0]))[i],(*(y_data_array[1]))[j],(*(y_data_array[2]))[k]],chisq=chisq)
           if chisq lt min_chi then begin
              min_chi = chisq
              image1_point = i
              image2_point = j
              image3_point = k
           endif
        endfor
     endfor
  endfor

  ;repeat from other end of sequence
  min_chi = 9999
  imageneg1_point = -9999
  imageneg2_point = -9999
  imageneg3_point = -9999
  for i=0, n_elements(*(x_data_array[-1]))-1 do begin ;first image points
     for J=0, n_elements(*(x_data_array[-2]))-1 do begin ;second image points
        for k=0, n_elements(*(x_data_array[-3]))-1 do begin ;third image points
           temp = linfit([(*(x_data_array[-1]))[i],(*(x_data_array[-2]))[j],(*(x_data_array[-3]))[k]],[(*(y_data_array[0]))[-1],(*(y_data_array[-2]))[j],(*(y_data_array[-3]))[k]],chisq=chisq)
           if chisq lt min_chi then begin
              min_chi = chisq
              imageneg1_point = i
              imageneg2_point = j
              imageneg3_point = k
           endif
        endfor
     endfor
  endfor

  ;use only these points
  x_points = fltarr(6)
  y_points = fltarr(6)
  x_points[0] = (*(x_data_array[0]))[image1_point]
  x_points[1] = (*(x_data_array[1]))[image2_point]
  x_points[2] = (*(x_data_array[2]))[image3_point]
  x_points[3] = (*(x_data_array[-1]))[imageneg1_point]
  x_points[4] = (*(x_data_array[-2]))[imageneg2_point]
  x_points[5] = (*(x_data_array[-3]))[imageneg3_point]
  y_points[0] = (*(y_data_array[0]))[image1_point]
  y_points[1] = (*(y_data_array[1]))[image2_point]
  y_points[2] = (*(y_data_array[2]))[image3_point]
  y_points[3] = (*(y_data_array[-1]))[imageneg1_point]
  y_points[4] = (*(y_data_array[-2]))[imageneg2_point]
  y_points[5] = (*(y_data_array[-3]))[imageneg3_point]



  ;plot detections
  colors= ['blue','green','red','yellow', 'cyan']
  colorcode = colors[1]
  circlesize = 7   &  circletext = strtrim(string(circlesize))
  fontsize = 1.75  &    fonttext = strtrim(string(fontsize))
  for i = 0, 5 do begin
     if nplot lt maxplot then begin
        nplot++
        region_str = 'circle('+strtrim(string(x_points[i]),2)+', '+strtrim(string(y_points[i]),2)+', ' $
                     + circletext + ') # color=' + colorcode
        
           options = {color:colorcode,thick:fonttext}
           options.color = phast_icolor(options.color)
           pstruct = {type:'region',reg_array:[region_str],options:options}
           plot_ptr[nplot] =ptr_new(pstruct)
           phast_plotwindow
           phast_plot1region,nplot
        endif
  endfor
end

;----------------------------------------------------------------------

pro phast_do_all

  ;routine to automatically process an image through the entire pipeline

  common phast_state
  common phast_images
  
  widget_control, /hourglass
  
  ;run SExtractor
  ;spawn, 'sex ' + state.imagename + ' -CATALOG_NAME phast.cat'
  phast_do_sextractor, cat_name = 'phast.cat'
  
  ;run Scamp
  ;spawn, 'scamp phast.cat'
  phast_do_scamp,cat_name = 'phast.cat'
  
  ;write astrometric solution to calibrated image
  ;spawn,'missfits phast.fits -SAVE_TYPE REPLACE'
  phast_do_missfits, image = 'phast.fits', flags = '-SAVE_TYPE REPLACE'
  
  ;find zero-point
  phast_calculate_zeropoint, msgarr
  
  ;report finished
  result = dialog_message('Done!              ',/center,/information)
end

;----------------------------------------------------------------------

pro phast_do_batch

  ;routine to batch process images.  Loads images from a give directory
  ;and passes them sequentially through the pipeline of processing tools

  common phast_state
  common phast_images
  
  widget_control,/hourglass
  tic
  case state.batch_source of
    0: begin
      num_files = state.num_images
      filelist = strarr(num_files)
      for i=0, num_files-1 do filelist[i] = image_archive[i]->get_name()
    end
    1: filelist = findfile(state.batch_dirname+'*.fits',count=num_files)
    2: begin
       filelist = image_archive[state.current_image_index]->get_name()
       num_files = 1
    end
    3: begin
       filelist = state.batch_imagename
       num_files = 1
    end
 endcase
  
  progress_bar = obj_new('cgprogressbar',title='Processing images',/start)
  for i=0,num_files-1 do begin
     mosaic = 0
     fits_info, filelist[i],n_ext=ext_count,/silent
     if ext_count gt 0 and state.batch_mef_toggle eq 1 then mosaic = 1
    ; fits_read,filelist[i],cal_science,cal_science_head
     split = strsplit(filelist[i],'/\.',count=count,/extract)
     state.cal_file_name = state.phast_dir+'/output/images/'+split[count-2]+'.'+split[count-1]
     
     file_exists = file_test(state.cal_file_name)
     if file_exists eq 1 then begin
        answer = dialog_message('File ' + state.cal_file_name + ' already exists! Overwrite this file?',/question,/center)
        if answer eq 'Yes' then begin
           spawn, 'rm ' + state.cal_file_name
        endif else goto, batch_skip_image
     endif
     phast_calibrate, input_file=filelist[i],output_file=state.cal_file_name,mosaic=mosaic
     
     progress_bar->update,float(i+1)/num_files*100*(.25)
     if state.astrometry_toggle ne 0 then begin
        phast_do_sextractor,image = state.cal_file_name,cat_name=state.phast_dir+'/output/images/'+split[count-2]+'.cat'
        progress_bar->update,float(i+1)/num_files*100*(.50)
        phast_do_scamp,cat_name=state.phast_dir+'/output/images/'+split[count-2]+'.cat'
        phast_do_missfits, image = state.cal_file_name, flags = state.missfits_flags+' -SAVE_TYPE REPLACE'
        if mosaic eq 1 then phast_do_swarp,image=state.cal_file_name
        progress_bar->update,float(i+1)/num_files*100*(.75)
        ;compute zero-point
        phast_calculate_zeropoint,state.cal_file_name,msgerr,external=external
     endif
     batch_skip_image:
     progress_bar->update,float(i+1)/num_files*100
  endfor
  progress_bar->destroy
  toc
end

;----------------------------------------------------------------------

pro phast_do_missfits,image = image, flags = flags

  ;routine to use missFITS to write a SCAMP header to the main FITS file

  common phast_state
  
  if not keyword_set(flags) then flags = ''
  if not keyword_set(image) then image = state.imagename

  cd, state.phast_dir
  spawn,'missfits ' + image + ' ' + flags
  cd, state.launch_dir
end

;----------------------------------------------------------------------

pro phast_do_scamp, cat_name = cat_name, flags = flags

  ;routine to call external package SCAMP to generate an astrometric solution from a given SExtractor catalog

  common phast_state
  
  if not keyword_set(cat_name) then cat_name = state.scamp_catalog_name
  if not keyword_set(flags) then flags = ''
  
  cd, state.phast_dir
  spawn, 'scamp ' + cat_name + flags
  cd, state.launch_dir
end

;----------------------------------------------------------------------

pro phast_do_sextractor,image = image, flags = flags, cat_name = cat_name

  ;routine to call external package SExtractor to find sources in the image.

  common phast_state
  common phast_images
  
  if not keyword_set(image) then image = state.imagename
  if not keyword_set(flags) then flags = state.sex_flags
  if not keyword_set(cat_name) then cat_name = state.sex_catalog_name
  
  cd, state.phast_dir
  spawn, 'sex ' + image + ' ' + flags +  ' -CATALOG_NAME ' + cat_name
  cd, state.launch_dir
end

;----------------------------------------------------------------------

pro phast_do_swarp,image = image, flags = flags

  ;routine to stitch together a mosaic using the external package SWarp

  common phast_state
  common phast_images
  
  if not keyword_set(image) then image = state.imagename
  if not keyword_set(flags) then flags = state.swarp_flags
  
  cd, state.phast_dir
  spawn, 'swarp ' + image + ' ' + flags + ' -IMAGEOUT_NAME ' + state.phast_dir+'/output/images/coadd.fits'
  spawn, 'mv '+  state.phast_dir+'/output/images/coadd.fits' + ' ' + image
  cd, state.launch_dir
end

;----------------------------------------------------------------------

pro phast_missfits

  ;routine to run missFITS to combine a header with a FITS image

  common phast_state
  
  if (not (xregistered('phast_missfits', /noshow))) then begin
  
    missfits_base = $
      widget_base(/base_align_left, $
      group_leader = state.base_id, $
      /column, $
      title = 'missFITS interface', $
      uvalue = 'apphot_base',xsize = 500)
    desc_label = widget_label(missfits_base,value='Combine a header with a FITS image,')
    temp_base = widget_base(missfits_base,/row)
    cat_select = widget_button(temp_base,value='Choose image',uvalue='image_select')
    image_name = widget_label(temp_base,value='No image loaded',/dynamic_resize)
    temp2_base = widget_base(missfits_base,/row)
    flags_label = widget_label(temp2_base,value='Flags:')
    state.missfits_flags_widget_id = widget_text(temp2_base,value=state.missfits_flags,uvalue='flags',xsize=50,/editable,/all_events)
    buttonbox = widget_base(missfits_base,/row)
    start_scamp = widget_button(buttonbox,value='Start', uvalue='start_missfits')
    done = widget_button(buttonbox,value='Done',uvalue='done')
    
    state.missfits_image_widget_id = image_name
    widget_control, missfits_base, /realize
    
    xmanager, 'phast_missfits', missfits_base, /no_block
    
    phast_resetwindow
  endif
end

;----------------------------------------------------------------------

pro phast_missfits_event,event

  common phast_state
  
  widget_control, event.id, get_uvalue = uvalue
  
  case uvalue of
    'image_select': begin
      state.missfits_image_name = dialog_pickfile(filter='*.fits',/must_exist,$
        path=state.sex_catalog_path)
      widget_control,state.missfits_image_widget_id,set_value=state.missfits_image_name
    end
    'flags': begin
      widget_control,state.missfits_flags_widget_id,get_value=value
      state.missfits_flags = value
    end
    'start_missfits':phast_do_missfits,image=state.missfits_image_name,flags=state.missfits_flags
    'done':widget_control,event.top,/destroy
    
    
  endcase
end

;----------------------------------------------------------------------

pro phast_scamp

  ;routine to run SCAMP on a given catalog

  common phast_state
  
  if (not (xregistered('phast_scamp', /noshow))) then begin
  
    scamp_base = $
      widget_base(/base_align_left, $
      group_leader = state.base_id, $
      /column, $
      title = 'SCAMP interface', $
      uvalue = 'apphot_base',xsize = 500)
    desc_label = widget_label(scamp_base,value='Analyze a catalog generated by SExtractor')
    desc_label2 = widget_label(scamp_base, value= 'The file scamp.conf must be in the local directory.')
    temp_base = widget_base(scamp_base,/row)
    cat_select = widget_button(temp_base,value='Choose catalog',uvalue='cat_select')
    cat_name = widget_label(temp_base,value='No catalog loaded',/dynamic_resize)
    temp2_base = widget_base(scamp_base,/row)
    flags_label = widget_label(temp2_base,value='Flags:')
    state.scamp_flags_widget_id = widget_text(temp2_base,value=state.scamp_flags,uvalue='flags',xsize=50,/editable,/all_events)
    buttonbox = widget_base(scamp_base,/row)
    start_scamp = widget_button(buttonbox,value='Start', uvalue='start_scamp')
    done = widget_button(buttonbox,value='Done',uvalue='done')
    
    state.scamp_cat_widget_id = cat_name
    widget_control, scamp_base, /realize
    
    xmanager, 'phast_scamp', scamp_base, /no_block
    
    phast_resetwindow
  endif
end

;----------------------------------------------------------------------

pro phast_scamp_event, event

  common phast_state
  
  widget_control, event.id, get_uvalue = uvalue  
  
  case uvalue of
    'start_scamp': begin
      phast_do_scamp
      widget_control, event.top, /destroy
    end
    'cat_select': begin
      ;print,state.sex_catalog_path
      state.scamp_catalog_name = dialog_pickfile(filter='*.cat',/must_exist,$
        path=state.sex_catalog_path)
      widget_control,state.scamp_cat_widget_id, set_value =  state.scamp_catalog_name
      
    end
    'flags': begin
      widget_control,state.scamp_flags_widget_id,get_value=value
      state.scamp_flags = value
    end
    'done':widget_control,event.top,/destroy
    
  endcase
end

;----------------------------------------------------

pro phast_sextractor

  common phast_state
  
  state.cursorpos = state.coord
  
  if (not (xregistered('phast_sextractor', /noshow))) then begin
  
    sex_base = $
      widget_base(/base_align_left, $
      group_leader = state.base_id, $
      /column, $
      title = 'SExtractor interface', $
      uvalue = 'apphot_base',xsize = 500)
    desc_label = widget_label(sex_base,value='Pass the current image to SExtractor for analysis and catalog creation.')
    desc_label2 = widget_label(sex_base, value= 'The files default.sex, default.conv, and default.param must be in the local dir.')
    temp_base = widget_base(sex_base,/row)
    file_label = widget_label(temp_base, value='Filename:')
    file_name = widget_label(temp_base,value=state.imagename)
    temp2_base = widget_base(sex_base,/row)
    cat_label = widget_label(temp2_base,value='Catalog name:')
    cat_name = widget_text(temp2_base,value=state.sex_catalog_path+'test.cat',uvalue='cat_name',/editable,/all_events)
    temp3_base = widget_base(sex_base,/row)
    flags_label = widget_label(temp3_base,value='Flags:')
    flags = widget_text(temp3_base,value=state.sex_flags,uvalue='flags',xsize=50,/editable,/all_events)
    
    buttonbox = widget_base(sex_base,/row)
    start_sextractor = widget_button(buttonbox,value='Start', uvalue='start_sex')
    done = widget_button(buttonbox,value='Done',uvalue='done')
    
    state.sex_cat_widget_id = cat_name
    state.sex_flags_widget_id = flags
    widget_control, sex_base, /realize
    
    xmanager, 'phast_sextractor', sex_base, /no_block
    
    phast_resetwindow
  endif
end

;----------------------------------------------------------------------

pro phast_sextractor_event, event

  common phast_state
  common phast_images
  
  widget_control, event.id, get_uvalue = uvalue
  
  case uvalue of
    'start_sex': begin
      phast_do_sextractor
      widget_control, event.top, /destroy
    end
    'cat_name': begin
      widget_control,state.sex_cat_widget_id, get_value =  value
      state.sex_catalog_name = value
    end
    'flags': begin
      widget_control,state.sex_flags_widget_id,get_value=value
      state.sex_flags = value
    end
    'done': widget_control,event.top,/destroy
    
  endcase
end

;----------------------------------------------------------------------

pro phast_zeropoint

  ;front end for photometric zeropoint calculation

  common phast_state
  
  if (not (xregistered('phast_missfits', /noshow))) then begin
  
    zero_base = $
      widget_base(/base_align_left, $
      group_leader = state.base_id, $
      /column, $
      title = 'Photometric Zero-point', $
      uvalue = 'apphot_base',xsize=450)
    desc_label = widget_label(zero_base,value='Calculate a photometric zero-point')
    ;     temp_base = widget_base(zero_base,/row)
    ;     cat_select = widget_button(temp_base,value='Choose image',uvalue='image_select')
    ;     image_name = widget_label(temp_base,value='No image loaded',/dynamic_resize)
    ;temp2_base = widget_base(missfits_base,/row)
    ;flags_label = widget_label(temp2_base,value='Flags:')
    ;state.missfits_flags_widget_id = widget_text(temp2_base,value=state.missfits_flags,uvalue='flags',xsize=50,/editable,/all_events)
    buttonbox = widget_base(zero_base,/row)
    start_scamp = widget_button(buttonbox,value='Start', uvalue='start_zeropoint')
    done = widget_button(buttonbox,value='Done',uvalue='done')
    
    ; state.zeropoint_image_widget_id = image_name
    widget_control, zero_base, /realize
    
    xmanager, 'phast_zeropoint', zero_base, /no_block
    
    phast_resetwindow
  endif
end

;----------------------------------------------------------------------

pro phast_zeropoint_event, event

  ;event handler for phast_zeropoint

  common phast_state
  
  widget_control, event.id, get_uvalue = uvalue
  
  case uvalue of
    'image_select': begin
      state.zeropoint_image_name = dialog_pickfile(filter='*.fits',/must_exist,$
        path=state.sex_catalog_path)
      widget_control,state.zeropoint_image_widget_id,set_value=state.zeropoint_image_name
    end
    'start_zeropoint':begin
    phast_calculate_zeropoint, state.imagename,msgarr
    result = dialog_message(msgarr,/center,/information)
  end
  'done':widget_control,event.top,/destroy
endcase
end

;----------------------------------------------------------------------

pro phast_pipeline

;for compilation purposes only

end
