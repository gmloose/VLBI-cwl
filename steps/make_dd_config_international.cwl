cwlVersion: v1.2
class: CommandLineTool
id: make_dd_config
label: Make DD config file
doc: Return config file as input for facetselfcal DD solve for international stations with pre-applied Dutch solutions

baseCommand:
    - make_config_international.py

inputs:
  - id: ms
    type: Directory
    doc: Input MeasurementSet
    inputBinding:
      position: 2
      prefix: "--ms"
      itemSeparator: " "
      separate: true

  - id: phasediff_output
    type: File?
    doc: Phasediff scoring output csv
    inputBinding:
      prefix: "--phasediff_output"
      position: 3
      itemSeparator: " "
      separate: true

  - id: forwidefield
    type: boolean?
    default: false
    doc: Wide-field imaging mode for optimising 1.2" imaging.
    inputBinding:
      prefix: "--forwidefield"
      position: 4

outputs:
    - id: dd_config
      type: File
      doc: Parameter configuration file for facetselfcal
      outputBinding:
        glob: "*.config.txt"
    - id: logfile
      type: File[]
      doc: Log files corresponding to this step
      outputBinding:
        glob: make_dd_config*.log


requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entry: $( inputs.ms )

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl

stdout: make_dd_config.log
stderr: make_dd_config_err.log