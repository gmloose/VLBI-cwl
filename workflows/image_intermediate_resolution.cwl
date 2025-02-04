class: Workflow
cwlVersion: v1.2
id: image_intermediate_resolution
label: Intermediate resolution imaging
doc: |
    This workflow will make an intermediate resolution image.

requirements:
    - class: InlineJavascriptRequirement
    - class: StepInputExpressionRequirement

inputs:
    - id: msin
      type: Directory[]
      doc: MeasurementSets that will be imaged.

    - id: number_cores
      type: int?
      default: 12
      doc: The minimum number of cores that should be available for steps that require high I/O.

steps:
    - id: make_facet_layout
      label: make_facet_layout
      in:
        - id: ms
          source: msin
          pickValue: first_non_null
      out:
        - id: facet_region
      run: ../steps/make_facet_regions.cwl

outputs:
    - id: facet_region
      outputSource:
        - make_facet_layout/facet_region
      type: File
      doc: |
        DS9 region file containing the facet layout.
