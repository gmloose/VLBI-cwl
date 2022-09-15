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
    - id: imsize
      type: int?
      default: 1600
    - id: skymodel
      type: string?
      default: MYMODEL
      doc:
    - id: pixelscale
      type: float?
      default: 0.075
      type:
    - id: robust
      type: float?
      default: -0.5
      doc:
    - id: uvmin
      type: int?
      default: 40000
      doc:
    - id: maskthreshold
      type: float[]?
      default: [7.0]
      doc:
    - id: soltype_list
      type: string[]?
      default: ['scalarphasediff','scalarphase','scalarcomplexgain']
      doc:
    - id: soltypecycles_list
      type: int[]?
      default: [0,0,2]
    - id: solint_list
      type: int[]?
      default: [4,1,100]
      doc:
    - id: nchan_list
      type: int[]?
      default: [1,1,1]
      doc:
    - id: smoothnessconstraint_list
      type: string?
      default: [10.0,2.0,10.0]
      doc:
    - id: antennaconstraint_list
      type: string?
      default: [\'alldutch\',None,None]
      doc: 
    - id: docircular
      type: boolean?
      default: true
      doc: 
    - id: forwidefield
      type: boolean?
      default: true
      doc:
    - id: stop
      type: int?
      default: 10
      doc:
    - id: no_beamcor
      type: boolean?
      default: True
      doc:
    - id: phaseupstations
      type: string?
      default: core
      doc:

outputs:
    - id: h5parm
      type: File
      doc: TEC solution file.
      outputBinding:
        glob: *.h5
    - id: logfile
      type: File[]
      outputBinding:
         glob: 'delay_solve*'

  - class: InitialWorkDirRequirement
    listing:
      - entryname: delay_solve.py
        entry: |
          import sys
          import json
          from TargetListToCoords import plugin_main as targetListToCoords

          mss = sys.argv[1:]
          inputs = json.loads(r"""$(inputs)""")

          target_file = inputs['delay_calibrator']['path']

          output = targetListToCoords(target_file=target_file)

          coords = output['coords']
          name = output['name']

          cwl_output = {}
          cwl_output['coords'] = coords
          cwl_output['name'] = name

          with open('./out.json', 'w') as fp:
              json.dump(cwl_output, fp)


hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl

stdout: delay_solve.log
stderr: delay_solve_err.log
