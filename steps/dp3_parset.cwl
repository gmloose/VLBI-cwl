cwlVersion: v1.2
class: CommandLineTool
id: dp3_parset
label: DP3 with parset
doc: Run DP3 with a parset

baseCommand: DP3

inputs:
  - id: parset
    type: File
    doc: Parset for DP3
    inputBinding:
      position: 0
  - id: msin
    type: Directory[]
    doc: input MS
  - id: prefix
    type: string?
    default: ""
    doc: Optional prefix for the output MeasurementSet
  - id: max_cores
    type: int?
    default: 6
    doc: The number of CPU threads to use.

outputs:
  - id: msout
    type: Directory
    doc: Output MeasurementSet
    outputBinding:
      glob: |
        ${
          return inputs.prefix ? inputs.prefix + "*.concat.ms" : "*.concat.ms";
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
    coresMin: $(inputs.max_cores)

stdout: dp3_parset.log
stderr: dp3_parset_err.log
