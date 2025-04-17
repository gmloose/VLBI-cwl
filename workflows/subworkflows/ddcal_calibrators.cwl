cwlVersion: v1.2
class: Workflow
id: ddcal_int
label: Selfcals with international stations for multiple directions
doc: Performing DD self-calibration for international stations for multiple directions.

inputs:
  - id: msin
    type: Directory[]
    doc: Input MeasurementSets from individual calibrator directions.

  - id: dutch_multidir_h5
    type: File?
    doc: Multi-directional h5parm with Dutch DD solutions.

  - id: dd_selection_csv
    type: File?
    doc: CSV with DD selection positions and phasediff scores.

  - id: lofar_helpers
    type: Directory
    doc: LOFAR helpers directory

  - id: facetselfcal
    type: Directory
    doc: facetselfcal directory

steps:
    - id: ddcal
      in:
        - id: msin
          source: msin
        - id: dutch_multidir_h5
          source: dutch_multidir_h5
        - id: dd_selection_csv
          source: dd_selection_csv
        - id: lofar_helpers
          source: lofar_helpers
        - id: facetselfcal
          source: facetselfcal
      out:
        - merged_h5
        - fits_images
        - selfcal_inspection_images
        - solution_inspection_images
      run: ./auto_selfcal.cwl
      scatter: msin

    - id: multidir_merge
      in:
        - id: h5parms
          source: ddcal/merged_h5
        - id: facetselfcal
          source: facetselfcal
      out:
        - multidir_h5
      run: ../../steps/multidir_merger.cwl

    - id: flatten_image_inspection
      in:
        - id: nestedarray
          source: ddcal/selfcal_inspection_images
      out:
        - flattenedarray
      run: ../../steps/flatten.cwl

    - id: flatten_solution_inspection
      in:
        - id: nestedarray
          source: ddcal/solution_inspection_images
      out:
        - flattenedarray
      run: ../../steps/flatten.cwl

requirements:
  - class: ScatterFeatureRequirement

outputs:
  - id: final_merged_h5
    type: File
    outputSource: multidir_merge/multidir_h5
    doc: Final merged h5parm with multiple directions

  - id: individual_h5s
    type: File[]
    outputSource: ddcal/merged_h5
    doc: Separate h5parms

  - id: selfcal_images
    type: File[]
    outputSource: ddcal/fits_images
    doc: Self-calibration images in FITS format

  - id: selfcal_inspection_images
    type: File[]
    outputSource: flatten_image_inspection/flattenedarray
    doc: Self-calibration inspection images in PNG format

  - id: solution_inspection_images
    type: Directory[]
    outputSource: flatten_solution_inspection/flattenedarray
    doc: LoSoTo solution inspection images
