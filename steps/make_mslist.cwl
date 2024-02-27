class: CommandLineTool
cwlVersion: v1.2
id: make-mslist
label: Generate a text file containing names of MeasurementSets for DDF-pipeline.
doc: |-
  Generates a text file containing the names of MeasurementSets, used by e.g. the DDF-pipeline.
  This will be the input for the subtract. This requires DDF-pipeline to be installed.

baseCommand:
  - make_mslists.py

arguments:
  - force

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
        writable: true

