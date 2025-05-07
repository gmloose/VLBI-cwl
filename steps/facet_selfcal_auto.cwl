cwlVersion: v1.2
class: CommandLineTool
id: facet_selfcal_international
label: Facetselfcal International phase-up
doc: |
       Performs direction dependent calibration of the international antenna
       array with facetselfcal on small phased-up MeasurementSet.

baseCommand:
    - python3

inputs:
    - id: msin
      type: Directory
      doc: Input MeasurementSet.
      inputBinding:
        position: 6

    - id: skymodel
      type: File?
      doc: The skymodel to be used in the first cycle in the self-calibration.
      inputBinding:
        prefix: "--skymodel"
        position: 2
        itemSeparator: " "
        separate: true

    - id: configfile
      type: File
      doc: A plain-text file containing configuration options for self-calibration.
      inputBinding:
        prefix: "--configpath"
        position: 3
        itemSeparator: " "
        separate: true

    - id: dde_directions
      type: File?
      doc: A text file with directions for DDE calibration with facetselfcal
      inputBinding:
        prefix: "--facetdirection"
        position: 4
        itemSeparator: " "
        separate: true

    - id: facetselfcal
      type: Directory
      doc: External self-calibration script.

outputs:
    - id: h5_facetselfcal
      type: File
      outputBinding:
        glob: 'best_addCS_solutions.h5'
      doc: The best merged calibration solution files generated in HDF5 format, selected during self-calibration.

    - id: selfcal_images
      type: File[]
      outputBinding:
         glob: 'ILTJ*.png'
      doc: Selfcal PNG images for quick inspection.

    - id: solution_inspection_images
      type: Directory[]
      outputBinding:
         glob: 'plotlosoto*'
      doc: Solution inspection plots

    - id: fits_image
      type: File
      outputBinding:
         glob: 'best_*MFS-image.fits'
      doc: Best selfcal FITS image

    - id: logfile
      type: File[]
      outputBinding:
         glob: [facet_selfcal*.log, selfcal.log]
      doc: |
        The files containing the stdout
        and stderr from the step.

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.msin)
      - entry: $(inputs.configfile)

arguments:
  - $( inputs.facetselfcal.path + '/facetselfcal.py' )

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl
  - class: ResourceRequirement
    coresMin: 12

stdout: facet_selfcal.log
stderr: facet_selfcal_err.log
