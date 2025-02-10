class: CommandLineTool
cwlVersion: v1.2
id: dp3_avg_dutch
label: DP3 averaging for Dutch resolution calibration
doc: Average MeasurementSet in time and frequency for direction-dependent calibration with Dutch stations in DDE-mode.

baseCommand:
  - python3

inputs:
  - id: msin
    type: Directory[]
    inputBinding:
        prefix: "--msin"
        position: 1
        separate: true
    doc: Input data in MeasurementSet format.

  - id: lofar_helpers
    type: Directory
    doc: Path to lofar_helpers directory.

outputs:
  - id: ms_avg
    doc: Concatenated averaged MeasurementSet for 6" DDE calibration.
    type: Directory
    outputBinding:
      glob: concat_6asec.ms

  - id: logfile
    type: File[]
    outputBinding:
      glob: dp3_dutch_avg*.log
    doc: |
        The files containing the stdout
        and stderr from the step.

arguments:
  - $( inputs.lofar_helpers.path + '/ms_helpers/concat_with_dummies.py' )
  - --make_only_parset
  - --msout=concat_6asec.ms
  - --time_res=16
  - --freq_res='195312.5Hz'

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.msin)
        writable: false

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl

stdout: python_concat.log
stderr: python_concat_err.log