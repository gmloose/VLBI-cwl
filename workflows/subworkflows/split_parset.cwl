cwlVersion: v1.2
class: Workflow
id: split_parset
label: Create parset split directions
doc: |
    This workflow does the following:

    * It creates a list of target direction coordinates (RA, Dec).
    * For each direction it creates a name for the MeasurementSet
    * It creates a parameter set file for DP3 to phase shift the
      target data to each direction, and to store that phase-shifted
      data in a MeasurementSet with the name generated before.

    The output is a DP3 parameter set file.

inputs:
    - id: msin
      type: Directory
      doc: The input data in MeasurementSet format.

    - id: image_cat
      type: File
      doc: |
        The image catalogue in CSV format,
        containing the target directions.

outputs:
    - id: parset
      type: File
      doc: The parameterset file for DP3.
      outputSource: generate_parset/parset

steps:
    - id: get_coordinates
      label: Get target ID and coordinates
      in:
        - id: delay_calibrator
          source: image_cat
      out:
        - id: source_id
        - id: coordinates
        - id: logfile
      run: ../../steps/prep_delay.cwl

    - id: generate_filenames
      label: Generate MeasurementSet output names
      in:
        - id: msin
          source: msin
        - id: source_ids
          source: get_coordinates/source_id
      out:
        - id: msout_names
      run: ../../steps/generate_filenames.cwl

    - id: generate_parset
      label: Generate direction parset.
      in:
        - id: msout_names
          source: generate_filenames/msout_names
        - id: phase_centers
          source: get_coordinates/coordinates
      out:
        - id: parset
      run: ../../steps/generate_parset_split.cwl
