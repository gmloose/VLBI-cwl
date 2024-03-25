class: CommandLineTool
cwlVersion: v1.2
id: gatherdis2
doc: |-
  Gathers the final direction dependent solutions from the DDF-pipeline
  and other files required for the subtraction: the clean component model,
  the facet layout and the clean mask.

baseCommand:
  - convert_DIS2_to_h5parm.sh

inputs:
  - id: msin
    type: Directory
    doc: |
      MeasurementSet to extract a reference station list from
      for adding dummy international stations to the final h5parm.
    inputBinding:
      position: 2
      valueFrom: $(self.path)
  - id: ddf_solsdir
    type: Directory
    doc: |-
      Path to the SOLSIDR directory of the DDF-pipeline containing the
      folders with DIS2 solutions.
    inputBinding:
      position: 1
      valueFrom: $(self.path)
  - id: h5merger
    type: Directory
    doc: Path to external LOFAR helper scripts for merging h5 files.
    inputBinding:
      position: 0
      valueFrom: $(self.path)/h5_merger.py

outputs:
  - id: dis2_h5parm
    type: File
    doc: The direction independent solutions from DDF-pipeline.
    outputBinding:
      glob: DIS2_full.h5

