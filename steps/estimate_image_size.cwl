class: CommandLineTool
cwlVersion: v1.2
id: estimate_facet_size
doc: Estimates the appropriate image size and baseline averaging for imaging the facet.

baseCommand:
  - estimate_facet_size.py

inputs:
  - id: region
    type: File
    doc: DS9 region file describing the facet.
    inputBinding:
      position: 0
      prefix: '--region'
  - id: resolution
    type: string
    doc: Angular resolution that will be passed to WSClean. Used here for naming the output image.
    inputBinding:
      position: 0
      prefix: '--resolution'
  - id: pixel_size
    type: float
    doc: Pixel size in arcseconds of the image that will be made.
    inputBinding:
      position: 0
      prefix: '--pixel_size'
  - id: padding
    type: float?
    doc: Factor by which to multiply the calculated image size.
    default: 1.0
    inputBinding:
      position: 0
      prefix: '--padding'

outputs:
  - id: image_name
    type: string
    doc: Name of the image that will be created.
    outputBinding:
      glob: bounding_box.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents).name)
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

requirements:
    - class: InlineJavascriptRequirement
