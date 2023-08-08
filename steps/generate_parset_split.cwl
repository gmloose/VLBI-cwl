cwlVersion: v1.2
class: CommandLineTool
id: generate_parset_split_directions
label: Generate DP3 parset for split directions
doc: |
    Generates a DP3 parameterset to split off
    directions from a given MeasurementSet.

baseCommand: [cat, input.parset]

stdout: dp3_explode.parset

inputs:
    - id: msout_names
      type: string
      doc: |
        A string of names, one for each direction to image.

    - id: phase_centers
      type: string
      doc: |
        A string of pairs of right ascension and declination
        coordinates, one for each direction to image.

    - id: frequency_resolution
      type: string?
      default: '390.56kHz'
      doc: |
        Frequency resolution for the third averaging.

    - id: time_resolution
      type: string?
      default: '32.'
      doc: |
        Time resolution in seconds for the third averaging.

outputs:
  - id: parset
    type: File
    doc: A DP3 parameterset file.
    outputBinding:
      glob: dp3_explode.parset

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: input.parset
        entry: |+
            steps                       = [split]

            split.replaceparms          = [phaseshift.phasecenter, applybeam.direction, msout.name]
            split.steps                 = [phaseshift, averager1, applybeam, averager2, applycal, averager3, msout]

            phaseshift.type             = phaseshift
            phaseshift.phasecenter      = $(inputs.phase_centers)

            averager1.type              = averager
            averager1.freqresolution    = 48.82kHz
            averager1.timeresolution    = 4.

            applybeam.type              = applybeam
            applybeam.direction         = $(inputs.phase_centers)
            applybeam.beammode          = full

            averager2.type              = averager
            averager2.freqresolution    = 390.56kHz
            averager2.timeresolution    = 32
            
            # Apply solutions and more average_target

            applycal.type               = applycal
            applycal.correction         = fulljones
            applycal.soltab             = [amplitude000, phase000]

            averager3.type              = averager
            averager3.freqresolution    = $(inputs.frequency_resolution)
            averager3.timeresolution    = $(inputs.time_resolution)

            msout.storagemanager        = dysco
            msout.name                  = $(inputs.msout_names)
            msout.overwrite             = True
