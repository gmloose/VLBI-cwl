class: CommandLineTool
cwlVersion: v1.2
id: concatfiles
label: Concatenate files
doc: |
    Takes an array of text files and concatenates them.
    The output file can be given a file name and, optionally,
    a suffix.

baseCommand:
    - bash
    - bulk_rename.sh

requirements:
  - class: InitialWorkDirRequirement
    listing:
      - entryname: bulk_rename.sh
        entry: |
          #!/bin/bash
          set -e
          FILE_LIST=("\${@}")
          FILE_PREFIX=$(inputs.file_prefix)
          FILE_SUFFIX=$(inputs.file_suffix === null ? '' : inputs.file_suffix)
          cat "\${FILE_LIST[@]}" > $FILE_PREFIX.$FILE_SUFFIX
        writable: false
  - class: InlineJavascriptRequirement

inputs:
    - id: file_list
      type: File[]
      inputBinding:
        position: 0
      doc: The list of files to be concatenated.

    - id: file_prefix
      type: string
      doc: The output file name.

    - id: file_suffix
      type: string?
      default: log
      doc: The output file extension.

outputs:
    - id: output
      type: File
      outputBinding:
        glob: "$(inputs.file_prefix).$(inputs.file_suffix)"
      doc: The concatenated file.
