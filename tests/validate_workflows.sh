#!/bin/sh

# VLBI_ROOT_DIR is defined in .gitlab-ci.yml

errors=0
for workflow in "$VLBI_ROOT_DIR/workflows"/*.cwl; do
    cwltool --validate $workflow || errors=$(($errors+1))
done

[ $errors -gt 0 ] && echo "Failed validation count = $errors"

[ $errors -eq 0 ] # exit status
