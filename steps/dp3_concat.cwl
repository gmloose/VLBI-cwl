class: CommandLineTool
cwlVersion: v1.2
id: dp3concat
label: DP3 concatenate
doc: |
    Reduces the dataset by concatenating
    subbands into frequency groups.

baseCommand:
  - DP3

inputs:
  - id: msin
    type: Directory[]
    doc: Input data in MeasurementSet format.

  - id: msin_filenames
    doc: An array of MeasurementSets to be concatenated.
    type: string[]
    inputBinding:
      position: 0
      prefix: msin=
      separate: false
      itemSeparator: ','
      valueFrom: "[$(self.join(','))]"

  - id: msout_name
    type: string
    doc: The name of the output data in MeasurementSet format.
    inputBinding:
      position: 0
      prefix: msout=
      separate: false
      shellQuote: false

  - id: storagemanager
    type: string?
    default: 'dysco'
    inputBinding:
      prefix: msout.storagemanager=
      separate: false
      shellQuote: false
      position: 0
    doc: |
        A string that specifies what storage manager
        to use. By default uses `dysco` compression.

  - id: datacolumn_in
    type: string?
    default: 'DATA'
    inputBinding:
      prefix: msin.datacolumn=
      separate: false
      shellQuote: false
      position: 0
    doc: |
        The name of the data column from
        which the input data is read.

  - id: datacolumn_out
    type: string?
    default: 'DATA'
    inputBinding:
      prefix: msout.datacolumn=
      separate: false
      shellQuote: false
      position: 0
    doc: |
        The name of the data column into
        which the output data is written.

  - id: max_dp3_threads
    type: int?
    default: 5
    inputBinding:
      prefix: numthreads=
      separate: false
      shellQuote: false
      position: 0
    doc: The number of CPU threads to use.

outputs:
  - id: msout
    doc: |
        The output data with corrected
        data in MeasurementSet format.
    type: Directory
    outputBinding:
      glob: $(inputs.msout_name)

  - id: flagged_statistics
    type: string
    outputBinding:
        loadContents: true
        glob: out.json
        outputEval: $(JSON.parse(self[0].contents).flagged_fraction_dict)
    doc: |
        A JSON formatted file containing flagging
        statistics of the data after concatenation.

  - id: logfile
    type: File[]
    outputBinding:
      glob: dp3_concat*.log
    doc: |
        The files containing the stdout
        and stderr from the step.

arguments:
  - steps=[count]
  - msin.orderms=False
  - msin.missingdata=True
  - msout.overwrite=True
  - count.savetojson=True
  - count.jsonfilename=out.json

requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.msin)
        writable: false
  - class: ResourceRequirement
    coresMin: 6

stdout: dp3_concat.log
stderr: dp3_concat_err.log
