class: CommandLineTool
cwlVersion: v1.2
id: flux_scaling
doc: Script to probe flux scaling required between 6" flux density and input image flux 

baseCommand:
  - /home/pwcc62/Bootes/postprocessing/flux_scaling.py

inputs:
  - id: fitsfile
    type: File
    doc: Fits file containing flux measurements for VLBI image which require flux scaling
    inputBinding:
      position: 0
      prefix: '--fitsfile'
  - id: lotss_flux
    type: string
    doc: Column name of total flux from LoTSS
    inputBinding:
      position: 1
      prefix: '--lotss_flux'
  - id: image_flux
    type: string
    doc: Column name of total flux from image catalouge which requires flux scaling
    inputBinding:
      position: 2
      prefix: '--image_flux'

outputs:
   - id: flux_scale_plot
     type: File
     doc: Plot to probe the flux scaling between the lotss and VLBI image
     outputBinding:
       glob: flux_scaling.png
   - id: flux_scale
     type: File
     doc: Table containing flux scaling values (input/6")
     outputBinding:
       glob: flux_scale.csv
