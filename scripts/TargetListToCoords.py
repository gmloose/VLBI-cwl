from astropy.table import Table

def plugin_main(**kwargs):
    """
    Takes in a catalogue with a target and returns appropriate coordinates

    Parameters
    ----------
    filename: str
        Name of output mapfile
    target_file: str
        file containing target info

    Returns
    -------
    result : dict
        Output coordinates
    """

    # parse the input
    target_file = kwargs['target_file']
    mode = kwargs['mode']

    # read in the catalogue to get source_id, RA, and DEC
    t = Table.read(target_file, format='csv')
    RA_val = t['RA'].data
    DEC_val = t['DEC'].data
    Source_id = t['Source_id'].data
    if mode: # == 'single':
        RA_val = [RA_val[0]]
        DEC_val = [DEC_val[0]]
        Source_id = Source_id[:1]
        if str(Source_id[0])[0:1] == 'I':
            pass
        elif str(Source_id[0])[0:1] == 'S':
            pass
        else:
            Source_id = ['S' + str(x) for x in Source_id[0]]

    # make a string of coordinates for the NDPPP command
    ss = [ '[' + str(x) + 'deg,' + str(y) + 'deg]' for x, y in zip(RA_val, DEC_val) ]

    result = {'name' : ",".join(Source_id),
              'coords' : ss[0] if len(ss) == 1 else "[" + ",".join(ss) + "]"}

    return result
