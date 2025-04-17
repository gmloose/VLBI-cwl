class: CommandLineTool
cwlVersion: v1.2
id: makeparsets
label: Make concat parsets
doc: |
    Generate parsets for post-calibration of main calibrators

baseCommand:
  - make_postcal_parsets.py

inputs:
  - id: msin
    type: Directory[]
    inputBinding:
        prefix: "--msin"
        position: 1
        separate: true
    doc: Input data in MeasurementSet format.
  - id: polygon_info_csv
    type: File
    inputBinding:
        prefix: "--polygon_info"
        position: 2
        separate: true
    doc: Polygon information CSV

outputs:
  - id: split_parsets
    doc: Parsets to split calibrators
    type: File[]
    outputBinding:
      glob: '*.parset'

  - id: logfile
    type: File[]
    outputBinding:
      glob: split_parset*.log
    doc: |
        The files containing the stdout
        and stderr from the step.

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl

stdout: split_parset.log
stderr: split_parset_err.log
