cwlVersion: v1.2
class: CommandLineTool
id: select_bright_sources
label: Select sources above flux density threshold
doc: Select bright sources above flux_density_cut and within 2.5deg box (see Sweijen et al. 2022; de Jong et al. 2024)

baseCommand:
    - pre_flux_selection.py

inputs:
    - id: msin
      type: Directory[]
      doc: MeasurementSet
      inputBinding:
        position: 1
        prefix: "--ms"
        valueFrom: "$(inputs.msin[0])"
        itemSeparator: " "
        separate: true
    - id: image_cat
      type: File
      doc: LoTSS 6" catalogue
      inputBinding:
        position: 2
        prefix: "--catalogue"
        itemSeparator: " "
        separate: true
    - id: flux_density_cut
      type: float
      doc: Flux density cut in mJy
      inputBinding:
        prefix: "--fluxcut"
        position: 3
        itemSeparator: " "
        separate: true

outputs:
    - id: bright_cat
      type: File
      doc: Output catalogue after selection in CSV format
      outputBinding:
        glob: "bright_cat.csv"
    - id: logfile
      type: File[]
      doc: Log files corresponding to this step
      outputBinding:
        glob: make_dd_config*.log

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl

stdout: select_bright_sources.log
stderr: select_bright_sources_err.log