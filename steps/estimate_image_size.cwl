class: CommandLineTool
cwlVersion: v1.2
id: estimate_facet_size
doc: Estimates the required image size to image the facet.

baseCommand:
  - ../scripts/estimate_facet_size.py

inputs:
  - id: region
    type: File
    doc: DS9 region file describing the facet.
    inputBinding:
      position: 0
      prefix: '--region'
  - id: pixel_size
    type: float
    doc: Pixel size of the image that will be made.
    inputBinding:
      position: 0
      prefix: '--pixel_size'
  - id: padding
    type: float?
    default: 0.0
    inputBinding:
      position: 0
      prefix: '--padding'

outputs:
  - id: image_size
    type: File
    doc: Text file containing the width and height of the image.
    outputBinding:
      glob: bounding_box.txt
      loadContents: true
      outputEval: $(self[0].contents)

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl
