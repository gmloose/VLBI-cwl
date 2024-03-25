#!/usr/bin/env bash
DDFDIR=$1
SOLSDIR=$2
for folder in ${SOLSDIR}/L*MHz_uv_pre-cal.ms; do
    echo "Checking symlinks in $folder"
    cd $folder
    for solution in *.npz; do
        if [[ -L $solution ]]; then
            echo "Fixing symlink for ${solution}"
            solname=$(basename $(readlink $solution))
            unlink $solution
            cp ${DDFDIR}/${solname} $solution
        fi
    done
done
