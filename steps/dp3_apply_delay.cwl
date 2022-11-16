cwlVersion: v1.2
class: CommandLineTool
id: dp3_apply_delay
label: dp3_apply_delay

baseCommand: DP3

arguments:
    - 'steps=[applyphase,applyamp,count]'
    - applyphase.type=applycal
    - applyphase.parmdb=$(inputs.h5parm.path)
    - applyphase.solset=$(inputs.solset)
    - applyamp.type=applycal
    - applyamp.parmdb=$(inputs.h5parm.path)
    - applyamp.solset=$(inputs.solset)

inputs:
    - id: msin
      type: Directory
      doc: Input measurement set.
      inputBinding:
        position: 0
        prefix: msin=
        separate: false
    - id: h5parm
      type: File
      doc: Delay calibrator solution set.
    - id: solset
      type: string?
      default: sol001
      doc: solution set in the h5parm to be used.
    - id: numthreads
      type: int?
      default: 5
      inputBinding:
        prefix: numthreads=
        separate: false
    - id: msin_datacolumn
      type: string?
      default: DATA
      inputBinding:
        prefix: msin.datacolumn=
        separate: false
        shellQuote: false
    - id: baseline
      type: string?
      default: '*&'
      inputBinding:
        prefix: msin.baseline=
        separate: false
    - id: msout_datacolumn
      type: string?
      default: CORRECTED_DATA
      inputBinding:
        prefix: msout.datacolumn=
        separate: false
    - id: storagemanager
      type: string?
      default: dysco
      inputBinding:
        prefix: msout.storagemanager=
        separate: false
    - id: fullresflags
      type: boolean?
      default: False
      inputBinding:
        prefix: msout.writefullresflag=
        separate: false
    - id: phase_correction
      type: string?
      default: phase000
      inputBinding:
        prefix: applyphase.correction=
        separate: false
    - id: phase_weights
      type: boolean?
      default: False
      inputBinding:
        prefix: applyphase.updateweights=
        separate: false
    - id: amplitude_correction
      type: string?
      default: amplitude000
      inputBinding:
        prefix: applyamp.correction=
        separate: false
    - id: amplitude_weights
      type: boolean?
      default: False
      inputBinding:
        prefix: applyamp.updateweights=
        separate: false

outputs:
    - id: msout
      type: Directory
      outputBinding:
        glob: $(msin.basename)
    - id: logfile
      type: File[]
      outputBinding:
        glob: 'dp3_apply_delay*.log'

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl

requirements:
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.msin)
        writable: true
  - class: InplaceUpdateRequirement
    inplaceUpdate: true

stdin: dp3_apply_delay.log
stderr: dp3_apply_delay_err.log

