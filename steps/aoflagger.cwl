class: CommandLineTool
cwlVersion: v1.2
id: aoflagging
label: AOflagger
doc: |
    Runs the AO-flagging module of DP3.

baseCommand: DP3

inputs:
    - id: msin
      type: Directory
      inputBinding:
        position: 0
        prefix: msin=
        separate: false
        shellQuote: false
      doc: Data to be processed in MeasurementSet format.

    - id: msin_datacolumn
      type: string?
      default: DATA
      inputBinding:
        position: 0
        prefix: msin.datacolumn=
        separate: false
        shellQuote: true
      doc: The data column of the MeasurementSet to be processed.

    - id: memoryperc
      type: int?
      default: 15
      inputBinding:
        position: 0
        prefix: aoflagger.memoryperc=
        separate: false
        shellQuote: false
      doc: Indicates the percentage of pc memory to use

    - id: keepstatistics
      type: boolean?
      default:  true
      inputBinding:
        prefix: aoflagger.keepstatistics=True
      doc: Indicates whether statistics should be written to file.

    - id: strategy
      type:
        - File?
        - string?
      default: $VLBI_DATA_ROOT/rfistrategies/lofar-default.lua
      inputBinding:
        position: 0
        prefix: aoflagger.strategy=
        separate: false
        shellQuote: false
      doc: The name of the strategy file to use.

    - id: max_dp3_threads
      type: int?
      default: 5
      inputBinding:
        position: 0
        prefix: numthreads=
        separate: false
        shellQuote: false
      doc: The number of threads per DP3 process.

arguments:
    - steps=[aoflagger]
    - aoflagger.type=aoflagger
    - msout=.

outputs:
  - id: msout
    doc: Output MeasurementSet.
    type: Directory
    outputBinding:
      glob: $(inputs.msin.basename)

  - id: logfile
    type: File[]
    outputBinding:
      glob: aoflag*.log
    doc: |
        The files containing the stdout
        and stderr from the step.

requirements:
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.msin)
        writable: true
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    coresMin: 6

hints:
  DockerRequirement:
    dockerPull: vlbi-cwl

stdout: aoflag.log
stderr: aoflag_err.log
