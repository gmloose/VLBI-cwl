class: CommandLineTool
cwlVersion: v1.2
id: filter_ms_group
label: Filter MeasurementSet group
doc: |
    Collects MeasurementSets for concatenation,
    excluding dummy data.

baseCommand:
  - python3

arguments:
    - position: 0
      valueFrom: filter_ms_group.py

inputs:
  - id: group_id
    type: string
    doc: |
        A string that determines which
        MeasurementSets should be combined.

  - id: groups_specification
    type: File
    inputBinding:
      position: 1
    doc: |
        A file containing directories of MeasurementSets.

  - id: measurement_sets
    type: Directory[]
    inputBinding:
      position: 2
    doc: The total number of input MeasurementSets.

outputs:
  - id: selected_ms
    type: string[]
    outputBinding:
        loadContents: true
        glob: 'out.json'
        outputEval: $(JSON.parse(self[0].contents).selected_ms)
    doc: |
        The names of the selected MeasurementSets.

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
     - entryname: filter_ms_group.py
       entry: |
        import sys
        import json
        import os

        inputs = json.loads(r"""$(inputs)""")
        group_id = inputs['group_id']
        json_file = sys.argv[1]
        ms_list = sys.argv[2:]

        ms_by_name = { ms.split(os.path.sep)[-1]:
                       {'class':'Directory', 'path': ms} for ms in ms_list}

        output_file = 'selected_ms.json'

        with open(json_file, 'r') as f_stream:
            selected_ms = json.load(f_stream)[group_id]

        selected_ms = [os.path.basename(ms_name) for ms_name in selected_ms]
        cwl_output  = {'selected_ms': selected_ms}

        with open('./out.json', 'w') as fp:
            json.dump(cwl_output, fp)

        selected_ms = [ms_by_name[ms_name] for ms_name in selected_ms if ms_name != 'dummy.ms']


        with open(output_file, 'w') as f_stream:
            json.dump(selected_ms, f_stream)

hints:
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.measurement_sets)
        writable: true

stdout: filter_ms_by_group.log
stderr: filter_ms_by_group_err.log
