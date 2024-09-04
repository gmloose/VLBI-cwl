class: Workflow
cwlVersion: v1.2
id: stacked-selfcal
label: Stacked selfcal of multiple sources.
doc: |
  Performs joint self calibration on the input MeasurementSets
  by stacking them in the visbility plane.

inputs:
  - id: msin
    type: Directory[]
    doc: Input data in MeasurementSet format.

  - id: configfile
    type: File
    doc: Settings for the delay calibration in solve_stacked.

  - id: selfcal
    type: Directory
    doc: Path of external calibration scripts.

  - id: h5merger
    type: Directory
    doc: External LOFAR helper scripts for merging h5 files.

  - id: max_dp3_threads
    type: int?
    default: 5
    doc: The maximum number of threads DP3 should use per process.

steps:
  - id: solve_stacked
    in:
      - id: msin
        source: msin
        valueFrom: $(self[0])
      - id: configfile
        source: configfile
      - id: selfcal
        source: selfcal
      - id: h5merger
        source: h5merger
      - id: stack
        default: true
    out:
      - id: h5parm
      - id: images
      - id: logfile
    run: ../steps/facet_selfcal.cwl
    label: solve_stacked

  - id: save_logfiles
    in:
      - id: files
        linkMerge: merge_flattened
        source:
          - solve_stacked/logfile
      - id: sub_directory_name
        default: stacked_selfcal
    out:
      - id: dir
    run: ../steps/collectfiles.cwl
    label: save_logfiles

outputs:
  - id: solutions
    type: File
    outputSource: solve_stacked/h5parm
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
    outputSource: solve_stacked/images
    doc: |
        The inspection plots generated
        by solve_stacked.

requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
