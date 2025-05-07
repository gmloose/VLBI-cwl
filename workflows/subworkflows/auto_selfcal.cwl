cwlVersion: v1.2
class: Workflow
id: auto_selfcal
label: Selfcal with international stations
doc: Performing DD self-calibration with MeasurementSets of calibrators with international stations.

inputs:
  - id: msin
    type: Directory
    doc: Input MeasurementSet from calibrator source.

  - id: dutch_multidir_h5
    type: File?
    doc: Multi-directional h5parm with Dutch DD solutions.

  - id: dd_selection_csv
    type: File?
    doc: CSV with DD calibrator positions and phasediff scores.

  - id: lofar_helpers
    type: Directory
    doc: lofar_helpers directory

  - id: facetselfcal
    type: Directory
    doc: facetselfcal directory

steps:
    - id: find_closest_h5
      in:
        - id: h5parm
          source: dutch_multidir_h5
        - id: ms
          source: msin
        - id: lofar_helpers
          source: lofar_helpers
        - id: dutch_multidir_h5
          source: dutch_multidir_h5
      out:
        - closest_h5
      when: $(inputs.dutch_multidir_h5 != null)
      run: ../../steps/find_closest_h5.cwl

    - id: addCS
      in:
        - id: ms
          source: msin
        - id: h5parm
          source: find_closest_h5/closest_h5
        - id: facetselfcal
          source: facetselfcal
        - id: dutch_multidir_h5
          source: dutch_multidir_h5
      out:
        - addCS_out_h5
      when: $(inputs.dutch_multidir_h5 != null)
      run: ../../steps/addCS.cwl

    - id: applycal
      in:
        - id: ms
          source: msin
        - id: h5parm
          source: addCS/addCS_out_h5
        - id: lofar_helpers
          source: lofar_helpers
        - id: dutch_multidir_h5
          source: dutch_multidir_h5
      out:
        - ms_out
      when: $(inputs.dutch_multidir_h5 != null)
      run: ../../steps/applycal.cwl

    - id: make_dd_config
      in:
        - id: phasediff_output
          source: dd_selection_csv
        - id: ms
          source: msin
        - id: dutch_multidir_h5
          source: dutch_multidir_h5
      out:
        - dd_config
      run: ../../steps/make_dd_config.cwl

    - id: run_facetselfcal
      in:
        - id: msin
          source:
            - applycal/ms_out
            - msin
          pickValue: first_non_null
        - id: facetselfcal
          source: facetselfcal
        - id: configfile
          source: make_dd_config/dd_config
      out:
        - h5_facetselfcal
        - selfcal_images
        - solution_inspection_images
        - fits_image
      run: ../../steps/facet_selfcal_auto.cwl

    - id: addCS_selfcal
      in:
        - id: ms
          source: msin
        - id: h5parm
          source: run_facetselfcal/h5_facetselfcal
        - id: facetselfcal
          source: facetselfcal
      out:
        - addCS_out_h5
      run: ../../steps/addCS.cwl

    - id: merge_all_in_one
      in:
        - id: first_h5
          source: addCS/addCS_out_h5
        - id: second_h5
          source: addCS_selfcal/addCS_out_h5
        - id: facetselfcal
          source: facetselfcal
        - id: dutch_multidir_h5
          source: dutch_multidir_h5
      out:
        - merged_h5
      when: $(inputs.dutch_multidir_h5 != null)
      run: ../../steps/merge_in_one_dir.cwl


requirements:
  - class: InlineJavascriptRequirement

outputs:
  - id: merged_h5
    type: File
    outputSource:
      - merge_all_in_one/merged_h5
      - addCS_selfcal/addCS_out_h5
    pickValue: first_non_null

  - id: fits_images
    type: File
    outputSource: run_facetselfcal/fits_image

  - id: selfcal_inspection_images
    type: File[]
    outputSource: run_facetselfcal/selfcal_images

  - id: solution_inspection_images
    type: Directory[]
    outputSource: run_facetselfcal/solution_inspection_images