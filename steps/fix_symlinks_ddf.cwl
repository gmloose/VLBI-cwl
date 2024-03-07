class: CommandLineTool
cwlVersion: v1.2
id: fixsymlinks
doc: |-
  Gathers the final direction dependent solutions from the DDF-pipeline
  and other files required for the subtraction: the clean component model,
  the facet layout and the clean mask.

baseCommand:
  - fix_symlinks_ddf.sh

arguments:
  - $(inputs.ddf_rundir.path)
  - $(inputs.ddf_solsdir.basename)

inputs:
  - id: ddf_rundir
    type: Directory?
    doc: |
      Path to the directory of the ddf-pipeline run, where
      the output files for applying DI solutions and subtracting
      LoTSS can be found.
  - id: ddf_solsdir
    type: Directory?
    doc: |
      Path to the SOLSDIR directory of the ddf-pipeline run,

outputs:
  - id: solsdir
    type: Directory
    outputBinding:
      glob: SOLSDIR
    doc: |
      SOLSDIR with symlinks fixed.
  - id: logfiles
    type: File[]
    outputBinding:
      glob: fixsymlinks*.log
    doc: |
        The files containing the stdout
        and stderr from the step.

requirements:
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.ddf_solsdir)

stdout: fixsymlinks.log
stderr: fixsymlinks_err.log
