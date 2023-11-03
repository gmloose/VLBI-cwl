class: CommandLineTool
cwlVersion: v1.2
id: Ateamclipper
label: A-team clipper
doc: |
    Clipping of the A-team sources
    using LINC`s Ateamclipper script.

baseCommand:
  - python3
  - Ateamclipper.py

inputs:
  - id: msin
    type:
      - Directory
      - type: array
        items: Directory
    inputBinding:
      position: 0
    doc: Input measurementSet.

  - id: number_cores
    type: int?
    default: 12
    doc: |
     Number of cores to use per job for tasks with
     high I/O or memory.

  - id: linc_libraries
    type: File[]
    doc: |
      Scripts and reference files from the
      LOFAR INitial calibration pipeline.
      Must contain `Ateamclipper.py`.

outputs:
  - id: msout
    doc: Output MeasurementSet.
    type: Directory
    outputBinding:
      glob: $(inputs.msin.basename)

  - id: logfile
    type: File[]
    outputBinding:
      glob: Ateamclipper.log
    doc: The files containing the stdout from the step.

  - id: output
    type: File
    outputBinding:
      glob: Ateamclipper.txt
    doc: A text file containing flagging fraction statistics.

hints:
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.msin)
        writable: true
      - entry: $(inputs.linc_libraries)
  - class: InplaceUpdateRequirement
    inplaceUpdate: true
  - class: DockerRequirement
    dockerPull: vlbi-cwl
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.number_cores)

stdout: Ateamclipper.log
stderr: Ateamclipper_err.log
