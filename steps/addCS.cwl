cwlVersion: v1.2
class: CommandLineTool
id: addCS
label: Add core stations to h5parm
doc: Use h5_merger to add back the core stations to the h5parm, which had been replaced by ST001 (super station)

baseCommand:
  - python3

inputs:
  - id: ms
    type: Directory
    doc: Input MeasurementSet
    inputBinding:
      position: 2
      prefix: "-ms"
      itemSeparator: " "
      separate: true
  - id: h5parm
    type: File?
    doc: Input h5parm
    inputBinding:
      prefix: "-in"
      position: 3
      itemSeparator: " "
      separate: true
  - id: facetselfcal
    type: Directory
    doc: facetselfcal directory

outputs:
    - id: addCS_out_h5
      type: File
      doc: h5parm with preapplied solutions and core stations
      outputBinding:
        glob: "*.addCS.h5"
    - id: logfile
      type: File[]
      doc: Log files corresponding to this step
      outputBinding:
        glob: h5_merger_dd*.log


arguments:
  - $( inputs.facetselfcal.path + '/submods/h5_merger.py' )
  - --h5_out=$( inputs.h5parm.basename + '.addCS.h5' )
  - --add_ms_stations

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl

stdout: h5_merger_dd.log
stderr: h5_merger_dd_err.log