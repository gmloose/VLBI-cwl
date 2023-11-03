cwlVersion: v1.2
class: CommandLineTool
label: Collect LINC libraries
doc: |
    This step is intended to extract a list of
    files from the LOFAR INitial Calibration
    (LINC) pipeline, which can then be used by
    the VLBI pipeline.

baseCommand: cp
arguments:
    - -t
    - $(runtime.outdir)

inputs:
    - id: linc
      type: Directory
      doc: |
        The installation directory of the
        LOFAR INitial Calibration pipeline.

    - id: library
      type: string
      inputBinding:
        position: 1
        valueFrom: $(inputs.linc.path)/$(self)
      doc: |
        The paths of the necessary libraries
        with respect to the LINC root directory.

outputs:
    - id: libraries
      type: File
      doc: The files extracted from LINC.
      outputBinding:
        glob: "*"

requirements:
    - class: InlineJavascriptRequirement
