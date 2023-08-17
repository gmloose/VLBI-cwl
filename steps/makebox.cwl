class: CommandLineTool
cwlVersion: v1.2
id: makebox
label: Generate a square DS9 region.
doc: Generate a square DS9 region file outside which sources will be subtracted.

baseCommand:
  - make_box.py

inputs:
  - id: ms
    type: Directory
    doc: MeasurementSet to take the phase centre from.
    inputBinding:
      position: 0
  - id: box_size
    type: float?
    doc: Size in degrees the sides of the square box. Defaults to 2.5 deg.
    default: 2.5
    inputBinding:
      position: 1

outputs:
  - id: box
    type: File
    doc: DS9 region file indicating the subtract borders.
    outputBinding:
      glob: boxfile.reg