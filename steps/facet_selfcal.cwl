class: CommandLineTool
cwlVersion: v1.2
id: facet_selfcal
label: facet_selfcal
inputs:
  - id: msin
    type: Directory[]
    doc: Input measurement sets
    inputBinding:
      position: 1
  - id: boxfile
    type: File?
    inputBinding:
      position: 0
      prefix: --boxfile=
      separate: false
      shellQuote: false
  - id: imsize
    type: int?
    default: 1600
    inputBinding:
      position: 0
      prefix: --imsize=
      separate: false
      shellQuote: false
  - id: pixelscale
    type: float?
    default: 0.075
    inputBinding:
      position: 0
      prefix: --pixelscale=
      separate: false
      shellQuote: false
  - id: imagename
    type: string?
    inputBinding:
      position: 0
      prefix: --imagename=
      separate: false
      shellQuote: false
  - id: fitsmask
    type: File?
    inputBinding:
      position: 0
      prefix: --fitsmask=
      separate: false
      shellQuote: false
  - id: niter
    type: int?
    inputBinding:
      position: 0
      prefix: --niter=
      separate: false
      shellQuote: false
  - id: robust
    type: float?
    default: -0.5
    inputBinding:
      position: 0
      prefix: --robust=
      separate: false
      shellQuote: false
  - id: channelsout
    type: int?
    inputBinding:
      position: 0
      prefix: --channelsout=
      separate: false
      shellQuote: false
  - id: multiscale
    type: boolean?
    default: false
    inputBinding:
      position: 0
      prefix: --multiscale
  - id: multiscale-start
    type: int?
    inputBinding:
      position: 0
      prefix: --multiscale-start=
      separate: false
      shellQuote: false
  - id: multiscalescalebias
    type: float?
    inputBinding:
      position: 0
      prefix: --multiscalescalebias=
      separate: false
      shellQuote: false
  - id: deepmultiscale
    type: boolean?
    inputBinding:
      position: 0
      prefix: --deepmultiscale
  - id: uvminim
    type: float?
    inputBinding:
      position: 0
      prefix: --uvminim=
      separate: false
      shellQuote: false
  - id: usewgridder
    type: boolean?
    default: True
    inputBinding:
      position: 0
      prefix: --usewgridder=True
  - id: phaseupstations
    type: string?
    default: 'core'
    inputBinding:
      position: 0
      prefix: --phaseupstations=
      separate: false
      shellQuote: false
  - id: phaseshiftbox
    type: File?
    inputBinding:
      position: 0
      prefix: --phaseshiftbox=
  - id: paralleldeconvolution
    type: int?
    inputBinding:
      position: 0
      prefix: --paralleldeconvolution=
      separate: false
      shellQuote: false
  - id: parallelgridding
    type: int?
    inputBinding:
      position: 0
      prefix: --parallelgridding=
      separate: false
      shellQuote: false
  - id: deconvolutionchannels
    type: int?
    inputBinding:
      position: 0
      prefix: --deconvolutionchannels=
      separate: false
      shellQuote: false
  - id: idg
    type: boolean?
    inputBinding:
      position: 0
      prefix: --idg
  - id: maskthreshold
    type: float[]?
    default:
      - 7.0
    inputBinding:
      position: 0
      prefix: --maskthreshold=
      separate: false
      shellQuote: false
      valueFrom: "[$(self.join(','))]"
  - id: imager
    type: string?
    inputBinding:
      position: 0
      prefix: --imager=
      separate: false
      shellQuote: false
  - id: fitspectralpol
    type: boolean?
    default: True
    inputBinding:
      position: 0
      prefix: --fitspectralpol=True
      separate: false
      shellQuote: false
  - id: fitspectralpolorder
    type: int?
    inputBinding:
      position: 0
      prefix: --fitspectralpolorder
      separate: false
      shellQuote: false
  - id: taperinnertukey
    type: float?
    inputBinding:
      position: 0
      prefix: --taperinnertukey=
      separate: false
      shellQuote: false
  - id: removenegativefrommodel
    type: boolean?
    default: True
    inputBinding:
      position: 0
      prefix: --removenegativefrommodel=True
  - id: autoupdate-removenegativefrommodel
    type: boolean?
    default: True
    inputBinding:
      position: 0
      prefix: --autoupdate-removenegativefrommodel=True
  - id: autofrequencyaverage
    type: boolean?
    inputBinding:
      position: 0
      prefix: --autofrequencyaverage
  - id: autofrequencyaverage-calspeedup
    type: boolean?
    inputBinding:
      position: 0
      prefix: --autofrequencyaverage-calspeedup
  - id: avgfreqstep
    type: int?
    inputBinding:
      position: 0
      prefix: --avgfreqstep=
      separate: false
      shellQuote: false
  - id: avgtimestep
    type: int?
    inputBinding:
      position: 0
      prefix: --avgtimestep=
      separate: false
      shellQuote: false
  - id: msinnchan
    type: int?
    inputBinding:
      position: 0
      prefix: --msinnchan=
      separate: false
      shellQuote: false
  - id: msinntimes
    type: int?
    inputBinding:
      position: 0
      prefix: --msinntimes=
      separate: false
      shellQuote: false
  - id: weightspectrum-clipvalue
    type: float?
    inputBinding:
      position: 0
      prefix: --weightspectrum-clipvalue=
      separate: false
      shellQuote: false
  - id: --uvmin
    type: float?
    default: 40000.0
    inputBinding:
      position: 0
      prefix: --uvmin=
      separate: false
      shellQuote: false
  - id: uvminscalarphasediff
    type: float?
    inputBinding:
      position: 0
      prefix: --uvminscalarphasediff=
      separate: false
      shellQuote: false
  - id: update-uvmin
    type: boolean?
    inputBinding:
      position: 0
      prefix: --update-uvmin=
  - id: update-multiscale
    type: boolean?
    inputBinding:
      position: 0
      prefix: --update-multiscale=
  - id: soltype-list
    type: string[]?
    default:
      - "\"scalarphasediff\""
      - "\"scalarphase\""
      - "\"scalarcomplexgain\""
    inputBinding:
      position: 0
      prefix: --soltype-list=
      separate: false
      shellQuote: false
      valueFrom: "[$(self.join(','))]"
  - id: solint-list
    type: int[]?
    default:
      - 4
      - 1
      - 100
    inputBinding:
      position: 0
      prefix: --solint-list=
      separate: false
      shellQuote: false
      valueFrom: "[$(self.join(','))]"
  - id: nchan-list
    type: int[]?
    default:
      - 1
      - 1
      - 1
    inputBinding:
      position: 0
      prefix: --nchan-list=
      separate: false
      shellQuote: false
      valueFrom: "[$(self.join(','))]"
  - id: smoothnessconstraint-list
    type: float[]?
    default:
      - 10.0
      - 2.0
      - 10.0
    inputBinding:
      position: 0
      prefix: --smoothnessconstraint-list=
      separate: false
      shellQuote: false
      valueFrom: "[$(self.join(','))]"
  - id: smoothnessreffrequency-list
    type: float[]?
    inputBinding:
      position: 0
      prefix: --smoothnessreffrequency-list=
      separate: false
      shellQuote: false
      valueFrom: "[$(self.join(','))]"
  - id: smoothnessspectralexponent-list
    type: float[]?
    inputBinding:
      position: 0
      prefix: --smoothnessspectralexponent-list=
      separate: false
      shellQuote: false
      valueFrom: "[$(self.join(','))]"
  - id: smoothnessrefdistance-list
    type: float[]?
    inputBinding:
      position: 0
      prefix: --smoothnessrefdistance-list=
      separate: false
      shellQuote: false
      valueFrom: "[$(self.join(','))]"
  - id: antennaconstraint-list
    type: string[]?
    default:
      - "\"alldutch\""
      - None
      - None
    inputBinding:
      position: 0
      prefix: --antennaconstraint-list=
      separate: false
      shellQuote: false
      valueFrom: "[$(self.join(','))]"
  - id: resetsols-list
    type: float[]?
    inputBinding:
      position: 0
      prefix: --resetsols-list=
      separate: false
      shellQuote: false
  - id: soltypecycles-list
    type: int[]?
    default:
      - 0
      - 0
      - 2
    inputBinding:
      position: 0
      prefix: --soltypecycles-list=
      separate: false
      shellQuote: false
      valueFrom: "[$(self.join(','))]"
  - id: BLsmooth
    type: boolean?
    inputBinding:
      position: 0
      prefix: --BLsmooth
  - id: iontimefactor
    type: float?
    inputBinding:
      position: 0
      prefix: --iontimefactor=
      separate: false
      shellQuote: false
  - id: ionfreqfactor
    type: float?
    inputBinding:
      position: 0
      prefix: --ionfreqfactor=
      separate: false
      shellQuote: false
  - id: blscalefactor
    type: float?
    inputBinding:
      position: 0
      prefix: --blscalefactor=
      separate: false
      shellQuote: false
  - id: dejumpFR
    type: boolean?
    inputBinding:
      position: 0
      prefix: --dejumpFR
  - id: usemodeldataforsolints
    type: boolean?
    inputBinding:
      position: 0
      prefix: --usemodeldataforsolints=
  - id: tecfactorsolint
    type: float?
    inputBinding:
      position: 0
      prefix: --tecfactorsolint=
      separate: false
      shellQuote: false
  - id: gainfactorsolint
    type: float?
    inputBinding:
      position: 0
      prefix: --gainfactorsolint=
      separate: false
      shellQuote: false
  - id: phasefactorsolint
    type: float?
    inputBinding:
      position: 0
      prefix: --phasefactorsolint=
      separate: false
      shellQuote: false
  - id: preapplyH5-list
    type: File[]?
    inputBinding:
      position: 0
      prefix: --preapplyH5-list=
      separate: false
      shellQuote: false
  - id: skymodel
    type: File?
    inputBinding:
      position: 0
      prefix: --skymodel=
      separate: false
      shellQuote: false
  - id: skymodelsource
    type: string?
    inputBinding:
      position: 0
      prefix: --skymodelsource=
      separate: false
      shellQuote: false
  - id: skymodelpointsource
    type: float?
    inputBinding:
      position: 0
      prefix: --skymodelpointsource=
      separate: false
      shellQuote: false
  - id: wscleanskymodel
    type: File?
    inputBinding:
      position: 0
      prefix: --wscleanskymodel=
      separate: false
      shellQuote: false
  - id: predictskywithbeam
    type: boolean?
    inputBinding:
      position: 0
      prefix: --predictskywithbeam
  - id: startfromtgss
    type: boolean?
    inputBinding:
      position: 0
      prefix: --startfromtgss
  - id: tgssfitsimage
    type: File?
    inputBinding:
      position: 0
      prefix: --tgssfitsimage=
      separate: false
      shellQuote: false
  - id: no-beamcor
    type: boolean?
    default: True
    inputBinding:
      position: 0
      prefix: --no-beamcor
  - id: losotobeamcor-beamlib
    type: string?
    inputBinding:
      position: 0
      prefix: --losotobeamcor-beamlib=
      separate: false
      shellQuote: false
  - id: docircular
    type: boolean?
    default: True
    inputBinding:
      position: 0
      prefix: --docircular
  - id: dolinear
    type: boolean?
    inputBinding:
      position: 0
      prefix: --dolinear
  - id: forwidefield
    default: True
    type: boolean?
    inputBinding:
      position: 0
      prefix: --forwidefield
  - id: doflagging
    type: boolean?
    default: True
    inputBinding:
      position: 0
      prefix: --doflagging=True
  - id: dysco
    type: boolean?
    default: True
    inputBinding:
      position: 0
      prefix: --dysco=True
      separate: false
      shellQuote: false
  - id: restoreflags
    type: boolean?
    inputBinding:
      position: 0
      prefix: --restoreflags
  - id: remove-flagged-from-startend
    type: boolean?
    inputBinding:
      position: 0
      prefix: --remove-flagged-from-startend
  - id: flagslowamprms
    type: float?
    inputBinding:
      position: 0
      prefix: --flagslowamprms=
      separate: false
      shellQuote: false
  - id: flagslowphaserms
    type: float?
    inputBinding:
      position: 0
      prefix: --flagslowphaserms=
      separate: false
      shellQuote: false
  - id: doflagslowphases
    type: boolean?
    default: True
    inputBinding:
      position: 0
      prefix: --doflagslowphases=True
  - id: useaoflagger
    type: boolean?
    inputBinding:
      position: 0
      prefix: --useaoflagger
  - id: useaoflaggerbeforeavg
    type: boolean?
    default: True
    inputBinding:
      position: 0
      prefix: --useaoflaggerbeforeavg=True
  - id: normamps
    type: boolean?
    default: True
    inputBinding:
      position: 0
      prefix: --normamps=True
  - id: normampsskymodel
    type: boolean?
    default: False
    inputBinding:
      position: 0
      prefix: --normampsskymodel=True
  - id: resetweights
    type: boolean?
    inputBinding:
      position: 0
      prefix: --resetweights
  - id: start
    type: int?
    inputBinding:
      position: 0
      prefix: --start=
      separate: false
      shellQuote: false
  - id: stop
    type: int?
    default: 10
    inputBinding:
      position: 0
      prefix: --stop=
      separate: false
      shellQuote: false
  - id: stopafterskysolve
    type: boolean?
    inputBinding:
      position: 0
      prefix: --stopafterskysolve
  - id: noarchive
    type: boolean?
    inputBinding:
      position: 0
      prefix: --noarchive
  - id: skipbackup
    type: boolean?
    default: True
    inputBinding:
      position: 0
      prefix: --skipbackup
  - id: helperscriptspath
    type: Directory
    inputBinding:
      position: 0
      prefix: --helperscriptspath=
      separate: false
      shellQuote: false
  - id: helperscriptspathh5merge
    type: Directory
    inputBinding:
      position: 0
      prefix: --helperscriptspathh5merge=
      separate: false
      shellQuote: false
  - id: auto
    type: boolean?
    inputBinding:
      position: 0
      prefix: --auto
  - id: delaycal
    type: boolean?
    inputBinding:
      position: 0
      prefix: --delaycal
  - id: targetcalILT
    type: string?
    inputBinding:
      position: 0
      prefix: --targetcalILT=
      separate: false
      shellQuote: false
  - id: makeimage-ILTlowres-HBA
    type: boolean?
    inputBinding:
      position: 0
      prefix: --makeimage-ILTlowres-HBA
  - id: makeimage-fullpol
    type: boolean?
    inputBinding:
      position: 0
      prefix: --makeimage-fullpol
  - id: blsmooth_chunking_size
    type: int?
    inputBinding:
      position: 0
      prefix: --blsmooth_chunking_size=
      separate: false
      shellQuote: false
outputs:
  - id: output_plots
    type: Directory[]
    outputBinding:
      glob: 'plotlosoto*'
  - id: solutions
    type: File[]
    outputBinding:
      glob: '*.h5'
  - id: fits_images
    type: File[]
    outputBinding:
      glob: '*.fits'
  - id: png_images
    type: File[]
    outputBinding:
      glob: '*.png'
  - id: logfile
    type: File
    outputBinding:
      glob: 'selfcal.log'
baseCommand:
  - python3
  - /home/alex/VLBI_BusyWeek/facetselfcal.py
requirements:
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.msin)
        writable: false
      - entry: $(inputs.helperscriptspath)
        writable: false
  - class: InlineJavascriptRequirement
stdout: facet_selfcal.log
stderr: facet_selfcal_err.log