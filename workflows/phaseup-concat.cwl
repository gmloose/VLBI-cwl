class: Workflow
cwlVersion: v1.2
id: phaseup-concat
label: VLBI phaseup and concatenation
doc: |
    Phase shifts data to the in-field calibrator
    and performs the direction-independent calibration.

inputs:
  - id: msin
    type: Directory[]
    doc: Input data in MeasurementSet format.

  - id: delay_calibrator
    type: File
    doc: Catalogue file with information on in-field calibrator.

  - id: numbands
    type: int?
    default: -1
    doc: The number of files that have to be grouped together.

  - id: firstSB
    type: int?
    default: null
    doc: If set, reference the grouping of files to this station subband.

  - id: configfile
    type: File
    doc: Settings for the delay calibration in delay_solve.

  - id: selfcal
    type: Directory
    doc: Path of external calibration scripts.

  - id: h5merger
    type: Directory
    doc: External LOFAR helper scripts for merging h5 files.

  - id: flags
    type: File[]
    doc: Flagging information in JSON format.

  - id: pipeline
    type: string?
    default: 'VLBI'
    doc: Name of the pipeline.

  - id: run_type
    type: string?
    default: 'sol000'
    doc: Type of the pipeline.

  - id: filter_baselines
    type: string?
    default: '[CR]S*&'
    doc: Name pattern of antennas to be filtered from the processing.

  - id: bad_antennas
    type: string?
    default: '[CR]S*&'
    doc: Antenna string to be processed.

  - id: compare_stations_filter
    type: string?
    default: '[CR]S*&'

  - id: check_Ateam_separation.json
    type: File
    doc: |
        A list of angular distances between the
        delay calibrator and the A-team sources.

  - id: clip_sources
    type: string[]?
    default: []
    doc: List of sources that were clipped.

  - id: removed_bands
    type: string[]?
    default: []
    doc: The list of bands that were removed from the data.

  - id: min_unflagged_fraction
    type: float?
    default: 0.5
    doc: The minimum fraction of unflagged data per band to continue.

  - id: refant
    type: string?
    default: 'CS001HBA0'
    doc: The reference antenna used.

  - id: max_dp3_threads
    type: int?
    default: 5
    doc: The maximum number of threads DP3 should use per process.

  - id: linc
    type: Directory
    doc: |
      The installation directory for the
      LOFAR INitial calibration pipeline.

steps:
  - id: collect_linc_libraries
    label: Collect neccesary LINC libraries
    in:
      - id: linc
        source: linc
      - id: library
        default:
          - scripts/sort_times_into_freqGroups.py
    out:
      - id: libraries
    scatter: library
    run: ../steps/collect_linc_libraries.cwl

  - id: prep_delay
    in:
      - id: delay_calibrator
        source: delay_calibrator
      - id: extract_single
        default: true
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
      - id: max_dp3_threads
        source: max_dp3_threads
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
      - id: firstSB
        source: firstSB
      - id: linc_libraries
        source: collect_linc_libraries/libraries
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
    out:
      - id: msout
      - id: concat_flag_statistics
      - id: concatenate_logfile
      - id: aoflag_logfile
    run: ./subworkflows/concatenation.cwl
    scatter: group_id
    label: phaseup_concatenate

  - id: phaseup_flags_join
    in:
      - id: flagged_fraction_dict
        source:
          - phaseup_concatenate/concat_flag_statistics
      - id: filter_station
        default: ''
      - id: state
        default: phaseup_concat
    out:
      - id: flagged_fraction_antenna
      - id: logfile
    run: ../steps/findRefAnt_join.cwl
    label: prep_target_flags_join

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
      - id: skymodel
      - id: logfile
    run: ../steps/delay_cal_model.cwl

  - id: delay_solve
    in:
      - id: msin
        source: phaseup_concatenate/msout
        valueFrom: $(self[0])
      - id: skymodel
        source: delay_cal_model/skymodel
      - id: configfile
        source: configfile
      - id: selfcal
        source: selfcal
      - id: h5merger
        source: h5merger
    out:
      - id: h5parm
      - id: images
      - id: logfile
    run: ../steps/delay_solve.cwl
    label: delay_solve

  - id: summary
    in:
      - id: flagFiles
        source:
          - flags
          - phaseup_flags_join/flagged_fraction_antenna
        linkMerge: merge_flattened
      - id: pipeline
        source: pipeline
      - id: run_type
        source: run_type
      - id: filter
        source: filter_baselines
      - id: bad_antennas
        source:
          - bad_antennas
          - compare_stations_filter
        valueFrom: $(self.join(''))
      - id: Ateam_separation_file
        source: check_Ateam_separation.json
      - id: solutions
        source: delay_solve/h5parm
      - id: clip_sources
        source: clip_sources
        valueFrom: "$(self.join(','))"
      - id: removed_bands
        source: removed_bands
        valueFrom: "$(self.join(','))"
      - id: min_unflagged_fraction
        source: min_unflagged_fraction
      - id: refant
        source: refant
    out:
      - id: summary_file
      - id: logfile
    run: ../steps/summary.cwl
    label: summary

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
          - delay_solve/logfile
          - summary/logfile
      - id: sub_directory_name
        default: phaseup
    out:
      - id: dir
    run: ../steps/collectfiles.cwl
    label: save_logfiles

outputs:
  - id: msout
    type: Directory[]
    outputSource: phaseup_concatenate/msout
    doc: |
        The data in MeasurementSet format after
        phase-shifting to the delay calibrator.

  - id: solutions
    type: File
    outputSource: delay_solve/h5parm
    doc: |
        The calibrated solutions for the
        delay calibrator in HDF5 format.

  - id: logdir
    outputSource: save_logfiles/dir
    type: Directory
    doc: |
        The directory containing all the stdin
        and stderr files from the workflow.

  - id: pictures
    type: File[]
    outputSource: delay_solve/images
    doc: |
        The inspection plots generated
        by delay_solve.

  - id: summary_file
    type: File
    outputSource: summary/summary_file
    doc: |
        Pipeline summary statistics
        in JSON format.

requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
