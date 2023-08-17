class: CommandLineTool
cwlVersion: v1.2
id: make-mslist
label: Generate a text file containing names of MeasurementSets for DDFacet.
doc: Generate a text file containing names of MeasurementSets for DDFacet. This will be the input for the subtract.

baseCommand:
  - make_mslists.py

inputs:
  - id: ms
    type: Directory
    doc: MeasurementSet to operate on.
    inputBinding:
      position: 10
  - id: force
    type: string?
    doc: Force the generation of the text file containing MeasurementSets to operate on even if there are too few (less than 18).
    default: "force"
    inputBinding:
      position: 0

outputs:
  - id: mslist
    type: File
    doc: Text file containing the MeasurementSets that DDFacet will operate on for the subtract.
    outputBinding:
      glob: big-mslist.txt

requirements:
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.ms)
        writable: true

