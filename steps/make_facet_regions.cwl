class: CommandLineTool
cwlVersion: v1.2
id: facet_regions
doc: Generate a square DS9 region file centred on the observation phase centre.

baseCommand:
  - ds9facetgenerator

inputs:
  - id: ms
    type: Directory
    doc: MeasurementSet to take the phase centre from.
    inputBinding:
      position: 0
      prefix: '--ms'
  - id: dd_solutions
    type: File
    doc: Multi-direction H5parm containing the solutions of each DD calibrator.
    inputBinding:
      position: 0
      prefix: '--h5'
  - id: image_size
    type: int
    inputBinding:
      position: 0
      prefix: '--imsize'
  - id: pixel_scale
    type: float
    inputBinding:
      position: 0
      prefix: '--pixelscale'

outputs:
  - id: facet_regions
    type: File
    doc: DS9 region file containing the facet layout from Voronoi tesselation of the DD calibrators.
    outputBinding:
      glob: facets.reg

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl
