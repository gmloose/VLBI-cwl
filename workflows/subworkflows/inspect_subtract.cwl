class: Workflow
cwlVersion: v1.2
id: concatenation
label: Subtract_inspection
doc: |
    Workflow to determine the subtract quality in image space. This consists of 2 steps:
    - Average data, remove international stations, and concat MS
    - Make 20" image with wsclean

inputs:
  - id: msin
    type: Directory[]
    doc: |
        Input data in MeasurementSets after subtract.

steps:
  - id: dp3_avg_remove_int_stations
    in:
      - id: msin
        source: msin
    out:
      - id: msout
    run: ../../steps/dp3_avg_remove_int_stations.cwl
    label: dp3_avg_remove_int_stations
  - id: imaging_subtract
    in:
      - id: ms
        source: dp3_avg_remove_int_stations/msout
    out:
      - id: fits
    run: ../../steps/wsclean_subtract.cwl
    label: imaging_subtract


outputs:
  - id: fits
    outputSource:
        - imaging_subtract/fits
    type: File
    doc: Fits image with subtracted field of view

requirements:
    - class: InlineJavascriptRequirement
    - class: StepInputExpressionRequirement
