class: CommandLineTool
cwlVersion: v1.2
id: findRefAnt_join
label: Find Reference Antenna join
doc: |
    Selects station data from a dictionary, determines
    and outputs the fraction of flagged data and the
    station name with the least amount of flagged data.

baseCommand:
  - python3
  - findRefAnt_join.py

inputs:
    - id: flagged_fraction_dict
      type: string[]?
      default: []
      doc: A list of flagged antennas per MeasurementSet.

    - id: filter_station
      type: string?
      default: '*&'
      doc: A regular expression pattern for station names to select.

    - id: state
      type: string?
      default: 'NONE'
      doc: State information for the collection of antenna statistics.

outputs:
  - id: refant
    type: string
    outputBinding:
        loadContents: true
        glob: out.json
        outputEval: $(JSON.parse(self[0].contents).refant)
    doc: |
        The reference antenna, containing
        the least amount of flagged data.

  - id: flagged_fraction_antenna
    type: File
    outputBinding:
      glob: flagged_fraction_antenna.json
    doc: |
        The fraction of flagged data per
        antenna in a CSV format.

  - id: logfile
    type: File
    outputBinding:
      glob: findRefAnt.log
    doc: |
        The files containing the stdout
        and stderr from the step.

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: input.json
        entry: $(inputs.flagged_fraction_dict)
      - entryname: findRefAnt_join.py
        entry: |
            import sys
            import json
            import re
            import ast

            inputs = json.loads(r"""$(inputs)""")
            with open('input.json', 'r') as f_stream:
                flagged_fraction_dict_list = json.load(f_stream)
            filter_station = inputs['filter_station']
            no_station_selected = True

            while no_station_selected:
                print('Applying station filter ' + str(filter_station))
                flagged_fraction_data = {}
                no_station_selected = False
                for flagged_fraction_dict in flagged_fraction_dict_list:
                    entry = ast.literal_eval(flagged_fraction_dict)
                    antennas = entry.keys()
                    selected_stations = [ station_name for station_name in antennas if re.match(filter_station, station_name) ]
                    if len(selected_stations) == 0:
                        print('No stations left after filtering. Station(s) do(es) not exist in all subbands. No filter is used.')
                        filter_station = ''
                        no_station_selected = True
                        break
                    for antenna in selected_stations:
                        try:
                            flagged_fraction_data[antenna].append(float(entry[antenna]))
                        except KeyError:
                            flagged_fraction_data[antenna] = [float(entry[antenna])]

            flagged_fraction_list = []
            sorted_stations = sorted(flagged_fraction_data.keys())

            flagged_fraction_antenna = {}

            for antenna in sorted_stations:
                flagged_fraction = sum(flagged_fraction_data[antenna]) / len(flagged_fraction_data[antenna])
                flagged_fraction_list.append(flagged_fraction)
                flagged_fraction_antenna[antenna] = flagged_fraction
                try:
                    flagged_fraction_data[flagged_fraction].append(antenna)
                except KeyError:
                    flagged_fraction_data[flagged_fraction] = [antenna]

            min_flagged_fraction = min(flagged_fraction_list)
            refant = flagged_fraction_data[min_flagged_fraction][0]
            print('Selected station ' + str(refant) + ' as reference antenna. Fraction of flagged data is ' + '{:>3}'.format('{:.1f}'.format(100 * min_flagged_fraction) + '%'))

            flagged_fraction_antenna['state'] = inputs['state']

            cwl_output = {'refant': str(refant)}

            with open('./out.json', 'w') as fp:
                json.dump(cwl_output, fp)

            with open('./flagged_fraction_antenna.json', 'w') as fp:
                json.dump(flagged_fraction_antenna, fp)

stdout: findRefAnt.log
stderr: findRefAnt_err.log
