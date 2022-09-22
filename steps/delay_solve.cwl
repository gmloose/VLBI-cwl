cwlVersion: v1.2
class: CommandLineTool
id: delay_solve
label: delay_solve

baseCommand:
    - python3
    - delay_solve.py

inputs:
    - id: msin
      type: Directory
      doc: Delay calibrator measurement set.
    - id: configfile
      type: File
      doc: Configuration options for self-calibration.
    - id: selfcal
      type: File
      doc: External self-calibration script.
    - id: h5merger
      type: File
      doc: External LOFAR helper scripts for mergin h5 files.

outputs:
    - id: logfile
      type: File[]
      outputBinding:
         glob: 'delay_solve*.log'

requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.configfile)
      - entry: $(inputs.h5merger)
      - entryname: delay_solve.py
        entry: |
          import subprocess
          import sys
          import json

          inputs = json.loads(r"""$(inputs)""")
            
          msin = inputs['msin']['path']
          configfile = inputs['configfile']['path']
          skymodel = inputs['msin']['path'] + "/skymodel"
          selfcal = inputs['selfcal']['path']
          h5merge = inputs['h5merger']['path']

          print(f'{msin}\n{skymodel}\n{selfcal}\n{h5merge}\n{configfile}')

          subprocess.run(f'python3 {selfcal} {msin}', shell = True) #.format(os.path.join(helperscriptspath,'facetselfcal.py'), msin ) )

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl

stdout: delay_solve.log
stderr: delay_solve_err.log
