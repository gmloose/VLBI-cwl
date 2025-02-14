class: Workflow
cwlVersion: v1.2
id: image_facet 
label: Facet imaging
doc: |
    This workflow will image a facet at the specified angular resolution.

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
      default: 24
      doc: The number of cores that WSClean will use.

    - id: pixel_scale
      type: float
      doc: Pixel size in arcseconds.

    - id: resolution
      type: string
      default: 0.3asec
      doc: Angular resolution that will be passed to WSClean's taper argument. Its syntax follows that of WSClean.

    - id: facet_polygons
      type: File[]
      doc: DS9 region files of the individual facets.

steps:
    - id: find_image_size
      label: image_size
      in:
        - id: region
          source: facet_polygons
        - id: pixel_size
          source: pixel_scale
        - id: resolution
          source: resolution
      out:
        - id: image_name
        - id: image_size
        - id: baseline_averaging
      scatter: region
      run: ../steps/estimate_image_size.cwl

    - id: make_facet_image
      label: make_facet_image
      in:
        - id: cores
          source: number_cores
        - id: msin
          source: msin
        - id: name
          source: find_image_size/image_name
        - id: size
          source: find_image_size/image_size
        - id: baseline_averaging
          source: find_image_size/baseline_averaging
        - id: taper-gaussian
          source: resolution
        - id: scale
          source: pixel_scale
      out:
        - id: MFS_images
      scatter: [msin, name, size, baseline_averaging]
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

    - id: trim_facets
      label: Trim facets
      in:
        - id: image
          source: flatten_images/flattenedarray
          valueFrom: $(self.sort(function(a, b) { return a.basename.localeCompare(b.basename); }))
        - id: region
          source: facet_polygons
          valueFrom: $(self.sort(function(a, b) { return a.basename.localeCompare(b.basename); }))
        - id: output_name
          valueFrom: $('trimmed_'.concat(inputs.image))
      out:
        - id: trimmed_image
      scatter: [image, region]
      scatterMethod: dotproduct
      run: ../steps/trim_facet.cwl

outputs:
    - id: MFS_images
      type: File[]
      outputSource:
        - trim_facets/trimmed_image
      
