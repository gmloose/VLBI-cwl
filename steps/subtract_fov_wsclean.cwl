class: CommandLineTool
cwlVersion: v1.2
id: subtract_with_wsclean
label: Subtract with WSClean
doc: This step uses WSClean to subtract visibilities corresponding to model images.

baseCommand: python3

inputs:
  - id: msin
    type: Directory
    doc: MeasurementSet for source subtraction.
    inputBinding:
      prefix: "--mslist"
      position: 1

  - id: model_image_folder
    type: Directory
    doc: Directory containing 1.2" (or optionally other resolution) model images.
    inputBinding:
      prefix: "--model_image_folder"
      position: 2

  - id: facet_regions
    type: File
    doc: The DS9 region file that defines the facets for prediction.
    inputBinding:
      prefix: "--facets_predict"
      position: 3

  - id: h5parm
    type: File
    doc: The HDF5 solution file containing the solutions for prediction.
    inputBinding:
      prefix: "--h5parm_predict"
      position: 4

  - id: lofar_helpers
    type: Directory
    doc: LOFAR helpers directory.

  - id: scratch
    type: boolean?
    default: false
    inputBinding:
      prefix: "--scratch_toil"
      position: 5
      separate: false
    doc: |
      Whether you want the subtract step to copy data to local scratch space from your running node.
      If 'scratch' is set to 'true', ensure that there is sufficient scratch storage space on the running nodes
      (at least 1 TB per 15 cores).

outputs:
  - id: logfile
    type: File[]
    doc: Log files from current step.
    outputBinding:
      glob: subtract_fov*.log
  - id: subtracted_ms
    type: Directory
    doc: MS subtracted data
    outputBinding:
      glob: subfov_*.ms


arguments:
  - $( inputs.lofar_helpers.path + '/subtract/subtract_with_wsclean.py' )

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.msin)
      - entry: $(inputs.model_image_folder)
        writable: true
      - entry: $(inputs.facet_regions)
      - entry: $(inputs.h5parm)

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl
  - class: ResourceRequirement
    coresMin: 15

stdout: subtract_fov.log
stderr: subtract_fov_err.log