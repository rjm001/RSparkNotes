#!/bin/bash
cat "SparkNotes.md" | sed -n -e '/^```r$/,/^```$/{ /^```r$/d; /^```$/d; p; }' > RSparkCode.R
# Looks for start line and end line, then extracts everything between and deletes start and endline. Prints them all out.
# to empty file, use `echo "" | > RSparkCode.R
# to execute, run bash ./ExtractMDcode.sh in shell