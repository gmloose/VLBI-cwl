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

    - id: source_catalogue
      type: File
      doc: External image catalogue (in CSV or FITS format) containing candidate target directions (e.g. LoTSS catalogue).

    - id: polygon_info_csv
      type: File?
      doc: Polygon information CSV (output file from facet_subtract.cwl)

    - id: lofar_helpers
      type: Directory
      doc: The LOFAR helpers directory.

    - id: facetselfcal
      type: Directory
      doc: The facetselfcal directory.

steps:

    - id: make_split_parsets
      in:
        #TODO
      out:
        - parsets
      run: XXX

    - id: dp3_parset
      in:
        - id: parset
          source: make_split_parsets/parsets
        - id: msin
          source: msin
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
      out:
        - final_merged_h5
        - selfcal_images
        - selfcal_inspection_images
        - solution_inspection_images
      run: ./subworkflows/ddcal_calibrators.cwl

outputs:
    - id: final_merged_h5
      type: File
      outputSource: ddcal_int/final_merged_h5
      doc: Final merged h5parm

    - id: phasediff_score_csv
      type: File?
      outputSource: split_directions/phasediff_score_csv
      doc: Phasediff-score CSV file

    - id: best_FITS_images
      type: File[]
      outputSource: ddcal_int/selfcal_images
      doc: Best self-calibration image in FITS format

    - id: selfcal_PNG_images
      type: File[]
      outputSource: ddcal_int/selfcal_inspection_images
      doc: Self-calibration images in PNG format

    - id: solution_inspection_images
      type: Directory[]
      outputSource: ddcal_int/solution_inspection_images
      doc: LoSoTo solution inspection images
