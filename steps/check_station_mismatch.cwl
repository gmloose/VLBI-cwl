class: CommandLineTool
cwlVersion: v1.2
id: check_station_mismatch
label: Check station mismatch
doc: |
    Compares the lists of stations contained in MeasurementSets
    against the list of station in the solution file and ensures
    both are consistent.

baseCommand:
    - python3
    - compare_station_list.py

inputs:
    - id: msin
      type: Directory[]
      doc: Input MeasurementSets.
      inputBinding:
        position: 0

    - id: solset
      type: File
      doc: The solution set from the LINC pipeline.

    - id: solset_name
      type: string?
      doc: Name of the solution set.
      default: vlbi

    - id: filter_baselines
      type: string?
      default: "*&"
      doc: Filter constrains for the dp3_prep_target step.

outputs:
    - id: filter_out
      type: string
      outputBinding:
        loadContents: true
        glob: out.json
        outputEval: $(JSON.parse(self[0].contents).filter_out)
      doc: |
        A JSON formatted filter command containing
        the station names to filter.

    - id: logfile
      type: File[]
      outputBinding:
        glob: compareStationMismatch*.log
      doc: |
        The files containing the stdout
        and stderr from the step.

requirements:
    - class: InlineJavascriptRequirement
    - class: InitialWorkDirRequirement
      listing:
        - entryname: compare_station_list.py
          entry: |
            import sys
            import json
            import yaml
            import os
            from compareStationListVLBI import plugin_main as compareStationList

            mss = sys.argv[1:]
            try:
                inputs = json.loads(r"""$(inputs)""")
            except:
                inputs = yaml.loads(r"""$(inputs)""")
            h5parmdb = inputs['solset']['path']
            solset_name = inputs['solset_name']
            filter = inputs['filter_baselines']
            print(mss)

            output = compareStationList(mss,
                                        h5parmdb = h5parmdb,
                                        solset_name = solset_name,
                                        filter = filter)

            filter_out = output['filter']
            cwl_output = {"filter_out": filter_out}

            with open('./out.json', 'w') as fp:
                json.dump(cwl_output, fp)

hints:
    - class: DockerRequirement
      dockerPull: vlbi-cwl

stdout: compareStationMismatch.log
stderr: compareStationMismatch_err.log
