cwlVersion: v1.2
class: CommandLineTool
id: copyST_gains
label: copyST_gains

baseCommand:
    - python3
    - run_h5merger.py

inputs:
    - id: msin
      type: Directory
      doc: Input measurement set.
    - id: selfcal_solution
      type: File
      doc: Self-calibration solution h5 file.
    - id: h5merger
      type: Directory
      doc: Path to a copy of the LOFAR_helper scripts.

outputs:
    - id: h5parm
      type: File
      doc: |
        Selfcal_solution with linear polarization and 
        addition of ST001 solutions for core stations.
      outputBinding:
        glob: '*_toapply.h5'
    - id: logfile
      type: File[]
      outputBinding:
        glob: copyST_gains*.log

requirements:
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.selfcal_solution)
        writable: true
      - entryname: run_h5merger.py
        entry: |
            import subprocess
            import json

            inputs = json.loads(r"""$(inputs)""")
            msin = inputs['msin']['path']
            h5parm = inputs['selfcal_solution']
            # ensure that the path points at the actual script
            h5_merger = inputs['h5merger']['path'] + '/h5_merger.py'

            h5parm_in = h5parm['basename']
            h5parm_out = h5parm['basename'].replace('.h5','_toapply.h5')

            ## run on the h5parm using a measurement set for the core station info
            h5_modify = subprocess.run(['python3', f'{h5_merger}',
                                        '--ms', f'{msin}',
                                        '--h5_tables', f'{h5parm_in}',
                                        '--h5_out', f'{h5parm_out}',
                                        '--circ2lin', '--add_cs',
                                        '--h5_time', f'{h5parm_in}'],
                                        capture_output=True, text=True)
            
            print("run_h5merger stdout:", h5_modify.stdout)
            print("run_h5merger stderr:", h5_modify.stderr)

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl

stdout: copyST_gains.log
stderr: copyST_gains_err.log
