class: CommandLineTool
cwlVersion: v1.2
id: collectfiles
label: Collect files
doc: |
    This step stores an array of files
    or directories in an a directory.

baseCommand:
  - bash
  - collect_files.sh

inputs:
  - id: start_directory
    type: Directory?
    doc: |
        A string of the directory that
        should contain the output directory.

  - id: files
    type:
      - File
      - type: array
        items:
           - File
           - Directory
    inputBinding:
      position: 0
    doc: |
        The files or directories that should be placed
        in the output directory.

  - id: sub_directory_name
    type: string
    doc: |
        A string that determines
        the name of the output directory.

outputs:
  - id: dir
    type: Directory
    outputBinding:
        glob: |
          $(inputs.start_directory === null ? inputs.sub_directory_name: inputs.start_directory.basename)

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: collect_files.sh
        writable: false
        entry: |
          #!/bin/bash
          set -e
          BASE_DIR="$(inputs.start_directory === null ? "" : inputs.start_directory.basename)"
          SUB_DIR="$(inputs.sub_directory_name)"
          if [ -z "$BASE_DIR" ]
          then
          OUTPUT_PATH=$SUB_DIR
          else
          OUTPUT_PATH=$BASE_DIR/$SUB_DIR
          fi
          echo $OUTPUT_PATH
          mkdir -p $OUTPUT_PATH
          cp -rL $* $OUTPUT_PATH
