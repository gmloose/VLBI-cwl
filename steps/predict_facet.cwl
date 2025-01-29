class: CommandLineTool
cwlVersion: v1.2
id: predict_facet
label: Predict with WSClean
doc: Uses WSClean to predict sources within a facet and adds the predicted visibilities to the input data.


baseCommand: python3

inputs:
  - id: subtracted_ms
    type: Directory
    doc: MeasurementSet.
    inputBinding:
      prefix: "--mslist"
      position: 1

  - id: model_image_folder
    type: Directory
    doc: Folder containing 1.2" model images.
    inputBinding:
      prefix: "--model_image_folder"
      position: 2

  - id: polygon_region
    type: File
    doc: DS9 region file with facets for prediction.
    inputBinding:
      prefix: "--region"
      position: 3

  - id: h5parm
    type: File
    doc: HDF5 file containing the solutions for prediction.
    inputBinding:
      prefix: "--h5parm_predict"
      position: 4

  - id: lofar_helpers
    type: Directory
    doc: LOFAR helpers directory.

  - id: polygon_info
    type: File
    doc: CSV with polygon information (RA/DEC of calibrator and facet centres and averaging factor)

  - id: scratch
    type: boolean?
    default: false
    doc: Run job on scratch.
    inputBinding:
      prefix: "--scratch_toil"
      position: 5
      separate: false

outputs:
  - id: logfile
    type: File[]
    doc: Log files from current step.
    outputBinding:
      glob: predict_facet*.log
  - id: facet_ms
    type: Directory
    doc: MS subtracted data
    outputBinding:
      glob: facet*.ms


arguments:
  - $( inputs.lofar_helpers.path + '/subtract/subtract_with_wsclean.py' )
  - --applybeam
  - --applycal
  - --forwidefield
  - --inverse
  - --speedup_facet_subtract

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.subtracted_ms)
      - entry: $(inputs.model_image_folder)
        writable: true
      - entry: $(inputs.polygon_region)
      - entry: $(inputs.h5parm)
      - entry: $(inputs.polygon_info)

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl
  - class: ResourceRequirement
    coresMin: 15

stdout: predict_facet.log
stderr: predict_facet_err.log