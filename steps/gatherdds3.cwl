class: CommandLineTool
cwlVersion: v1.2
id: gatherdds3
label: Gathers the DDS3 solutions.
doc: |-
  Gathers the final direction dependent solutions from the ddf-pipeline
  and other files required for the subtraction: the clean component model,
  the facet layout and the clean mask.

baseCommand:
  - bash
  - gather_dds3.sh

inputs:
  - id: ddfdir
    type: Directory
    doc: Directory containing the output of the ddf-pipeline run, or at the very least the required files for the subtract.

outputs:
  - id: dds3sols
    type: File[]
    doc: The final direction dependent solutions from ddf-pipeline.
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

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: gather_dds3.sh
        entry: |-
          cp $(inputs.ddfdir.path)/DDS3*.npz .
          cp $(inputs.ddfdir.path)/image_full_ampphase_di_m.NS.mask01.fits .
          cp $(inputs.ddfdir.path)/image_full_ampphase_di_m.NS.DicoModel .
          cp $(inputs.ddfdir.path)/image_dirin_SSD_m.npy.ClusterCat.npy .
