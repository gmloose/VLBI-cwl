class: Workflow
cwlVersion: v1.2
id: sort-concatenate
label: sort-concatenate

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
  - id: sort_concatmap
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
        source: firstSB
    out:
      - id: filenames
      - id: groupnames
      - id: logfile
    run: ../../steps/sort_concatmap.cwl
    label: sort_concatmap
  - id: concatenate
    in:
      - id: msin
        source:
          - msin
      - id: group_id
        source: sort_concatmap/groupnames
      - id: groups_specification
        source: sort_concatmap/filenames
    out:
      - id: msout
      - id: logfile
    run: ./concatenation.cwl
    scatter: group_id
    label: concatenation
  - id: concatenate_logfiles_concatenate
    in:
      - id: file_list
        source:
          - concatenate/logfile
      - id: file_prefix
        default: concatenate
    out:
      - id: output
    run: ../../steps/concatenate_files.cwl
    label: concatenate_logfiles_concatenate

outputs:
    - id: logfile_concatenate
      outputSource: concatenate_logfiles_concatenate/output
      type: File
    - id: logfile_sortconcat
      outputSource: sort_concatmap/logfile
      type: File
    - id: msout
      outputSource: concatenate/msout
      type: Directory[]

requirements:
    - class: SubworkflowFeatureRequirement
    - class: ScatterFeatureRequirement
    - class: MultipleInputFeatureRequirement
