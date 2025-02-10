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
    type: int[]
    doc: Width and height of the image in pixels.
    outputBinding:
      glob: bounding_box.json
      loadContents: true
      outputEval: $([JSON.parse(self[0].contents).width, JSON.parse(self[0].contents).height])
  - id: baseline_averaging
    type: float
    doc: Baseline averaging factor corresponding to the image size.
    outputBinding:
      glob: bounding_box.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents).blavg)

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl
