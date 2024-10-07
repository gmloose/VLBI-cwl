class: Workflow
cwlVersion: v1.2
id: facet_subtract
label: Facet subtraction
doc: |
  This workflow employs wsclean predicts to split all facets into separate measurement sets,
  before an optional calibration refinement and final imaging. Note that it is highly recommended
  to run this on an HPC cluster with toil-cwl-runner and to use the scratch option
  (see documentation 'scratch' parameter below).

requirements:
  - class: MultipleInputFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement

inputs:
    - id: msin
      type: Directory[]
      doc: Unaveraged MeasurementSets with coverage of the target directions.
    - id: model_image_folder
      type: Directory
      doc: Folder with 1.2" model images
    - id: h5parm
      type: File
      doc: Merged h5parms
    - id: lofar_helpers
      type: Directory
      doc: LOFAR helpers directory.
    - id: selfcal
      type: Directory
      doc: The selfcal directory.
    - id: scratch
      type: boolean?
      default: true
      doc: |
        Whether you are running the final predict on scratch. This is crucial for running sub-arcsecond imaging on clusters.
        If 'scratch' is set to 'true' (the default and recommended setting), ensure that there is sufficient scratch storage
        space on the running nodes (at least ~400 GB per 15 cores). Alternatively, if 'scratch' set to 'false', you must limit the number
        of parallel predict jobs to prevent excessive use of intermediate storage disk space. However, this approach
        may increase the overall wall-time.

steps:
    - id: get_facet_layout
      label: Target Phaseup
      in:
        - id: msin
          source: msin
          valueFrom: $(inputs.msin[0])
        - id: h5parm
          source: h5parm
        - id: selfcal
          source: selfcal
      out:
        - id: facet_regions
      run: ../steps/get_facet_layout.cwl

    - id: split_polygons
      label: Split polygon file
      in:
         - id: facet_regions
           source: get_facet_layout/facet_regions
         - id: h5parm
           source: h5parm
         - id: lofar_helpers
           source: lofar_helpers
      out:
         - id: polygon_info
         - id: polygon_regions
      run: ../steps/split_polygons.cwl

    - id: subtract_fov
      label: Subtract complete FoV
      in:
         - id: msin
           source: msin
         - id: h5parm
           source: h5parm
         - id: facet_regions
           source: get_facet_layout/facet_regions
         - id: model_image_folder
           source: model_image_folder
         - id: lofar_helpers
           source: lofar_helpers
      out:
         - subtracted_ms
      run: ../steps/subtract_fov.cwl
      scatter: msin

    - id: predict_facet
      label: Predict a polygon back in empty MS
      in:
         - id: subtracted_ms
           source: subtract_fov/subtracted_ms
         - id: polygon_region
           source: split_polygons/polygon_regions
         - id: h5parm
           source: h5parm
         - id: polygon_info
           source: split_polygons/polygon_info
         - id: model_image_folder
           source: model_image_folder
         - id: lofar_helpers
           source: lofar_helpers
         - id: scratch
           source: scratch
      out:
         - facet_ms
      run: ../steps/predict_facet.cwl
      scatter: [polygon_region, subtracted_ms]
      scatterMethod: flat_crossproduct


outputs:
    - id: facet_ms
      type: Directory[]
      outputSource: predict_facet/facet_ms
    - id: polygon_info
      type: File
      outputSource: split_polygons/polygon_info
    - id: polygon_regions
      type: File[]
      outputSource: split_polygons/polygon_regions
