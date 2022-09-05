class: Workflow
cwlVersion: v1.2
id: sort-concat
label: sort-concat

inputs:
  - id: msin
    type: Directory[]
  - id: numbands
    type: int?
    default: 10
    doc: The number of files that have to be grouped together.
  - id: DP3fill
    type: boolean?
    default: True
    doc: Add dummy file names for missing frequencies, so that DP3 can fill the data with flagged dummy data.
  - id: stepname
    type: string?
    default: '.dp3-concat'
    doc: Add this stepname into the file names of the output files.
  - id: mergeLastGroup
    type: boolean?
    default: False
    doc: Add dummy file names for missing frequencies, so that DP3 can fill the data with flagged dummy data.
  - id: truncateLastSBs
    type: boolean?
    default: True
    doc: Add dummy file names for missing frequencies, so that DP3 can fill the data with flagged dummy data.
  - id: firstSB
    type: int?
    default: null
    doc: If set, reference the grouping of files to this station subband.

steps:
  - id: sort_concatenate
    in:
      - id: msin
        source: msin
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
        source: truncateLastSBs
    out:
      - id: msout
      - id: logfile_sortconcat
      - id: logfile_concatenate
    run: ./subworkflows/sort-concatenate.cwl
    label: sort_concatenate
  - id: save_logfiles
    in:
      - id: files
        linkMerge: merge_flattened
        source:
            - sort_concatmap/logfile
            - concatenate_logfiles_concatenate/output
      - id: sub_directory_name
        default: 'sort-concat'
    out:
      - id: dir
    run: ../steps/collectfiles.cwl
    label: save_logfiles

outputs:
    - id: logdir
      outputSource: save_logfiles/dir
      type: Directory
    - id: msout
      outputSource: concatenation/msout
      type: Directory[]

requirements:
    - class: SubworkflowFeatureRequirement
    - class: ScatterFeatureRequirement
    - class: MultipleInputFeatureRequirement
