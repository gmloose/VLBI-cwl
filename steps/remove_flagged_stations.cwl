cwlVersion: v1.2
class: CommandLineTool
id: remove_flagged_stations
label: Remove fully flagged stations
doc: Remove stations in MeasurementSet that are fully flagged to help safe data volume and compute time.

baseCommand:
  - python3

inputs:
    - id: ms
      type: Directory
      doc: MeasurementSet
      inputBinding:
        position: 3
    - id: lofar_helpers
      type: Directory
      doc: LOFAR helpers directory.

outputs:
    - id: cleaned_ms
      type: Directory
      doc: MeasurementSet where fully flagged stations are removed.
      outputBinding:
        glob: $( 'flagged_' + inputs.ms.basename )
    - id: logfile
      type: File[]
      doc: Log files from current step.
      outputBinding:
        glob: remove_flagged_stations*.log

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.ms)
        writable: false

arguments:
  - $( inputs.lofar_helpers.path + '/ms_helpers/remove_flagged_stations.py' )
  - --msout
  - $( 'flagged_' + inputs.ms.basename )

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl
  - class: ResourceRequirement
    coresMin: 2

stdout: remove_flagged_stations.log
stderr: remove_flagged_stations_err.log