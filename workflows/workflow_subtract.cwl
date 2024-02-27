class: Workflow
cwlVersion: v1.2
id: subtract_lotss
label: Subtract a LoTSS model from the data.
doc: |-
  Subtract a LoTSS model from the data using results from the ddf-pipeline.
  This prepares the data for widefield imaging by subtracting sources outside a given region,
  defaulting to the approximate FWHM of the international stations.

inputs:
  - id: msin
    type: Directory
    doc: Input data from which the LoTSS skymodel will be subtracted.
  - id: solsdir
    type: Directory
    doc: Path to the SOLSDIR directory of the ddf-pipeline run.
  - id: ddfdir
    type: Directory
    doc: Directory containing the output from ddf-pipeline.
  - id: box_size
    type: float?
    doc: Side length of a square box in degrees. The LoTSS skymodel is subtracted outside of this box. Defaults to 2.5 degrees.
    default: 2.5
  - id: force_mslist
    type: string?
    doc: |-
      Set to 'force' to force the generation of the mslist required for the subtract.
      This is needed if less than 18 MS are present. Defaults to 'force'.
    default: "force"
  - id: delaycalcol
    type: string?
    doc: Column from which to  subtract the LoTSS skymodel. Defaults to DATA_DI_CORRECTED.
    default: "DATA_DI_CORRECTED"
  - id: freqavg
    type: int?
    doc: Factor to average with in frequency after the subtract has been performed. Defaults to 1 (no averaging).
    default: 1
  - id: timeavg
    type: int?
    doc: Factor to average with in time after the subtract has been performed. Defaults to 1 (no averaging).
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
    type: File
    outputSource:
      - makemslist/mslist
    doc: Text file containing the name of the input MS from which the LoTSS skymodel hase been subtracted.
  - id: msout
    type: Directory
    outputSource:
      - subtract/subms
    doc: MS from which the LoTSS skymodel has been subtracted.

steps:
  - id: makebox
    in:
      - id: ms
        source: ms
      - id: box_size
        source: box_size
    out:
      - id: box
    run: ../steps/makebox.cwl
    label: Make the box outside which subtraction will happen.

  - id: makemslist
    in:
      - id: ms
        source: ms
      - id: force
        source: force_mslist
    out:
      - id: mslist
    run: ../steps/make_mslist.cwl
    label: Make the list of MSes to subtract.

  - id: gather_dds3
    in:
      - id: ddfdir
        source: ddfdir
    out:
      - id: dds3sols
      - id: fitsfiles
      - id: dicomodels
      - id: facet_layout
    run: ../steps/gatherdds3.cwl
    label: Gather the solutions and imaged required to subtract.

  - id: subtract
    in:
      - id: ms
        source: ms
      - id: boxfile
        source: makebox/box
      - id: mslist
        source: makemslist/mslist
      - id: column
        source: delaycalcol
      - id: solsdir
        source: solsdir
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
    out:
      - id: subms
    run: ../steps/subtract.cwl
    label: Subtract the LoTSS model from the data.

requirements:
  - class: SubworkflowFeatureRequirement
