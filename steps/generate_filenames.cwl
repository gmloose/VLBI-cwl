cwlVersion: v1.2
class: CommandLineTool
id: generate_filenames
label: Generate direction filenames
doc: |
    Take a MeasurementSet and a list of target sources, and
    creates a list of strings where the MeasurementSet name
    and target names are concatenated.

baseCommand: [python3, concatenate.py]

inputs:
    - id: msin
      type: Directory
      doc: A MeasurementSet to extract the name from.

    - id: source_ids
      type: string
      doc: A string containing a list of target source IDs.

outputs:
    - id: msout_names
      type: string
      doc: |
        a string containing the names for the MeasurementSets
        for each direction.
      outputBinding:
        loadContents: true
        glob: out.json
        outputEval: $(JSON.parse(self[0].contents).filenames)

requirements:
    - class: InlineJavascriptRequirement
    - class: InitialWorkDirRequirement
      listing:
        - entryname: concatenate.py
          entry: |
            import json

            msin = "$(inputs.msin.basename)".split(".")[0]
            source_ids = "$(inputs.source_ids)".split(",")
            list = [ msin + x + ".mstargetphase" for x in source_ids]
            result = {'filenames' : "[" + ",".join(list) + "]"}
            with open('./out.json', 'w') as fp:
                json.dump(result, fp)
