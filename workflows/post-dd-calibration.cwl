class: Workflow
cwlVersion: v1.2
id: post-ddcal-widefield
label: Automated post-calibration for wide-field imaging
doc: |
  This is a workflow for the LOFAR-VLBI pipeline that follows on the facet-subtraction and:
    * Splits the main calibrator from the facet MeasurementSets
    * Performs self-calibration on the target directions with facetselfcal (with automatically tuned parameter settings)

requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
    - id: msin
      type: Directory[]
      doc: The input MeasurementSets of the entire field-of-view with or without delay-calibration solutions applied.

    - id: polygon_info_csv
      type: File
      doc: Polygon information CSV (output file from facet_subtract.cwl)

    - id: skip_selfcal
      type: boolean?
      default: false
      doc: Skip the self-calibration step when you only want to split of calibrator sources and do manual self-calibration.

    - id: lofar_helpers
      type: Directory
      doc: The LOFAR helpers directory.

    - id: facetselfcal
      type: Directory
      doc: The facetselfcal directory.

steps:

    - id: make_split_parsets
      in:
        - id: msin
          source: msin
        - id: polygon_info_csv
          source: polygon_info_csv
      out:
        - split_parsets
      run: ../steps/make_split_parsets.cwl

    - id: dp3_parset
      in:
        - id: parset
          source: make_split_parsets/split_parsets
        - id: msin
          source: msin
        - id: prefix
          valueFrom: "selfcal_"
        - id: max_cores
          valueFrom: "16"
      out:
        - id: msout
      run: ../steps/dp3_parset.cwl
      scatter: parset

    - id: ddcal_int
      in:
        - id: msin
          source: dp3_parset/msout
        - id: lofar_helpers
          source: lofar_helpers
        - id: facetselfcal
          source: facetselfcal
        - id: skip_selfcal
          source: skip_selfcal
      out:
        - individual_h5s
        - selfcal_images
        - selfcal_inspection_images
        - solution_inspection_images
      run: ./subworkflows/ddcal_calibrators.cwl
      when: $(not inputs.skip_selfcal)


outputs:
    - id: split_calibrators
      type: Directory[]
      outputSource: dp3_parset/msout
      doc: Splitted MS of calibrators

    - id: output_h5s
      type: File[]?
      outputSource: ddcal_int/individual_h5s
      doc: Final h5s for each calibrator

    - id: best_FITS_images
      type: File[]?
      outputSource: ddcal_int/selfcal_images
      doc: Best self-calibration image in FITS format

    - id: selfcal_PNG_images
      type: File[]?
      outputSource: ddcal_int/selfcal_inspection_images
      doc: Self-calibration images in PNG format

    - id: solution_inspection_images
      type: Directory[]?
      outputSource: ddcal_int/solution_inspection_images
      doc: LoSoTo solution inspection images
