#!/bin/bash -eu
#
# Script to generate input YAML file for the VLBI pipeline.
#

H5DIR=${2}/lofar_helpers
SELFCALDIR=${2}/lofar_facet_selfcal
SELFCALCONFIG=${INSTALL_DIR}/vlbi/facetselfcal_config.txt

usage() {
    cat <<-EOF
	Usage: ${0} generate_input.sh <data directory> <pipeline directory>
	
		where <data directory> is a directory containing
		
		* all MeasurementSets for a given observation
		* LINC calibrator and target solutions for this observation
		* a catalogue containing a suitable delay calibrator
		
		<pipeline directory> is the directory assumed to contain
		
		* VLBI pipeline
		* lofar_helpers
		* lofar_facet_selfcal
EOF
error
}

error()
{
    echo "$@" >&2
    exit 1
}

# Check input arguments
[[ $# -eq 2 ]] || usage
DIR=$(realpath -s ${1})
[[ -d ${DIR} ]] || error "Directory '${DIR}' does not exist"
YAML="$(pwd)/input.yaml"

# Check if skymodels exist
[[ -d ${H5DIR} ]] \
    || error "H5merger directory '${H5DIR}' does not exist"
[[ -d ${SELFCALDIR} ]] \
    || error "Facet selfcal directory '${SELFCALDIR}' does not exist"
[[ -f ${SELFCALCONFIG} ]] \
    || error "Facet selfcal configfile '${SELFCALCONFIG}' not found"

# Fetch list of MS files, determine length and index of last element
declare MSs=($(ls -1d ${DIR}/*.MS 2> /dev/null))
len=${#MSs[@]}
last=$(expr ${len} - 1)
[[ ${len} -gt 0 ]] || error "Directory '${DIR}' contains no MS-files."
SOLSET=$(ls ${DIR}/*.h5 2> /dev/null)
[[ -f ${SOLSET} ]] || error "Directory '${DIR}' contains no solset."
CATALOGUE=$(ls ${DIR}/*.csv 2> /dev/null)
[[ -f ${CATALOGUE} ]] || error "No delay calibrator catalogue found in '${DIR}'."

# Open output file
exec 3> ${YAML}

# Write file contents
cat >&3 <<-EOF
	msin:
	$(for((i=0; i<${len}; i++))
	  do
	    echo "    - class: \"Directory\""
	    echo "      path : \"${MSs[$i]}\""
	  done
	)
	solset:
	    class: "File"
	    path: "${SOLSET}"
	h5merger: 
	    class: "Directory"
	    path: "${H5DIR}"
	selfcal:
	    class: "Directory"
	    path: "${SELFCALDIR}"
	configfile:
	    class: "File"
	    path: "${SELFCALCONFIG}"
	delay_calibrator:
	    class: "File"
	    path: "${CATALOGUE}"
EOF

# Close output file
exec 3>&-

echo "Wrote output to '${YAML}'"