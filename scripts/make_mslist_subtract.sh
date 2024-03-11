#!/usr/bin/env bash
for f in *pre-cal.ms; do
    echo Adding $f to the subtract list
    echo $f >> big-mslist.txt
done
