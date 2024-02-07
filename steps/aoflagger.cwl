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

    - id: keepstatistics
      type: boolean?
      default:  true
      inputBinding:
        prefix: aoflagger.keepstatistics=True
      doc: Indicates whether statistics should be written to file.

    - id: linc_libraries
      type: File[]
      doc: |
        Scripts and reference files from the
        LOFAR INitial calibration pipeline.
        Must contain `lofar-default.lua`.

    - id: max_dp3_threads
      type: int?
      default: 5
      inputBinding:
        position: 0
        prefix: numthreads=
        separate: false
        shellQuote: false
      doc: The number of threads per DP3 process.

    - id: memory
      type: 
        - int
        - float
      inputBinding:
        position: 0
        prefix: aoflagger.memorymax=
        separate: false
        shellQuote: false
        valueFrom: "$((self/1000 > 30) ? self/1000 : 30)"
      doc: The amount of maximum amount of memory to use in GB. 

arguments:
    - steps=[aoflagger]
    - aoflagger.strategy=lofar-default.lua
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
      - entry: $(inputs.linc_libraries)
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 6
    ramMin: $(inputs.memory)

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl

stdout: aoflag.log
stderr: aoflag_err.log
