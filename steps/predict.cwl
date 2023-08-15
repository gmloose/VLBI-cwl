class: CommandLineTool
cwlVersion: v1.2
id: predict_ateam
label: DP3 predict A-team
doc: |
    Simulates data for the A-team sources
    based off a skymodel. Writes the simulated
    data to the MSOUT datacolumn of the given
    MeasurementSet.

baseCommand:
  - DP3

inputs:
  - id: msin
    type: Directory
    inputBinding:
      position: 0
      prefix: msin=
      separate: false
      shellQuote: false
    doc: Input data in MeasurementSet format.

  - id: msin_datacolumn
    type: string?
    default: DATA
    inputBinding:
      position: 0
      prefix: msin.datacolumn=
      separate: false
      shellQuote: false
    doc: |
        Data column of the MeasurementSet
        from which input data is read.

  - id: msout_datacolumn
    type: string?
    default: MODEL_DATA
    inputBinding:
      position: 0
      prefix: msout.datacolumn=
      separate: false
      shellQuote: false
    doc: |
        Data column of the MeasurementSet
        into which output data is written.

  - id: skymodel
    type:
      - File?
      - string?
    default: $VLBI_DATA_ROOT/skymodels/Ateam_LBA_CC.skymodel
    inputBinding:
      position: 0
      prefix: predict.sourcedb=
      separate: false
      shellQuote: false
    doc: |
        A file containing a suitable skymodel or
        the path to such a file.

  - id: sources
    type: string[]?
    default:
        - "VirA_4_patch"
        - "CygAGG"
        - "CasA_4_patch"
        - "TauAGG"
    inputBinding:
      position: 0
      prefix: predict.sources=
      separate: false
      itemSeparator: ','
      valueFrom: '"$(self)"'
      shellQuote: false
    doc: |
        Labels of the skymodel patches to
        use to simulate visibilities.

  - id: usebeammodel
    type: boolean?
    default: true
    inputBinding:
      position: 0
      prefix: predict.usebeammodel=True
      shellQuote: false
    doc: |
        Determines whether to use the beam model.

  - id: storagemanager
    type: string?
    default: "dysco"
    inputBinding:
      prefix: msout.storagemanager=
      separate: false
      shellQuote: false
    doc: |
        String that specifies what storage manager
        to use. By default uses `dysco` compression.

  - id: databitrate
    type: int?
    default: 0
    inputBinding:
      prefix: msout.storagemanager.databitrate=
      separate: false
      shellQuote: false
    doc: |
        Number of bits per float used for columns
        containing visibilities. Default compresses
        weights only.

  - id: max_dp3_threads
    type: int?
    default: 5
    inputBinding:
      prefix: numthreads=
      separate: false
      shellQuote: false
    doc: The number of threads per DP3 process.

requirements:
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.msin)
        writable: true
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

arguments:
  - steps=[filter,predict]
  - predict.usechannelfreq=False
  - predict.operation=replace
  - predict.beamproximitylimit=2000
  - filter.baseline=[CR]S*&
  - filter.remove=False
  - msout=.

outputs:
  - id: msout
    doc: Output data in MeasurementSet format.
    type: Directory
    outputBinding:
      glob: $(inputs.msin.basename)

  - id: logfile
    type: File[]
    outputBinding:
      glob: predict_ateam*.log
    doc: |
        The files containing the stdout
        and stderr from the step.

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl:latest
  - class: ResourceRequirement
    coresMin: 6

stdout: predict_ateam.log
stderr: predict_ateam_err.log
