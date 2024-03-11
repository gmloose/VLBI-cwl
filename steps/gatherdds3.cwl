class: CommandLineTool
cwlVersion: v1.2
id: gatherdds3
doc: |-
  Gathers the final direction dependent solutions from the DDF-pipeline
  and other files required for the subtraction: the clean component model,
  the facet layout and the clean mask.

baseCommand:
  - gather_dds3.sh

arguments:
  - $(inputs.ddfdir.path)

inputs:
  - id: ddfdir
    type: Directory
    doc: |-
      Directory containing the output of the DDF-pipeline run,
      or at the very least the required files for the subtract.

outputs:
  - id: dds3sols
    type: File[]
    doc: The final direction dependent solutions from DDF-pipeline.
    outputBinding:
      glob: DDS3*.npz
  - id: fitsfiles
    type: File[]
    doc: FITS files required for the subtract. This is the clean mask.
    outputBinding:
      glob: image*.fits
  - id: dicomodels
    type: File[]
    doc: Clean component model required for the subtract.
    outputBinding:
      glob: image*.DicoModel
  - id: facet_layout
    type: File
    doc: Numpy data containing the facet layout used during imaging.
    outputBinding:
      glob: image*.npy

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl
