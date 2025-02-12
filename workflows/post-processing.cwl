cwlVersion: v1.2
class: Workflow
id: Post-Processing
label: Post Processing
doc: |
      This runs the post-processing step required to adjust wide-field images to comply with LoTSS fields. A catalouge will be generated using pyBDSF, astrometry offset will be analysed as well as the flux scaling require by comparing the image with 6".

inputs:
    - id: input_image
      type: File
      doc: The input image to produce catalouge
    - id: rmsbox
      type: float?
      default: 120
      doc: rmsbox for pyBDSF
    - id: thresh_isl
      type: float?
      default: 5
      doc: Sigma threshold for island detections with pyBDSF
    - id: thresh_pix
      type: float?
      default: 5
      doc: Sigma threshold for pixels with pyBDSF
    - id: crossmatch_fits
      type: File
      doc: The catalouge to base astrometry of sources
    - id: source_fits
      type: File
      doc: The catalouge created from the image astromerty needs to be corrected for
    - id: ra1
      type: string
      doc: Column name of RA from crossmatch catalouge
    - id: ra2
      type: string
      doc: Column name of RA from pyBDSF catalouge which needs correcting
    - id: dec1
      type: string
      doc: Column name of Dec from crossmatch catalouge
    - id: dec2
      type: string
      doc: Column name of Dec from pyBDSF catalouge which needs correcting
    - id: error
      type: float?
      default: 5
      doc: Error for source location in pyBDSF
    - id: fitsfile
      type: File
      doc: Source catalouge with both image and 6" flux values
    - id: lotss_flux
      type: string
      doc: Column name of total flux from 6" catalouge
    - id: image_flux
      type: string
      doc: Column anme of total flux from image catalouge

steps:
        - id: source_finding
          label: Source Finder
          in:
            - id: input_image
              source: input_image
            - id: rmsbox
              source: rmsbox
            - id: thresh_isl
              source: thresh_isl
            - id: thresh_pix
              source: thresh_pix
          out:
            - id: catalouge
          run: source_finding.cwl

        - id: astrometry
          label: astrometry
          in:
            - id: crossmatch_fits
              source: crossmatch_fits
            - id: source_fits
              source: source_finding/catalouge
            - id: ra1
              source: ra1
            - id: ra2
              source: ra2
            - id: dec1
              source: dec1
            - id: dec2
              source: dec2
            - id: error
              source: error
          out:
            - id: ra_offset
            - id: dec_offset
            - id: astrometry_plot
            - id: match_submission
            - id: source_matches
          run: astrometry.cwl

        - id: flux_scaling
          label: Flux Scaling
          in:
             - id: fitsfile
               source: astrometry/source_matches
             - id: lotss_flux
               source: lotss_flux
             - id: image_flux
               source: image_flux
          out:
             - id: flux_scale
             - id: flux_scale_plot
          run: flux_scaling.cwl
outputs:
        - id: source_finding_out
          type: File
          outputSource: source_finding/catalouge
        - id: astrometry_out
          type: File[]
          outputSource:
            - astrometry/ra_offset
            - astrometry/dec_offset
            - astrometry/astrometry_plot
            - astrometry/match_submission
            - astrometry/source_matches
        - id: flux_scaling_out
          type: File[]
          outputSource:
            - flux_scaling/flux_scale
            - flux_scaling/flux_scale_plot

requirements:
  - class: MultipleInputFeatureRequirement
