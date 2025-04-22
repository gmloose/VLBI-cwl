cwlVersion: v1.2
class: CommandLineTool
id: dp3_parset
label: DP3 with parset
doc: Run DP3 with a parset, optionally renaming output using a prefix

baseCommand: ./dp3_wrapper.sh

inputs:
  - id: parset
    type: File
    doc: Parset for DP3
    inputBinding:
      position: 0
  - id: msin
    type: Directory[]
    doc: Input MS
    inputBinding:
      position: 2
      prefix: ""
      itemSeparator: " "
  - id: prefix
    type: string?
    default: ""
    doc: Optional prefix for the output MeasurementSet
    inputBinding:
      position: 1

outputs:
  - id: msout
    type: Directory
    doc: Output MeasurementSet
    outputBinding:
      glob: |
        ${
          return inputs.prefix ? inputs.prefix + ".concat.ms" : "*.concat.ms";
        }
  - id: logfile
    type: File[]
    outputBinding:
      glob: dp3_parset*.log
    doc: |
      The files containing the stdout and stderr from the step.

requirements:
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.msin)

  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl
  - class: ResourceRequirement
    coresMin: 6

stdout: dp3_parset.log
stderr: dp3_parset_err.log
