class: CommandLineTool
cwlVersion: v1.2
id: makeparsets
label: Make concat parsets
doc: |
    Generate direction concatenation parsets

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
  - id: concat_parsets
    doc: |
        The output data with corrected
        data in MeasurementSet format.
    type: File[]
    outputBinding:
      glob: '*.parset'

  - id: logfile
    type: File[]
    outputBinding:
      glob: python_concat*.log
    doc: |
        The files containing the stdout
        and stderr from the step.

arguments:
  - $( inputs.lofar_helpers.path + '/ms_helpers/concat_with_dummies.py' )
  - --make_only_parset

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
