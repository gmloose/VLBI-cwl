class: CommandLineTool
cwlVersion: v1.2
id: wsclean
baseCommand:
  - wsclean
inputs:
  - id: msin
    type: Directory[]
    inputBinding:
      position: 2
      shellQuote: false
      itemSeparator: ','
      valueFrom: $(concatenate_path_wsclean(self))

label: WSClean
hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl
requirements:
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.msin)
        writable: true
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
stdout: wsclean.log
stderr: wsclean_err.log
