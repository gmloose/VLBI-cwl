#!/bin/sh

TEST1=$(mktemp prefix_affix_test_XXX)
TEST2=$(mktemp prefix_test_XXX)

OUTDIR=$(mktemp -d)

CWLFILE=$(mktemp)
cat <<- EOF > ${CWLFILE}
cwlVersion: v1.2
class: CommandLineTool
baseCommand: echo
arguments: ["globbing test"]

inputs:
  files:
    type: File[]

outputs:
  output:
    type: File
    outputBinding:
      glob: ["*", "*_affix*"]
      outputEval: |
        \$(self[self.length - 1])

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entry: \$(inputs.files)
        writable: true
EOF

GREEN='\033[32m'
RED='\e[31m'
CLEAR='\033[0m'

cwltool --outdir $OUTDIR $CWLFILE --files $TEST1 --files $TEST2 > /dev/null 2>&1
printf "Glob\t\t"
if [ -f $OUTDIR/$(basename $TEST1) ]; then
  printf "${GREEN}passed${CLEAR}\n"
else
  printf "${RED}failed${CLEAR}\n"
fi
rm -rf $OUTDIR
