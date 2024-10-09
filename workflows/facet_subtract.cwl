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
  - class: SubworkflowFeatureRequirement

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
        Whether you are running the final predict on scratch. This is important for running sub-arcsecond imaging on HPC clusters.
        If 'scratch' is set to 'true' (the default and recommended setting), ensure that there is sufficient scratch storage
        space on the running nodes (at least ~400 GB per 15 cores). Alternatively, if 'scratch' set to 'false', you must limit the number
        of parallel predict jobs to prevent excessive use of intermediate storage disk space. However, this approach
        may increase the overall wall-time.

steps:
    - id: get_facet_layout
      label: Get DS9 facet layout
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

    - id: subtract_predict_facets
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
         - id: polygon_info
           source: split_polygons/polygon_info
         - id: polygon_regions
           source: split_polygons/polygon_regions
         - id: scratch
           source: scratch
      out:
         - facet_ms
      scatter: msin
      run:
         class: Workflow
         cwlVersion: v1.2
         inputs:
            - id: msin
              type: Directory
            - id: h5parm
              type: File
            - id: facet_regions
              type: File
            - id: model_image_folder
              type: Directory
            - id: lofar_helpers
              type: Directory
            - id: polygon_info
              type: File
            - id: polygon_regions
              type: File[]
            - id: scratch
              type: boolean
         outputs:
            - id: facet_ms
              type: Directory[]
              outputSource: predict_facet/facet_ms
         steps:
            - id: subtract_fov_wsclean
              label: Subtract complete FoV
              in:
                 - id: msin
                   source: msin
                 - id: h5parm
                   source: h5parm
                 - id: facet_regions
                   source: facet_regions
                 - id: model_image_folder
                   source: model_image_folder
                 - id: lofar_helpers
                   source: lofar_helpers
              out:
                 - subtracted_ms
              run: ../steps/subtract_fov_wsclean.cwl

            - id: predict_facet
              label: Predict a polygon back in empty MS
              in:
                 - id: subtracted_ms
                   source: subtract_fov_wsclean/subtracted_ms
                 - id: polygon_region
                   source: polygon_regions
                 - id: h5parm
                   source: h5parm
                 - id: polygon_info
                   source: polygon_info
                 - id: model_image_folder
                   source: model_image_folder
                 - id: lofar_helpers
                   source: lofar_helpers
                 - id: scratch
                   source: scratch
              out:
                 - facet_ms
              run: ../steps/predict_facet.cwl
              scatter: polygon_region
         # end of subtract-predict workflow

    - id: flatten_facet_ms
      label: Flatten MS
      in:
        - id: nestedarray
          source: subtract_predict_facets/facet_ms
      out:
        - id: flattenedarray
      run: ../steps/flatten.cwl

    - id: make_concat_parset
      label: Make concat parsets
      in:
         - id: msin
           source: flatten_facet_ms/flattenedarray
         - id: lofar_helpers
           source: lofar_helpers
      out:
         - id: concat_parsets
      run: ../steps/make_concat_parsets.cwl

    - id: concat_facets
      label: Run DP3 parsets
      in:
        - id: parset
          source: make_concat_parset/concat_parsets
        - id: msin
          source: flatten_facet_ms/flattenedarray
      out:
        - id: msout
      run: ../steps/dp3_parset.cwl
      scatter: parset


outputs:
    - id: facet_ms
      type: Directory[]
      outputSource: concat_facets/msout
    - id: polygon_info
      type: File
      outputSource: split_polygons/polygon_info
    - id: polygon_regions
      type: File[]
      outputSource: split_polygons/polygon_regions
