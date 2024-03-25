class: Workflow
cwlVersion: v1.2
id: sort-concat-flag
label: VLBI concatenation and flagging
doc: |
    Reduces the number of MeasurementSets by concatenating
    of subbands into groups by frequency, and flags bad data
    in the resulting MeasurementSets. Optionally applies the
    solutions from the DDF pipeline, if these are given.

inputs:
  - id: msin
    type: Directory[]
    doc: |
        Input data in MeasurementSets. A-team data
        has been removed in the setup workflow.

  - id: ddf_solsdir
    type: Directory?
    doc: |
        The SOLSDIR directory of the ddf-pipeline run
        containing the DIS2 solutions.

  - id: numbands
    type: int?
    default: 10
    doc: |
        The number of files that have to be
        grouped together in frequency.

  - id: firstSB
    type: int?
    default: null
    doc: |
        If set, reference the grouping of files
        to this station subband.

  - id: max_dp3_threads
    type: int?
    default: 5
    doc: |
        The maximum number of threads that DP3
        should use per process.

  - id: linc
    type: Directory
    doc: |
        The installation directory for the
        LOFAR INitial Calibration pipeline.

  - id: aoflagger_memory_fraction
    type: int?
    default: 15
    doc: |
        The fraction of the node's memory that
        will be used by AOFlagger (and should be
        available before an AOFlagger job can start).

  - id: h5merger
    type: Directory
    doc: External LOFAR helper scripts for merging h5 files.

steps:
  - id: get_memory
    in:
      - id: fraction
        source: aoflagger_memory_fraction
        valueFrom: $(self)
    out:
      - id: memory
    run: ../steps/get_memory_fraction.cwl
    label: Get memory fraction

  - id: collect_linc_libraries
    label: Collect neccesary LINC libraries
    in:
      - id: linc
        source: linc
      - id: library
        default:
          - scripts/sort_times_into_freqGroups.py
          - rfistrategies/lofar-default.lua
    out:
      - id: libraries
    scatter: library
    run: ../steps/collect_linc_libraries.cwl

  - id: sort_concatenate
    in:
      - id: msin
        source: msin
      - id: numbands
        source: numbands
      - id: firstSB
        source: firstSB
      - id: linc_libraries
        source: collect_linc_libraries/libraries
      - id: stepname
        default: '_pre-cal.ms'
    out:
      - id: filenames
      - id: groupnames
      - id: logfile
    run: ../steps/sort_concatmap.cwl
    label: sort_concatmap
  - id: convert_ddf_dis2
    in:
      - id: msin
        source: msin
        valueFrom: $(self[0])
      - id: ddf_solsdir
        source: ddf_solsdir
        valueFrom: $(self)
      - id: h5merger
        source: h5merger
    out:
      - id: dis2_h5parm
    when: $(inputs.ddf_solsdir != null)
    run: ../steps/gatherdis2.cwl
  - id: concatenate-flag
    in:
      - id: msin
        source:
          - msin
      - id: ddf_solset
        source: convert_ddf_dis2/dis2_h5parm
      - id: group_id
        source: sort_concatenate/groupnames
      - id: groups_specification
        source: sort_concatenate/filenames
      - id: max_dp3_threads
        source: max_dp3_threads
      - id: aoflagger_memory
        source: get_memory/memory
      - id: linc_libraries
        source: collect_linc_libraries/libraries
    out:
      - id: msout
      - id: concat_flag_statistics
      - id: aoflag_logfile
      - id: concatenate_logfile
    run: ./subworkflows/concatenation.cwl
    scatter: group_id
    label: concatenation-flag
  - id: concat_flags_join
    in:
      - id: flagged_fraction_dict
        source:
          - concatenate-flag/concat_flag_statistics
      - id: filter_station
        default: ''
      - id: state
        default: concat
    out:
      - id: flagged_fraction_antenna
      - id: logfile
    run: ../steps/findRefAnt_join.cwl
    label: initial_flags_join
  - id: concatenate_logfiles_concatenate
    in:
      - id: file_list
        source:
          - concatenate-flag/concatenate_logfile
      - id: file_prefix
        default: concatenate
    out:
      - id: output
    run: ../steps/concatenate_files.cwl
    label: concatenate_logfiles_concatenate
  - id: concatenate_logfiles_aoflagging
    in:
      - id: file_list
        linkMerge: merge_flattened
        source: concatenate-flag/aoflag_logfile
      - id: file_prefix
        default: AOflagging
    out:
      - id: output
    run: ../steps/concatenate_files.cwl
    label: concat_logfiles_AOflagging
  - id: save_logfiles
    in:
      - id: files
        linkMerge: merge_flattened
        source:
            - sort_concatenate/logfile
            - concatenate_logfiles_concatenate/output
            - concatenate_logfiles_aoflagging/output
            - concat_flags_join/logfile
      - id: sub_directory_name
        default: 'sort-concat-flag'
    out:
      - id: dir
    run: ../steps/collectfiles.cwl
    label: save_logfiles

outputs:
    - id: logdir
      outputSource: save_logfiles/dir
      type: Directory
      doc: |
        The directory containing all the stdin
        and stderr files from the workflow.

    - id: msout
      outputSource: concatenate-flag/msout
      type: Directory[]
      doc: |
        An array of MeasurementSets
        containing the concatenated data.

    - id: concat_flags
      type: File
      outputSource: concat_flags_join/flagged_fraction_antenna
      doc: |
        A JSON formatted file containing flagging statistics
        of the MeasurementSet data after concatenation.

requirements:
    - class: SubworkflowFeatureRequirement
    - class: ScatterFeatureRequirement
    - class: MultipleInputFeatureRequirement
    - class: StepInputExpressionRequirement
