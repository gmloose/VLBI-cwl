class: Workflow
cwlVersion: v1.2
id: phaseup-concat
label: phaseup-concat

inputs:
  - id: msin
    type: Directory[]
    doc: Input measurement sets.
  - id: delay_calibrator
    type: File
    doc: Catalogue file with information on in-field calibrator.
  - id: numbands
    type: int?
    default: -1
    doc: The number of files that have to be grouped together.
  - id: DP3fill
    type: boolean?
    default: True
    doc: Add dummy file names for missing frequencies, so that DP3 can fill the data with flagged dummy data.
  - id: stepname
    type: string?
    default: '.dp3-phaseup-concat'
    doc: Add this stepname into the file names of the output files.
  - id: mergeLastGroup
    type: boolean?
    default: False
    doc: Add dummy file names for missing frequencies, so that DP3 can fill the data with flagged dummy data.
  - id: truncateLastSBs
    type: boolean?
    default: False
    doc: Add dummy file names for missing frequencies, so that DP3 can fill the data with flagged dummy data.
  - id: firstSB
    type: int?
    default: null
    doc: If set, reference the grouping of files to this station subband.
  - id: do_flagging
    type: boolean?
    default: false

steps:
  - id: prep_delay
    in:
      - id: delay_calibrator
        source: delay_calibrator
    out:
      - id: source_id
      - id: coordinates
      - id: logfile
    run: ../steps/prep_delay.cwl
    label: prep_delay
  - id: dp3_phaseup
    in:
      - id: msin
        source: msin
      - id: phase_center
        source: prep_delay/coordinates
      - id: beam_direction
        source: prep_delay/coordinates
      - id: msout_name
        source: prep_delay/source_id
    out:
      - id: msout
      - id: logfile
      - id: errorfile
    run: ../steps/dp3_phaseup.cwl
    scatter: msin
    label: dp3_phaseup
  - id: sort_concatenate
    in:
      - id: msin
        source: dp3_phaseup/msout
      - id: numbands
        source: numbands
      - id: DP3fill
        source: DP3fill
      - id: stepname
        source: stepname
      - id: mergeLastGroup
        source: mergeLastGroup
      - id: truncateLastSBs
        source: truncateLastSBs
      - id: firstSB
        source: firstSB
    out:
      - id: filenames
      - id: groupnames
      - id: logfile
    run: ../steps/sort_concatmap.cwl
    label: sort_concatmap
  - id: phaseup_concatenate
    in:
      - id: msin
        source:
          - dp3_phaseup/msout
      - id: group_id
        source: sort_concatenate/groupnames
      - id: groups_specification
        source: sort_concatenate/filenames
      - id: do_flagging
        source: do_flagging
    out:
      - id: msout
      - id: concatenate_logfile
      - id: aoflag_logfile
    run: ./subworkflows/concatenation.cwl
    scatter: group_id
    label: phaseup_concatenate
  - id: concat_logfiles_phaseup
    label: concat_logfiles_phaseup
    in:
      - id: file_list
        linkMerge: merge_flattened
        source:
          - dp3_phaseup/logfile
      - id: file_prefix
        default: dp3_phaseup
    out:
      - id: output
    run: ../steps/concatenate_files.cwl
  - id: concat_logfiles_concatenate
    label: concat_logfiles_concatenate
    in:
      - id: file_list
        linkMerge: merge_flattened
        source:
          - phaseup_concatenate/concatenate_logfile
      - id: file_prefix
        default: phaseup_concatenate
    out:
      - id: output
    run: ../steps/concatenate_files.cwl
  - id: delay_cal_model
    label: delay_cal_model
    in:
      - id: msin
        source: phaseup_concatenate/msout
        valueFrom: $(self[0])
      - id: delay_calibrator
        source: delay_calibrator
    out:
      - id: msout
      - id: logfile
    run: ../steps/delay_cal_model.cwl

  - id: save_logfiles
    in:
      - id: files
        linkMerge: merge_flattened
        source:
          - prep_delay/logfile
          - concat_logfiles_phaseup/output 
          - sort_concatenate/logfile
          - concat_logfiles_phaseup/output
          - delay_cal_model/logfile
      - id: sub_directory_name
        default: phaseup
    out:
      - id: dir
    run: ../steps/collectfiles.cwl
    label: save_logfiles

outputs:
  - id: msout
    outputSource: delay_cal_model/msout
    type: Directory
  - id: logdir
    outputSource: save_logfiles/dir
    type: Directory

requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
