class: CommandLineTool
cwlVersion: v1.2
id: cut_fits_with_region

baseCommand: cut_fits_with_region.py

inputs:
  - id: region
    type: File
    doc: DS9 region file describing the facet.
    inputBinding:
      position: 0
      prefix: '--region'
  - id: output_name
    type: string
    doc: Name for the output file.
    inputBinding:
      position: 0
      prefix: '--output_name'
  - id: image
    type: File
    doc: FITS image to trim with the given region.
    inputBinding:
      position: 1

outputs:
  - id: trimmed_image
    type: File
    doc: FITS image trimmed to the provided region.
    outputBinding:
      glob: '*.fits'

requirements:
    - class: InlineJavascriptRequirement
