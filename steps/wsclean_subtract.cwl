class: Workflow
cwlVersion: v1.2
id: imaging_subtract
label: Imaging subtract
doc: |
    Make fits image from subtracted MS at 20".

baseCommand:
  - DP3

inputs:
  - id: msin
    type: Directory
    doc: |
        Input data in MeasurementSets after subtract and averaging and removing international stations

outputs:
  - id: subtr_fits
    doc: |
        Output image with subtracted FoV
    type: File
    outputBinding:
      glob: *image.fits

  - id: logfile
    type: File[]
    outputBinding:
      glob: imaging_subtract*.log
    doc: |
        The files containing the stdout
        and stderr from the step.

arguments:
  - -scale 3arcsec
  - -taper-gaussian 20arcsec
  - -no-update-model-required
  - -minuv-l 80
  - -size 6000 6000
  - -reorder
  - -weight briggs -0.5
  - -parallel-reordering 4
  - -mgain 0.75
  - -data-column DATA
  - -auto-mask 2.5
  - -auto-threshold 0.5
  - -pol i
  - -gridder wgridder
  - -name subtracted_fov
  - -nmiter 10
  - -niter 100000
  - -maxuv-l 20e3
  - $(inputs.msin.path)

requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.msin)
        writable: true
  - class: ResourceRequirement
    coresMin: 6

stdout: imaging_subtract.log
stderr: imaging_subtract.log
