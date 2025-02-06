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

  - id: forwidefield
    type: boolean
    default: false
    doc: Wide-field imaging mode, which focuses in this step in optimizing 1.2" imaging for best facet-subtraction in the next step.

  - id: dd_selection_csv
    type: File?
    doc: CSV with DD selection positions and phasediff scores

  - id: lofar_helpers
    type: Directory
    doc: lofar_helpers directory

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
        - id: forwidefield
          source: forwidefield
      out:
        - merged_h5
        - fits_images
        - selfcal_inspection_images
        - solution_inspection_images
      run: ./auto_selfcal.cwl
      scatter: msin

    - id: multidir_merge
      label: Merge multiple directions into one h5
      in:
        - id: h5parms
          source: ddcal/merged_h5
        - id: facetselfcal
          source: facetselfcal
      out:
        - multidir_h5
      run: ../../steps/multidir_merger.cwl

    - id: flatten_images
      label: Flatten image array of arrays
      in:
        - id: nestedarray
          source: ddcal/selfcal_inspection_images
      out:
        - flattenedarray
      run: ../../steps/flatten.cwl

    - id: flatten_solutions
      label: Flatten solution array of arrays
      in:
        - id: nestedarray
          source: ddcal/solution_inspection_images
      out:
        - flattenedarray
      run: ../../steps/flatten.cwl

requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: InlineJavascriptRequirement

outputs:
  - id: final_merged_h5
    type: File
    outputSource: multidir_merge/multidir_h5
    doc: Final merged h5parm with multiple directions

  - id: selfcal_images
    type: File[]
    outputSource: ddcal/fits_images
    doc: Selfcal FITS images

  - id: selfcal_inspection_images
    type: File[]
    outputSource: flatten_images/flattenedarray
    doc: Selfcal inspection images

  - id: solution_inspection_images
    type: Directory[]
    outputSource: flatten_solutions/flattenedarray
    doc: Solution inspection images
