class: Workflow
cwlVersion: v1.2
id: subtract_lotss
doc: |-
  Subtract a LoTSS model from the data using results from the DDF-pipeline.
  This prepares the data for widefield imaging by subtracting sources outside a given region,
  defaulting to the approximate FWHM of the international stations.

inputs:
  - id: msin
    type: Directory[]
    doc: Input data from which the LoTSS skymodel will be subtracted.
  - id: solsdir
    type: Directory
    doc: Path to the SOLSDIR directory of the DDF-pipeline run.
  - id: ddf_rundir
    type: Directory
    doc: Directory containing the output from DDF-pipeline.
  - id: box_size
    type: float?
    doc: |-
      Side length of a square box in degrees. The LoTSS skymodel is subtracted outside of this box.
      Defaults to 2.5 degrees.
    default: 2.5
  - id: freqavg
    type: int?
    doc: Number of frequency channels to average after the subtract has been performed. Defaults to 1 (no averaging).
    default: 1
  - id: timeavg
    type: int?
    doc: Number of time slots to average after the subtract has been performed. Defaults to 1 (no averaging).
    default: 1
  - id: ncpu
    type: int?
    doc: Number of cores to use during the subtract. Defaults to 24.
    default: 24

outputs:
  - id: regionbox
    type: File
    outputSource:
      - makebox/box
    doc: DS9 region file outside of which the LoTSS skymodel has been subtracted.
  - id: mslist
    type: File[]
    outputSource:
      - makemslist/mslist
    doc: Text file containing the name of the input MS from which the LoTSS skymodel hase been subtracted.
  - id: msout
    type: Directory[]
    outputSource:
      - subtract/subms
    doc: MS from which the LoTSS skymodel has been subtracted.

steps:
  - id: makebox
    in:
      - id: ms
        source: msin
        valueFrom: $(self[0])
      - id: box_size
        source: box_size
    out:
      - id: box
    run: ../steps/makebox.cwl
    doc: Make the box outside which the LoTSS skymodel will be subtracted.

  - id: makemslist
    in:
      - id: ms
        source: msin
    out:
      - id: mslist
    run: ../steps/make_mslist.cwl
    scatter: ms
    doc: Make the list of MSes to subtract.

  - id: gather_dds3
    in:
      - id: ddf_rundir
        source: ddf_rundir
    out:
      - id: dds3sols
      - id: fitsfiles
      - id: dicomodels
      - id: facet_layout
    run: ../steps/gatherdds3.cwl
    doc: Gather the solutions and images required to subtract the LoTSS model.

  - id: fix_symlinks
    in:
      - id: ddf_rundir
        source: ddf_rundir
      - id: ddf_solsdir
        source: solsdir
    out:
      - id: logfiles
      - id: solsdir
    run: ../steps/fix_symlinks_ddf.cwl

  - id: subtract
    in:
      - id: ms
        source: msin
      - id: boxfile
        source: makebox/box
      - id: mslist
        source: makemslist/mslist
      - id: column
        valueFrom: DATA_DI_CORRECTED
      - id: solsdir
        source: fix_symlinks/solsdir
      - id: dds3sols
        source: gather_dds3/dds3sols
      - id: fitsfiles
        source: gather_dds3/fitsfiles
      - id: dicomodels
        source: gather_dds3/dicomodels
      - id: facet_layout
        source: gather_dds3/facet_layout
      - id: freqavg
        source: freqavg
      - id: timeavg
        source: timeavg
      - id: ncpu
        source: ncpu
    out:
      - id: subms
    run: ../steps/subtract.cwl
    scatter:
      - ms
      - mslist
    scatterMethod: dotproduct
    doc: Subtract the LoTSS model from the data.

requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement

