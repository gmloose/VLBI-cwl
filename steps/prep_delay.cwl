class: CommandLineTool
cwlVersion: v1.2
id: prep_delay
label: Prepare delay
doc: |
    Converts the delay calibrator information into strings.

baseCommand:
  - python3
  - prep_delay.py

inputs:
    - id: delay_calibrator
      type: File
      doc: |
        The file containing the properties and
        coordinates of the delay calibrator.

    - id: mode
      type: string
      doc: |
        A boolean that, if set to true, ensures that
        the step will only extract the source_id and
        coordinates of the first entry of the catalogue.

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: prep_delay.py
        entry: |
          import json
          from TargetListToCoords import plugin_main as targetListToCoords

          inputs = json.loads(r"""$(inputs)""")

          target_file = inputs['delay_calibrator']['path']
          mode = inputs['mode']

          output = targetListToCoords(target_file=target_file, mode=mode)

          with open('./out.json', 'w') as fp:
              json.dump(output, fp)
hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl

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
        glob: out.json
        outputEval: $(JSON.parse(self[0].contents).coords)

    - id: logfile
      type: File[]
      outputBinding:
        glob: prep_delay*.log
      doc: |
        The files containing the stdout
        and stderr outputs from the step.

stdout: prep_delay.log
stderr: prep_delay_err.log
