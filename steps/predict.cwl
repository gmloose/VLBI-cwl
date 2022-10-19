class: CommandLineTool
cwlVersion: v1.2
id: predict_ateam
label: predict_ateam

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
    doc: Input Measurement Set
  - id: msin_datacolumn
    type: string?
    default: DATA
    inputBinding:
      position: 0
      prefix: msin.datacolumn=
      separate: false
      shellQuote: false
    doc: Input data Column
  - id: msout_datacolumn
    type: string?
    default: MODEL_DATA
    inputBinding:
      position: 0
      prefix: msout.datacolumn=
      separate: false
      shellQuote: false
  - id: skymodel
    type:
      - File?
      - string?
    default: $PREFACTOR_DATA_ROOT/skymodels/Ateam_LBA_CC.skymodel
    inputBinding:
      position: 0
      prefix: predict.sourcedb=
      separate: false
      shellQuote: false
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
  - id: usebeammodel
    type: boolean?
    default: true
    inputBinding:
      position: 0
      prefix: predict.usebeammodel=True
      shellQuote: false
  - id: storagemanager
    type: string?
    default: "dysco"
    inputBinding:
      prefix: msout.storagemanager=
      separate: false
      shellQuote: false
  - id: databitrate
    type: int?
    default: 0
    inputBinding:
      prefix: msout.storagemanager.databitrate=
      separate: false
      shellQuote: false

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
    doc: Output Measurement Set
    type: Directory
    outputBinding:
      glob: $(inputs.msin.basename)
  - id: logfile
    type: File[]
    outputBinding:
      glob: 'predict_ateam*.log'

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl:latest

stdout: predict_ateam.log
stderr: predict_ateam_err.log
