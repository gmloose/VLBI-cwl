#!/bin/sh

# VLBI_ROOT_DIR is defined in pyproject.toml

errors=0
for workflow in $(find "$VLBI_ROOT_DIR" -name "*.cwl"); do
    cwltool --validate $workflow || errors=$(($errors+1))
done

[ $errors -gt 0 ] && echo "Failed validation count = $errors"

[ $errors -eq 0 ] # exit status
