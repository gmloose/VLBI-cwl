cwlVersion: v1.2
class: Workflow
id: ddcal_int
label: DD calibration international stations
doc: Performing DD calibration for international stations (follows after DD calibration for Dutch stations)

inputs:
  - id: msin
    type: Directory[]
    doc: Input MeasurementSets from individual calibrator directions
  - id: dutch_multidir_h5
    type: File?
    doc: Multi-directional h5parm with Dutch DD solutions
  - id: forwidefield
    type: boolean?
    default: false
    doc: Wide-field imaging mode, which focuses in this step in optimizing 1.2" imaging for best facet-subtraction in the next step.
  - id: dd_selection_csv
    type: File
    doc: DD selection CSV (with phasediff scores)
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
        - selfcal_images
        - solution_inspection_images
      scatter: msin
      run:
        # start ddcal for each ms
        cwlVersion: v1.2
        class: Workflow

        inputs:
          msin: Directory
          dutch_multidir_h5: File?
          dd_selection_csv: File
          lofar_helpers: Directory
          facetselfcal: Directory
          forwidefield: boolean

        steps:
          - id: find_closest_h5
            when: $(inputs.dutch_multidir_h5 != null)
            run: ../../steps/find_closest_h5.cwl
            in:
              h5parm: dutch_multidir_h5
              ms: msin
              lofar_helpers: lofar_helpers
            out:
              - closest_h5

          - id: addCS
            when: $(inputs.dutch_multidir_h5 != null)
            run: ../../steps/addCS.cwl
            in:
              ms: msin
              h5parm: find_closest_h5/closest_h5
              facetselfcal: facetselfcal
            out:
              - preapply_h5

          - id: applycal
            when: $(inputs.dutch_multidir_h5 != null)
            run: ../../steps/applycal.cwl
            in:
              ms: msin
              h5parm: addCS/preapply_h5
              lofar_helpers: lofar_helpers
            out:
              - ms_out

          - id: make_dd_config
            run: ../../steps/make_dd_config_int_with_resets.cwl
            in:
              phasediff_output: dd_selection_csv
              ms: msin
              forwidefield: forwidefield
            out:
              - dd_config

          - id: run_facetselfcal
            run: ../../steps/facet_selfcal_international.cwl
            in:
              msin:
                valueFrom: |
                  $(inputs.applycal/ms_out ? inputs.applycal/ms_out : inputs.msin)
              facetselfcal: facetselfcal
              configfile: make_dd_config/dd_config
            out:
              - h5_facetselfcal
              - selfcal_images
              - solution_inspection_images
              - fits_images

          - id: merge_all_in_one
            run: ../../steps/merge_in_one_dir.cwl
            when: $(inputs.dutch_multidir_h5 != null)
            label: Merge preapplied h5parm and output h5parm in one h5parm
            in:
              first_h5: addCS/preapply_h5
              second_h5: run_facetselfcal/h5_facetselfcal
              facetselfcal: facetselfcal
            out:
              - merged_h5

        outputs:
          merged_h5:
            type: File
            outputSource:
              - merge_all_in_one/merged_h5
              - run_facetselfcal/h5_facetselfcal
            pickValue: first_non_null
          selfcal_images:
            type: File[]
            outputSource: run_facetselfcal/selfcal_images
          solution_inspection_images:
            type: Directory[]
            outputSource: run_facetselfcal/solution_inspection_images

        # end ddcal for each ms

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
          source: ddcal/selfcal_images
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

outputs:
  - id: final_merged_h5
    type: File
    outputSource: multidir_merge/multidir_h5
    doc: Final merged h5parm with multiple directions
  - id: selfcal_images
    type: File[]
    outputSource: flatten_images/flattenedarray
    doc: Selfcal images
  - id: solution_inspection_images
    type: Directory[]
    outputSource: flatten_solutions/flattenedarray
    doc: Selfcal inspection plots