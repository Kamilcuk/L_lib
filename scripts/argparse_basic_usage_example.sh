#!/bin/bash
# Source the L_lib library. The -s flag makes it silent.
. ../bin/L_lib.sh -s

L_argparse \
  prog="MyProgram" \
  description="This is a sample program demonstrating L_argparse." \
  epilog="Thank you for using MyProgram!" \
  -- filename help="The name of the file to process." \
  -- -c --count help="Count the occurrences of something. Increments with each use." action=count \
  -- -v --verbose help="Enable verbose output." action=store_true \
  -- -o --output help="Specify an output file." dest=output_file \
  ---- "$@"

# Access the parsed variables directly
echo "Filename: $filename"
echo "Count: $count"
echo "Verbose: $verbose"
echo "Output File: $output_file"

# Example of how you might use the variables
if [[ "$verbose" == "true" ]]; then
  echo "Verbose mode is enabled."
fi

for ((i=0; i<count; i++)); do
  echo "Counting... $((i+1))"
done

if [[ -n "$output_file" ]]; then
  echo "Results will be written to $output_file"
fi
