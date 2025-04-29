class: CommandLineTool
cwlVersion: v1.2
id: source_finding
doc: Generates a source catalouge of input image using pyBDSF

baseCommand:
  - /home/pwcc62/Bootes/postprocessing/source_finding.py

inputs:
  - id: input_image
    type: File
    doc: fits image to create catalouge from
    inputBinding:
      position: 0
      prefix: '--input_image'
  - id: rmsbox
    type: float?
    doc: Size in pixels of noise area for pyBDSF
    default: 120
    inputBinding:
      position: 1
      prefix: '--rmsbox'
  - id: thresh_isl
    type: float?
    doc: Sigma threshold for island detections with pyBDSF                
    default: 5
    inputBinding:
      position: 2
      prefix: '--thresh_isl'
  - id: thresh_pix
    type: float?
    doc: Sigma threshold for pixel detections with pyBDSF                
    default: 5
    inputBinding:
      position: 3
      prefix: '--thresh_pix'

outputs:
   - id: catalouge
     type: File
     doc: source catalouge
     outputBinding:
       glob: source_catalouge.fits
