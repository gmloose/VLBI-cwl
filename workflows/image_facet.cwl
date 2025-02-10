class: Workflow
cwlVersion: v1.2
id: image_facet 
label: Sub-arcsecond resolution facet imaging
doc: |
    This workflow will make a sub-arcsecond resolution images of a facet.

requirements:
    - class: InlineJavascriptRequirement
    - class: StepInputExpressionRequirement
    - class: ScatterFeatureRequirement

inputs:
    - id: msin
      type: Directory[]
      doc: MeasurementSets that will be imaged.

    - id: number_cores
      type: int?
      default: 12
      doc: The minimum number of cores that should be available for steps that require high I/O.

    - id: pixel_scale
      type: float
      doc: Pixel size in arcseconds.

    - id: resolution
      type: float?
      default: 0.3
      doc: Angular resolution in arcseconds that will be passed to WSClean's taper argument.

    - id: facet_polygons
      type: File[]
      doc: DS9 region files representing each facet.

steps:
    - id: find_image_size
      label: image_size
      in:
        - id: region
          source: facet_polygons
        - id: pixel_size
          source: pixel_scale
      out:
        - id: image_size
        - id: baseline_averaging
      scatter: region
      run: ../steps/estimate_image_size.cwl

    - id: make_facet_image
      label: make_facet_image
      in:
        - id: msin
          source: msin
        - id: size
          source: find_image_size/image_size
        - id: baseline_averaging
          source: find_image_size/baseline_averaging
        - id: taper-gaussian
          source: resolution
      out:
        - id: MFS_images
      scatter: [msin, size, baseline_averaging]
      scatterMethod: dotproduct
      run: ../steps/wsclean.cwl

    - id: flatten_images
      label: Flatten images
      in:
        - id: nestedarray
          source: make_facet_image/MFS_images
      out:
        - id: flattenedarray
      run: ../steps/flatten.cwl

outputs:
    - id: MFS_images
      type: File[]
      outputSource:
        - flatten_images/flattenedarray
      
