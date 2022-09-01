class: CommandLineTool
cwlVersion: v1.2
id: prep_delay
label: prep_delay

baseCommand:
  - python3
  - prep_delay.py

inputs:
    - id: delay_calibrator
      type: File
      doc: file containing target info.

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: prep_delay.py
        entry: |
          import sys
          import json
          from TargetListToCoords import plugin_main as targetListToCoords

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

outputs:
    - id: source_id
      type: string
      doc: Catalogue source ID.
      outputBinding:
        loadContents: true
        glob: out.json
        outputEval: $(JSON.parse(self[0].contents).name)
    - id: coordinates
      type: string
      doc: Catalogue source coordinates.
      outputBinding:
        loadContents: true
        glob: 'out.json'
        outputEval: $(JSON.parse(self[0].contents).coords)
    - id: logfile
      type: File[]
      outputBinding:
        glob: 'prep_delay*.log'

hints:
  DockerRequirement:
    dockerPull: vlbi-cwl

stdout: prep_delay.log
stderr: prep_delay_err.log
