class: CommandLineTool
cwlVersion: v1.1
id: order_by_direction
label: Order by Direction
doc: |
  This tool takes an array of arrays of directories containing MeasurementSet files which are in groups of frequency.
  It re-orders them such that they are in groups of direction ready to be concatenated.

baseCommand: 
  - python3
  - order_by_direction.py

inputs:
  - id: msin
    type:
      type: array
      items:
        type: array
        items: Directory
    inputBinding:
      position: 0
    doc: Array of arrays of directories containing the MeasurementSet files to be ordered

requirements:
    - class: InlineJavascriptRequirement
    - class: InitialWorkDirRequirement
      listing:
        - entryname: order_by_direction.py
          entry: |
            import json

            mss = $(inputs)['msin']
            print(mss)

            #The line below does the re-ordering. It performs the transpose of a list.
            output = list(map(list, zip(*mss))) 

            cwl_output = {}

            cwl_output['msout'] = output

            print(cwl_output)

            # The results are written to this file to circumvent the size
            # restrictions placed on files that can be parsed by outputEval. See
            # https://www.commonwl.org/v1.2/CommandLineTool.html#CommandOutputBinding
            with open('$(runtime.outdir)/cwl.output.json', 'w') as fp:
              json.dump(cwl_output, fp)

outputs:
  - id: msout
    type:
      type: array
      items:
        type: array
        items: Directory
    outputBinding:
        glob: $(runtime.outdir)/cwl.output.json
        outputEval: $(self.msout)
    doc: Array of arrays of directories containing the MeasurementSet 
      files ordered by direction.
