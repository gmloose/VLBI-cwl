class: CommandLineTool
cwlVersion: v1.2
id: make-mslist
doc: |-
  Generates a text file containing the names of MeasurementSets, used by e.g. the DDF-pipeline.
  This will be the input for the subtract. This requires DDF-pipeline to be installed.

baseCommand:
  - make_mslist_subtract.sh

inputs:
  - id: ms
    type: Directory
    doc: Input MeasurementSet.
    inputBinding:
      position: 1

outputs:
  - id: mslist
    type: File
    doc: Text file containing the names of the MeasurementSet.
    outputBinding:
      glob: big-mslist.txt

requirements:
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.ms)

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl
