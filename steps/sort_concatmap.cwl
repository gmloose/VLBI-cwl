class: CommandLineTool
cwlVersion: v1.2
id: sort_concatmap
label: Sort concatenate map
doc: |
    Sorts the subbands into a given number
    of regularly spaced frequency groups.

baseCommand:
  - python3
  - sort_times.py

inputs:
  - id: msin
    type:
      - Directory[]
    inputBinding:
      position: 0
    doc: Input MeasurementSets to be sorted.

  - id: numbands
    type: int?
    default: 10
    doc: The number of elements in each group.

  - id: DP3fill
    type: boolean?
    default: True
    doc: |
        Add dummy file names for missing frequencies,
        so that DP3 can fill the data with flagged dummy data.

  - id: stepname
    type: string?
    default: '.dp3-concat'
    doc: |
        A string to be appended to the file names of the output files.

  - id: mergeLastGroup
    type: boolean?
    default: False
    doc: |
        Add dummy file names for missing frequencies,
        so that DP3 can fill the data with flagged dummy data.

  - id: truncateLastSBs
    type: boolean?
    default: False
    doc: |
        Add dummy file names for missing frequencies,
        so that DP3 can fill the data with flagged dummy data.

  - id: firstSB
    type: int?
    default: null
    doc: |
        If set, reference the grouping of
        files to this station subband.

  - id: linc_libraries
    type: File[]
    doc: |
      Scripts and reference files from the
      LOFAR INitial calibration pipeline.
      Must contain `sort_times_into_freqGroups.py`.

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.linc_libraries)
      - entryname: sort_times.py
        entry: |
          import sys
          import json
          from sort_times_into_freqGroups import main as sort_times_into_freqGroups

          mss = sys.argv[1:]

          inputs = json.loads(r"""$(inputs)""")

          numbands = inputs['numbands']
          stepname = inputs['stepname']
          NDPPPfill = inputs['DP3fill']
          mergeLastGroup = inputs['mergeLastGroup']
          truncateLastSBs = inputs['truncateLastSBs']
          firstSB = inputs['firstSB']

          print(mss, numbands, NDPPPfill, stepname, mergeLastGroup, truncateLastSBs, firstSB)

          output = sort_times_into_freqGroups(mss, numbands, NDPPPfill, stepname, mergeLastGroup, truncateLastSBs, firstSB)
          print(output)
          filenames  = output['filenames']
          groupnames = output['groupnames']
          total_bandwidth = output['total_bandwidth']

          cwl_output = {}
          cwl_output['groupnames'] = groupnames
          cwl_output['total_bandwidth'] = total_bandwidth

          with open('./filenames.json', 'w') as fp:
              json.dump(filenames, fp)

          with open('./out.json', 'w') as fp:
              json.dump(cwl_output, fp)

outputs:
  - id: filenames
    type: File
    outputBinding:
        glob: filenames.json
    doc: |
        A list of filenames that have to
        be concatenated, in JSON format.

  - id: groupnames
    type: string[]
    outputBinding:
        loadContents: true
        glob: out.json
        outputEval: $(JSON.parse(self[0].contents).groupnames)
    doc: A string of names of the frequency groups.

  - id: logfile
    type: File
    outputBinding:
      glob: sort_concatmap.log
    doc: The file containing the stdout output from the step.

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl

stdout: sort_concatmap.log
stderr: sort_concatmap_err.log
